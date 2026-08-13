# Agent entry point

This repository ships one skill: **multica-ops** — a Mops (Executive Advisor) that builds and
runs an autonomous company of AI agents on [Multica](https://multica.ai).

**Using the skill?** Whatever harness you are (Claude Code, Codex, Cursor, Windsurf, Gemini
CLI, …): read **[SKILL.md](skills/mops/SKILL.md)** and follow it. Slash commands are a Claude Code plugin
convenience; every flow works from natural language in any agent — "set up my team", "join
this project", "status", "add a feature: …".

Requires the `multica` CLI on the machine, pointed at a workspace:
`multica setup cloud`, or `multica setup self-host --server-url …` for your own server.

---

## Changing this repository? Read this part.

Two scripts guard it. Run them; they are fast and they have caught real defects:

```sh
bash scripts/preflight.sh            # form: is the documentation well-made?
python3 scripts/verify.py --live     # truth: do the commands and sources still exist?
```

### What the automation cannot check — and what you must therefore read

The scripts verify **shape and existence**. They are blind to whether a paragraph is still
*correct*, and every expensive defect this repo has shipped was of exactly that kind: a
statement that parsed perfectly, linked correctly, and was false. So before you commit,
**read for these six things** — as a human, or as an agent asked to review, but never assume
a green hook covered them.

**1 · Does this contradict another file?** Rules live in several places on purpose (core,
companion, guide template) and drift apart silently. The core once said squad leaders
"never implement" while ROLES made working craft leads out of them; both files were
internally consistent and the pair was wrong. **If you change a rule, grep for it
everywhere** and fix every copy in the same commit.

**2 · Is the framing still the current one?** Text ages by being outrun, not by breaking.
The docs-site introduction described version 1.x long after 2.1 shipped — every sentence
true when written, the whole page misleading. **When you add a capability, ask what page now
describes an older product.**

**3 · Does a claim about the outside world still hold?** `verify.py` checks commands, flags
and URLs. It cannot check that a command still *means* what we say it means: `multica setup`
exists and prints configuration, while our text implied it performs setup. **If a sentence
explains what a tool does, run the tool.**

**4 · Are the numbers still measured?** Any figure about ourselves rots — the guide template
was quoted at ~1.7k tokens after it had grown. One such claim is now checked automatically;
the rest are not. **If you quote a size, a count or a share, re-measure it.**

**5 · Does the example still match the rule?** EXAMPLES.md and the templates demonstrate the
standard the prose describes. Change the standard and the demonstration quietly becomes the
counter-example.

**6 · Is this reachable?** A capability that no command, use case, routing trigger or index
points at does not exist for the agent who needs it. The hook checks command coherence; it
cannot tell that a *concept* has no door.

### Before building anything: does Multica already do it?

This skill is a **methodology on top of a platform that keeps growing**, so the first question
for any new capability is not *how do we build it* but **does Multica already have it**. Check
`multica <group> --help` for every group it might touch, and the docs, *before* designing.
Recording the answer costs a minute; missing it costs a home-grown mechanism that drifts from
the platform and confuses anyone reading both.

This has already bitten twice: agents were created with the **legacy `--visibility`** flag long
after Multica had a real per-agent permission model (and the legacy flag cannot express
"specific people" at all); and the workspace **member roles** — owner · admin · member, with
the invite and removal rules that follow from them — went undocumented here for versions.

Same rule when the platform *lacks* something: say so explicitly, and note the version checked,
so a later reader knows the wheel was deliberate. (`workspace delete` does not exist in the CLI
as of 0.4.8: Mops cannot remove a workspace it created, and must say so rather than promise.)

### When a flow deserves a command — and how one appears

The scripts guard command *coherence* (every table row has a file, is reachable from SKILL and
the `/multica-ops:mops` dispatcher, and has a use case). They cannot judge whether a command should exist
at all, so decide it deliberately, every time you add capability.

**A command is a shortcut for a flow the owner reaches for repeatedly, by name.** Add one when
all three hold: it is **invoked as an action in its own right** (not a phase inside another
flow), it has **a name in the owner's own language**, and **plain language alone reaches it
unreliably**. Do not add one for a one-off step, an internal stage of another flow, or a
synonym — a synonym is an alias on an existing row. A quick job deliberately has none.

**The command appears in the same commit as the capability** — table row, `commands/<name>.md`,
a use case, and a mention in SKILL — or the commit message says plainly why the capability is
*not* getting one. A capability shipped now and given its door later is invisible in between,
which is the same failure as an unreachable one.

### What a capability owes before it ships — four things, and why each one is here

**A capability is not shipped when it is written. It is shipped when it is held, exercised and
measured.** Every item below is here because shipping without it was measured *in this
repository* and produced a release that looked finished and was not. They land in the same
commit as the capability, or the commit message says plainly which one is missing and why.

**1 · If the rule can fail, a form — never a stronger sentence.** Prose does not hold the weak
executor, and this is not an opinion: three rules of one release were measured at **0/5, 0/5 and
0/3** while stated clearly in the always-loaded core. Two were rebuilt as `PreToolUse` refusals
and went to **5/5** each. **A refusal moves the rate; a note does not** — the third was written
as a `PostToolUse` note and did not move it. Before writing the sentence, ask what artifact a
liar cannot fill cheaply, what template leaves a visible hole when omitted, what check refuses.
Where no form exists, say so and put the rule on the named `prose-only` list rather than
believing in it. **And a form is not finished until you have watched it refuse, in the shape the
path it ships on honours** — a flat `permissionDecision` is executed and ignored on the plugin
path while `exit 2` holds, so `check-structure.py` fails the flat shape. The rule and its
measured matrix live in PLAYBOOKS → *A gate is not enforced until you have watched it refuse*,
because it is a company's problem before it is ours; what this section adds is that the same
rule binds the hooks this repository itself ships.

**2 · A mutation test on the form, asserting what it refuses.** A guard that cannot be wrong is
decoration, so each is shown **speaking on the mutant and silent on its honest twin**. The
load-bearing assertion is almost never what the holder does — it is what it *declines* to do: a
migration leaving the craft's own files alone, a gate whose **retry also stops** (the first
outward gate let the second attempt through, and three runs of five simply pushed again), a hook
staying quiet on a repository this skill does not operate. Two traps worth naming, both paid
for: **a guard must not share its sweep's blind spot** — the `docs/` check read the same two
directories the sweep did and confirmed its silence while the always-loaded core kept sixteen
stale paths — and **a suite must own its state directory**, or markers survive between runs and
it passes *less* the more often you run it.

