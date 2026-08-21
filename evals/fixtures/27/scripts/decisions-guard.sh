#!/usr/bin/env bash
# Guard: _ops/DECISIONS.md is append-only. Wired as a PreToolUse hook on Edit|Write.
set -euo pipefail

payload=$(cat)
path=$(printf '%s' "$payload" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || true)

case "$path" in
  *_ops/DECISIONS.md)
    # Appends arrive via Write with the old content as a prefix; an Edit to this file
    # rewrites history, which the decisions log does not allow.
    tool=$(printf '%s' "$payload" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || true)
    if [ "$tool" = "Edit" ]; then
      echo "decisions-guard: refusing — DECISIONS.md is append-only" >&2
      printf '{"permissionDecision": "deny", "permissionDecisionReason": "DECISIONS.md is append-only; add a new entry instead of editing history"}\n'
      exit 0
    fi
    ;;
esac
exit 0
