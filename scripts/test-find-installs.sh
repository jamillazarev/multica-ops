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
printf '%s' "$_flag" | grep -q 'reset --hard' \
  && ok || bad "the flag does not give a runnable discard command"
printf '%s' "$_flag" | grep -q 'Do NOT rsync onto a clone' \
  && ok || bad "the flag does not name the act that causes this"

echo "find-installs: $pass passed, $fail failed"
exit "$fail"
