#!/usr/bin/env bash
# Prints "<waiting> <stuck> <reset>" for status indicators:
#   waiting = assigned in_progress/in_review whose latest run is NOT a limit failure
#   stuck   = issues whose LATEST run failed on a session/usage limit (agent_error)
#   reset   = "resets …" parsed from the failed run's error field (or "-")
# Usage: bash health.sh [<project-id>]
set -euo pipefail
cd "$(dirname "$0")"
command -v multica >/dev/null 2>&1 || { echo "0 0 -"; exit 0; }
PROJECT="${1:-}" python3 - <<'PY'
import json, os, re, sys
sys.path.insert(0, ".")
import issues as I

def clean(s): return re.sub(r"[\x00-\x1f]", " ", s)
def latest_run(iid):
    try:
        d = json.loads(clean(I._run(["issue", "runs", iid, "--output", "json"])))
        rs = d if isinstance(d, list) else d.get("runs", [])
        return rs[0] if rs else None
    except Exception:
        return None

LIMIT = re.compile(r"agent_error|session limit|hit your|usage limit|rate limit", re.I)
RESET = re.compile(r"resets?\s+([0-9:apm ]+\([^)]+\))", re.I)
proj = os.environ.get("PROJECT") or ""
pids = [proj] if proj else I.project_ids()
waiting = stuck = 0
resets = []
for pid in pids:
    for it in I.all_issues(pid):
        if not it.get("assignee_id"):
            continue
        if (it.get("status") or "") not in ("in_progress", "in_review"):
            continue
        r = latest_run(it["id"])
        reason = str((r or {}).get("error") or (r or {}).get("reason") or "")
        if r and r.get("status") == "failed" and LIMIT.search(reason):
            stuck += 1
            m = RESET.search(reason)
            if m:
                resets.append(m.group(1).strip())
        else:
            waiting += 1
print(f"{waiting} {stuck} {resets[0] if resets else '-'}")
PY
