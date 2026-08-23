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
_SQ=$(printf '\047')
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
# `timeout` is NOT part of macOS — it arrives with Homebrew's coreutils, which a GitHub
# macos-latest runner does not have. Measured 2026-08-20: the first CI run of these four assertions
# failed all four with 127, while every local run was green, because this machine has
# /opt/homebrew/bin/timeout on its PATH and the runner does not. Third instance this session of a
# tool the author has and the target does not — after `grep` and `awk`. `--check-only` returns
# before any dispatch, so the timeout was belt-and-braces; it is used when present and skipped
# when not, rather than being a hidden dependency of the suite.
_TMO=$(command -v timeout || command -v gtimeout || true)
_ck(){ ( cd "$T/c" && EVAL_WORKSPACE_ID="${EVAL_WORKSPACE_ID:-probe}" \
         ${_TMO:+$_TMO 90} bash scripts/eval-run.sh "$1" 97 probe --check-only >/dev/null 2>&1; echo $? ); }

# a scenario with NEITHER half must refuse with 4. No live scenario is that void any more —
# 2026-08-21 gave the last five their missing halves (3 · 27 repository, 3 · 11 · 18 · 23
# builders) — so the void is CONSTRUCTED in the clone: strip two builder entries from a
# scenario with no fixtures directory, which is a tracked-file edit `undo` can revert.
# 18 was chosen because it is the scenario the guard was measured missing (pass eleven).
( cd "$T/c" && python3 - <<'VOID'
import pathlib
p = pathlib.Path("scripts/eval-fixture.py"); t = p.read_text()
assert '"11": build_11,' in t and '"18": build_18,' in t
p.write_text(t.replace('"11": build_11,', '').replace('"18": build_18,', ''))
VOID
) || bad "the void could not be constructed — the clone's BUILDERS map has no 11/18 to strip"
[ "$(_ck 18)" = 4 ] \
  && ok || bad "scenario 18 stripped of its builder does not refuse — the void the guard was written for"
[ "$(_ck 11)" = 4 ] \
  && ok || bad "scenario 11 stripped of its builder was allowed to dispatch"
undo
# and the same two, whole, are admitted — the guard sees the halves 2026-08-21 added
[ "$(_ck 18)" != 4 ] \
  && ok || bad "scenario 18 has a builder now and the guard still refuses it as having neither half"
[ "$(_ck 27)" = 0 ] \
  && ok || bad "scenario 27 has a provisioned repository half now and was refused"
# a scenario with both halves must not be refused BY THE GUARD. Its exit is 5 without a live
# workspace, because its builder cannot reach one — so the assertion is on the guard's decision,
# not the build's outcome, or this suite would only pass on a developer's machine with credentials.
[ "$(_ck 9)" != 4 ] \
  && ok || bad "scenario 9 has both halves and the guard refused it as having neither"
# **The assertion that used to sit here could not fail, and is deleted rather than reworded.**
# It broke `build_9` and required exit 5 — but scenario 9's builder fails on any machine without a
# live workspace, which is the CI case and this suite's own stated condition, so 5 arrived whether
# the mutation was applied or not. A test whose two branches return the same value is a green tick
# with no question behind it. Measured 2026-08-21 (pass twelve).
# What replaces it is the pair above, which genuinely disagrees: an unloadable module refuses with
# 6, a healthy one does not. **A builder that RAISES while the workspace is reachable is not
# testable from here**, and that is said rather than faked — it needs credentials this suite
# deliberately does not have.
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


# ── the WRITER's uniqueness guard, invoked ─────────────────────────────────────────────────
# `--regen-cli` carries its own copy of the marker-uniqueness check, and only verify.py's copy was
# ever exercised — so the half attached to the thing that REWRITES the pin could be deleted with
# every suite green. Measured 2026-08-21 (pass twelve). `--regen-cli` refuses without a CLI on
# PATH, which is the CI case, so a stub supplies one: the guard runs before any real CLI call.
_stub=$T/stub; mkdir -p "$_stub"
printf '#!/bin/sh\ncase "$1" in --version) echo "multica 0.4.26";; *) exit 0;; esac\n' > "$_stub/multica"
chmod +x "$_stub/multica"
_regen(){ ( cd "$T/c" && PATH="$_stub:$PATH" bash scripts/preflight.sh --regen-cli ) 2>&1; }
_regen | grep -qc 'markers' >/dev/null 2>&1   # warm the path; the assertion is below
[ "$(_regen | grep -c 'markers, not 1')" = 0 ] \
  && ok || bad "--regen-cli reports a duplicate marker on the honest REFERENCE"
