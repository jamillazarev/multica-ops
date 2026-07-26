#!/usr/bin/env python3
"""Aggregate the telemetry ledger into a generated Markdown dashboard.

The ledger (`events.jsonl`, see telemetry.py) is the source of truth; this is the viewing
layer, regenerated on demand. It writes the dashboard **next to the ledger** — into the
same LOCAL, gitignored directory the events live in — never into the public repo's tracked
files. Idempotent: every run overwrites the previous dashboard.

    python3 scripts/telemetry-report.py                 # dashboard next to the ledger
    python3 scripts/telemetry-report.py --since 2026-07-01
    python3 scripts/telemetry-report.py --out /tmp/dash.md   # override the destination

Dashboards produced (tables + mermaid where a shape helps):
  · Commands — count and last-used (the console's own usage).
  · Companion loads — the 2.6 family-split evidence board.
  · Tools — usage count and last-used, the feed for the future toolbox-GC.
  · Conveyor health — rounds per release and verdict mix.
  · Consult funnel — sessions → conversions, by addressee class.
  · Economy nudges & source challenges — smaller signal tables.
  · Activity trend — events per day.

Stdlib only.
"""
import argparse
import datetime
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import telemetry  # noqa: E402  (shares ledger-path resolution with the dispatcher)


def _load(ledger, since):
    """Every well-formed event at/after `since`. Malformed lines are skipped, never fatal —
    a corrupt tail must not blank the whole dashboard."""
    rows = []
    try:
        text = Path(ledger).read_text(encoding="utf-8")
    except OSError:
        return rows
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            rec = json.loads(line)
        except ValueError:
            continue
        if since and (rec.get("ts") or "")[:10] < since:
            continue
        rows.append(rec)
    return rows


def _day(rec):
    return (rec.get("ts") or "")[:10] or "—"


def _table(header, rows):
    if not rows:
        return "_No data yet._\n"
    out = ["| " + " | ".join(header) + " |",
           "|" + "|".join("---" for _ in header) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c) for c in r) + " |")
    return "\n".join(out) + "\n"


def _pie(title, counter, limit=8):
    items = counter.most_common(limit)
    if not items:
        return ""
    lines = ["```mermaid", "pie showData", f'    title {title}']
    for k, v in items:
        lines.append(f'    "{k}" : {v}')
    lines.append("```")
    return "\n".join(lines) + "\n"


def _bar(title, labels, values, ylabel="count"):
    if not labels:
        return ""
    xs = "[" + ", ".join(f'"{l}"' for l in labels) + "]"
    ys = "[" + ", ".join(str(v) for v in values) + "]"
    return ("```mermaid\n"
            "xychart-beta\n"
            f'    title "{title}"\n'
            f"    x-axis {xs}\n"
            f'    y-axis "{ylabel}"\n'
            f"    bar {ys}\n"
            "```\n")


def _count_and_last(rows, key):
    """count per value of `key`, plus the last day it was seen — the GC/last-used shape."""
    count, last = Counter(), {}
    for r in rows:
        v = r.get(key)
        if v is None:
            continue
        count[v] += 1
        d = _day(r)
        if v not in last or d > last[v]:
            last[v] = d
    return count, last


def _section_commands(rows):
    ev = [r for r in rows if r.get("event") == "command_invoked"]
    count, last = _count_and_last(ev, "command")
    body = ["## Commands\n"]
    table = [(c, n, last.get(c, "—")) for c, n in count.most_common()]
    body.append(_table(["command", "count", "last used"], table))
    if table:
        top = count.most_common(12)
        body.append("\n" + _bar("Commands by count", [k for k, _ in top], [v for _, v in top]))
    return "\n".join(body)


def _section_companions(rows):
    ev = [r for r in rows if r.get("event") == "companion_loaded"]
    count, last = _count_and_last(ev, "file")
    body = ["## Companion loads — the 2.6 family-split evidence\n",
            "Which companion files a session actually pulls, and how often — the usage "
            "record behind any decision to split the family.\n"]
    table = [(f, n, last.get(f, "—")) for f, n in count.most_common()]
    body.append(_table(["companion", "loads", "last"], table))
    body.append("\n" + _pie("Companion loads", count))
    return "\n".join(body)


def _section_tools(rows):
    ev = [r for r in rows if r.get("event") == "tool_invoked"]
    count, last = _count_and_last(ev, "tool")
    body = ["## Tools — usage & last-used (toolbox-GC feed)\n",
            "A tool nobody runs is a candidate for retirement; a stale last-used date is "
            "the signal.\n"]
    table = [(t, n, last.get(t, "—")) for t, n in count.most_common()]
    body.append(_table(["tool", "runs", "last used"], table))
    return "\n".join(body)


