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
import os, re, subprocess, sys
sys.path.insert(0, ".")   # resume.sh cd's into scripts/ first
import issues as I

MARKER = re.compile(r"(cancel[- ]?reason|причина отмены|отменено с причиной)", re.I)
proj = os.environ.get("PROJECT") or ""
pids = [proj] if proj else I.project_ids()
for pid in pids:
    for it in I.all_issues(pid):
        if (it.get("status") or "") != "cancelled":
            continue
        raw = I._run(["issue", "comment", "list", it["id"], "--output", "json"])
        title = (it.get("title") or "")[:70]
        if MARKER.search(raw or ""):
            print(f"  skip (intentional cancel): {title}")
        else:
            subprocess.run(["multica", "issue", "status", it["id"], "todo"],
                           stdin=subprocess.DEVNULL, capture_output=True)
            print(f"  revived (no reason = accidental/limit): {title}")
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