( cd "$T/c" && python3 - <<'DUP'
import pathlib
p = pathlib.Path("REFERENCE.md")
p.write_text("A convention note: the pin is marked **v9.9.9** <!-- cli-pin -->.\n\n" + p.read_text())
DUP
)
[ "$(_regen | grep -c 'markers, not 1')" -ge 1 ] \
  && ok || bad "a SECOND <!-- cli-pin --> marker was accepted by the writer — it rewrites whichever it reads first"
undo

# TWO MARKERS ON ONE LINE. `grep -c` counts matching LINES under the grep a script actually gets,
# so a reflowed line carrying two markers counted as 1, the guard passed, and the rewrite hit
# whichever came first — leaving §10 stale at exit 0, which is the incident the marker exists to
# stop. Measured 2026-08-23; the fourth instance of this class in two days.
( cd "$T/c" && python3 - <<'ONELINE'
import pathlib
p = pathlib.Path("REFERENCE.md"); s = p.read_text()
i = s.index("<!-- cli-pin -->"); j = s.rindex("\n", 0, i)
p.write_text(s[:j] + "\n> also **v0.4.11** <!-- cli-pin --> on this very line" + s[j:])
ONELINE
) || bad "could not plant two markers on one line"
[ "$(_regen | grep -c 'markers, not 1')" -ge 1 ] \
  && ok || bad "two <!-- cli-pin --> markers on ONE line were counted as one — grep -c counts lines"
undo

# ── the fixture probe must give THREE answers, and --check-only must be a flag ──────────────
# `&& has_builder=yes` collapsed "this scenario has no builder" and "the module does not load at
# all" into the same `no`, so a broken eval-fixture.py read as a scenario legitimately lacking a
# builder and the refusal sent the reader to write a builder into a file that cannot be parsed.
# Reading python's own exit status does not separate them either — an unhandled exception exits 1,
# which is also "no builder" — so the probe assigns its codes itself. Measured 2026-08-21.
( cd "$T/c" && printf '\nthis is not python(\n' >> scripts/eval-fixture.py )
[ "$(_ck 11)" = 6 ] \
  && ok || bad "an unloadable eval-fixture.py did not refuse with 6 — it reads as a missing builder"
undo
[ "$(_ck 11)" != 6 ] \
  && ok || bad "a healthy fixture module was reported unloadable"
# and the flag is read from the FLAG positions only, never from $3 — the operator's own query.
# A scenario whose text mentions --check-only would otherwise stop the run and print
# "preconditions ok", which reads exactly like a pass.
_q=$( ( cd "$T/c" && EVAL_WORKSPACE_ID=probe bash scripts/eval-run.sh 27 97 "does --check-only work?" 2>&1 ) | grep -c "preconditions ok" )
[ "$_q" = 0 ] \
  && ok || bad "--check-only inside the operator's query stopped the run and reported preconditions ok"

