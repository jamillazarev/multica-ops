#!/usr/bin/env python3
"""Paginated, corruption-tolerant issue listing for Multica.

Survives the two CLI traps: pages cap at 100 (needs --offset pagination) and raw
control characters in descriptions break json.loads (sanitized here).

Usage:
  python3 issues.py                # all projects in the workspace
  python3 issues.py <project-id>   # one project
  MULTICA_PROJECT_FILTER=<substr> python3 issues.py   # projects whose title contains substr

Prints TSV: id, status, assignee_id, assignee_type, parent_issue_id, title, updated_at.

`updated_at` is *last touched*, not *waiting since*: the platform stores no
status-change timestamp, so renaming a blocked issue resets its age. It is the best
signal available and status.sh labels it as an age, not as a promise.
"""
import json
import os
import re
import subprocess
import sys


def _clean(s: str) -> str:
    return re.sub(r"[\x00-\x1f]", " ", s)


def _run(args):
    return subprocess.run(["multica", *args], capture_output=True, text=True).stdout


def _run_full(args):
    """stdout, returncode, stderr — for callers that must fail on a non-zero exit
    rather than parse an error message as data."""
    p = subprocess.run(["multica", *args], capture_output=True, text=True)
    return p.stdout, p.returncode, p.stderr


def _die(msg):
    """One clean line to stderr, non-zero exit — never a raw traceback (BOOTSTRAP §8:
    a bad id or a dead daemon must read as an error, not a Python stacktrace)."""
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(2)


def _first_line(*text):
    for t in text:
        t = (t or "").strip()
        if t:
            return t.splitlines()[0]
    return "no output"


def _loads(raw):
    """Parse CLI JSON defensively (BOOTSTRAP §8): strip control characters, and if a
    human line precedes the JSON, retry from the first `[`/`{`. Returns {} on failure —
    a missing parse must never masquerade as data."""
    s = _clean(raw or "")
    try:
        return json.loads(s)
    except Exception:
        pass
    for i, ch in enumerate(s):
        if ch in "[{":
            try:
                return json.loads(s[i:])
            except Exception:
                return {}
    return {}


def latest_run(issue_id: str) -> dict:
    """The issue's most recent execution, or {} when it has none. `issue runs` may
    return a bare list or a {"runs":[…]} wrapper (BOOTSTRAP §8); order is not
    guaranteed, so sort by a timestamp field when present, else take the last row."""
    d = _loads(_run(["issue", "runs", issue_id, "--output", "json"]))
    runs = d if isinstance(d, list) else (d.get("runs") or d.get("executions") or [])
    rows = [r for r in runs if isinstance(r, dict)] if isinstance(runs, list) else []
    if not rows:
        return {}

    def when(r):
        for k in ("created_at", "started_at", "createdAt", "startedAt", "inserted_at"):
            if r.get(k):
                return str(r[k])
        return ""

    return max(rows, key=when) if any(when(r) for r in rows) else rows[-1]


def is_agent_error(run: dict) -> bool:
    """True when a run failed for `agent_error` (tool error, quota, or session limit —
    REFERENCE §7). The reason may sit in `status`, `error`, `reason` or `failure_reason`
    depending on the CLI build, so search them all rather than assume one field."""
    if not run:
        return False
    if (run.get("status") or "").lower() in ("completed", "running", "queued", "dispatched", "cancelled"):
        return False
    blob = " ".join(
        str(run.get(k) or "")
        for k in ("status", "error", "error_type", "reason", "failure_reason", "errorReason", "result")
    ).lower()
    return "agent_error" in blob


def project_ids() -> list:
    out, rc, err = _run_full(["project", "list", "--output", "json"])
    if rc != 0:
        _die(f"`multica project list` failed (exit {rc}): {_first_line(err, out)}")
    d = _loads(out)
    projs = d if isinstance(d, list) else (d.get("projects", []) if isinstance(d, dict) else [])
    if not isinstance(projs, list):
        _die("`multica project list` returned unexpected JSON (no project array)")
    filt = os.environ.get("MULTICA_PROJECT_FILTER", "")
    ids = [p["id"] for p in projs if isinstance(p, dict) and "id" in p and filt in (p.get("title") or "")]
    if not ids:
        sys.exit("no projects matched")
    return ids


def all_issues(pid: str) -> list:
    out, off = [], 0
    while True:
        raw, rc, err = _run_full(
            ["issue", "list", "--project", pid, "--output", "json",
             "--limit", "100", "--offset", str(off)])
        if rc != 0:
            _die(f"`multica issue list --project {pid}` failed (exit {rc}): {_first_line(err, raw)}")
        d = _loads(raw)
        # A bare array or a {"issues":[…]} wrapper are both valid (BOOTSTRAP §8).
        batch = d if isinstance(d, list) else (d.get("issues", []) if isinstance(d, dict) else None)
        if batch is None:
            _die(f"`multica issue list --project {pid}` returned unexpected JSON (neither array nor object)")
        if not isinstance(batch, list):
            batch = []
        out += batch
        has_more = isinstance(d, dict) and d.get("has_more")
        if not has_more or not batch:
            break
        off += len(batch)
    return out


if __name__ == "__main__":
    pids = [sys.argv[1]] if len(sys.argv) > 1 else project_ids()
    for pid in pids:
        for i in all_issues(pid):
            print("\t".join([
                i["id"],
                i.get("status") or "",
                i.get("assignee_id") or "",
                i.get("assignee_type") or "",
                i.get("parent_issue_id") or "",
                (i.get("title") or "").replace("\t", " "),
                i.get("updated_at") or "",
            ]))
