#!/usr/bin/env bash
# Mutation tests for hooks/rule-home.py — it must speak on the trap and stay silent everywhere
# else, because a hook that fires on a project's own files is one the owner switches off.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
H="python3 $PWD/hooks/rule-home.py"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0

mkops() { mkdir -p "$1"; printf '# Guide\n\nOperated by multica-ops 0.4.0.\n' > "$1/CLAUDE.md"; }
mkplain() { mkdir -p "$1"; printf '# Readme\n\nJust a project.\n' > "$1/README.md"; }

fire() { # cwd path tool
  local err rc
  err=$(CWD="$1" P="$2" TOOL="${3:-Write}" python3 -c 'import json,os,sys; sys.stdout.write(json.dumps({"hook_event_name":"PreToolUse","tool_name":os.environ["TOOL"],"cwd":os.environ["CWD"],"tool_input":{"file_path":os.environ["P"]}}))' | $H 2>&1 >/dev/null); rc=$?
  echo "$rc|$err"
}
speaks() { local r; r=$(fire "$2" "$3" "${4:-Write}"); [ "${r%%|*}" = "2" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: $1 — expected a stop, got rc=${r%%|*}"; }; }
silent() { local r; r=$(fire "$2" "$3" "${4:-Write}"); [ "${r%%|*}" = "0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: $1 — expected silence, got rc=${r%%|*}"; }; }

OPS="$T/company"; mkops "$OPS"
PLAIN="$T/plain"; mkplain "$PLAIN"
MEM="$T/config/projects/-tmp-company-work/memory"

speaks "the runtime memory store"        "$OPS" "$MEM/feedback_no_friday.md"
speaks "its MEMORY.md index"             "$OPS" "$MEM/MEMORY.md"
speaks "an Edit into memory"             "$OPS" "$MEM/x.md" "Edit"

silent "the guide itself"                "$OPS" "$OPS/CLAUDE.md"
silent "_ops/DECISIONS.md"               "$OPS" "$OPS/_ops/DECISIONS.md"
silent "a source file"                   "$OPS" "$OPS/src/app.ts"
# A project's OWN memory/ directory is its business, not ours.
silent "the project's own memory/ dir"   "$OPS" "$OPS/memory/notes.md"
# In a repository this skill does not operate, the runtime's memory is nobody's business.
silent "an unoperated repository"        "$PLAIN" "$MEM/feedback.md"
# Other tools and other events never trip it.
silent "a Bash call"                     "$OPS" "$MEM/x.md" "Bash"

r=$(printf '{"hook_event_name":"PostToolUse","tool_name":"Write","cwd":"'"$OPS"'","tool_input":{"file_path":"'"$MEM"'/x.md"}}' | $H 2>&1 >/dev/null; echo "rc=$?")
[ "$r" = "rc=0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: another event must not trip it ($r)"; }
r=$(printf 'not json' | $H 2>&1 >/dev/null; echo "rc=$?")
[ "$r" = "rc=0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: malformed input must fail open ($r)"; }
r=$(MOPS_RULE_HOME_GATE=off fire "$OPS" "$MEM/x.md")
[ "${r%%|*}" = "0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: the off-switch must open the door"; }

msg=$(fire "$OPS" "$MEM/x.md"); msg=${msg#*|}
case "$msg" in *"_ops/DECISIONS.md"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: message does not name the homes";; esac
case "$msg" in *"unread by every agent"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: message does not say why memory is wrong";; esac

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
