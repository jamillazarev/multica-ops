#!/usr/bin/env bash
# `find-installs.sh` exercised on its mutants and its honest twins.
#
# **It shipped with none, under a commit titled "a route nobody verifies is a route nobody has".**
# A cold-read lens said so on 2026-08-23, which is the sort of thing a lens is for: the irony was
# invisible from inside. What the check does is decide whether an install's documented update
# route can actually be walked, and it was wrong in the direction that costs most — it promised a
# refusal on a condition that does not cause one, then prescribed `reset`, which discards work.
#
# Everything here runs in throwaway repositories under the scratchpad. This tree is never touched.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
HERE=$(pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ pass=$((pass+1)); }; bad(){ fail=$((fail+1)); echo "  ✗ $1"; }

# `clone_state` is a shell function inside the script; lift it out and call it directly rather
# than reaching it through a whole inventory run, which would depend on this machine's installs.
# **A failed lift must ABORT.** Without this exit, `clone_state` is simply undefined and every
# later `[ -z "$(clone_state …)" ]` passes on empty output — three assertions go green over a
# function that does not exist, which is the corpse this repository spent a commit on elsewhere
# the same day. The lift needs `clone_state() {` at column 0 and a closing `}` at column 0.
sed -n '/^clone_state() {/,/^}$/p' "$HERE/scripts/find-installs.sh" > "$T/fn.sh"
if [ ! -s "$T/fn.sh" ]; then
  bad "clone_state could not be lifted out of scripts/find-installs.sh — it needs \`clone_state() {\` at column 0 and a closing \`}\` at column 0; every assertion below would have passed vacuously"
  echo "find-installs: $pass passed, $fail failed"
  exit "$fail"
fi
ok
# shellcheck disable=SC1090
. "$T/fn.sh"

# ── a plain directory is not a clone, and has no git route to break ─────────────────────────
mkdir -p "$T/plaincopy"; printf 'x\n' > "$T/plaincopy/a.txt"
[ -z "$(clone_state "$T/plaincopy")" ] \
  && ok || bad "a plain copy was flagged — it has no git route to break in the first place"

# ── a clean clone is fine ───────────────────────────────────────────────────────────────────
git init -q "$T/src"
( cd "$T/src" && printf 'x\n' > a.txt && git add -A \
  && git -c user.email=t@t -c user.name=t commit -qm one ) >/dev/null 2>&1
git clone -q "$T/src" "$T/clean" 2>/dev/null
[ -z "$(clone_state "$T/clean")" ] \
  && ok || bad "a clean clone was flagged as broken"

# ── an UNTRACKED file does not stop `git pull --ff-only`, so it must not be flagged ─────────
# This is the finding. The flag used to fire here and tell the reader to reset — destructive
# advice for a directory whose route works. Measured against real git, 2026-08-23: with the
# upstream ahead and one stray untracked file, the pull fast-forwards.
printf 'note\n' > "$T/clean/stray.md"
[ -z "$(clone_state "$T/clean")" ] \
  && ok || bad "a stray untracked file was reported as a broken route"
( cd "$T/src" && printf 'y\n' > b.txt && git add -A \
  && git -c user.email=t@t -c user.name=t commit -qm two ) >/dev/null 2>&1
( cd "$T/clean" && git pull --ff-only ) >/dev/null 2>&1 \
  && ok || bad "git itself refused the pull with only an untracked file present — the premise is wrong"
rm -f "$T/clean/stray.md"

# ── a MODIFIED tracked file does stop it, and must be flagged ───────────────────────────────
printf 'edited\n' > "$T/clean/a.txt"
_flag=$(clone_state "$T/clean")
[ -n "$_flag" ] && ok || bad "a clone with a modified tracked file was not flagged"
# The flag says AT RISK, not BROKEN, and the difference is real: a modified file only stops a
# fast-forward when an incoming commit TOUCHES it. This assertion pair is why the wording moved —
# the first draft claimed a refusal "while they stand", and git fast-forwarded straight past a
# modified file the upstream had not gone near.
( cd "$T/src" && printf 'z\n' > c.txt && git add -A \
  && git -c user.email=t@t -c user.name=t commit -qm three ) >/dev/null 2>&1
( cd "$T/clean" && git pull --ff-only ) >/dev/null 2>&1 \
  && ok || bad "a fast-forward that does not touch the modified file should still succeed"
printf 'edited again\n' > "$T/clean/a.txt"
( cd "$T/src" && printf 'upstream too\n' > a.txt && git add -A \
  && git -c user.email=t@t -c user.name=t commit -qm four ) >/dev/null 2>&1