**3 · A scenario, and the fixture that scenario needs.** A behaviour with no scenario has no
regression test; a scenario with no fixture is **unmeasured, not passing**, and `evals/COVERAGE.md`
has a column that says which. Four things a fixture owes, each measured:

- **Both halves.** The repository half *and* the workspace half. With the board built and the
  ground missing, four runs of five answered *"the working directory is empty, could you give me
  more context?"* — correct about the room, nothing to do with the scenario.
- **Rebuilt before every run.** A scenario that acts on its own fixture invalidates every run
  after the first; runs 2–5 once arrived at a workspace the earlier runs had dismantled.
- **A unique name per build for anything the teardown archives.** Archived entities keep their
  names and block re-creation, so the second build silently produces *less* than the first — one
  scenario ran for three rounds with no agent to dispatch to, and scored the skill for it.
- **A teardown that reports its own failure.** The first one printed *"0 issue(s) cancelled"*
  over three live issues, because the verb was wrong and the error was swallowed. It exits
  nonzero and names what it left behind; a probe left in a workspace is indistinguishable from
  real work a month later.

**4 · A door** — the command rule above, unchanged: a capability nobody can reach does not exist
for the agent who needs it.

**And the measurement is only as good as the harness.** A number taken through a broken rig is
worse than no number, because it reads as behaviour. Before trusting a rate, confirm the player
had its own working directory, its own config home, no other MCP servers, the corpus under test
**readable** (the companions sit outside the working directory and were denied for a whole
round), and no answer key in the box. When a defect is found in the rig, **the numbers taken
before the fix are withdrawn, not carried forward**.

### Writing the changelog

The changelog is the migration map `/multica-ops:upgrade` reads, and it is also what a stranger uses to
decide whether to adopt this. Both audiences want the same thing: **what changed for me, and
what must I do differently.**

- **Lead with the capability or the consequence, not the discovery.** "`/multica-ops:import` brings a
  backlog over from Linear" — not "we noticed imports were unhandled".
- **A fix is worth an entry when it changes what a reader should do**: a recipe they may have
  copied, a behaviour they relied on. Say it plainly and briefly, including the remedy.
- **The story of how a defect was found belongs in the commit message**, where the next
  maintainer will look for it. It does not belong in the release notes, and a changelog full
  of self-audit reads as a product made of bugs rather than one kept honest.
- **Never rewrite a released entry's substance.** Versions are public; correct forward.
- **Terse, and grouped.** Compact technical language — the reader wants the delta, not an
  essay. Not every fix earns a paragraph; fold a handful of minor corrections into one line
  (*"several doc and notation fixes"*) rather than a bullet each. Over-granular notes read as
  a product made of bugs.

