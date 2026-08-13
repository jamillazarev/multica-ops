#!/usr/bin/env bash
# Mutation tests for the preflight's own checks — the ones a lens found shipping with zero
# coverage ("no test touches preflight at all"). Each check is shown speaking on the mutant
# and silent on the honest twin, in a local clone so the working tree is never touched.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
git clone -q --local . "$T/c"
run(){ ( cd "$T/c" && bash scripts/preflight.sh ) > "$T/out" 2>&1; }
undo(){ ( cd "$T/c" && git checkout -q -- . ); }
pass=0; fail=0
ok(){ pass=$((pass+1)); }; bad(){ fail=$((fail+1)); echo "  ✗ $1"; }

# the twin: an untouched clone passes (warnings allowed, exit 0 required)
run && ok || bad "the untouched twin failed preflight"

# §9b · a typo'd date is reported AND does not kill the loop for the stale row beside it
printf '\n| tf-a | checked 2026-06-31 |\n| tf-b | checked 2024-01-01 |\n' >> "$T/c/STACKS.md"
run; grep -q "is not a date" "$T/out" && ok || bad "a typo'd date went unreported"
grep -q "2024-01-01" "$T/out" && ok || bad "one bad date silenced the stale row beside it"
undo

# §6c · rephrasing the advertised count away is refused, and a wrong number is named
perl -pi -e 's/\d+ stratified eval scenarios/many scenarios, stratified/' "$T/c/README.md"
perl -pi -e 's/the \d+ scenarios/the whole rubric/' "$T/c/README.md"
run && bad "a README with no canonical count phrase passed" || ok
undo
perl -pi -e 's/the (\d+) scenarios/the 12 scenarios/' "$T/c/README.md"
run && bad "a README advertising the wrong count passed" || ok
grep -q "also advertises 12" "$T/out" && ok || bad "the wrong count is not named"
undo

# §1b · a stale pin is refused; an import URL added to the exempt page is refused
perl -pi -e 's{tree/v[0-9.]+/skills/mops}{tree/v0.1.0/skills/mops}' "$T/c/PLAYBOOKS.md"
run && bad "a stale pin in PLAYBOOKS passed" || ok
undo
printf '\nmulica: github.com/jamillazarev/multica-ops/tree/main/skills/mops\n' >> "$T/c/SECURITY.md"
run && bad "a foreign import URL hidden in the exempt page passed" || ok
grep -q "neither the recorded control" "$T/out" && ok || bad "the exempt-page refusal lost its reason"
undo

echo "preflight-checks: $pass passed, $fail failed"
exit "$fail"