( cd "$T/clean" && git pull --ff-only ) >/dev/null 2>&1 \
  && bad "git accepted a pull whose incoming commit overwrites a locally modified file" || ok
printf '%s' "$(clone_state "$T/clean")" | grep -q 'ROUTE AT RISK' \
  && ok || bad "the flag does not say AT RISK — BROKEN overclaims what a modified file causes"

# ── the remedy has to be runnable, and the prohibition has to be there ──────────────────────
# "Stash or reset it to origin" named no branch and no command. A remedy a reader cannot paste
# is a remedy they will improvise, and the improvisation here discards their work.
printf '%s' "$_flag" | grep -q 'git -C .* stash' \
  && ok || bad "the flag does not give a runnable stash command"
# **No discard is prescribed, and that is the assertion.** Three remedies shipped here and two
# destroyed work — `reset --hard` is repo-wide, and a scoped `restore --source=HEAD` deletes a
# staged new file, because a path absent from HEAD is restored to not existing. The message names
# the risk and offers the reversible move; a discard belongs to whoever owns the work. The test
# looks for an imperative shape, because the message names both commands in order to warn off them.
printf '%s' "$_flag" | grep -qE '(Recover with|Discard (just|only)|to discard) [^.]*(restore|reset)' \
  && bad "the flag prescribes a discard — two of those have destroyed work" || ok
printf '%s' "$_flag" | grep -q 'Discarding is your call' \
  && ok || bad "the flag does not say whose call a discard is"
printf '%s' "$_flag" | grep -q 'stash pop' \
  && ok || bad "the stash is offered with no way to get the work back"
printf '%s' "$_flag" | grep -q 'diff --name-only --diff-filter=MDRT HEAD' \
  && ok || bad "the look-at-them command does not match what was counted"
printf '%s' "$_flag" | grep -qE '\*\*|`git ' \
  && bad "the flag prints markdown to a terminal — asterisks read literally, backticked commands paste as substitutions" || ok
printf '%s' "$_flag" | grep -qE 'Recover with .*reset --hard|or `git -C [^`]*reset --hard' \
  && bad "the flag still PRESCRIBES a repo-wide reset" || ok
printf '%s' "$_flag" | grep -q 'Do NOT rsync onto a clone' \
  && ok || bad "the flag does not name the act that causes this"

# ── an install inside a larger repository is AT RISK, and the flag must say whose work ──────
# The route is repo-wide, so a clean install in a dirty enclosing repository is genuinely at risk
# and silence there is a false negative.
NEST="$T/nest"
git clone -q "$T/src" "$NEST" 2>/dev/null
mkdir -p "$NEST/plugins/skill" "$NEST/unrelated"
printf 'door\n' > "$NEST/plugins/skill/a.txt"
printf 'important v1\n' > "$NEST/unrelated/notes.md"
( cd "$NEST" && git add -A && git -c user.email=t@t -c user.name=t commit -qm nest ) >/dev/null 2>&1
printf 'important v2 EDITED\n' > "$NEST/unrelated/notes.md"
# **This assertion used to demand the opposite, and it was wrong.** It asserted that a clean
# install inside a dirty repository must NOT be flagged — but the pull it is judging is repo-wide,
# so that route is genuinely at risk and the silence was a false negative I had just written in.
# A lens caught it. What the flag must do is FIRE and say how much of the damage is the install.
_nf=$(clone_state "$NEST/plugins/skill")
[ -n "$_nf" ] \
  && ok || bad "a genuinely at-risk route went unflagged because the edit was outside the install"
printf '%s' "$_nf" | grep -q 'NONE of them under the install itself' \
  && ok || bad "the flag does not separate what is under the install from what is not"
# A STAGED NEW FILE does not block a fast-forward — an incoming commit cannot overwrite a path it
# does not know about — so it must not be counted, and the remedy that used to be printed for it
# deleted it. Measured 2026-08-27 with the file gone.
printf 'brand new\n' > "$NEST/plugins/skill/fresh.txt"
( cd "$NEST" && git add plugins/skill/fresh.txt ) >/dev/null 2>&1
[ "$(clone_state "$NEST/plugins/skill")" = "$_nf" ] \
  && ok || bad "a staged new file changed the count, though it cannot block a fast-forward"
( cd "$NEST" && git rm -q --cached plugins/skill/fresh.txt ) >/dev/null 2>&1
rm -f "$NEST/plugins/skill/fresh.txt"
printf 'door edited\n' > "$NEST/plugins/skill/a.txt"
[ -n "$(clone_state "$NEST/plugins/skill")" ] \
  && ok || bad "an edit INSIDE the install directory was not seen"

echo "find-installs: $pass passed, $fail failed"
exit "$fail"
