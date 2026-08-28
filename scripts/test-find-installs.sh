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

# ── a STRAY untracked file does not stop `git pull --ff-only`, so it must not be flagged ────
# This is the finding. The flag used to fire here and tell the reader to reset — destructive
# advice for a directory whose route works. Measured against real git, 2026-08-23: with the
# upstream ahead and one stray untracked file, the pull fast-forwards.
# **"Stray" is the whole of the claim, and this comment used to omit it.** An untracked file
# whose path an incoming commit ADDS does abort the pull — *"The following untracked working
# tree files would be overwritten by merge"* — measured 2026-08-28, with this counter reading 0.
# So does a staged new file at such a path. Both are left uncounted on purpose: the incoming
# commit is unknown without a fetch, and counting every untracked file recreates the original
# false positive. The flag says outright that the count is a warning and the pull is the test.
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
# **The discard IS prescribed now, and what makes that safe is measured here, not asserted.**
# Three remedies shipped before this one and two destroyed work; a fourth was one command from
# shipping on 2026-08-27, when a lens correctly said the restraint had gone too far and I reached
# for `--diff-filter=MDRT` — whose R rows name the rename DESTINATION, absent from HEAD, which
# `restore --source=HEAD` deletes. The assertions below take the listing command out of the
# printed message itself, run it against a tree containing a rename, and require every path it
# yields to exist in HEAD. The mutant check underneath proves those assertions can fail.
_list=$(printf '%s' "$_flag" | sed -n 's/.*SEE: git -C "[^"]*" \(diff [^.]*HEAD\)\..*/\1/p')
[ -n "$_list" ] \
  && ok || bad "no listing command could be lifted out of the flag — the safety assertions below cannot run"
printf '%s' "$_flag" | grep -q 'restore --staged --worktree --source=HEAD' \
  && ok || bad "the flag names no per-path discard in its full form — without --staged the index keeps differing, which stops the pull while this flag reads clean (measured 2026-08-27), and the bare form was the one deleted as known-wrong a release earlier"
printf 'renamable\n' > "$T/clean/torename.txt"
( cd "$T/clean" && git add torename.txt \
  && git -c user.email=t@t -c user.name=t commit -qm rn ) >/dev/null 2>&1
( cd "$T/clean" && git mv torename.txt renamed-away.txt ) >/dev/null 2>&1
_unsafe=0
for _p in $( cd "$T/clean" && git $_list 2>/dev/null ); do
  ( cd "$T/clean" && git cat-file -e "HEAD:$_p" ) 2>/dev/null || _unsafe=$((_unsafe+1))
done
[ "$_unsafe" -eq 0 ] \
  && ok || bad "the listing the flag prints yields $_unsafe path(s) absent from HEAD — restore --source=HEAD DELETES those, which is how three earlier remedies destroyed work"
# **The mutant.** Same tree, rename detection left on: the destination path appears and is not in
# HEAD. If this ever comes back clean, the assertion above has stopped testing anything.
_mut=0
for _p in $( cd "$T/clean" && git diff --name-only --diff-filter=MDRT HEAD 2>/dev/null ); do
  ( cd "$T/clean" && git cat-file -e "HEAD:$_p" ) 2>/dev/null || _mut=$((_mut+1))
done
[ "$_mut" -gt 0 ] \
  && ok || bad "the MDRT mutant produced no HEAD-absent path, so the safety assertion above proves nothing on this git"
( cd "$T/clean" && git mv renamed-away.txt torename.txt ) >/dev/null 2>&1
printf '%s' "$_flag" | grep -q 'stash pop' \
  && ok || bad "the stash is offered with no way to get the work back"
printf '%s' "$_flag" | grep -q 'diff --no-renames --name-only --diff-filter=MDT HEAD' \
  && ok || bad "the listing command does not match what was counted — a reader discarding from a different listing is discarding from a set nobody proved safe"
printf '%s' "$_flag" | grep -qE '\*\*|`git ' \
  && bad "the flag prints markdown to a terminal — asterisks read literally, backticked commands paste as substitutions" || ok
