#!/usr/bin/env python3
"""The telemetry dispatcher — one place every event passes through, sink-agnostic.

The taxonomy lives in `telemetry/TRACKING-PLAN.md`; this is the wire that carries an
event to a sink. It appends one JSON line per event to a LOCAL ledger and, by design,
nothing leaves the machine in this release. It must **never break real work**: any
failure degrades to a one-line warning on stderr and a clean exit — a dropped event is
always cheaper than a broken command.

    python3 scripts/telemetry.py log command_invoked --prop command=status --prop mode=auto
    python3 scripts/telemetry.py log tool_invoked --prop tool=resume --prop args_class=revive

Other scripts self-log by importing this module instead of shelling out:

    import telemetry
    telemetry.log("tool_invoked", tool="verify", args_class="live")

Ledger path resolution order (first that applies wins):
  1. $MOPS_TELEMETRY_DIR — an explicit directory. The value `off` (also 0/false/none/
     disabled) is the OFF SWITCH: telemetry does nothing and exits 0.
  2. <repo>/company/telemetry/  — when a company/ dir exists (gitignored by our
     convention, so tier-1 data is never committed).
  3. ~/.multica-ops/telemetry/ — the fallback for a checkout with no company/.
The ledger file is `events.jsonl` inside that directory; parents are created as needed.

Sinks are read from `telemetry/sinks.json` (or env):
  · jsonl   — always on; the local ledger above.
  · posthog — a RECOGNIZED but DARK slot. The schema names it; the wire is cut. Even
              configured with a key it forwards nothing — it prints a notice and makes
              no HTTP call — until the owner turns it on deliberately. No secrets in repo.

Every event carries ts · skill_version · session_id. session_id is random per session
(or $MOPS_SESSION_ID), never a hostname, username or path — nothing user-identifiable.

Stdlib only — runs anywhere Python does.
"""
import datetime
import json
import os
import sys
import uuid
from pathlib import Path

_OFF = {"off", "0", "false", "no", "none", "disabled", "disable"}
_TRUE = {"true", "yes", "on"}
_FALSE = {"false", "no", "off"}


def _repo_root():
    # scripts/telemetry.py → repo root is two levels up, resolved from the file itself so
    # it holds regardless of the caller's cwd (scripts cd around).
    return Path(__file__).resolve().parent.parent


def resolve_ledger_dir():
    """The directory the ledger lives in, or None when telemetry is switched off."""
    env = os.environ.get("MOPS_TELEMETRY_DIR")
    if env is not None and env.strip():
        if env.strip().lower() in _OFF:
            return None
        return Path(env).expanduser()
    company = _repo_root() / "company"
    if company.is_dir():
        return company / "telemetry"
    return Path.home() / ".multica-ops" / "telemetry"


def resolve_ledger():
    """Absolute path to events.jsonl, or None when disabled. Shared with the reporter."""
    d = resolve_ledger_dir()
    return None if d is None else d / "events.jsonl"


def _skill_version():
    v = os.environ.get("MOPS_SKILL_VERSION")
    if v:
        return v
    try:
        for line in (_repo_root() / "SKILL.md").read_text(encoding="utf-8").splitlines():
            if line.startswith("version:"):
                return line.split(":", 1)[1].strip()
    except OSError:
        pass
    return "unknown"


_SESSION_ID = None


def _session_id():
    global _SESSION_ID
    if _SESSION_ID is None:
        # A per-session random id lets events be grouped without ever recording who or
        # where. Mops can share one across a chat via $MOPS_SESSION_ID; a lone script run
        # gets its own ephemeral id.
        _SESSION_ID = os.environ.get("MOPS_SESSION_ID") or uuid.uuid4().hex[:16]
    return _SESSION_ID


def _load_sinks():
    """Sink config: jsonl always on; posthog present-but-dark. Env can force posthog on
    the schema (still dark). A malformed file never breaks logging — it degrades to
    jsonl-only."""
    cfg = {"jsonl": {"enabled": True}, "posthog": {"enabled": False, "api_key": None}}
    path = _repo_root() / "telemetry" / "sinks.json"
    try:
        loaded = json.loads(path.read_text(encoding="utf-8"))
        for name, sub in (loaded.get("sinks") or loaded).items():
            if isinstance(sub, dict):
                cfg.setdefault(name, {}).update(sub)
    except (OSError, ValueError, AttributeError):
        pass
    if os.environ.get("MOPS_POSTHOG_API_KEY"):
        cfg["posthog"]["api_key"] = os.environ["MOPS_POSTHOG_API_KEY"]
    return cfg


def _emit_jsonl(ledger, record):
    ledger.parent.mkdir(parents=True, exist_ok=True)
    with open(ledger, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, ensure_ascii=False) + "\n")


def _emit_posthog(conf, record):
    """The dark slot. Configured-with-a-key would forward in a future release; today the
    wire is cut — a notice, and NO network call ships in this code."""
    if conf.get("api_key") or conf.get("enabled"):
        sys.stderr.write(
            "telemetry: posthog sink configured but disabled until enabled by the owner "
            "(local-only in this release; no event was transmitted)\n"
        )
    # deliberately no HTTP — the slot exists, the wire does not.


def log(event, **props):
    """Append one event to every enabled sink. Never raises: a telemetry failure must not
    become the caller's failure."""
    try:
        if not event:
            return 0
        ledger = resolve_ledger()
        if ledger is None:
            return 0  # off switch — do nothing, quietly
        record = {"event": str(event)}
        record.update({k: v for k, v in props.items() if v is not None})
        record["ts"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        record["skill_version"] = _skill_version()
        record["session_id"] = _session_id()
        sinks = _load_sinks()
        if sinks.get("jsonl", {}).get("enabled", True):
            _emit_jsonl(ledger, record)
        if "posthog" in sinks:
            _emit_posthog(sinks["posthog"], record)
        return 0
    except Exception as e:  # any error at all → warn, never break the caller
        sys.stderr.write(f"telemetry: dropped {event!r} ({e})\n")
        return 0


def _coerce(v):
    """CLI props arrive as strings; recover the obvious types so dashboards aggregate
    cleanly (converted=true → bool, round=2 → int). 'unknown' stays a string."""
    low = v.lower()
    if low in _TRUE:
        return True
    if low in _FALSE:
        return False
    if v.lstrip("-").isdigit():
        return int(v)
    return v


def _cli(argv):
    # Hand-rolled parse so a malformed invocation still exits 0 (argparse would exit 2 and
    # trip a caller that forgot `|| true`).
    if len(argv) < 2 or argv[0] != "log":
        sys.stderr.write("telemetry: usage: telemetry.py log <event> [--prop k=v ...]\n")
        return 0
    event = argv[1]
    props, i = {}, 2
    while i < len(argv):
        if argv[i] == "--prop" and i + 1 < len(argv) and "=" in argv[i + 1]:
            k, val = argv[i + 1].split("=", 1)
            props[k] = _coerce(val)
            i += 2
        else:
            i += 1  # tolerate stray tokens rather than erroring
    return log(event, **props)


if __name__ == "__main__":
    try:
        sys.exit(_cli(sys.argv[1:]))
    except Exception:
        sys.exit(0)  # telemetry never fails the caller, full stop
