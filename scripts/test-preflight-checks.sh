#!/usr/bin/env bash
# Runs against a LOCAL CLONE of HEAD — an uncommitted edit is exercised one commit late,
# on purpose: the suite tests what ships.
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
wrong=$(( $(grep -cE '^## [0-9]+\. ' "$T/c/evals/README.md") + 1 ))
perl -pi -e "s/the (\\d+) scenarios/the $wrong scenarios/" "$T/c/README.md"
run && bad "a README advertising the wrong count passed" || ok
grep -q "also advertises $wrong" "$T/out" && ok || bad "the wrong count is not named"
undo

# §1b · a stale pin is refused; an import URL added to the exempt page is refused
perl -pi -e 's{tree/v[0-9.]+/skills/mops}{tree/v0.1.0/skills/mops}' "$T/c/PLAYBOOKS.md"
run && bad "a stale pin in PLAYBOOKS passed" || ok
undo
printf '\nmulica: github.com/jamillazarev/multica-ops/tree/main/skills/mops\n' >> "$T/c/SECURITY.md"
run && bad "a foreign import URL hidden in the exempt page passed" || ok
grep -q "neither the recorded control" "$T/out" && ok || bad "the exempt-page refusal lost its reason"
undo

# ── the pin readers, which were this release's headline repair and had zero coverage ───────
# Three commits anchored three readers BY NAME, and the suite added in the same release tested
# none of them — a cold-read reverted both readers in `preflight.sh` to the positional form that
# shipped the defect and this file stayed 9/9 green. The bar this repository sets is a form where
# the repair can fail; these are it. The mechanic under test: a `MUL-####` citation of somebody
# else's release sits ABOVE §10, so `head -1` returns THEIR version as OUR pin.
cite='> `MUL-0001` (**v9.9.9** — checked against the release, not swept) does a thing\n\n'
pin_by_name(){ grep -oE 'of `multica` \*\*v[0-9]+\.[0-9]+\.[0-9]+' "$1" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'; }
pin_positional(){ grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$1" | head -1 | sed 's/^v//'; }
true_pin=$(pin_by_name "$T/c/REFERENCE.md")
[ -n "$true_pin" ] && ok || bad "the by-name anchor reads no pin out of the shipped REFERENCE"
# put a citation of a foreign release at the top of the file, as this release actually did
printf "$cite" | cat - "$T/c/REFERENCE.md" > "$T/c/.ref" && mv "$T/c/.ref" "$T/c/REFERENCE.md"
[ "$(pin_by_name "$T/c/REFERENCE.md")" = "$true_pin" ] \
  && ok || bad "a foreign release cited above §10 changed what the by-name reader returns"
[ "$(pin_positional "$T/c/REFERENCE.md")" = "9.9.9" ] \
  && ok || bad "the positional form no longer demonstrates the defect — this pair proves nothing"
undo
# and every reader of the pin in the repository must use the anchored form, including the one
# in CI that nobody watches: it was byte-identical to the two that were fixed and was missed.
for f in scripts/preflight.sh scripts/verify.py .github/workflows/cli-watch.yml; do
  grep -q 'of `multica`' "$T/c/$f" \
    && ok || bad "$f reads the CLI pin without the by-name anchor"
done
grep -qE "grep -oE 'v\[0-9\]" "$T/c/.github/workflows/cli-watch.yml" \
  && bad "the CI pin reader still holds a positional read" || ok

echo "preflight-checks: $pass passed, $fail failed"
exit "$fail"
