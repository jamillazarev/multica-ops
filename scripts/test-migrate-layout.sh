#!/usr/bin/env bash
# Mutation tests for scripts/migrate-layout.py — a migration is only trustworthy if what it
# REFUSES to touch is proven, not promised. Each behaviour is shown on a tree that has it and
# on the honest twin that doesn't.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
M="$PWD/scripts/migrate-layout.py"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0

ok() { # name expected-rc actual-rc
  if [ "$2" = "$3" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 (want rc=$2, got rc=$3)"; fi
}
has() { # name substring file
  if grep -q -- "$2" "$3"; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 — '$2' not in output:"; sed 's/^/    /' "$3"; fi
}
hasnt() { # name substring file
  if grep -q -- "$2" "$3"; then fail=$((fail+1)); echo "FAIL: $1 — '$2' should NOT be in output"; else pass=$((pass+1)); fi
}

mkproj() { # dir
  rm -rf "$1"; mkdir -p "$1/docs"; git -C "$1" init -q
  git -C "$1" config user.email t@t; git -C "$1" config user.name t
}

# ── a full pre-1.0 tree migrates, and the craft's own docs stay put ──────────────
P="$T/p1"; mkproj "$P"
for f in ROADMAP TEAM TOOLING DECISIONS LATER; do echo "# $f" > "$P/docs/$f.md"; done
mkdir -p "$P/docs/research" "$P/docs/tooling"
echo "# a finding" > "$P/docs/research/q1.md"
echo "# vercel" > "$P/docs/tooling/vercel.md"
# the craft's own — must survive untouched
echo "# our API reference" > "$P/docs/api-reference.md"
mkdir -p "$P/docs/adr"; echo "# adr-001" > "$P/docs/adr/001.md"
git -C "$P" add -A >/dev/null; git -C "$P" commit -qm init

python3 "$M" "$P" > "$T/o1" 2>&1; ok "a full tree migrates" 0 $?
[ -f "$P/_ops/DECISIONS.md" ]; ok "DECISIONS.md landed in _ops/" 0 $?
[ -f "$P/_ops/runbooks/vercel.md" ]; ok "docs/tooling became _ops/runbooks" 0 $?
[ -f "$P/docs/api-reference.md" ]; ok "the craft's own file stayed in docs/" 0 $?
[ -f "$P/docs/adr/001.md" ]; ok "the craft's own directory stayed in docs/" 0 $?
has "leftovers are named, not silently kept" "left in docs/" "$T/o1"
has "the unknown file is named by name" "api-reference.md" "$T/o1"
# history survives: git sees a rename, not a delete+add
git -C "$P" diff --cached --name-status -M | grep -q '^R.*docs/DECISIONS.md.*_ops/DECISIONS.md'
ok "the move is a rename, so blame survives" 0 $?

# ── idempotent: a second run finds nothing ───────────────────────────────────────
git -C "$P" commit -qm migrate
python3 "$M" "$P" > "$T/o2" 2>&1; ok "a second run exits clean" 0 $?
has "a second run says there is nothing to do" "nothing to migrate" "$T/o2"

# ── a dirty tree is refused, so the migration is its own diff ────────────────────
echo "scratch" > "$P/dirty.txt"
python3 "$M" "$P" > "$T/o3" 2>&1; ok "a dirty tree is refused" 2 $?
has "and says why" "commit or stash first" "$T/o3"
python3 "$M" "$P" --dry-run > "$T/o3b" 2>&1; ok "--dry-run works on a dirty tree" 0 $?
rm "$P/dirty.txt"

# ── a collision is named and never overwritten ───────────────────────────────────
Q="$T/p2"; mkproj "$Q"
echo "# old" > "$Q/docs/TEAM.md"; mkdir -p "$Q/_ops"; echo "# new" > "$Q/_ops/TEAM.md"
git -C "$Q" add -A >/dev/null; git -C "$Q" commit -qm init
python3 "$M" "$Q" > "$T/o4" 2>&1; ok "a collision exits nonzero" 1 $?
has "the collision is named" "CONFLICT" "$T/o4"
grep -q "^# new" "$Q/_ops/TEAM.md"; ok "the destination was not overwritten" 0 $?
grep -q "^# old" "$Q/docs/TEAM.md"; ok "the source was not lost" 0 $?

# ── a repo that was never ours is left entirely alone ────────────────────────────
R="$T/p3"; mkproj "$R"
echo "# their handbook" > "$R/docs/handbook.md"
git -C "$R" add -A >/dev/null; git -C "$R" commit -qm init
python3 "$M" "$R" > "$T/o5" 2>&1; ok "a foreign repo exits clean" 0 $?
has "and says nothing was ours" "nothing to migrate" "$T/o5"
[ -f "$R/docs/handbook.md" ]; ok "their file is untouched" 0 $?
[ -d "$R/_ops" ] && { fail=$((fail+1)); echo "FAIL: _ops/ was created in a repo with nothing to migrate"; } || pass=$((pass+1))

# ── a stale pre-commit copy is named, not silently rewritten ─────────────────────
S="$T/p4"; mkproj "$S"
echo "# t" > "$S/docs/TEAM.md"; git -C "$S" add -A >/dev/null; git -C "$S" commit -qm init
printf '#!/bin/sh\n[ -f docs/TEAM.md ] || exit 1\n' > "$S/.git/hooks/pre-commit"
python3 "$M" "$S" > "$T/o6" 2>&1
has "a stale pre-commit copy is named" "re-copy" "$T/o6"
grep -q "docs/TEAM.md" "$S/.git/hooks/pre-commit"; ok "the project's hook was not rewritten for them" 0 $?

# ── not a git repository ─────────────────────────────────────────────────────────
mkdir -p "$T/plain"
python3 "$M" "$T/plain" > "$T/o7" 2>&1; ok "a non-git directory is refused" 2 $?

# ── a tree operated by another system is handed back, untouched ───────────────────
F="$T/p5"; mkproj "$F"
echo "# t" > "$F/docs/TEAM.md"; mkdir -p "$F/_ops"
printf 'operator: opsinist\n' > "$F/_ops/config.md"
printf '# Guide\n\nrun by something else\n' > "$F/CLAUDE.md"
git -C "$F" add -A >/dev/null; git -C "$F" commit -qm init
python3 "$M" "$F" > "$T/o8" 2>&1; ok "a foreign _ops/ is refused" 2 $?
has "and names what it found" "operated by another system" "$T/o8"
[ -f "$F/docs/TEAM.md" ]; ok "nothing was moved" 0 $?
[ -f "$F/_ops/TEAM.md" ] && { fail=$((fail+1)); echo "FAIL: wrote into a foreign _ops/"; } || pass=$((pass+1))

# ...but OUR tree with a config.md and our operator line still migrates.
G="$T/p6"; mkproj "$G"
echo "# t" > "$G/docs/TEAM.md"; mkdir -p "$G/_ops"
printf 'operator: opsinist\n' > "$G/_ops/config.md"
printf '# Guide\n\nOperated by multica-ops 0.4.0.\n' > "$G/CLAUDE.md"
git -C "$G" add -A >/dev/null; git -C "$G" commit -qm init
python3 "$M" "$G" > "$T/o9" 2>&1; ok "our own tree still migrates" 0 $?
[ -f "$G/_ops/TEAM.md" ]; ok "and the move happened" 0 $?

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