printf '%s' "$_flag" | grep -qE 'Recover with .*reset --hard|or `git -C [^`]*reset --hard' \
  && bad "the flag still PRESCRIBES a repo-wide reset" || ok
printf '%s' "$_flag" | grep -q 'Do NOT rsync onto a clone' \
  && ok || bad "the flag does not name the act that causes this"

# ── the stash sequence is printed GUARDED, and the guard is exercised ───────────────────────
# **`git stash push` exits 0 having saved NOTHING when the only difference is a submodule
# gitlink** (measured 2026-08-28), so an unguarded `push; pull; pop` pops whatever was already
# on the stack — a stranger's abandoned work, dumped into the tree. That was the fifth remedy
# this one message has carried and the third able to touch work nobody pointed it at. The
# assertion below is not a spelling check: it runs the printed sequence verbatim against exactly
# that repository and requires the unrelated stash to survive.
printf '%s' "$_flag" | grep -q 'rev-parse -q --verify refs/stash' \
  && ok || bad "the flag prints an unguarded stash sequence — push exits 0 saving nothing on a submodule-only difference, and the pop then takes an unrelated entry"
_gseq=$(printf '%s' "$_flag" | sed -n 's/.*load-bearing: \(S=.*stash pop\)\. Bare.*/\1/p')
[ -n "$_gseq" ] \
  && ok || bad "the guarded sequence could not be lifted out of the flag — the behavioural test below cannot run"
git init -q "$T/smod"
( cd "$T/smod" && printf 'v1\n' > s.txt && git add -A \
  && git -c user.email=t@t -c user.name=t commit -qm s1 \
  && printf 'v2\n' > s.txt && git add -A \
  && git -c user.email=t@t -c user.name=t commit -qm s2 ) >/dev/null 2>&1
git init -q "$T/host"
( cd "$T/host" && git -c protocol.file.allow=always submodule add -q "$T/smod" mod \
  && git add -A && git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
if [ -d "$T/host/mod" ]; then
  ( cd "$T/host/mod" && git checkout -q HEAD~1 ) >/dev/null 2>&1
  printf 'A STRANGER WIP\n' > "$T/host/stranger.txt"
  ( cd "$T/host" && git add stranger.txt \
    && git -c user.email=t@t -c user.name=t stash push -q -m unrelated ) >/dev/null 2>&1
  [ "$(cd "$T/host" && git stash list | grep -c .)" -eq 1 ] \
    && ok || bad "the submodule fixture did not produce the unrelated stash entry the test needs"
  # the flag must fire here at all, or the sequence below is being tested on a quiet repo
  [ -n "$(clone_state "$T/host")" ] \
    && ok || bad "a submodule whose gitlink differs from HEAD did not raise the flag, so the guard is untested"
  _mine=$(printf '%s' "$_gseq" | sed "s|git -C \"[^\"]*\"|git -C \"$T/host\"|g")
  ( cd "$T/host" && eval "$_mine" ) >/dev/null 2>&1
  [ "$(cd "$T/host" && git stash list | grep -c .)" -eq 1 ] \
    && ok || bad "the printed sequence consumed an unrelated stash entry — this is the measured data-loss path, not a hypothetical"
  [ ! -f "$T/host/stranger.txt" ] \
    && ok || bad "the printed sequence dumped a stranger's stashed work into the tree"
  # **The mutant.** The bare sequence the guard replaced, run on the same fixture. If this ever
  # comes back clean, the two assertions above have stopped testing anything.
  ( cd "$T/host" && git stash push -u -m pre-pull && git pull --ff-only; git stash pop ) >/dev/null 2>&1
  [ "$(cd "$T/host" && git stash list | grep -c .)" -eq 0 ] \
    && ok || bad "the unguarded mutant left the stash intact, so the guard assertions above prove nothing on this git"
else
  bad "the submodule fixture could not be built (git refused the file protocol?) — the guard is UNTESTED on this machine, which is worse than a red assertion"
fi

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