### When to cut a version

Two artifacts ship from this repo and they version differently. **The docs site deploys
continuously** — a wording, IA or typo fix is a deploy, never a version. **The skill is what
users pull** with `/multica-ops:upgrade`, so a bump is a whole upgrade cycle for them (a re-screen, a
restart, a changelog entry someone reads) — bump it only when a user has a reason to move.

SemVer picks the number: **PATCH** (x.y.Z) a bug fix or correction that changes what a reader
should do · **MINOR** (x.Y.0) a new command, flow or capability · **MAJOR** (X.0.0) a breaking
change (a removed or renamed command, a changed contract).

**Batch, don't drip.** Commit small; tag on a coherent unit of value, not per commit. Pool
small fixes into one patch and let wording/notation/doc-only changes ride the next real
release rather than minting a version each — **the changelog is the upgrade map**, so an entry
must be something a user cares about; a release of "renamed a column" reads as a product made
of noise. The one exception is an **urgent** fix — a real block, a security or data issue —
which ships alone, immediately. (An earlier run of five patch releases in one week was exactly the drip this
rule now prevents.)

### Cutting a release

A version bump is not just a changelog entry. Before you tag:

1. **Refresh the evals, then run them and record the run.** A round is driven by
   `evals/runsheet.tsv` (what the player is told, and whether the situation is workspace state
   that must exist first) and `bash scripts/eval-run.sh <id> <run> "<query>"`, which isolates
   three things or the number means nothing: **a config home of its own** (a shared one lets
   another installed skill answer — measured 2026-08-02), **a copy of the corpus** (the skill is
   frozen for the round), and **the test workspace passed as `MULTICA_WORKSPACE_ID`** rather
   than the profile default. The eval home needs **its own login, once** — credentials are
   keychain-scoped per home, so it never touches the main one, and the runner refuses to start
   without it rather than recording 125 "not logged in" transcripts as results.
   A scenario whose situation is workspace state gets it from
   `python3 scripts/eval-fixture.py <id> build|teardown`, which **builds from nothing every
   time** rather than on top of a previous round, tags everything `EVAL-<id>-` so a sweep finds
   its own litter and nothing else, and **reports what it failed to clean** — teardown verbs
   differ per entity (issues only cancel, agents archive, squads delete) and a teardown that
   cannot say it failed once printed *"0 cancelled"* over three live issues.
   Every new behaviour needs a
   scenario, or it has no regression test — evals go stale silently (2.3 shipped a release
   behind until caught by hand). preflight warns when the version bumped and
   `evals/README.md` didn't. **A minor or major is not tagged without
   `evals/runs/<version>.md`** — date, player and judge tiers, a verdict per scenario with its
   evidence, and `not run` listed rather than omitted (`evals/runs/TEMPLATE.md`). The rubric
   says what should hold; the run record is the only place saying whether it did.
2. **Run the four review lenses** (deletion · adversarial · contradiction · cold-read) on the
   changed skill — they find the class of defect no script can: a sentence that parses, links
   and is false. This is not optional for a minor or major; a patch can skip it.
   **`bash scripts/lens.sh <lens> <base-ref>`** runs one as an isolated headless session — its
   own config home, no connectors, no memory of the session that wrote the corpus, read-only —
   because **the author cannot be the reader who did not write it**. On 0.4.0 the four found
   **sixteen defects with every script green**, including the always-loaded core still pointing
   at the pre-release layout. **State the limit with the result**: this is independent of the
   *session* and not of the *model*, and the rule below still prefers a different provider. A
   lens that exhausts its turn budget reported nothing and is recorded as **not completed** —
   it is indistinguishable from one nobody ran, and the run record says so rather than quietly
   dropping it.
