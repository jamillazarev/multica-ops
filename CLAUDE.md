# This is the skill's own repository

Development of the skill, not use of it. **Reading this from inside another project means the
routing went wrong**: a workspace built *with* the skill carries its own generated guide, and
that guide governs there — this file governs only work on this source tree. Runtimes load a
plugin's skills, never its root guide, so the two cannot meet by accident.

**The full contract is [AGENTS.md](AGENTS.md)** — read it before changing anything of
consequence, and [GLOSSARY.md](GLOSSARY.md) plus [PATTERNS.md](PATTERNS.md) before writing
prose others will read. What follows is the loop this file exists to stop anyone re-deriving
once a session.

**This repository is not a company Mops operates.** It ships the skill; nothing here is a
workspace under migration, so there is no `UPGRADES.md` and none is owed.

## The session loop

1. **Change** — one home per rule, cited from everywhere else, never restated. When a rule
   turns out not to hold, the repair is **a form, not a stronger sentence** — measured here
   more than once. **A capability ships with four things or it ships incomplete**: a form where
   the rule can fail, a mutation test asserting what that form *refuses*, a scenario with the
   fixture it needs, and a door — AGENTS.md → *What a capability owes before it ships*, which
   carries the measurement behind each one. Missing one is a sentence in the commit message
   saying which and why, never a silence.
2. **Lenses** on anything of consequence — deletion · adversarial · contradiction ·
   cold-read — by a reader who did not write it, each reporting even when it found nothing.
   Not optional for a minor or major; a patch may skip them.
3. **Showcase** every new mechanic where a reader will meet it: a **diagram** where the shape
   is the explanation (we draw in mermaid), a **situation** in [USE-CASES.md](USE-CASES.md),
   and a **fact** in [sources/SOURCES.md](sources/SOURCES.md) when the claim is about the
   outside world. A wording-only change owes none of these — say so rather than inventing one.
4. **Checks**, exit codes captured *first* — `cmd > /tmp/out 2>&1; rc=$?` — then read the tail:
   `bash scripts/preflight.sh` · `python3 scripts/verify.py --live` ·
   `python3 scripts/fetch-source.py --verify` then `--verify-citations` ·
   `python3 scripts/tests/test_issues_helpers.py` · and **every shipped guard's mutation
   suite** — `test-migration-hook.sh` · `test-migrate-layout.sh` · `test-outward-gate.sh` ·
   `test-rule-home.sh` · `test-map-blocks.sh` · `test-dispatch-nudge.sh`. Each one's load-bearing assertion is about what
   its holder *refuses*, so a suite left out of this list is a guard nobody re-checks.
   Green is evidence about the corpus, never about behaviour — behaviour is the eval suite's
   job, and **a minor or major is not tagged without `evals/runs/<version>.md`**. Then
   `python3 scripts/coverage-map.py` and *read* `evals/COVERAGE.md`: a holder with no test and
   a version with no run record both show up there first.
5. **Changelog entry** (capability first — it is the migration map `/multica-ops:upgrade`
   reads) → bump every manifest (**the sweep runs inside preflight**, so a straggler fails
   rather than ships) → README roadmap pruned of what landed.
6. **Tag — only on the owner's word** (see *Versioning*), then the **GitHub Release whose
   notes are the entry whole with its heading collapsed to a bare italic date**.
7. **Site**: `cd ~/Dev/ai && python3 scripts/generate.py`, then commit and push that repo
   too. It deploys continuously, so a skipped regen silently ships the previous pages against
   the new tag. A new page-worthy file needs a route in the generator first.
8. **Installs on this machine**: `bash scripts/find-installs.sh`, follow each row's route,
   run it again, and read the **`RESULT:` line** — that line is the canon, not a remembered
   count. Machines differ, installs come and go, and a runtime the script does not know yet
   gets added to it when met.
9. **Memory**: update the project memory file with what shipped and what is owed.

## Versioning

**The tag waits for the owner — every release, its own word.** Everything before it — the
entry, the bump, the checks — is preparation and may land in `main`; **the tag, the GitHub
Release, the site push and the machine re-sync happen only after an explicit yes**, and an
earlier yes does not roll forward to the next version. This is the skill's own law about
outward acts — deploy and announce are owner-confirmed every time — applied to the one
repository where it is easiest to forget.

**Evidence moves without a tag; a rule moves with one.** Run records, eval verdicts and dated
measurements are plain commits. Anything that changes behaviour or format is a release,
however small, so nothing accumulates outside versions.

**Batch, don't drip** — pool small fixes into one patch (AGENTS.md → *When to cut a version*).
The exception is an urgent fix: a real block, a security or data issue ships alone.

## Machine notes

- **A pipe eats the exit code.** `preflight.sh | tail` gates nothing — capture the code
  first, then read the output. Measured next door: a red preflight rode a green pipeline
  into `main`.
- **CI runs on macOS on purpose** — the same tools the release ritual runs on. A badge green
  on a platform nobody releases from is decoration.
- GitHub issues land as triage: read, classify, fix or decline with a reason, and close with
  the reasoning in a comment.
