#!/usr/bin/env bash
# "Everyone continue" in one command.
#
# Reruns work that a run left mid-flight OR that a failed run rolled back:
#   • ASSIGNED, INTERRUPTED tasks (in_progress/in_review) — agents resume from the
#     repository state, hence the team rule to commit incrementally.
#   • todo issues whose LATEST run failed with agent_error — a failed task rolls its
#     issue back in_progress → todo (REFERENCE §7), so those need a rerun too. Task
#     history (`issue runs`) tells them apart from untouched backlog, which is NEVER
#     touched: an untouched todo/backlog issue has no failed run and waits on its
#     --stage barrier.
#
# cancelled: an intentional cancel always carries a "Cancel reason:" comment;
# --revive-cancelled revives ONLY marker-less ones (accidental), then reruns.
#
# --dry-run: report what WOULD be reran/revived without calling the platform. Safe
# offline (no live workspace needed) — for sanity-checking the selection logic.
#
# Usage: bash resume.sh [--revive-cancelled] [--dry-run] [--project <id>]
set -euo pipefail
cd "$(dirname "$0")"

REVIVE=0
DRY=0
PROJECT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --revive-cancelled) REVIVE=1 ;;
    --dry-run) DRY=1 ;;
    --project) shift; PROJECT="${1:-}" ;;
  esac
  shift
done

# self-log this run; telemetry must never break resume (cwd is scripts/)
_ac="default"; [ "$REVIVE" = 1 ] && _ac="revive"; [ "$DRY" = 1 ] && _ac="dry_run"
python3 telemetry.py log tool_invoked --prop tool=resume --prop args_class="$_ac" 2>/dev/null || true

if [ "$REVIVE" = 1 ]; then
  PROJECT="$PROJECT" DRY="$DRY" python3 - <<'PY'
import json, os, re, subprocess, sys
sys.path.insert(0, ".")   # resume.sh cd's into scripts/ first
import issues as I

# The documented convention is an English "Cancel reason: …" comment. Teams working in
# another language add their own marker via CANCEL_MARKERS, as regex alternatives
# (e.g. CANCEL_MARKERS="motivo de cancelacion|annullingsgrund").
_extra = os.environ.get("CANCEL_MARKERS", "").strip()
MARKER = re.compile(r"cancel[- ]?reason" + (f"|{_extra}" if _extra else ""), re.I)
DRY = os.environ.get("DRY") == "1"
proj = os.environ.get("PROJECT") or ""
revived = []
pids = [proj] if proj else I.project_ids()
for pid in pids:
    for it in I.all_issues(pid):
        if (it.get("status") or "") != "cancelled":
            continue
        raw = I._run(["issue", "comment", "list", it["id"], "--output", "json"])
        title = (it.get("title") or "")[:70]
        # Search the comment BODIES, not the raw JSON: an imported ticket or a quoted
        # external snippet containing the phrase would otherwise immunise an issue
        # from recovery forever.
        try:
            comments = json.loads(raw or "[]")
            bodies = " ".join(
                (c.get("body") or c.get("content") or "")
                for c in (comments if isinstance(comments, list) else comments.get("comments", []))
            )
        except Exception:
            # Unparseable comments (a stray control character is the documented cause) must
            # NOT fall back to the raw blob — that reopens the hole this fix closed, where a
            # quoted "Cancel reason" anywhere in the JSON immunises an issue forever. Skip
            # instead: leaving a cancelled issue alone is safe, reviving one wrongly is not.
            print(f"  skip (comments unreadable, not judging): {title}")
            continue
        if MARKER.search(bodies):
            print(f"  skip (intentional cancel): {title}")
        elif DRY:
            revived.append(title)
            print(f"  would revive to todo (no reason found): {title}")
        else:
            subprocess.run(["multica", "issue", "status", it["id"], "todo"],
                           stdin=subprocess.DEVNULL, capture_output=True)
            revived.append(title)
            print(f"  revived to todo (no reason found): {title}")

if revived:
    # Honest reporting: these are NOT restarted here. They sit in `todo` with a cancelled
    # (not agent_error) last run, so the rerun pass below leaves them alone too — a stage
    # barrier or the conductor picks them up.
    print(f"  → {len(revived)} revived to todo; they are queued, not restarted.")
    print("  → A cancel made by a person in the Multica app carries no marker, so it")
    print("    looks accidental to this script. Check the list above before walking away.")
PY
fi

# Bulk rerun. Interrupted assigned work resumes; a todo issue is reran ONLY when its own
# run history shows the last run failed with agent_error (a rollback) — never untouched
# backlog. The run-history check is why this pass is Python, not a bash/jq loop.
PROJECT="$PROJECT" DRY="$DRY" python3 - <<'PY'
import os, subprocess, sys
sys.path.insert(0, ".")
import issues as I

DRY = os.environ.get("DRY") == "1"
proj = os.environ.get("PROJECT") or ""
pids = [proj] if proj else I.project_ids()
n = 0
for pid in pids:
    for it in I.all_issues(pid):
        status = it.get("status") or ""
        title = (it.get("title") or "")[:70]
        if status in ("in_progress", "in_review"):
            if not (it.get("assignee_id") or ""):
                continue                       # interrupted but unassigned — nothing to resume
        elif status == "todo":
            if not I.is_agent_error(I.latest_run(it["id"])):
                continue                       # untouched backlog, or rolled back for another reason
        else:
            continue                           # backlog/done/blocked/cancelled — not ours
        if DRY:
            print(f"  would rerun ({status}): {title}")
            n += 1
            continue
        r = subprocess.run(["multica", "issue", "rerun", it["id"]],
                           stdin=subprocess.DEVNULL, capture_output=True)
        if r.returncode == 0:
            print(f"  reran ({status}): {title}")
            n += 1
        else:
            print(f"  failed: {title}")
print(f"would rerun: {n}" if DRY else f"reran tasks: {n}")
PY