3. **Keep the guards current — they rot too.** **The shipped hooks are tested by mutation** —
   `bash scripts/test-migration-hook.sh` — each rule shown speaking on the mutant and silent on
   its honest twin, because a hook that cannot be wrong is decoration and this one only ever
   *reports*, so its whole value is being right about when it speaks. **So is the layout
   migration** — `bash scripts/test-migrate-layout.sh` — where the load-bearing assertions are
   about what it *refuses* to touch: a project's own `docs/` files staying put, a collision
   named rather than overwritten, a second run doing nothing, a foreign repo left without an
   `_ops/` at all.
   **And the two `PreToolUse` gates** — `bash scripts/test-outward-gate.sh` and
   `bash scripts/test-rule-home.sh`. The outward gate's load-bearing assertion is that **the
   retry does not pass**: the first design stopped once and let the second attempt through, and
   three runs of five simply pushed again. The rule-home gate's is that it stays **silent** on a
   repository this skill does not operate and on a project's own `memory/` directory — a hook
   that fires on someone's own files is one they switch off.
   **And the preflight's own checks** — `bash scripts/test-preflight-checks.sh`: the typo'd date that used to silence the freshness gate, the count rephrase, the stale pin and the URL hidden in the exempt page — each mutant refused in a local clone of HEAD. **And the dispatch note** — `bash scripts/test-dispatch-nudge.sh`, whose four behaviours are silent-below-threshold, speaks-at-it, never-twice, and any real action resets the count. **And so is the map generator** — `bash scripts/test-map-blocks.sh` — where
   the assertion that matters is that `scripts/map-blocks.py` rewrites *only* between its
   markers: a generator that reformats a document it does not own is one nobody dares run. A new capability usually needs a new check, and
   this session's guards were mostly added *reactively*, after a defect shipped. Ask *before*:
   does this change need a guard, or break an existing one's assumption? The rot surfaces are
   the guards' own hardcoded lists — `verify.py`'s `STRUCTURAL`/`IGNORE` object sets and `SMOKE`
   calls, `check-structure.py`'s section-contiguity and command checks, the CLI pin. A guard
   that no longer matches reality passes silently, which is worse than no guard.
4. **Every new capability has a door, or a stated reason it doesn't** — see *When a flow
   deserves a command*. Reachability is guarded; the decision to add a command is not.
   **Then regenerate the coverage map** — `python3 scripts/coverage-map.py` writes
   `evals/COVERAGE.md` from the tree itself: what the corpus says holds each rule, which
   validators, hooks and suites ship, how many scenarios exist and which versions have a run
   record. A hand-kept version of that table lies within a release, so it is generated and
   **no rates are copied into it** — a rate belongs where its date is. Read the output: a new
   holder with no test, or a version with no run, is visible there before it is visible to a
   user.
5. **`bash scripts/preflight.sh`, `python3 scripts/verify.py --live`, and `python3 scripts/fetch-source.py --verify` then `--verify-citations` green** (warnings named) — the last two walk `sources/SOURCES.md` in both directions: the register's live URLs are re-checked, and every `cited-by` is re-checked against the line it points at, since a rewrite moves the claim without touching the register.
6. **Changelog** leads with the capability or the consequence, not the archaeology of how a
   defect was found (that goes in the commit message).

**Then the cut itself, in order — the last two steps were live misses on an earlier release:**

1. **Bump both** — `skills/mops/SKILL.md` frontmatter and `.claude-plugin/plugin.json`; preflight fails on a mismatch.
2. **Changelog + README roadmap** — write the `## x.y.z` section (the map `/multica-ops:upgrade`
   reads), and **remove landed items from the README roadmap, refresh the rest** — it is
   forward-only, so a shipped feature lives in the body and changelog, never as a checked box.
3. **preflight green** — the checklist above.
4. **Merge** — a human merges the release branch (self-editing is locked; the loop adopts *after* the gate).
5. **Tag** the merge commit — **and the tag waits for the owner's word** (the law and its
   reasoning have one home: `CLAUDE.md` → *Versioning*). Everything above this line is
   preparation; nothing below it moves without an explicit yes.
6. **`gh release create`** from that changelog section — a tag alone is **not** a Release, and a stranger deciding whether to adopt this reads the Releases page, not the tag list. (a previous version was tagged with no Release until the owner caught it; created retroactively.) **The title is `x.y.z — <the release's own line>`, with no repository name in front of it.** The Releases page is already scoped to this repo, so the prefix only eats the visible width and truncates the part that carries meaning — every title is a row read top to bottom, and the version plus its one line is what has to survive the truncation. (Both mistakes were made on 0.2.0 in one day: shipped bare as `0.2.0`, then renamed with the prefix, then renamed again without it.)
   **The notes are the changelog entry whole, and its heading collapses to a bare italic date** — `*2026-08-02*`, then the entry. The title already carries the version *and* the release's own line, so repeating the `## x.y.z — date` heading inside the body says both a second time and pushes the first real sentence below the fold; the date is the only thing the title does not carry, so the date is what survives. Not a summary, not a subset: a reader on the Releases page gets what a reader of `CHANGELOG.md` gets. (All seven past releases were retro-fitted in place on 2026-08-07 — one of them had been published carrying the changelog's *file header* instead of its entry.)
7. **Regenerate and push the docs site** — `python3 scripts/generate.py` in the `ai` repo, then push. The site deploys continuously, so a skipped regen silently ships the previous pages against the new tag. (a previous release's site lagged its tag the same way.)