# ── check 0 counts an INVOCATION, and only an invocation ───────────────────────────────────
# The gate that guards every other gate accepted a MENTION: the interpreter token was allowed
# anywhere on the line, and comments inside a block scalar reached the matcher verbatim. So the
# two ordinary ways a step stops running — commenting it out, and an `echo` that names the suite
# in an instruction — both left this gate green while CI ran nothing. Measured 2026-08-21 (pass
# twelve) by two lenses; three repairs were prescribed and this five-shape matrix chose between
# them. The two honest shapes are asserted too: a gate that fires on everything is not a gate.
# IN THE CLONE, like every other case in this file. The first version edited the real
# working tree's workflow and ran the real preflight — it passed, and it would have left a
# modified workflow behind on any interruption. The file's own header promises the tree is
# never touched; a test that breaks that promise to test something else is not a test.
_c0(){ # <run: body> → 1 if check 0 refuses the suite, 0 if it is satisfied
  ( cd "$T/c" && python3 - "$1" <<'C0PY'
import sys, pathlib
p = pathlib.Path(".github/workflows/preflight.yml"); t = p.read_text()
old = "        run: bash scripts/test-preflight-checks.sh"
if old not in t:
    sys.exit(3)
p.write_text(t.replace(old, sys.argv[1].replace("\\n", "\n"), 1))
C0PY
  )
  n=$( ( cd "$T/c" && bash scripts/preflight.sh ) 2>&1 | grep -c "test-preflight-checks.sh is in scripts/")
  undo
  echo "$n"
}
[ "$(_c0 '        run: bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "check 0 refuses an honest inline invocation"
[ "$(_c0 '        run: |\n          bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "check 0 refuses an honest block-scalar invocation — the idiomatic form"
[ "$(_c0 '        run: echo nothing')" = 1 ] \
  && ok || bad "check 0 stayed green with the step deleted outright"
[ "$(_c0 '        run: |\n          # bash scripts/test-preflight-checks.sh')" = 1 ] \
  && ok || bad "a suite commented out inside a block scalar still counted as invoked"
[ "$(_c0 '        run: echo \"run bash scripts/test-preflight-checks.sh\"')" = 1 ] \
  && ok || bad "a suite named inside an echo counted as invoked — an instruction is not a run"
# Four honest shapes this gate refused until 2026-08-23. Measured against eleven ordinary forms of
# a CI step; seven passed and these four did not, so the gate was failing in both directions at
# once — silent on a commented-out suite before pass twelve, and loud on an ordinary quoted path
# after the anchoring work that fixed it. A gate that cries wolf gets its workflow edited to
# please it, which is how the honest shape becomes the rare one.
[ "$(_c0 '        run: bash \"scripts/test-preflight-checks.sh\"')" = 0 ] \
  && ok || bad "a double-quoted path was refused — an argument is not prose"
[ "$(_c0 "        run: bash ${_SQ}scripts/test-preflight-checks.sh${_SQ}")" = 0 ] \
  && ok || bad "a single-quoted path was refused"
[ "$(_c0 '        run: env CI=1 bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "an env prefix hid the interpreter from the command-position test"
[ "$(_c0 '        run: bash -e scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "a flag between the interpreter and the path was refused"
[ "$(_c0 '        run: echo scripts/test-preflight-checks.sh')" = 1 ] \
  && ok || bad "a bare path after echo counted as an invocation — the relaxation went too far"
# Shell grammar and command wrappers, measured 2026-08-23 by an adversarial lens. `if` and `time`
# are the two commonest ways anyone wraps a suite, and both were refused. These are not a guessed
# vocabulary — they are the language the step is written in.
[ "$(_c0 '        run: if bash scripts/test-preflight-checks.sh; then echo ok; fi')" = 0 ] \
  && ok || bad "a suite inside an \`if\` was read as not invoked"
[ "$(_c0 '        run: if ! bash scripts/test-preflight-checks.sh; then exit 1; fi')" = 0 ] \
  && ok || bad "a negated \`if\` was read as not invoked"
[ "$(_c0 '        run: time bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "\`time\` hid the interpreter from the command-position test"
[ "$(_c0 '        run: exec bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "\`exec\` hid the interpreter"
[ "$(_c0 '        run: xvfb-run bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "a command wrapper hid the interpreter"
# A `#` inside quotes must not eat the rest of the line. Unwrapping quotes before cutting comments
# let it, and inverted the fix's intent: adding a space inside the quotes was what made it pass.
[ "$(_c0 '        run: sed -i \"s/#.*//\" notes.txt \&\& bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "a \`#\` inside quotes truncated the line and hid a real invocation"
[ "$(_c0 '        run: git commit -m \"#123\" \&\& bash scripts/test-preflight-checks.sh')" = 0 ] \
  && ok || bad "a quoted issue number truncated the line"

# ── the CLI-removal registry, and the class that outlived its command ──────────────────────
# Both added 2026-08-23, when `multica plugin` — a group that arrived in 0.4.26 and was made a
# permanent fingerprint class the same day — turned out to be `unknown command` at 0.4.32. Two
# gates were missing in the same direction: nothing noticed a class the CLI had REMOVED (both
# the recipe and the constant were stale, and they agreed), and the gate that DID notice could
# not tell an obituary from a promise, so it refused the repair it was asking for.
if command -v multica >/dev/null 2>&1; then
  _reg(){ # <registry line> → count of `no such command group` refusals
    ( cd "$T/c" && python3 - "$1" <<'RPY'
import sys, pathlib
p = pathlib.Path("REFERENCE.md"); t = p.read_text()
old = "<!-- cli-removed: plugin 2026-08-23 -->"
if old not in t:
    sys.exit(3)
p.write_text(t.replace(old, sys.argv[1], 1))
RPY
    )
    n=$( ( cd "$T/c" && python3 scripts/check-structure.py ) 2>&1 | grep -c "no such command group")
    undo; echo "$n"; }

  [ "$(_reg '<!-- cli-removed: plugin 2026-08-23 -->')" = 0 ] \
    && ok || bad "a group buried in the registry, with a date, was still refused"
  [ "$(_reg '')" -ge 1 ] \
    && ok || bad "a docs mention of a removed CLI group passed with no registry line"
  [ "$(_reg '<!-- cli-removed: plugin someday -->')" -ge 1 ] \
    && ok || bad "an undated registry line was accepted — a burial with no date is not a record"
  [ "$(_reg '<!-- cli-removed: skill 2026-08-23 -->')" -ge 1 ] \
    && ok || bad "burying a DIFFERENT group exempted the one actually mentioned"

  # and the other direction: a class hashed as structure that the CLI no longer has
  _struct(){ ( cd "$T/c" && python3 - "$1" <<'SPY'
import sys, pathlib
p = pathlib.Path("scripts/verify.py"); t = p.read_text()
old = '"property"}                  # workspace shape'
if old not in t:
    sys.exit(3)
p.write_text(t.replace(old, sys.argv[1], 1))
SPY
    )
    n=$( ( cd "$T/c" && python3 scripts/verify.py ) 2>&1 | grep -c "the CLI has no such group")
    undo; echo "$n"; }
  [ "$(_struct '"property", "plugin"}        # workspace shape')" -ge 1 ] \
    && ok || bad "a fingerprint class the CLI no longer exposes was hashed in silence"
  [ "$(_struct '"property"}                  # workspace shape')" = 0 ] \
    && ok || bad "the honest class list was condemned"
else
  echo "  (skipped 6: no multica CLI on PATH — these assert against the live command surface)"
fi

# ── the mention-cost guard flattens a wrapped paragraph and NOTHING else ───────────────────
# It was wrong in both directions within two days. Flattening nothing missed a mutant that
# straddled this corpus's ~98-column wrap; flattening everything matched across headings, blank
# lines and list items, none of which carries a full stop — so honest prose under two unrelated
# headings read as one claim (measured 2026-08-23). Both cases are asserted here so a later
# "simplification" back to `text.replace("\n", " ")` fails instead of passing quietly.
_mc(){ # <file body> → 1 when the guard calls it a free mention
  printf '%b' "$1" > "$T/c/MENTIONPROBE.md"
  ( cd "$T/c" && python3 - <<'MPY'
import pathlib
p = pathlib.Path("scripts/verify.py"); t = p.read_text()
p.write_text(t.replace('scope = sorted(set(DOCS) | set(glob.glob("skills/**/*.md", recursive=True)))',
                       'scope = ["MENTIONPROBE.md"]', 1))
MPY
  )
  n=$( ( cd "$T/c" && python3 scripts/verify.py ) 2>&1 | grep -c "is called free in")
  rm -f "$T/c/MENTIONPROBE.md"; undo; echo "$n"; }

[ "$(_mc 'Remember that mentioning a member or an\nissue in a comment is free and costs nothing.\n')" -ge 1 ] \
  && ok || bad "a retracted rule split by the hard wrap went undetected — the 2026-08-21 mutant"
[ "$(_mc 'Mentioning a member or an issue in a comment is free.\n')" -ge 1 ] \
  && ok || bad "the same claim on one line went undetected"
[ "$(_mc '### Mentioning\n\n- what a mention does to an issue\n\n### Reading the board\n\n- the counters are free\n')" = 0 ] \
  && ok || bad "honest prose under two headings matched as one claim — the flattening crossed a block boundary"
[ "$(_mc '- mentioning a member is the act\n\n- issue counters are free\n')" = 0 ] \
  && ok || bad "two unrelated list items matched as one sentence"
# A heading and a table row are one line by construction; the newline after one is always a
# boundary, blank line or not. Testing only the FOLLOWING line let a heading join the prose
# beneath it — found 2026-08-23 by a cold-read lens, against a docstring that had promised the
# opposite. The wrapped list item below is the case that must still join: it is the whole reason
# any joining happens at all, and a fix that broke it would have traded one blind spot for another.
[ "$(_mc '## Mentioning a member or an issue\nthe counters are free\n')" = 0 ] \
  && ok || bad "a heading joined the prose under it — one line by construction, always a boundary"
[ "$(_mc '| Mentioning a member or an issue | x |\nthe counters are free\n')" = 0 ] \
  && ok || bad "a table row joined the prose under it"
[ "$(_mc '- mentioning a member or an\n  issue in a comment is free.\n')" -ge 1 ] \
  && ok || bad "a claim wrapped inside a list item went undetected — the join that must survive"
# A blockquote that wraps is one thought. REFERENCE alone carries 61 quoted lines, so writing the
# retracted rule as a two-line quote defeated this guard entirely (adversarial, 2026-08-23).
[ "$(_mc '> Remember that mentioning a member or an issue in a\n> comment is free and costs nothing.\n')" -ge 1 ] \
  && ok || bad "the claim written as a two-line blockquote was invisible"
# And the shape the failure message prescribes must PASS, or the gate refuses its own remedy.
[ "$(_mc 'The mention of a member or an issue adds no run of its own.\nAn unassigned issue is free.\n')" = 0 ] \
  && ok || bad "both halves as two sentences was refused — that is the remedy the message asks for"

echo "preflight-checks: $pass passed, $fail failed"
exit "$fail"