def _section_conveyor(rows):
    ev = [r for r in rows if r.get("event") == "conveyor_advanced"]
    body = ["## Conveyor health\n"]
    if not ev:
        body.append("_No conveyor events yet._\n")
        return "\n".join(body)
    rounds = defaultdict(int)
    stages = defaultdict(set)
    for r in ev:
        rel = r.get("release", "—")
        try:
            rounds[rel] = max(rounds[rel], int(r.get("round") or 0))
        except (TypeError, ValueError):
            pass
        stages[rel].add(r.get("stage", "—"))
    table = [(rel, rounds[rel], ", ".join(sorted(stages[rel]))) for rel in sorted(stages)]
    body.append(_table(["release", "max round", "stages seen"], table))
    verdicts = Counter(r.get("verdict") for r in ev if r.get("verdict"))
    if verdicts:
        body.append("\n" + _pie("Verdicts", verdicts))
    return "\n".join(body)


def _section_consult(rows):
    ev = [r for r in rows if r.get("event") == "consult_ended"]
    body = ["## Consult funnel — sessions → conversions\n"]
    if not ev:
        body.append("_No consult events yet._\n")
        return "\n".join(body)
    by = defaultdict(lambda: {"sessions": 0, "converted": 0, "ephemeral": 0})
    for r in ev:
        k = r.get("addressee_class", "—")
        by[k]["sessions"] += 1
        by[k]["converted"] += 1 if r.get("converted") is True else 0
        by[k]["ephemeral"] += 1 if r.get("ephemeral_validation") is True else 0
    table = []
    for k in sorted(by):
        s = by[k]
        pct = f"{100 * s['converted'] // s['sessions']}%" if s["sessions"] else "—"
        table.append((k, s["sessions"], s["converted"], pct, s["ephemeral"]))
    body.append(_table(["addressee", "sessions", "converted", "conv. rate", "ephemeral val."], table))
    return "\n".join(body)


def _section_signals(rows):
    body = ["## Economy nudges & source challenges\n"]
    nud = [r for r in rows if r.get("event") == "economy_nudged"]
    if nud:
        by = defaultdict(lambda: {"n": 0, "heeded": 0})
        for r in nud:
            k = r.get("kind", "—")
            by[k]["n"] += 1
            by[k]["heeded"] += 1 if r.get("heeded") is True else 0
        table = [(k, by[k]["n"], by[k]["heeded"]) for k in sorted(by)]
        body.append("**Economy nudges**\n\n" + _table(["kind", "shown", "heeded"], table))
    else:
        body.append("_No economy-nudge events yet._\n")
    body.append("")
    ch = [r for r in rows if r.get("event") == "source_challenged"]
    if ch:
        c = Counter(r.get("answered_from", "—") for r in ch)
        body.append("**Source challenges**\n\n"
                     + _table(["answered from", "count"], c.most_common()))
    else:
        body.append("_No source-challenge events yet._\n")
    return "\n".join(body)


def _section_trend(rows):
    body = ["## Activity trend — events per day\n"]
    if not rows:
        body.append("_No events yet._\n")
        return "\n".join(body)
    per_day = Counter(_day(r) for r in rows)
    days = sorted(per_day)
    body.append(_table(["day", "events"], [(d, per_day[d]) for d in days]))
    tail = days[-14:]
    body.append("\n" + _bar("Events per day", tail, [per_day[d] for d in tail], "events"))
    return "\n".join(body)


def build(rows, ledger, since):
    now = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")
    head = [
        "# Telemetry dashboard",
        "",
        "> Generated file — do not edit by hand; regenerate with "
        "`python3 scripts/telemetry-report.py`.",
        "",
        f"- generated: {now}",
        f"- events: {len(rows)}" + (f" (since {since})" if since else ""),
        f"- ledger: `{ledger}`",
        "",
    ]
    parts = [
        _section_commands(rows),
        _section_companions(rows),
        _section_tools(rows),
        _section_conveyor(rows),
        _section_consult(rows),
        _section_signals(rows),
        _section_trend(rows),
    ]
    return "\n".join(head) + "\n---\n\n" + "\n\n---\n\n".join(parts) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--since", metavar="YYYY-MM-DD", help="only events on/after this date")
    ap.add_argument("--out", metavar="PATH", help="destination (default: next to the ledger)")
    a = ap.parse_args()

    ledger = telemetry.resolve_ledger()
    if ledger is None:
        sys.exit("telemetry is switched off ($MOPS_TELEMETRY_DIR=off) — nothing to report")
    rows = _load(ledger, a.since)
    out = Path(a.out) if a.out else Path(ledger).parent / "DASHBOARD.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(build(rows, ledger, a.since), encoding="utf-8")
    print(f"wrote {out} — {len(rows)} event(s)")


if __name__ == "__main__":
    main()
