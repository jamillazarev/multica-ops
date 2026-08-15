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
# The poison carries the anchor PHRASE, because the phrase was the previous anchor and a poison
# that omits it proves nothing: measured 2026-08-15, the old poison walked past this suite 16/16
# while a single sentence containing "of \`multica\` **v…**" defeated every reader in the repo.
cite='> `MUL-0001` narrowed the behaviour of `multica` **v9.9.9**; not swept in.\n\n'
pin_by_name(){ grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+\*\* <!-- cli-pin -->' "$1" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'; }
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
# Assert on the READER, not on the file. `grep -q 'of \`multica\`' <file>` is a substring test over
# the whole document — the same `grp not in recipe` escape this very release deleted from verify.py
# with the words "a gate that reports the claim it was written to check is worse than no gate" —
# and preflight.sh carries that anchor text inside its refusal MESSAGES too, so either of its two
# readers could revert and the assertion would stay green. Measured 2026-08-15 (pass ten).
readers=$(grep -cE '^[[:space:]]*(pinned|pv)=' "$T/c/scripts/preflight.sh")
[ "$readers" -eq 2 ] \
  && ok || bad "preflight.sh has $readers pin readers, not the 2 this assertion is scoped to"
anchored=$(grep -E '^[[:space:]]*(pinned|pv)=' "$T/c/scripts/preflight.sh" | grep -c 'cli-pin')
[ "$anchored" -eq "$readers" ] \
  && ok || bad "$((readers-anchored)) of preflight.sh's $readers pin readers lost the by-name anchor"
grep -E '^[[:space:]]*m_pin' "$T/c/scripts/verify.py" | grep -q 'cli-pin' \
  && ok || bad "verify.py's pin reader lost the by-name anchor"
[ "$(grep -cE 'CLI v\?\(' "$T/c/scripts/verify.py")" -eq 0 ] \
  && ok || bad "verify.py grew a positional fallback under the anchored read again"
grep -E '^[[:space:]]*pinned=' "$T/c/.github/workflows/cli-watch.yml" | grep -q 'cli-pin' \
  && ok || bad "the CI pin reader lost the by-name anchor"

# ...and the behavioural twin, because a shape assertion is not a measurement: put a foreign
# release ABOVE §10, exactly as this release's own MUL-5958 citation did, and require every reader
# to keep returning OUR pin.
true_pin=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+\*\* <!-- cli-pin -->' "$T/c/REFERENCE.md" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
printf '> `MUL-0001` (**v9.9.9** — checked against the release, not swept) does a thing\n\n' \
  | cat - "$T/c/REFERENCE.md" > "$T/c/.ref" && mv "$T/c/.ref" "$T/c/REFERENCE.md"
got=$( cd "$T/c" && python3 -c "
import re
ref = open('REFERENCE.md', encoding='utf-8').read()
m = re.search(r'\*\*v(\d+\.\d+\.\d+)\*\* <!-- cli-pin -->', ref)
print(m.group(1) if m else 'NONE')" )
[ "$got" = "$true_pin" ] \
  && ok || bad "with a foreign release cited above §10, verify.py's reader returned $got, not $true_pin"
got2=$( cd "$T/c" && grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+\*\* <!-- cli-pin -->' REFERENCE.md | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' )
[ "$got2" = "$true_pin" ] \
  && ok || bad "with a foreign release cited above §10, the shell readers returned $got2, not $true_pin"
undo

# ── the eval guard's two halves ─────────────────────────────────────────────────────────────
# Three attempts, two of them plausible one-token fixes that measured wrong — the first read
# `query-source` and MISSED scenario 27, the very void it was named for; the second would have
# blocked six scenarios with 5-7 tracked fixture files. What ships refuses only a scenario with
# NEITHER half. These assert the boundary in both directions, from the runsheet and the module
# rather than from a remembered list, so the sets move with the corpus.
halves(){ # halves <sid> → "repo builder"
  r=$(cd "$T/c" && git ls-files "evals/fixtures/$1" 2>/dev/null | grep -cv 'FIXTURE\.md$')
  b=no; python3 -c "
import sys, importlib.util
spec = importlib.util.spec_from_file_location('f', sys.argv[1])
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
sys.exit(0 if sys.argv[2] in getattr(m, 'BUILDERS', {}) else 1)" \
    "$T/c/scripts/eval-fixture.py" "$1" 2>/dev/null && b=yes
  echo "$r $b"
}
nothing=""; provisioned=""
for sid in $(grep -vE '^#' "$T/c/evals/runsheet.tsv" | awk -F'\t' '$5=="yes"{print $1}' | grep -E '^[0-9]+$'); do
  set -- $(halves "$sid")
  if [ "$1" -eq 0 ] && [ "$2" = "no" ]; then nothing="$nothing $sid"; else provisioned="$provisioned $sid"; fi
done
[ -n "$nothing" ] \
  && ok || bad "no scenario has neither half — the eval guard can no longer fail, so this pair proves nothing"
[ -n "$provisioned" ] \
  && ok || bad "every needs-fixture scenario is unprovisioned — the guard would refuse the whole suite"
# scenario 27 is the named casualty: it must be in the refused set, by measurement not by memory
case " $nothing " in *" 27 "*) ok;; *) bad "scenario 27 is not in the guard's refusal set — it was the void this repair was named for";; esac
# and a scenario with a tracked repository half must NOT be refused
for sid in $provisioned; do
  set -- $(halves "$sid")
  [ "$1" -gt 0 ] || [ "$2" = "yes" ] \
    || { bad "scenario $sid is allowed with neither half"; break; }
done
ok

echo "preflight-checks: $pass passed, $fail failed"
exit "$fail"
