<p align="center">
  <img src="assets/mops-docs.png" alt="Mops — your Executive Advisor" width="250">
</p>

<h1 align="center">multica-ops</h1>

<p align="center">
  Meet <b>Mops</b> 🐶 — the pug behind the ops. One word gets you everything:<br>
  just say what you need — or <code>/multica-ops:status</code>
</p>

<p align="center">
  <a href="https://ai.jamillazarev.com/skills/multica-ops/overview"><img alt="Docs" src="https://img.shields.io/badge/docs-ai.jamillazarev.com-black"></a>
  <a href="https://ai.jamillazarev.com/skills/multica-ops/changelog"><img alt="Release" src="https://img.shields.io/github/v/release/jamillazarev/multica-ops?color=black"></a>
  <a href="LICENSE"><img alt="Apache-2.0" src="https://img.shields.io/badge/license-Apache--2.0-black"></a>
</p>

**Your Executive Advisor for [Multica](https://multica.ai)** — a skill that builds and
runs an autonomous company of AI agents: meets you at whatever you have — a blank slate, a live workspace, a Linear backlog, or just
a list of tasks — and routes you without making you pick a command. It shapes the work before
staffing it, runs a full company (conductor/PM, squads, skills, gates) **or** a plain crew
with no manager when that's all you want, and stays your console: status, recovery after
limits, features, roadmap, hiring, upgrades.

## Install

**Every route below was run end to end — measured, not assumed** (the harness installs on
2026-07-31, the Multica import re-measured 2026-08-01).

**Any agent (universal, via [skills.sh](https://skills.sh)):**
```sh
npx skills add jamillazarev/multica-ops
```
The installer detects your harnesses and installs where you choose — Claude Code,
Cursor, Codex, Windsurf, Gemini CLI, Copilot, Cline, opencode, Zed and more. It lands the
corpus in **`~/.agents/skills/multica-ops`** and symlinks it into each harness that reads
its own path.

**Claude Code as a plugin (slash commands):**
```sh
claude plugin marketplace add jamillazarev/multica-ops
claude plugin install multica-ops@multica-ops
```
Two commands, two steps. **In-session, `/plugin` opens the same thing as a menu** — there,
paste **only the source** (`jamillazarev/multica-ops`) into its *Add Marketplace* field, then
install from the list; pasting both lines into that one field is an error it hands straight
back. **Pick one route per harness, not both.** The **plugin manifest (`.claude-plugin/`) sits at
the repository root** while the corpus sits in `skills/mops/`, and a skills.sh install names the
*repository* rather than a folder — so it copies the manifest along with everything else, Claude
Code sees two plugins of one name, and **the installed plugin wins while the copy reads "not
loaded"** (measured 2026-07-31). That is the tidy case: no duplicate commands, and the skills.sh
copy still serves every *other* harness from `~/.agents/skills/`. Remove
`~/.claude/skills/multica-ops` if you want the message gone.

**Gemini CLI · Google Antigravity · Codex** — the same directory carries their manifests:
```sh
gemini extensions install https://github.com/jamillazarev/multica-ops
```
For Antigravity, place the repository at `~/.gemini/config/plugins/multica-ops/`; `rules/` keeps
the four owner-gated kinds always-on there, and `GEMINI.md` does the same for Gemini CLI. Codex
reads `.codex-plugin/plugin.json`. **All of these need a shell that can run the `multica` CLI** —
without it the skill loads but cannot act, which is worth knowing before you install it somewhere
it cannot work. Verification per runtime: see the table in this file's install notes.

**Into a Multica workspace (as an agent skill):**
```sh
multica skill import --url github.com/jamillazarev/multica-ops/tree/v0.3.2/skills/mops
```
**The URL must point at the folder that contains `SKILL.md` — here, `skills/mops`.** The
repository root does not work: it answers *"The Multica service is temporarily unavailable
(server error)"*, which is the CLI mislabelling a 502 (`--debug` shows the truth). Measured all
three ways on 2026-08-01 — the root failed, `…/tree/main/skills/mops` imported, and
`…/tree/v0.1.0/skills/mops` imported with `"ref": "v0.1.0"` recorded in its origin block.
**The line above pins a tag rather than `main` on purpose**: an import becomes agent
instructions, so a moving ref means the content behind your agents can change without you
moving. A tag cannot. Preflight fails if this line drifts from the released version.

Then just say what you need. In Claude Code the commands arrive **namespaced** —
`/multica-ops:status`, `/multica-ops:ship`, and `/multica-ops:mops <anything>` as the free-text
front door — because that is how plugin commands always work: the prefix is what stops two
plugins colliding over one verb. Everywhere else — Cursor, Codex, Windsurf and the rest — there
are no slash commands and none are needed: plain language reaches every flow, and so does the
plain word ("mops, status").

### First run — you don't need to know a command

Say what you're making, or just type **`/multica-ops:mops`** on its own (or "hi", or "where do I
start?"). That is the front door, not an error: Mops checks your setup — installed · signed
in · a workspace · daemon up · runtimes — reports it as one list with the fixes, then asks
three questions and routes you itself. Nobody picks a command.

The ways in, if you like to see them:

| You have | You want | You get |
|---|---|---|
| nothing yet | a team | **`/multica-ops:init`** — the work is shaped first, then staffed |
| a Multica workspace | it continued | **`/multica-ops:join`** — audit, then fixes in batches you approve |
| a backlog in Linear/Jira | it moved here | **`/multica-ops:import`**, then crew mode |
| a question, nothing to build | an answer, not a company | **`/multica-ops:consult`** — advice, no machinery unless it leads there |
| a list of tasks, no tracker | them done, you set the order | **`/multica-ops:mops crew`** — executors and gates, no PM layer |
| one job, no team | it done | a **quick job** (`/multica-ops:quick`) — three questions, no machinery |

### Updating

Ask Mops **"is there a new version?"** or run **`/multica-ops:upgrade`**. Mops fetches the new bytes
itself (it has your shell). **New content applies the next time a file is read** — you only need to
**restart Claude Code** when the update adds or renames a command, or changes a hook, since those
are registered at session start — **and Mops reads the changelog, so it tells you which case this
one is** rather than leaving you to guess. (Restarting doesn't lose the conversation: `claude --continue`
resumes it, at the cost of re-reading it into context.)

It then migrates your workspace, re-screens imported skills, and offers the CLI update
**only when the team is idle**. *Update* = new bytes arrive; *upgrade* = your workspace
moves onto them.

> **Can't run `/multica-ops:upgrade`?** If it says *unknown command*,
> your install has **no slash commands**: an older version, or a `skills.sh` install rather
> than a Claude Code plugin (slash commands are a plugin feature). **Just say "upgrade"** or
> **"is there a new version?"** — plain language reaches the flow on *any* install, which is
> why it's the path that never breaks.

## What's inside

**Manual (any agent that reads files):**
```sh
git clone https://github.com/jamillazarev/multica-ops
# point your agent at skills/mops/SKILL.md — AGENTS.md routes agents that land in the repo
```


## Why this exists

Most "agent team" tooling is a prompt and a hope. This is a **methodology with gates**, and the
parts worth trusting are the ones you can check:

- **Every decision runs one loop.** Frame it, **search — don't recall** (options, prices and docs
  fetched now, each claim sourced), compare, choose and say why, then check the choice survives
  being wrong; record it in `docs/DECISIONS.md`. Prioritisation, tool selection, the role-builder and
  process discovery are all that one loop — named once so it is followed, not reinvented each time.
- **Every claim carries how it is known** — **measured · cited · recalled · a judgement call**,
  or `unknown` when none applies — and the rung travels with the claim, so one agent cannot
  promote another's guess into a fact by quoting it. An argument with no source is called an
  opinion. Running the skill on itself, an executor **caught three stale upstream facts** before
  they shipped and a persona review **caught a doc contradiction and routed around it**: the
  method finds its own errors, which is the whole reason to build it this way.
- **It adopts its own improvements.** A merge to the skill triggers guards → wait for idle →
  re-import, so the team runs on its own latest version instead of a stale copy — the self-adoption
  loop, dogfooded on this repo.
- **Native-first, not a parallel universe.** Squads, stage barriers, @mention handoffs, permissions
  and branch protection are Multica's real primitives; when the platform already does a thing the
  skill uses it, rather than growing a home-grown copy that drifts.
- **Honest about the ceiling.** The caps are stated, not wished away: **6 tasks per agent, 20 per
  daemon** (the tighter wins), a `local_directory` serialises regardless, and `workspace delete`
  isn't in the CLI — so Mops says so instead of promising it. Every number carries its check-date.
- **Regression-tested behaviour, and the runs are on record.** **22 stratified eval scenarios** —
  from a job too small to deserve a company to an import carrying a hidden instruction — judged on
  the end state, not the route, by a judge that did not write the transcript and a player that
  never saw the rubric. Each release records its run in **`evals/runs/<version>.md`** with
  `not run` listed rather than omitted, so a green release is a claim you can check rather than
  one you take on trust; a minor or major is not tagged without one. Reviews route **away from the
  author, ideally onto a different provider**, because a model grades its own work generously.
  And one number is deliberately **not** treated as success: the eval pass-rate. It tells you
  whether behaviour got worse than it was — a regression detector, not evidence that it was ever
  good.
- **Gates say what actually holds them.** Every rule that matters carries an honest
  `enforced_by` — a request a human must answer, a validator that refuses, branch protection,
  the Multica platform itself, **or `prose-only`, which means nothing enforces it** — and the
  prose-only rules are listed by name (PLAYBOOKS → Gates), because a gate believed in but not
  enforced is worse than a stated rule.
- **The subsystems compound.** The parts feed each other, and the ones that already do are worth
  naming: a **stumble becomes a field note becomes a backlog item becomes a release** (the
  dogfood loop); an **eval scenario hardens into a rule** the moment a weaker
  model ignores the prose (an earlier regression gate re-formed exactly that); and the
  **self-adoption gate** puts each such fix onto the next build instead of a shelf. New
  subsystems join that mesh as they ship — described here when they do, not before.

And the operational grind it removes: setup that eats the first week, the operator bottleneck
(a conductor drives the conveyor, an optional resident Mops covers when you're away), session
limits that stall silently, teams that can't grow themselves, knowledge scattered across chats,
a backlog stranded in Linear/Jira, and one-size machinery forced onto a job that didn't want it —
each is a capability below, not a promise here.


## It finds the right *process*, not just the right tool

Ask it to design an app and it doesn't guess: it researches how that craft actually works —
information architecture, user flows, low-fi wireframes, **your approval of the structure**, then
high-fidelity screens composed from a real component library rather than hand-written HTML — shows
you the process so you can cut or add steps, and finds a skill or tool for each. The same
**process discovery** runs for a launch, a migration or a content pipeline: anywhere there is a
"how", so the team doesn't improvise and hand you gradient placeholders. And the design gate
*rejects* bad work instead of rubber-stamping it — Mops never signs off design itself, you do, at
the checkpoint your control level set.

## Two seats, one advisor

Mops is **one advisor with one name**, reachable in two places. **In the CLI** — where you build:
full machine reach (shell, git, the `multica` CLI, deploy), instant chat, its own quota. **In
Multica** — an optional resident agent carrying this same skill, present in the workspace while
you are away from the console: async, sharing the team's session limit, best for status, `@Mops`
advice on an issue, and being the escalation vertex. They do not share live chat memory and you
cannot write into an agent's chat, so **the bridge is written state** — the repo and issue
comments. The test that keeps it honest: the project must rebuild from repo + workspace alone.

## Works beyond Claude Code

The skill is plain **SKILL.md + markdown** — the Agent Skills convention. The
[skills.sh](https://skills.sh) installer puts it into Claude Code, Cursor, Codex, Windsurf,
Gemini CLI, Copilot and the rest of the skills.sh roster; `AGENTS.md` routes any agent that
lands in the repo. Slash commands are a Claude Code plugin bonus (namespaced: `/multica-ops:mops …`) — everywhere else,
natural language runs the same flows. Listing on skills.sh is automatic: it appears
via telemetry on the first `npx skills add jamillazarev/multica-ops`.

> Note on layout: the corpus lives at **`skills/mops/SKILL.md`**, one folder per verb beside it
> (`skills/init/`, `skills/ship/`…) — the plugin layout Claude Code specifies, where **the folder
> name becomes the command**: `skills/init/` is `/multica-ops:init`. A single `SKILL.md` at the
> repository root is the *one-skill* form, and it silently suppresses every other command — which
> is exactly the defect this layout fixes (measured 2026-07-31). None of this is related to the
> *workspace monorepo* the skill recommends for YOUR projects (`apps/ site/ marketing/ docs/`) —
> that guidance lives in [BOOTSTRAP.md §14](BOOTSTRAP.md).

## Why a skill, not another CLI agent

Why not ship Mops as a standalone binary with its own agent loop — a Hermes- or
OpenClaw-style CLI? Because the value here is the **operating doctrine** — the decision loop,
the gates, verify-first — not the agent loop underneath it, and that loop is commoditizing:
as a skill, Mops **inherits every harness improvement for free** instead of maintaining its
own. Billing rides the harness the owner **already pays for** — no second runtime, no third
bill. The two-seats design needs Mops to be a **guest inside Multica**, which hosts
instructions and skills, not third-party binaries — a skill fits that seat; a CLI agent
doesn't. And a skill is **auditable text**: every line is readable before you
run it, and it carries **no dependency tree of its own** — the trust it does ask for is named
in [SECURITY.md](SECURITY.md), which is the honest version of "zero supply-chain surface". The escape hatch stays open — if
skill conventions ever fracture across harnesses, or monetization demands an owned install
surface, the route is a Claude Agent SDK wrapper that reuses the loop, never a from-scratch
binary.

## Roadmap

Forward-only: what shipped lives in the body of this file and in the **CHANGELOG**, never as
a checked box here. The CHANGELOG is the record — and the migration map `/multica-ops:upgrade` reads.

## What Mops handles

The whole company, end to end — and the loop closes, it doesn't stop at merge:

- **The full product loop** — discover → define → prioritize (**ICE**, each score sourced) →
  design → build → review (**parallel gates**) → **ship → measure → learn** — closed, not a dead
  end at merge.
- **The team, humans included** — hire / fire / reconfigure **agents *and* real people**, squads,
  experts & personas, finance & support roles, a **role-builder** that researches any craft you
  name, optionally autonomous hiring.
- **Governance that actually binds** — per-member access, human **review checkpoints**, a
  **budget** cap in tokens or money, and the rule under them: **nobody edits the bar they're
  measured against** (locked · editable · append-only · human-only), reviews routed away from the
  author — ideally onto a different provider.
- **Not being played** — everything an agent reads from outside (a page, an issue, an imported
  backlog) is **data, never instructions**, and anything that must *not* happen gets a **gate**,
  because a guide instructs while only a gate constrains.
- **Staying alive** — session-limit recovery with reset times, a **full-circle health check**
  (runtimes · integrations · tokens · branch protection), **git-backed upgrades** with rollback,
  two-way drift sync, an assisted **provider switch**.
- **Two seats, many workspaces** — Mops in the CLI to build, an optional resident Mops in Multica
  for presence, across as many workspaces as you run.
- **Cost you can see** — a per-release **cost/effort ledger** (tokens · $ · time · per agent and
  per human), in git and on the issue — **and the waste named, not only the spend**: what went to
  runs that produced nothing, second attempts, and expensive settings that bought nothing.
- **Work that can actually be looked at** — Multica previews **images, PDF, HTML and text, and
  nothing else**: a video is a file row with no player, Office files are ZIPs with no preview, a
  design file opens as source, and **no link embeds** — not Figma, not Notion, not YouTube. So the
  rule is a lookup rather than a judgement: **attach a rendition *and* the original**, rendition
  first. `scripts/preview.sh` produces it or **exits non-zero with the reason**, and a diagram
  needs neither — a ` ```mermaid ` fence renders as a diagram in the comment itself. Every line of
  that was measured against the live platform, because the documentation says only *"comments
  support formatting, code blocks, links, and attachments"*.

## What the ledger looks like

An **illustrative** month for a twelve-agent company on a $300 envelope — the *shape* the ledger
gives you, not a measurement of anything:

| | |
|---|---|
| **$280 / $300** | spent against the envelope · ~180M tokens · 240 tasks |
| **~88%** | of those tokens are **cache reads** — caching carries ~72% of the bill |
| **per agent** | who burned what is itemized, so an expensive role is visible rather than suspected |
| **per feature** | model and service cost divided by what actually shipped |

Every number above is made up to show the columns; **your numbers come from `issue usage` and
`runtime usage`** at list prices, written into `docs/analytics/<release>.md` and onto the issue,
so *"what did this feature cost"* has an answer. A shrinking budget re-proposes the stack instead
of only raising an alarm.

## How you would know it is working

**Success here shows up as an absence.** Nothing was decided twice. Nothing was rebuilt that was
already built. No bill arrived that nobody saw coming. Nobody asked *"who chose this, and why?"*
and got silence. A system like this is invisible when it works and obvious when it fails — which
is exactly why it is tempting to measure something showier instead. The tests worth being judged
on:

- **Can a stranger continue?** Hand the repo + workspace to someone who was not there, give them
  a task. If they can pick it up without asking what was meant, the record is real.
- **Did the dead run resume?** Of the runs that hit a limit: how many came back and finished
  **without redoing work that was already applied**. That claim is on the box.
- **Is the waste share falling?** Cost is sliced so *spent on work that produced nothing* is a
  number, not a feeling. Over time it should go down.
- **How often do you go behind it?** Re-reading the diff because you don't believe "done",
  recounting the cost, re-checking the board — each is a failure even when every gate is green,
  because **a console you audit is not a console**.

## Known limits

Stated rather than wished away, each with its check-date where it can move:

- **Platform caps**: 6 tasks per agent, 20 per daemon (the tighter wins); a `local_directory`
  resource **serialises regardless** of how wide you fan out.
- **`workspace delete` is not in the CLI** — Mops says so instead of promising it.
- **Autopilot failures are silent** — no auto-retry, no inbox post; run them in `create_issue`
  mode and subscribe the owner, or a broken one goes unnoticed indefinitely.
- **Start dates are enforced by the team, not the platform** — nothing stops an agent beginning
  early except the guide rule and the conductor's check.
- **Some rules are prose-only** — nothing enforces them, and they are listed by name
  (PLAYBOOKS → Gates) rather than left to be believed in.

## What's inside

| File | Purpose |
|---|---|
| [SKILL.md](skills/mops/SKILL.md) | **the always-loaded core** — interview → stand up → conveyor → console |
| [INSTALL.md](INSTALL.md) | getting started, step by step — install, day zero, first run, updating |
| [SECURITY.md](SECURITY.md) | what this reaches, what is gated, what is `prose-only` — written for whoever audits it |
| [scripts/preview.sh](scripts/preview.sh) | makes a file visible in Multica, or refuses with a named reason — the attachment rule as a script rather than a request |
| [GLOSSARY.md](GLOSSARY.md) | one word, one meaning — and the pairs that look alike and are not |
| [PATTERNS.md](PATTERNS.md) | the recurring forms, named once — a rule that instantiates one cites it and stops |
| [USE-CASES.md](USE-CASES.md) | situation → what to say → which command |
| [EXAMPLES.md](EXAMPLES.md) | worked examples — the same issue, handoff, review or ledger done weakly and done well |
| [COMMANDS.md](COMMANDS.md) | every command, its aliases and the surface it runs best on |
| [STACKS.md](STACKS.md) | services, libraries, audio/DSP, testing, security, reference galleries |
| [MODULES.md](MODULES.md) | opt-in modules: design work · design system · brand · persona theatre · tracker bridge · HQ |
| [FLOWS.md](FLOWS.md) | the full procedures for `/multica-ops:init`, `/multica-ops:join`, `/multica-ops:mops health`, `/multica-ops:upgrade`, `/multica-ops:mops switch` |
| [BOOTSTRAP.md](BOOTSTRAP.md) | zero-to-team CLI recipes, capacity levers, real-hours traps |
| [ROLES.md](ROLES.md) | role catalog with curated skill packs + generic role-builder |
| [PLAYBOOKS.md](PLAYBOOKS.md) | daily operations, copy-paste ready |
| [REFERENCE.md](REFERENCE.md) | object model, anti-patterns, **CLI surface (§10)**, **frameworks (§11)** |
| [WORKFLOW.md](WORKFLOW.md) | Mermaid diagrams of the whole process |
| [CHANGELOG.md](CHANGELOG.md) | versioned history — the migration map for `/multica-ops:upgrade` |
| [BUDGET template](templates/BUDGET-template.md) | envelope · currency · credits with expiries · prices on record |
| [evals/](evals/) | stratified scenarios — from a job too small to deserve a company to an import carrying a hidden instruction — plus `runs/`, the recorded verdicts per release |
| [templates/](templates/) · [scripts/](scripts/) | guide · roadmap · brand · component docs · **decisions log · architecture map · tooling register · team roster** · **a docs guard for the companies Mops builds** · ops helpers · **resumable backlog import** |

Contributing? Run **`bash scripts/preflight.sh --install`** once. The pre-commit hook holds
the invariants that this repo has actually broken before: version sync, the CHANGELOG entry
(it is the migration map for `/multica-ops:upgrade`), README completeness, internal links, one-level-deep
references, the token budget on the always-loaded core, command↔file↔dispatcher coherence,
use-case coverage, and — via **`scripts/check-structure.py`** — table column counts, list
indentation, words a reflow tool broke across lines, counts that no longer match their list,
mermaid blocks that don't close, skeleton files with no template, repeated sentences, and
every `multica …` command the docs promise actually existing in the installed CLI.

What the hook cannot do is check whether a claim is still **true**. That is
**`scripts/verify.py`**, run against the world rather than the text:

```sh
python3 scripts/verify.py             # every documented command + flag exists in the CLI
python3 scripts/verify.py --sources   # every URL and skill-pack source still resolves
python3 scripts/verify.py --live      # the read-only CLI surface actually runs and parses
```

`--live` executes reads only — never a create, update, assign or delete — so it is safe to
run against a real workspace, and it is where a changed output format or a broken pagination
assumption shows up before a user finds it. Whether a *paragraph* is still true stays a
reading job; these two scripts remove the mechanical excuses for it going stale.

Everything but `skills/mops/SKILL.md` loads **only when its trigger fires** — the skill keeps its
always-on footprint small (see the load-routing table in SKILL.md).

Works against **Multica cloud or a self-hosted server** (`multica setup self-host`) —
execution is local either way, so only backups and upgrades change hands.

Verified with `multica` CLI v0.4.12. Code is **[Apache-2.0](LICENSE)**; the names "Mops" /
"multica-ops" and the avatar are reserved — see **[TRADEMARKS.md](TRADEMARKS.md)**.
