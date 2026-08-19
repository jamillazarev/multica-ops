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

# ...and the behavioural twin INVOKES THE SHIPPED READERS. The previous version retyped the
# marker regex inside this file, so the copy agreed with itself no matter what preflight.sh,
# verify.py or the watcher actually did — a test that cannot see the thing it tests. Measured
# 2026-08-15 (pass eleven). These call `--regen-cli` and `verify.py` for real.
poison(){ printf '%s\n\n' "$1" | cat - "$T/c/REFERENCE.md" > "$T/c/.ref" && mv "$T/c/.ref" "$T/c/REFERENCE.md"; }

# a foreign release cited above §10 — the incident the marker exists for
poison '> `MUL-0001` narrowed the behaviour of `multica` **v9.9.9**; not swept in.'
( cd "$T/c" && python3 scripts/verify.py > "$T/v1" 2>&1 ); grep -q '9\.9\.9' "$T/v1" \
  && bad "verify.py read a cited foreign release as the pin" || ok
undo

# a SECOND marker — every reader takes the first, so this is a second pin
poison 'A convention note: the pin is marked **v9.9.9** <!-- cli-pin -->.'
( cd "$T/c" && python3 scripts/verify.py > "$T/v2" 2>&1 )
grep -q 'markers' "$T/v2" \
  && ok || bad "a second <!-- cli-pin --> marker was accepted — every reader takes the first"
undo

# the reader must require exactly what the writer rewrites, or --regen-cli no-ops and says it
# re-pinned. Asserted on the shipped regexes rather than a retyped copy.
[ "$(grep -E '^[[:space:]]*(pinned|pv)=' "$T/c/scripts/preflight.sh" | grep -cF '\*\*v')" -eq 2 ] \
  && ok || bad "a pin reader does not require the leading ** that the writer's substitution needs"
grep -E '^[[:space:]]*m_pin' "$T/c/scripts/verify.py" | grep -qF '\*\*v' \
  && ok || bad "verify.py's reader does not require the leading ** the writer needs"

# ── the eval guard, INVOKED rather than reimplemented ──────────────────────────────────────
# Nothing ran `eval-run.sh` — not a suite, not a workflow — and the assertions written for its
# fixture guard rebuilt the guard's logic inside THIS file, so the copy agreed with itself no
# matter what shipped. Measured 2026-08-20 (pass eleven); it is the same escape this release
# deleted from the pin assertions. `--check-only` exists so the preconditions can be exercised
# without spending a player turn, which is why they were never exercised.
_ck(){ ( cd "$T/c" && EVAL_WORKSPACE_ID="${EVAL_WORKSPACE_ID:-probe}" \
         timeout 90 bash scripts/eval-run.sh "$1" 97 probe --check-only >/dev/null 2>&1; echo $? ); }

# a scenario with NEITHER half must refuse with 4 — 27 among them, the void this guard was named for
[ "$(_ck 27)" = 4 ] \
  && ok || bad "scenario 27 does not refuse — it is the void the fixture guard was written for"
[ "$(_ck 18)" = 4 ] \
  && ok || bad "scenario 18, which has neither half, was allowed to dispatch"
# a scenario with both halves must not be refused BY THE GUARD. Its exit is 5 without a live
# workspace, because its builder cannot reach one — so the assertion is on the guard's decision,
# not the build's outcome, or this suite would only pass on a developer's machine with credentials.
[ "$(_ck 9)" != 4 ] \
  && ok || bad "scenario 9 has both halves and the guard refused it as having neither"
# and a builder that FAILS refuses with 5, which needs no workspace to demonstrate
( cd "$T/c" && python3 - <<'BRK'
import pathlib
p = pathlib.Path("scripts/eval-fixture.py"); t = p.read_text()
p.write_text(t.replace("def build_9(sid):", "def build_9(sid):\n    raise SystemExit(3)", 1))
BRK
)
[ "$(_ck 9)" = 5 ] \
  && ok || bad "a builder that raises did not refuse the run with exit 5"
undo
# and one with a repository half and no builder runs, warned — refusing it would call the rig broken
[ "$(_ck 5)" = 0 ] \
  && ok || bad "scenario 5 has a provisioned repository half and was refused"

# ── check 0 must see an invocation, and only an invocation ─────────────────────────────────
# Four findings from pass eleven met here: it read only lines BEGINNING with `run:`, so a `run: |`
# block — the idiomatic form — was invisible; it was a bare substring test, so a suite named in an
# `echo` passed; it swept `test-*.sh` only, so deleting the verify.py step went unnoticed; and its
# `grep … | grep -q` carried this repo's own documented pipefail trap (rc=141 on a large input with
# an early match, read as "no match" — an accusation that CI does not run a suite it runs).
_step(){ python3 - "$T/c/.github/workflows/preflight.yml" "$1" <<'PY2'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); t = p.read_text()
old = """      - name: the preflight's own checks — each mutant denied, each twin passing
        run: bash scripts/test-preflight-checks.sh"""
p.write_text(t.replace(old, sys.argv[2], 1))
PY2
}
_fires(){ ( cd "$T/c" && bash scripts/preflight.sh 2>&1 || true ) | grep -c "test-preflight-checks.sh is in scripts"; }

_step '      # we used to run scripts/test-preflight-checks.sh'
[ "$(_fires)" -eq 1 ] && ok || bad "a suite named only in a workflow COMMENT was accepted as run by CI"
undo
_step '      - name: noise
        run: echo "we should add scripts/test-preflight-checks.sh one day"'
[ "$(_fires)" -eq 1 ] && ok || bad "a suite merely NAMED inside an echo was accepted as run by CI"
undo
_step '      - name: suites
        run: |
          echo starting
          bash scripts/test-preflight-checks.sh'
[ "$(_fires)" -eq 0 ] && ok || bad "a suite invoked inside a 'run: |' block was reported as not run"
undo
# and the sweep must cover gates, not only suites
perl -0pi -e 's{      - name: verify[^\n]*\n        run: python3 scripts/verify\.py\n}{}' "$T/c/.github/workflows/preflight.yml"
( cd "$T/c" && bash scripts/preflight.sh 2>&1 || true ) | grep -q 'verify.py is in scripts' \
  && ok || bad "deleting the verify.py CI step went unnoticed — the sweep covers suites only"
undo

echo "preflight-checks: $pass passed, $fail failed"
exit "$fail"
