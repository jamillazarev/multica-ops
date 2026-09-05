#!/usr/bin/env bash
# `check-releases.sh` exercised on its mutants and its honest twins.
#
# **It shipped with none**, and four defects were found in it the day it was written — a discarded
# `gh` exit status that turned "no authentication" into *"0 releases checked, every one matches"*,
# a summary reading "3 of 0", `--emit` recognised only as the first argument, and a blank line
# counted as drift. All four were repaired by hand and none was asserted, in a release whose own
# subject is a check that reports green on something it never read. `facts.md` 254.
#
# `gh` is stubbed: every case writes what the stub should answer, so the suite needs no network
# and no credentials. The stub is FIRST on PATH; the real `gh` is never called.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
HERE=$(pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ pass=$((pass+1)); }; bad(){ fail=$((fail+1)); echo "  ✗ $1"; }

# ── the stub, and a fixture repository for the script to read its CHANGELOG from ─────────────
mkdir -p "$T/bin" "$T/p/scripts"
cat > "$T/bin/gh" <<'STUB'
#!/bin/sh
# Answers from files the case wrote: LIST (one tag per line), BODY-<tag>, and LIST_RC.
D=${GH_FIXTURE:?}
case "$1 $2" in
  "release list") [ -f "$D/LIST_RC" ] && exit "$(cat "$D/LIST_RC")"
                  cat "$D/LIST" 2>/dev/null; exit 0;;
  "release view") cat "$D/BODY-$3" 2>/dev/null; exit 0;;
esac
exit 0
STUB
chmod +x "$T/bin/gh"
cp "$HERE/scripts/check-releases.sh" "$T/p/scripts/"
( cd "$T/p" && git init -q && git remote add origin git@github.com:acme/thing.git ) >/dev/null 2>&1

# One entry per version, in the shape the ritual publishes: the heading collapsed to a bare date.
entry(){ printf '## %s — 2026-01-01\n\nWhat it does.\n\n' "$1"; }
setup(){ : > "$T/fx/LIST"; rm -f "$T/fx/LIST_RC"; printf '# Changelog\n\n' > "$T/p/CHANGELOG.md"; }
mkdir -p "$T/fx"
run(){ ( cd "$T/p" && GH_FIXTURE="$T/fx" PATH="$T/bin:$PATH" bash scripts/check-releases.sh "$@" ) > "$T/out.txt" 2>&1; printf '%s' $?; }

# ── a listing that FAILED is not a listing of nothing ───────────────────────────────────────
# The sharpest of the four: `gh release list`'s status was discarded, so no auth, the wrong
# repository or no network read as a clean all-clear. Measured 2026-09-05 with this same stub.
setup; echo 1 > "$T/fx/LIST_RC"
rc=$(run)
[ "$rc" = 2 ] && ok || bad "gh failing to list releases exited $rc — a check that cannot read must not exit clean"
grep -q 'not a clean result' "$T/out.txt" \
  && ok || bad "the message on a failed listing does not say nothing was compared"
grep -q 'every one matches' "$T/out.txt" \
  && bad "a failed listing reported that every release matches its entry — green on nothing, which is what facts.md 254 is about" || ok

# ── no releases at all is a fact, and it is not the same fact ───────────────────────────────
setup
rc=$(run)
[ "$rc" = 0 ] && ok || bad "a repository with no releases exited $rc — that is not an error"
grep -q 'no published releases' "$T/out.txt" \
  && ok || bad "a repository with no releases was not told apart from one whose releases all match"

# ── the honest twin: every release matches its entry ────────────────────────────────────────
setup
printf 'v1.0.0\n' > "$T/fx/LIST"
entry 1.0.0 >> "$T/p/CHANGELOG.md"
printf '*2026-01-01*\n\nWhat it does.\n' > "$T/fx/BODY-v1.0.0"
rc=$(run)
[ "$rc" = 0 ] && ok || bad "a matching release was reported as drift"
grep -q '1 release(s) checked, every one matches' "$T/out.txt" \
  && ok || bad "the clean summary does not say how many were checked"

# ── the mutant: a correction added to the entry after the release was published ─────────────
printf '*2026-01-01*\n\nWhat it does.\n' > "$T/fx/BODY-v1.0.0"
printf '# Changelog\n\n## 1.0.0 — 2026-01-01\n\nWhat it does.\n\n> **Correction, 2026-02-02.** It also did this.\n\n' > "$T/p/CHANGELOG.md"
rc=$(run)
grep -q 'DRIFTED' "$T/out.txt" \
  && ok || bad "a correction added to a frozen entry after publication was not reported as drift — which is the whole reason this script exists"
grep -q '1 of 1 release(s)' "$T/out.txt" \
  && ok || bad "the drift summary miscounts what it checked"

# ── a blank line is not drift, or the check cries wolf and nobody reads it ──────────────────
printf '*2026-01-01*\n\n\nWhat it does.\n\n' > "$T/fx/BODY-v1.0.0"
printf '# Changelog\n\n' > "$T/p/CHANGELOG.md"; entry 1.0.0 >> "$T/p/CHANGELOG.md"
rc=$(run)
grep -q 'DRIFTED' "$T/out.txt" \
  && bad "a blank-line difference was called drift — the first version of this flagged 23 of 35 that way" || ok

# ── a release the changelog does not describe is counted, not subtracted ────────────────────
# It printed "3 of 0": `checked` was incremented only after the entry lookup succeeded.
setup
printf 'v9.9.9\n' > "$T/fx/LIST"
rc=$(run)
grep -q '1 of 1 release(s)' "$T/out.txt" \
  && ok || bad "a release with no entry was counted into the drift and out of the total — the summary read 'N of 0'"
grep -q 'no entry named 9.9.9' "$T/out.txt" \
  && ok || bad "a release the changelog does not describe was not named"

# ── --emit is accepted where a person would naturally put it ───────────────────────────────
setup
printf 'v1.0.0\n' > "$T/fx/LIST"
printf '# Changelog\n\n## 1.0.0 — 2026-01-01\n\nWhat it does.\n\n> **Correction.** More.\n\n' > "$T/p/CHANGELOG.md"
printf '*2026-01-01*\n\nWhat it does.\n' > "$T/fx/BODY-v1.0.0"
rm -rf "$T/emit"
rc=$(run acme/thing --emit "$T/emit")
[ -s "$T/emit/v1.0.0.md" ] \
  && ok || bad "\`--emit\` after the repository name wrote nothing — it was recognised only as the first argument, so the natural order silently disabled it"
grep -q 'gh release edit v1.0.0' "$T/out.txt" \
  && ok || bad "the emitted file was not accompanied by the command that uses it"

echo "check-releases: $pass passed, $fail failed"
exit "$fail"
