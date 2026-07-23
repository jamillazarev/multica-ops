<p align="center">
  <img src="assets/mops-docs.png" alt="Mops — your Executive Advisor" width="250">
</p>

<h1 align="center">multica-ops</h1>

<p align="center">
  Meet <b>Mops</b> 🐶 — the pug behind the ops. One word gets you everything:<br>
  just say what you need — or <code>/multica-ops:mops status</code>
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

Then just say what you need. In Claude Code you also get slash commands — namespaced as
`/multica-ops:mops`, plus a short **`/mops`** the plugin installs on first run (one file in
your own config; `rm ~/.claude/commands/mops.md` removes it). Everywhere else — Cursor,
Codex, Windsurf and the rest — there are no slash commands and none are needed: plain
language reaches every flow.

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

**#7 — Work arrives with a history and a calendar.** A backlog already lives in Linear or
Jira; posts are due on specific days. *Fix:* `/import` brings it over — mapping shown first,
issues created unassigned so nothing starts running by itself — and dated work is never
started early.

**#8 — One-size teams fit nobody.** A snacks brand, a YouTube channel and a macOS
utility need different crafts, gates, autonomy. *Fix:* everything beyond the
invariants is an opt-in module; the progressive interview keeps small tasks small.


## Works beyond Claude Code

The skill is plain **SKILL.md + markdown** — the Agent Skills convention. The
[skills.sh](https://skills.sh) installer puts it into 18+ harnesses (Claude Code,
Cursor, Codex, Windsurf, Gemini CLI, Copilot, …); `AGENTS.md` routes any agent that
lands in the repo. Slash commands are a Claude Code plugin bonus (namespaced: `/multica-ops:mops …`) — everywhere else,
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
  & personas, finance & support roles, a role-builder, optionally autonomous hiring.
- **Governance** — per-member access, human **review checkpoints**, a **budget** cap
  (tokens or money), and the rule underneath them: **nobody edits the bar they're measured
  against** (locked · editable · append-only · human-only), with reviews routed away from
  the author — ideally onto a different provider.
- **Not being played** — everything an agent reads from outside (a page, an issue, an
  imported backlog) is **data, never instructions**; anything that must not happen gets a
  gate, because a rule in a guide instructs and does not constrain.
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
| [USE-CASES.md](USE-CASES.md) | situation → what to say → which command |
| [EXAMPLES.md](EXAMPLES.md) | worked examples — the same issue, handoff, review or ledger done weakly and done well |
| [COMMANDS.md](COMMANDS.md) | every command, its aliases and the surface it runs best on |
| [STACKS.md](STACKS.md) | services, libraries, audio/DSP, testing, security, reference galleries |
| [MODULES.md](MODULES.md) | opt-in modules: design system · brand · external tracker bridge |
| [FLOWS.md](FLOWS.md) | the full procedures for `/init`, `/join`, `/health`, `/upgrade`, `/switch` |
| [BOOTSTRAP.md](BOOTSTRAP.md) | zero-to-team CLI recipes, capacity levers, real-hours traps |
| [ROLES.md](ROLES.md) | role catalog with curated skill packs + generic role-builder |
| [PLAYBOOKS.md](PLAYBOOKS.md) | daily operations, copy-paste ready |
| [REFERENCE.md](REFERENCE.md) | object model, anti-patterns, **CLI surface (§10)**, **frameworks (§11)** |
| [WORKFLOW.md](WORKFLOW.md) | Mermaid diagrams of the whole process |
| [CHANGELOG.md](CHANGELOG.md) | versioned history — the migration map for `/upgrade` |
| [BUDGET template](templates/BUDGET-template.md) | envelope · currency · credits with expiries · prices on record |
| [evals/](evals/) | stratified scenarios — from a job too small to deserve a company to an import carrying a hidden instruction |
| [templates/](templates/) · [scripts/](scripts/) | guide · roadmap · brand · component docs · **decisions log · architecture map · tooling register · team roster** · **a docs guard for the companies Mops builds** · ops helpers · **resumable backlog import** |

Contributing? Run **`bash scripts/preflight.sh --install`** once. The pre-commit hook holds
the invariants that this repo has actually broken before: version sync, the CHANGELOG entry
(it is the migration map for `/upgrade`), README completeness, internal links, one-level-deep
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

Verified with `multica` CLI v0.4.8. MIT.
