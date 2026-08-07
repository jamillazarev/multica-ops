#!/usr/bin/env bash
# Mutation tests for hooks/dispatch-nudge.py. Four behaviours, each shown and each shown absent:
# silent before the threshold, speaks at it, never twice, and any real action resets the count.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
H="python3 $PWD/hooks/dispatch-nudge.py"
export MOPS_GATE_DIR=$(mktemp -d); trap 'rm -rf "$MOPS_GATE_DIR"' EXIT
export MOPS_DISPATCH_THRESHOLD=5
pass=0; fail=0
ok(){ [ "$2" = "$3" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: $1 (want $2, got $3)"; }; }

fire(){ # session tool command  → "spoke" | "silent"
  local err
  # The note travels as `hookSpecificOutput.additionalContext` on STDOUT — measured: a
  # PostToolUse hook's stderr never reaches the model, so a test watching stderr would call a
  # correctly-wired note silent and a mis-wired one fine.
  local o
  o=$(S="$1" T="$2" C="${3:-}" python3 -c 'import json,os,sys; sys.stdout.write(json.dumps({"hook_event_name":"PostToolUse","tool_name":os.environ["T"],"session_id":os.environ["S"],"tool_input":{"command":os.environ["C"]}}))' | $H 2>/dev/null)
  case "$o" in *additionalContext*) echo spoke;; *) echo silent;; esac
}

# ── silent below the threshold, speaks at it ─────────────────────────────────────
for i in 1 2 3 4; do ok "read $i is silent" silent "$(fire s1 Read)"; done
ok "the fifth speaks" spoke "$(fire s1 Read)"
# ── and never twice ──────────────────────────────────────────────────────────────
for i in 1 2 3 4 5 6; do ok "retired after speaking ($i)" silent "$(fire s1 Read)"; done
# ── a write resets the count ─────────────────────────────────────────────────────
for i in 1 2 3 4; do fire s2 Read >/dev/null; done
ok "a Write resets" silent "$(fire s2 Write)"
for i in 1 2 3 4; do ok "counting restarts ($i)" silent "$(fire s2 Read)"; done
ok "and speaks only at the new fifth" spoke "$(fire s2 Read)"
# ── a looking Bash counts; an acting Bash resets ─────────────────────────────────
for i in 1 2 3 4; do fire s3 Bash "multica issue list" >/dev/null; done
ok "a looking Bash counts toward it" spoke "$(fire s3 Bash 'git log --oneline')"
for i in 1 2 3 4; do fire s4 Bash "multica issue list" >/dev/null; done
ok "an acting Bash resets" silent "$(fire s4 Bash 'multica issue assign X --to Y')"
# ── other events, and the off switch ─────────────────────────────────────────────
r=$(printf '{"hook_event_name":"PreToolUse","tool_name":"Read","session_id":"s5"}' | $H 2>/dev/null); [ -z "$r" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: another event must not trip it"; }
r=$(printf 'not json' | $H 2>/dev/null); [ -z "$r" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: malformed input must fail open"; }
for i in 1 2 3 4; do MOPS_DISPATCH_NUDGE=off fire s6 Read >/dev/null; done
ok "the off switch holds" silent "$(MOPS_DISPATCH_NUDGE=off fire s6 Read)"
# ── the note has to say what to do, or it is noise ───────────────────────────────
for i in 1 2 3 4; do fire s7 Read >/dev/null; done
msg=$(printf '{"hook_event_name":"PostToolUse","tool_name":"Read","session_id":"s7","tool_input":{}}' | $H 2>/dev/null)
case "$msg" in *dispatched*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: the note does not say to dispatch";; esac
case "$msg" in *"arrives once"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: the note does not say it is once";; esac

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
