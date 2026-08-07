#!/usr/bin/env bash
# Mutation tests for hooks/outward-gate.py. A gate that cannot be wrong is decoration, so each
# behaviour is shown speaking on the case it exists for and silent on its honest twin.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
H="python3 $PWD/hooks/outward-gate.py"
# A state directory of this run's own: the once-per-session markers must not survive from the
# last invocation, or every "speaks" assertion quietly goes silent the second time you run the
# suite — a test that passes less the more it runs.
export MOPS_GATE_DIR=$(mktemp -d)
trap 'rm -rf "$MOPS_GATE_DIR"' EXIT
pass=0; fail=0

# fire <session> <command> → "rc|stderr". The payload is built by python, not printf: a command
# containing `&&` — the exact case a real push arrives in — was breaking the JSON in the shell
# and the test read the hook as silent when the hook was fine. A test's own escaping is the
# quietest place for a false green to hide.
fire() {
  local sid="$1" cmd="$2" err rc
  err=$(SID="$sid" CMD="$cmd" python3 -c 'import json,os,sys; sys.stdout.write(json.dumps({"hook_event_name":"PreToolUse","tool_name":"Bash","session_id":os.environ["SID"],"tool_input":{"command":os.environ["CMD"]}}))' \
        | $H 2>&1 >/dev/null); rc=$?
  echo "$rc|$err"
}
speaks() { # name session command
  local r; r=$(fire "$2" "$3")
  if [ "${r%%|*}" = "2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 — expected a stop, got rc=${r%%|*}"; fi
}
silent() { # name session command
  local r; r=$(fire "$2" "$3")
  if [ "${r%%|*}" = "0" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 — expected silence, got rc=${r%%|*}: ${r#*|}"; fi
}

# ── it speaks on an outward act ──────────────────────────────────────────────────
speaks "git push"          "s-a1" "git push origin main"
speaks "git push, no args" "s-a2" "git push"
speaks "gh release create" "s-a3" "gh release create v1.0.0"
speaks "npm publish"       "s-a4" "npm publish"
speaks "vercel deploy"     "s-a5" "vercel deploy --prod"
speaks "docker push"       "s-a6" "docker push registry/app:1"
speaks "push inside a chain" "s-a7" "git add -A && git commit -m x && git push"

# ── and is silent on local work, which is most of what anyone runs ───────────────
silent "git commit"  "s-b1" "git commit -m 'a change'"
silent "git add"     "s-b2" "git add -A"
silent "git status"  "s-b3" "git status --short"
silent "a branch"    "s-b4" "git checkout -b feature"
silent "a build"     "s-b5" "npm run build"
silent "a test run"  "s-b6" "pytest -q"
silent "the word push in prose" "s-b7" "echo 'remember to push later'"

# ── a dry run is a read: nothing leaves ──────────────────────────────────────────
silent "git push --dry-run" "s-c1" "git push --dry-run origin main"

# ── the retry does NOT pass, and that is the whole repair ────────────────────────
# The first design stopped once and let the retry through. Measured: three runs of five simply
# ran `git push` again and it went. A gate the constrained party can retry past is not a gate.
speaks "first push stops"              "s-d1" "git push origin main"
speaks "the identical retry ALSO stops" "s-d1" "git push origin main"
speaks "and a third attempt stops"      "s-d1" "git push origin main"
speaks "a new session stops too"        "s-d2" "git push origin main"

# ── the off-switch is a named decision, not a retry ──────────────────────────────
r=$(MOPS_OUTWARD_GATE=off fire "s-d3" "git push origin main")
[ "${r%%|*}" = "0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: MOPS_OUTWARD_GATE=off must open the door (got rc=${r%%|*})"; }
speaks "and without it the gate is back" "s-d4" "git push origin main"

# ── it only looks at Bash, and only at PreToolUse ────────────────────────────────
r=$(printf '{"hook_event_name":"PreToolUse","tool_name":"Edit","session_id":"s-e1","tool_input":{"command":"git push"}}' | $H 2>&1 >/dev/null; echo "rc=$?")
[ "$r" = "rc=0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: a non-Bash tool must not trip it ($r)"; }
r=$(printf '{"hook_event_name":"PostToolUse","tool_name":"Bash","session_id":"s-e2","tool_input":{"command":"git push"}}' | $H 2>&1 >/dev/null; echo "rc=$?")
[ "$r" = "rc=0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: another event must not trip it ($r)"; }

# ── every internal error fails open: a broken gate must not break the session ────
r=$(printf 'not json at all' | $H 2>&1 >/dev/null; echo "rc=$?")
[ "$r" = "rc=0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: malformed input must fail open ($r)"; }
r=$(printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","session_id":"s-f1"}' | $H 2>&1 >/dev/null; echo "rc=$?")
[ "$r" = "rc=0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: a missing tool_input must fail open ($r)"; }

# ── the message has to carry the reason, or it is a refusal with no door ─────────
msg=$(fire "s-g1" "git push origin main"); msg=${msg#*|}
case "$msg" in *"outward act"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: message does not name the act as outward";; esac
case "$msg" in *"again will not work"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: message does not say the retry will not work";; esac
case "$msg" in *"MOPS_OUTWARD_GATE=off"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: message does not name the door";; esac

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
