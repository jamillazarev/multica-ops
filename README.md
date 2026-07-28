<p align="center">
  <img src="assets/mops-docs.png" alt="Mops — your Executive Advisor" width="250">
</p>

<h1 align="center">multica-ops</h1>

<p align="center">
  Meet <b>Mops</b> 🐶 — the pug behind the ops. One word gets you everything:<br>
  just say what you need — or <code>/mops status</code>
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

**Any agent (universal, via [skills.sh](https://skills.sh)):**
```sh
npx skills add jamillazarev/multica-ops
```
The installer detects your harnesses and installs where you choose — Claude Code,
Cursor, Codex, Windsurf, Gemini CLI, Copilot, Cline, opencode, Zed and more.

**Claude Code as a plugin (slash commands):**
```sh
claude plugin marketplace add jamillazarev/multica-ops
claude plugin install multica-ops@multica-ops
```

**Into a Multica workspace (as an agent skill):**
```sh
multica skill import --url github.com/jamillazarev/multica-ops
```

Then just say what you need. In Claude Code you also get slash commands — namespaced as
`/multica-ops:mops`, plus a short **`/mops`**: the plugin's hook installs it on first run, and
on a skills.sh install (where plugin hooks never fire) **Mops creates the same file itself the
first time you talk to it** (one file in your own config; `rm ~/.claude/commands/mops.md`
removes it). Everywhere else — Cursor, Codex, Windsurf and the rest — there are no slash
commands and none are needed: plain language reaches every flow, and so does the plain word
("mops, status").

### First run — you don't need to know a command

Say what you're making, or just type **`/mops`** on its own (or "hi", or "where do I
start?"). That is the front door, not an error: Mops checks your setup — installed · signed
in · a workspace · daemon up · runtimes — reports it as one list with the fixes, then asks
three questions and routes you itself. Nobody picks a command.

The ways in, if you like to see them:

| You have | You want | You get |
|---|---|---|
| nothing yet | a team | **`/mops init`** — the work is shaped first, then staffed |
| a Multica workspace | it continued | **`/mops join`** — audit, then fixes in batches you approve |
| a backlog in Linear/Jira | it moved here | **`/mops import`**, then crew mode |
| a question, nothing to build | an answer, not a company | **`/mops consult`** — advice, no machinery unless it leads there |
| a list of tasks, no tracker | them done, you set the order | **crew mode** — executors, no PM layer |
| one job, no team | it done | a **quick job** (`/mops quick`) — three questions, no machinery |

### Updating

Ask Mops **"is there a new version?"** or run **`/mops upgrade`**. Mops fetches the new bytes
itself (it has your shell). **New content applies the next time a file is read** — you only need to
**restart Claude Code** when the update adds or renames a command, or changes a hook, since those
are registered at session start — **and Mops reads the changelog, so it tells you which case this
one is** rather than leaving you to guess. (Restarting doesn't lose the conversation: `claude --continue`
resumes it, at the cost of re-reading it into context.)

It then migrates your workspace, re-screens imported skills, and offers the CLI update
**only when the team is idle**. *Update* = new bytes arrive; *upgrade* = your workspace
moves onto them.

> **Can't run `/mops upgrade`?** If it — or `/multica-ops:upgrade` — says *unknown command*,
> your install has **no slash commands**: an older version, or a `skills.sh` install rather
> than a Claude Code plugin (slash commands are a plugin feature). **Just say "upgrade"** or
> **"is there a new version?"** — plain language reaches the flow on *any* install, which is
> why it's the path that never breaks.

## What's inside

**Manual (any agent that reads files):**
```sh
git clone https://github.com/jamillazarev/multica-ops
# point your agent at SKILL.md — AGENTS.md routes agents that land in the repo
```


## Why this exists

Most "agent team" tooling is a prompt and a hope. This is a **methodology with gates**, and the
parts worth trusting are the ones you can check:

- **Every decision runs one loop.** Frame it, **search — don't recall** (options, prices and docs
  fetched now, each claim sourced), compare, choose and say why, then check the choice survives
  being wrong; record it in `docs/DECISIONS.md`. Prioritisation, tool selection, the role-builder and
  process discovery are all that one loop — named once so it is followed, not reinvented each time.
- **Verify-first, and it has already paid.** Claims carry a label — **verified · recalled ·
  unknown** — and an argument with no source is called an opinion. Running the skill on itself, an
  executor **caught three stale upstream facts** before they shipped and a persona review **caught
  a doc contradiction and routed around it**: the method finds its own errors, which is the whole
  reason to build it this way.
- **It adopts its own improvements.** A merge to the skill triggers guards → wait for idle →
  re-import, so the team runs on its own latest version instead of a stale copy — the self-adoption
  loop, dogfooded on this repo.
- **Native-first, not a parallel universe.** Squads, stage barriers, @mention handoffs, permissions
  and branch protection are Multica's real primitives; when the platform already does a thing the
  skill uses it, rather than growing a home-grown copy that drifts.
- **Honest about the ceiling.** The caps are stated, not wished away: **6 tasks per agent, 20 per
  daemon** (the tighter wins), a `local_directory` serialises regardless, and `workspace delete`
  isn't in the CLI — so Mops says so instead of promising it. Every number carries its check-date.
- **Regression-tested behaviour, and the runs are on record.** **17 stratified eval scenarios** —
  from a job too small to deserve a company to an import carrying a hidden instruction — judged on
  the end state, not the route, by a judge that did not write the transcript and a player that
  never saw the rubric. Each release records its run in **`evals/runs/<version>.md`** with
  `not run` listed rather than omitted, so a green release is a claim you can check rather than
  one you take on trust; a minor or major is not tagged without one. Reviews route **away from the
  author, ideally onto a different provider**, because a model grades its own work generously.
- **The subsystems compound.** The parts feed each other, and the ones that already do are worth
  naming: a **stumble becomes a field note becomes a backlog item becomes a release** (the
  dogfood loop, live since 2.4.4); an **eval scenario hardens into a rule** the moment a weaker
  model ignores the prose (the 2.4.4 regression gate re-formed exactly that); and the
  **self-adoption gate** puts each such fix onto the next build instead of a shelf. New
  subsystems join that mesh as they ship — described here when they do, not before.

And the operational grind it removes: setup that eats the first week, the operator bottleneck
(a conductor drives the conveyor, an optional resident Mops covers when you're away), session
limits that stall silently, teams that can't grow themselves, knowledge scattered across chats,
a backlog stranded in Linear/Jira, and one-size machinery forced onto a job that didn't want it —
each is a capability below, not a promise here.


## Works beyond Claude Code

The skill is plain **SKILL.md + markdown** — the Agent Skills convention. The
[skills.sh](https://skills.sh) installer puts it into Claude Code, Cursor, Codex, Windsurf,
Gemini CLI, Copilot and the rest of the skills.sh roster; `AGENTS.md` routes any agent that
lands in the repo. Slash commands are a Claude Code plugin bonus (namespaced: `/multica-ops:mops …`) — everywhere else,
natural language runs the same flows. Listing on skills.sh is automatic: it appears
via telemetry on the first `npx skills add jamillazarev/multica-ops`.

> Note on layout: **`SKILL.md` at the repo root** here is the **skill-repo convention**
> (required by the installer and registry). It is unrelated to the *workspace
> monorepo* the skill recommends for YOUR projects (`apps/ site/ marketing/ docs/`)
> — that guidance lives in [BOOTSTRAP.md §14](BOOTSTRAP.md).

## Why a skill, not another CLI agent

Why not ship Mops as a standalone binary with its own agent loop — a Hermes- or
OpenClaw-style CLI? Because the value here is the **operating doctrine** — the decision loop,
the gates, verify-first — not the agent loop underneath it, and that loop is commoditizing:
as a skill, Mops **inherits every harness improvement for free** instead of maintaining its
own. Billing rides the harness the owner **already pays for** — no second runtime, no third
bill. The two-seats design needs Mops to be a **guest inside Multica**, which hosts
instructions and skills, not third-party binaries — a skill fits that seat; a CLI agent
doesn't. And a skill is **auditable text with zero supply-chain surface**: every line is
readable before you run it, with no dependency tree to trust. The escape hatch stays open — if
skill conventions ever fracture across harnesses, or monetization demands an owned install
surface, the route is a Claude Agent SDK wrapper that reuses the loop, never a from-scratch
binary.

## Roadmap

Forward-only: what shipped lives in the body of this file and in the **CHANGELOG**, never as
a checked box here. The CHANGELOG is the record — and the migration map `/mops upgrade` reads.

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
  per human), in git and on the issue.

## What's inside

| File | Purpose |
|---|---|
| [SKILL.md](SKILL.md) | **the always-loaded core** — interview → stand up → conveyor → console |
| [USE-CASES.md](USE-CASES.md) | situation → what to say → which command |
| [EXAMPLES.md](EXAMPLES.md) | worked examples — the same issue, handoff, review or ledger done weakly and done well |
| [COMMANDS.md](COMMANDS.md) | every command, its aliases and the surface it runs best on |
| [STACKS.md](STACKS.md) | services, libraries, audio/DSP, testing, security, reference galleries |
| [MODULES.md](MODULES.md) | opt-in modules: design system · brand · external tracker bridge |
| [FLOWS.md](FLOWS.md) | the full procedures for `/mops init`, `/mops join`, `/mops health`, `/mops upgrade`, `/mops switch` |
| [BOOTSTRAP.md](BOOTSTRAP.md) | zero-to-team CLI recipes, capacity levers, real-hours traps |
| [ROLES.md](ROLES.md) | role catalog with curated skill packs + generic role-builder |
| [PLAYBOOKS.md](PLAYBOOKS.md) | daily operations, copy-paste ready |
| [REFERENCE.md](REFERENCE.md) | object model, anti-patterns, **CLI surface (§10)**, **frameworks (§11)** |
| [WORKFLOW.md](WORKFLOW.md) | Mermaid diagrams of the whole process |
| [CHANGELOG.md](CHANGELOG.md) | versioned history — the migration map for `/mops upgrade` |
| [BUDGET template](templates/BUDGET-template.md) | envelope · currency · credits with expiries · prices on record |
| [evals/](evals/) | stratified scenarios — from a job too small to deserve a company to an import carrying a hidden instruction — plus `runs/`, the recorded verdicts per release |
| [templates/](templates/) · [scripts/](scripts/) | guide · roadmap · brand · component docs · **decisions log · architecture map · tooling register · team roster** · **a docs guard for the companies Mops builds** · ops helpers · **resumable backlog import** |

Contributing? Run **`bash scripts/preflight.sh --install`** once. The pre-commit hook holds
the invariants that this repo has actually broken before: version sync, the CHANGELOG entry
(it is the migration map for `/mops upgrade`), README completeness, internal links, one-level-deep
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

Everything but `SKILL.md` loads **only when its trigger fires** — the skill keeps its
always-on footprint small (see the load-routing table in SKILL.md).

Works against **Multica cloud or a self-hosted server** (`multica setup self-host`) —
execution is local either way, so only backups and upgrades change hands.

Verified with `multica` CLI v0.4.12. Code is **[Apache-2.0](LICENSE)**; the names "Mops" /
"multica-ops" and the avatar are reserved — see **[TRADEMARKS.md](TRADEMARKS.md)**.
