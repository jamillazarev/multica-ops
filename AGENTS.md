# Agent entry point

This repository ships one skill: **multica-ops** — a Mops (Executive Advisor) that builds and
runs an autonomous company of AI agents on [Multica](https://multica.ai).

**Using the skill?** Whatever harness you are (Claude Code, Codex, Cursor, Windsurf, Gemini
CLI, …): read **[SKILL.md](SKILL.md)** and follow it. Slash commands are a Claude Code plugin
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
the `/mops` dispatcher, and has a use case). They cannot judge whether a command should exist
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

### Writing the changelog

The changelog is the migration map `/mops upgrade` reads, and it is also what a stranger uses to
decide whether to adopt this. Both audiences want the same thing: **what changed for me, and
what must I do differently.**

- **Lead with the capability or the consequence, not the discovery.** "`/mops import` brings a
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
users pull** with `/mops upgrade`, so a bump is a whole upgrade cycle for them (a re-screen, a
restart, a changelog entry someone reads) — bump it only when a user has a reason to move.

SemVer picks the number: **PATCH** (x.y.Z) a bug fix or correction that changes what a reader
should do · **MINOR** (x.Y.0) a new command, flow or capability · **MAJOR** (X.0.0) a breaking
change (a removed or renamed command, a changed contract).

**Batch, don't drip.** Commit small; tag on a coherent unit of value, not per commit. Pool
small fixes into one patch and let wording/notation/doc-only changes ride the next real
release rather than minting a version each — **the changelog is the upgrade map**, so an entry
must be something a user cares about; a release of "renamed a column" reads as a product made
of noise. The one exception is an **urgent** fix — a real block, a security or data issue —
which ships alone, immediately. (This repo's own 2.3.1–2.3.5 run was exactly the drip this
rule now prevents.)

### Cutting a release

A version bump is not just a changelog entry. Before you tag:

1. **Refresh the evals.** Every new behaviour needs a scenario, or it has no regression test —
   evals go stale silently (2.3 shipped a release behind until caught by hand). preflight warns
   when the version bumped and `evals/README.md` didn't.
2. **Run the four review lenses** (deletion · adversarial · contradiction · cold-read) on the
   changed skill — they find the class of defect no script can: a sentence that parses, links
   and is false. This is not optional for a minor or major; a patch can skip it.
3. **Keep the guards current — they rot too.** A new capability usually needs a new check, and
   this session's guards were mostly added *reactively*, after a defect shipped. Ask *before*:
   does this change need a guard, or break an existing one's assumption? The rot surfaces are
   the guards' own hardcoded lists — `verify.py`'s `STRUCTURAL`/`IGNORE` object sets and `SMOKE`
   calls, `check-structure.py`'s section-contiguity and command checks, the CLI pin. A guard
   that no longer matches reality passes silently, which is worse than no guard.
4. **Every new capability has a door, or a stated reason it doesn't** — see *When a flow
   deserves a command*. Reachability is guarded; the decision to add a command is not.
5. **`bash scripts/preflight.sh`, `python3 scripts/verify.py --live`, and `python3 scripts/fetch-source.py --verify` green** (warnings named) — the last walks `sources/SOURCES.md` so the register's live URLs are re-checked each release alongside the skill's own sources.
6. **Changelog** leads with the capability or the consequence, not the archaeology of how a
   defect was found (that goes in the commit message).

**Then the cut itself, in order — the last two steps were live misses caught on 2.4.1:**

1. **Bump both** — `SKILL.md` frontmatter and `.claude-plugin/plugin.json`; preflight fails on a mismatch.
2. **Changelog + README roadmap** — write the `## x.y.z` section (the map `/mops upgrade`
   reads), and **remove landed items from the README roadmap, refresh the rest** — it is
   forward-only, so a shipped feature lives in the body and changelog, never as a checked box.
3. **preflight green** — the checklist above.
4. **Merge** — a human merges the release branch (self-editing is locked; the loop adopts *after* the gate).
5. **Tag** the merge commit.
6. **`gh release create`** from that changelog section — a tag alone is **not** a Release, and a stranger deciding whether to adopt this reads the Releases page, not the tag list. (2.4.1 was tagged with no Release until the owner caught it; created retroactively.)
7. **Regenerate and push the docs site** — `python3 scripts/generate.py` in the `ai` repo, then push. The site deploys continuously, so a skipped regen silently ships the previous pages against the new tag. (2.4.1's site lagged its tag the same way.)
