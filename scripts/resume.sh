#!/usr/bin/env bash
# "Everyone continue" in one command.
#
# Reruns every ASSIGNED and INTERRUPTED task (in_progress/in_review). Agents resume
# from the repository state — hence the team rule to commit incrementally.
# Never touches todo/backlog: those wait on --stage barriers.
#
# cancelled: an intentional cancel always carries a "Cancel reason:" comment;
# --revive-cancelled revives ONLY marker-less ones (accidental), then reruns.
#
# Usage: bash resume.sh [--revive-cancelled] [--project <id>]
set -euo pipefail
cd "$(dirname "$0")"

REVIVE=0
PROJECT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --revive-cancelled) REVIVE=1 ;;
    --project) shift; PROJECT="${1:-}" ;;
  esac
  shift
done

if [ "$REVIVE" = 1 ]; then
  PROJECT="$PROJECT" python3 - <<'PY'
import json, os, re, subprocess, sys
sys.path.insert(0, ".")   # resume.sh cd's into scripts/ first
import issues as I

# The documented convention is an English "Cancel reason: …" comment. Teams working in
# another language add their own marker via CANCEL_MARKERS, as regex alternatives
# (e.g. CANCEL_MARKERS="motivo de cancelacion|annullingsgrund").
_extra = os.environ.get("CANCEL_MARKERS", "").strip()
MARKER = re.compile(r"cancel[- ]?reason" + (f"|{_extra}" if _extra else ""), re.I)
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
        else:
            subprocess.run(["multica", "issue", "status", it["id"], "todo"],
                           stdin=subprocess.DEVNULL, capture_output=True)
            revived.append(title)
            print(f"  revived to todo (no reason found): {title}")

if revived:
    # Honest reporting: these are NOT restarted here. They sit in `todo`, where a stage
    # barrier or the conductor picks them up — the rerun loop below only touches
    # in_progress/in_review, and rerunning `todo` is explicitly forbidden.
    print(f"  → {len(revived)} revived to todo; they are queued, not restarted.")
    print("  → A cancel made by a person in the Multica app carries no marker, so it")
    print("    looks accidental to this script. Check the list above before walking away.")
PY
fi

if [ -n "$PROJECT" ]; then
  TSV="$(python3 issues.py "$PROJECT")"
else
  TSV="$(python3 issues.py)"
fi
n=0
while IFS=$'\t' read -r id status assignee atype parent title; do
  [ -z "$assignee" ] && continue
  case "$status" in in_progress|in_review) ;; *) continue;; esac
  if multica issue rerun "$id" </dev/null >/dev/null 2>&1; then
    echo "  reran: ${title}"; n=$((n + 1))
  else
    echo "  failed: ${title}"
  fi
done <<< "$TSV"
echo "reran tasks: $n"
