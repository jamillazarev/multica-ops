<p align="center">
  <img src="assets/mops.png" alt="Mops — your Executive Advisor" width="250">
</p>

<h1 align="center">multica-ops</h1>

<p align="center">
  Meet <b>Mops</b> 🐶 — the pug behind the ops. One word gets you everything:<br>
  <code>/mops status</code> · <code>/mops next</code> · <code>/mops add a feature: …</code>
</p>

<p align="center">
  <a href="https://ai.jamillazarev.com/skills/multica-ops/overview"><img alt="Docs" src="https://img.shields.io/badge/docs-ai.jamillazarev.com-black"></a>
  <a href="https://github.com/jamillazarev/multica-ops/releases"><img alt="Release" src="https://img.shields.io/github/v/release/jamillazarev/multica-ops?color=black"></a>
  <a href="LICENSE"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-black"></a>
</p>

**Your Executive Advisor for [Multica](https://multica.ai)** — a skill that builds and
runs an autonomous company of AI agents: interviews you progressively (small tasks
stay small), stands up the workspace-as-company via the CLI (conductor/PM, squads,
skills, integrations), optionally stands up a resident Mops inside Multica, and stays
your console — status, recovery after limits, features, roadmap, hiring.

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

**Manual (any agent that reads files):**
```sh
git clone https://github.com/jamillazarev/multica-ops
# point your agent at SKILL.md — AGENTS.md routes agents that land in the repo
```


## Why this exists

**#1 — Setup eats the first week.** Before an agent team does anything useful you're
deep in plumbing: roles, prompts, review chains, issue conventions, integrations.
*Fix:* one interview and Mops stands the whole company up — you start working, not
configuring.

**#2 — Agent teams die without an operator.** Ten agents on ten issues and you're
the bottleneck: routing, restarting, remembering what's next. *Fix:* a conductor
drives the conveyor; Mops stays your console and, optionally, a resident copy inside
Multica for when you're away.

**#3 — Session limits stall everything silently.** All agents on one runtime share
one plan's window; a hit looks like a failed run and nothing retries itself. *Fix:*
limits are first-class — detection with reset time, `/recover`, capacity levers,
model tiering.

**#4 — Teams can't grow themselves.** Mid-project you need a designer, a marketer, a
pastry chef. *Fix:* a role-builder researches best practices and skills for any role
you name; hiring can even run autonomously (`/autonomy hiring auto`).

**#5 — Agents reinvent wheels and improvise opinions.** *Fix:* evidence-over-opinion
and self-improvement are baked into the shared guide — research before inventing,
and a routine repeated twice becomes a skill.

**#6 — Knowledge scatters.** Decisions live in chats, roadmaps in heads. *Fix:*
spec-driven intake (JTBD + stories + acceptance criteria), `docs/` as an
Obsidian-compatible vault, ROADMAP/TEAM as files — everything in the repo, mirrors
optional.

**#7 — One-size teams fit nobody.** A snacks brand, a YouTube channel and a macOS
utility need different crafts, gates, autonomy. *Fix:* everything beyond the
invariants is an opt-in module; the progressive interview keeps small tasks small.


## Works beyond Claude Code

The skill is plain **SKILL.md + markdown** — the Agent Skills convention. The
[skills.sh](https://skills.sh) installer puts it into 18+ harnesses (Claude Code,
Cursor, Codex, Windsurf, Gemini CLI, Copilot, …); `AGENTS.md` routes any agent that
lands in the repo. Slash commands are a Claude Code plugin bonus — everywhere else,
natural language runs the same flows. Listing on skills.sh is automatic: it appears
via telemetry on the first `npx skills add jamillazarev/multica-ops`.

> Note on layout: **`SKILL.md` at the repo root** here is the **skill-repo convention**
> (required by the installer and registry). It is unrelated to the *workspace
> monorepo* the skill recommends for YOUR projects (`apps/ site/ marketing/ docs/`)
> — that guidance lives in [BOOTSTRAP.md §14](BOOTSTRAP.md).

## What Mops handles

- **The whole product loop** — discover → define → prioritize (ICE) → design → build →
  review (parallel gates) → **ship → measure → learn**, closed, not a dead end at merge.
- **The team** — hire / fire / reconfigure **agents *and* real humans**, squads, experts
  & personas, a role-builder, optionally autonomous hiring.
- **Governance** — per-member access, human **review checkpoints**, a **budget** cap
  (tokens or money).
- **Staying alive** — session-limit recovery, a **full-circle health check** (runtimes,
  integrations, tokens), **git-backed skill upgrades** with rollback, two-way drift sync,
  assisted **provider switch**.
- **Two seats, many workspaces** — Mops in CLI for building + an optional Mops in Multica
  for presence, across several workspaces.
- **Cost visibility** — a per-release **cost/effort ledger** (tokens · $ · time · per
  agent/human) in git and on the issue.

## What's inside

| File | Purpose |
|---|---|
| [SKILL.md](SKILL.md) | **the always-loaded core** — interview → stand up → conveyor → console |
| [COMMANDS.md](COMMANDS.md) | every command, its aliases and the surface it runs best on |
| [STACKS.md](STACKS.md) | services, libraries, audio/DSP, testing, security, reference galleries |
| [MODULES.md](MODULES.md) | opt-in modules: design system & brand |
| [BOOTSTRAP.md](BOOTSTRAP.md) | zero-to-team CLI recipes, capacity levers, real-hours traps |
| [ROLES.md](ROLES.md) | role catalog with curated skill packs + generic role-builder |
| [PLAYBOOKS.md](PLAYBOOKS.md) | daily operations, copy-paste ready |
| [REFERENCE.md](REFERENCE.md) | object model, anti-patterns, **CLI surface (§10)**, **frameworks (§11)** |
| [WORKFLOW.md](WORKFLOW.md) | Mermaid diagrams of the whole process |
| [CHANGELOG.md](CHANGELOG.md) | versioned history — the migration map for `/upgrade` |
| [templates/](templates/) · [scripts/](scripts/) | guide · roadmap · brand · component docs · ops helpers |

Everything but `SKILL.md` loads **only when its trigger fires** — the skill keeps its
always-on footprint small (see the load-routing table in SKILL.md).

Verified with `multica` CLI v0.4.8. MIT.
