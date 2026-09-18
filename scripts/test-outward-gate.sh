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
  err=$(SID="$sid" CMD="$cmd" TP="${TP:-}" python3 -c 'import json,os,sys; sys.stdout.write(json.dumps({"hook_event_name":"PreToolUse","tool_name":"Bash","session_id":os.environ["SID"],"transcript_path":os.environ.get("TP",""),"tool_input":{"command":os.environ["CMD"]}}))' \
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

# ── a SENTENCE about publishing is not publishing ────────────────────────────────
# Measured 2026-09-18, twice in one session: a comment being written into a file said the verb
# mid-sentence and the gate refused it as if it were the act — the second time, on the comment
# explaining this very repair. The only way past a gate that reads prose is to reword the prose,
# which is the failure this repository names as *satisfied by vocabulary*, arriving at the one
# gate that must not be word-gameable. A command starts a command; a word after a word is prose.
silent "the verb mid-sentence"      "s-b8"  "python3 - <<'PY'
open('x','w').write('a vercel deploy is an outward act')
PY"
silent "prose in a comment"         "s-b9"  "printf '%s' '# this is what a git push costs' > note.md"
silent "an argument, not a command" "s-b10" "grep -r 'npm publish' docs/"
silent "a path that reads like it"  "s-b11" "cat notes/about-git-push.md"

# ── and a wrapper is still the act, because the verb still starts a command ───────
speaks "inside a quoted -c"     "s-b12" "bash -c \"git push origin main\""
speaks "after a semicolon"      "s-b13" "cd /tmp; git push"
speaks "inside a subshell"      "s-b14" "(cd repo && git push)"
speaks "on its own line"        "s-b15" "cd repo
git push origin main"

# ── eleven ways past it, every one reproduced by an adversarial lens ─────────────
# A wrapper word is not a delimiter, so nothing anchored before the verb; a line continuation is
# one command to the shell and two lines to a regex; a redirect needs no space; the runner's quote
# can sit further than forty characters away, or not exist at all. **This is the costly direction**
# — a miss lets a publish through — so each shape is a case rather than a note.
speaks "env prefix"              "s-i1" "env VAR=x git push origin main"
speaks "sudo prefix"             "s-i2" "sudo git push origin main"
speaks "nohup and background"    "s-i3" "nohup git push origin main &"
speaks "time prefix"             "s-i4" "time git push origin main"
speaks "nice -n prefix"          "s-i5" "nice -n 10 git push origin main"
speaks "a line continuation"     "s-i6" "git \\
push origin main"
speaks "a redirect right after"  "s-i7" "git push>/dev/null 2>&1"
speaks "xargs, quote far away"   "s-i8" "xargs -I{} --a-very-long-placeholder-flag 'git push origin main'"
speaks "eval with no quote"      "s-i9" "eval git push origin main"
speaks "a brace group"           "s-i10" "{ git push origin main; }"
speaks "env before a deploy"     "s-i11" "env CI=1 vercel deploy --prod"

# ── and a heredoc body is data being fed to another program ──────────────────────
# Writing a document that carries the verb at the start of a line was refused as a publish — the
# same *prose is not an act* defect, arriving back through the newline anchor that repaired it.
silent "a heredoc body"          "s-i12" "cat > docs/how.md <<'EOF'
git push origin main
EOF"
# …while a backticked command inside a double-quoted message is NOT prose: the shell substitutes
# it. Kept as a case so nobody ever "fixes" a true positive.
speaks "backticks in a message"  "s-i13" "git commit -m \"how \`git push origin main\` works\""
silent "a plain message"         "s-i14" "git commit -m \"describe how to git push later\""

# ── the verbs the other copy had and this one did not ────────────────────────────
# Two copies of one rule with three different verb lists, and nothing saying why. Aligned after a
# contradiction lens ran them side by side, 2026-09-18.
speaks "flyctl deploy"    "s-j1" "flyctl deploy"
speaks "kamal deploy"     "s-j2" "kamal deploy"
speaks "make deploy"      "s-j3" "make deploy"
speaks "npm run deploy"   "s-j4" "npm run build && npm run deploy"

# ── the blanker's three, and the wrappers' eight ─────────────────────────────────
# All reproduced by an adversarial lens, 2026-09-18. A blanker that cannot see both ends of a
# heredoc body blanks nothing; a wrapper word takes flags, and a flag takes its own argument.
speaks "heredoc, no terminator" "s-k1" "cat <<EOF; git push origin main"
speaks "<< inside a message"    "s-k2" "git commit -m \"a<<b is not a heredoc\" && git push origin main"
speaks "a here-string"          "s-k3" "cat <<< \"some text\" && git push origin main"
speaks "env, no assignment"     "s-k4" "env git push origin main"
speaks "env -i"                 "s-k5" "env -i git push origin main"
speaks "sudo -u root"           "s-k6" "sudo -u root git push origin main"
speaks "command -p"             "s-k7" "command -p git push origin main"
speaks "time -p"                "s-k8" "time -p git push origin main"
speaks "nice --adjustment=10"   "s-k9" "nice --adjustment=10 git push origin main"
speaks "exec -a name"           "s-k10" "exec -a myname git push origin main"
silent "a real heredoc body"    "s-k11" "cat > docs/how.md <<'EOF'
git push origin main
EOF"

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

# ── the owner's last words are QUOTED, and quoting is not consenting ─────────────
# A gate cannot read intent; asking the constrained party for theirs is asking the thing being
# stopped to grade itself, and the measured failure is that its account was confident and wrong.
# So the human's own last message is put beside the refusal — and the refusal is unchanged.
T_OK="$MOPS_GATE_DIR/t.jsonl"
python3 - "$T_OK" <<'PY'
import json, sys
rows = [
    {"type": "user", "message": {"role": "user",
     "content": [{"type": "text", "text": "fix the gate and commit"}]}},
    {"type": "assistant", "message": {"role": "assistant",
     "content": [{"type": "text", "text": "ok"}]}},
    {"type": "user", "message": {"role": "user",
     "content": [{"type": "tool_result", "content": "some tool output"}]}},
    {"type": "user", "message": {"role": "user",
     "content": [{"type": "text",
                  "text": "now ship it <system-reminder>noise</system-reminder>"}]}},
    {"type": "user", "message": {"role": "user",
     "content": [{"type": "tool_result", "content": "more tool output"}]}},
]
with open(sys.argv[1], "w") as f:
    for r in rows:
        f.write(json.dumps(r) + "\n")
PY
msg=$(TP="$T_OK" fire "s-h1" "git push origin main")
rc=${msg%%|*}; msg=${msg#*|}
[ "$rc" = "2" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: quoting must not open the door (rc=$rc)"; }
case "$msg" in *"now ship it"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: the owner's last instruction is not quoted";; esac
case "$msg" in *"context, not consent"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: the quote is not marked as context rather than consent";; esac
# the tool results between them are machinery, not the owner — and the harness's reminder is not either
case "$msg" in *"tool output"*) fail=$((fail+1)); echo "FAIL: a tool result was read as the owner speaking";; *) pass=$((pass+1));; esac
case "$msg" in *noise*) fail=$((fail+1)); echo "FAIL: a system-reminder was read as the owner speaking";; *) pass=$((pass+1));; esac
# and an unreadable transcript changes nothing about the verdict
r=$(TP="$MOPS_GATE_DIR/nope.jsonl" fire "s-h2" "git push origin main")
[ "${r%%|*}" = "2" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: a missing transcript must not change the verdict"; }
case "${r#*|}" in *"context, not consent"*) fail=$((fail+1)); echo "FAIL: nothing to quote, yet it quoted";; *) pass=$((pass+1));; esac

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
