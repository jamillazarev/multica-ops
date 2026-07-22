# Changelog

## 1.2.1

- CI/CD row expanded for agent teams: GitHub Actions + the **official GitHub MCP server**
  (agents read workflow runs, analyze failures, manage releases), CircleCI MCP, Buildkite,
  Dagger. New decision rule: **pick CI your agents can read** — structured, fetchable
  failure context beats raw build speed.

## 1.2.0

- **Freshness over training data** — for anything version-sensitive (OS/SDK versions and
  their APIs, framework/library APIs, store rules, pricing) agents verify against live
  sources (**Context7** MCP/skill, official docs, `--help`) instead of a frozen cutoff;
  target versions recorded in `docs/TOOLING.md`, re-checked at `/audit` and before major
  `/ship`. Generalizes to any time-sensitive data.
- **CI/CD & release automation** in STACKS: GitHub Actions, Fastlane / EAS (mobile store
  submission), electron-builder / tauri-action + notarization (desktop), Changesets /
  semantic-release — pipelines that gate the launch checklist.
- Context7 added as an invariant skill source for agents writing version-sensitive code.

## 1.1.2

- Migrations belong to the new version: update flows fetch the latest skill first and
  follow its instructions (forward-compat bootstrap); CHANGELOG = the migration map.
- CI: weekly watcher opens an issue when a new multica CLI ships (REFERENCE §10 regen).

## 1.1.1

- `/join` into a workspace stood up by an older skill version now runs the same
  migration delta as `/upgrade` (files, guide rules, commands) and reports adaptations.

## 1.1.0

A large release — the skill grows from "stand up a team" into "run the whole company,
end to end." Migration from 1.0.0 is automatic via `/upgrade` or `/join`.

### Two seats of Mops
- **Mops in CLI** (build/heavy ops) + an optional **Mops in Multica** (resident agent,
  presence/escalation when you're away) — one advisor, one name, two surfaces.
- No shared live memory: the bridge is **written state** (repo + issue comments). Bootstrap
  ends with a **kickoff handoff**; "Mops writes as it goes" so the project rebuilds from
  repo + workspace alone. Redirect lanes each way; the `Where` tag is a recommendation.

### The full product loop
- `/ship` (`/release` `/launch` `/deliver`), `/measure`, `/bug` (`/urgent` `/hotfix`
  `/incident`), `/feedback` — closes Discover → … → **Ship → Measure → Learn**, no longer
  a dead end at merge. Domain-neutral verbs (code, a batch, an episode).
- **Launch-completeness gate**: before the first release the conductor analyzes the
  medium's real go-live requirements (icons/favicons, store assets, signing, legal, OG…)
  into a checklist `/ship` gates on.
- **Cost/effort ledger** — tokens · $ · time · per agent/human, in git
  (`docs/analytics/`) + a summary comment on the issue; $ reproduces Multica's own
  open-source list-price estimate.

### Governance & people
- **Authority** (`/access`): owner always full, members default full, narrowable;
  destructive/outward & spend always route to the owner.
- **Budget** caps in tokens / money / time (subscription-aware).
- **Review checkpoints** (`/reviews`): a named human signs off on chosen flows.
- Humans as first-class members: `/hire` (agent **or** real person via workspace invite),
  `/fire` (owner-only removal in the app), `/update` (`/role` `/edit`) reconfigures a
  member or reassigns a project lead.

### Design system & brand
- **Design system** module: reuse-first gate, three origins (build / adopt / inherit),
  **one component standard** (`CONVENTIONS.md` + `COMPONENT-template.md`), DTCG tokens +
  Style Dictionary, systematization done in-feature and **reviewed by the curator**.
- **Brand** module (`/brand`): brand book (positioning · archetype · sliders · tone
  samples · anti-references), rebrand flow (critique · change-magnitude · keep/change ·
  owner vote); a creator gets the same scaled down.

### Registries & memory
- `docs/TOOLING.md` (every tool: what · for what · access · wiring · conventions),
  `docs/LATER.md` (deferrals with **revisit triggers** — the good-consultant nudge).
- **Docs follow decisions** & **system follows solutions** baked into the guide.
- Reference galleries, `awesome-{topic}` search, MCP registries — seeds for the common,
  search for the tail. Testing & security defaults per platform/stage. Frameworks §11
  (adaptive per stage: ICE/RICE/Kano, HEART/AARRR/GAME/OMTM, Impact Mapping…).

### Operations
- `/health` (full-circle sweep), `/upgrade` (git-backed, self-migrating), `/switch`
  (assisted provider migration), `/workspace` (multi-workspace), two-way `/sync`, `/cli`
  (raw CLI escape hatch). Full Multica CLI command surface documented (REFERENCE §10).
- **Express setup** ("defaults"), **batched approvals** in `/status`, versioned skill
  (frontmatter `version`) so updates are detectable. 38 commands + aliases.

## 1.0.0 — 2026-07-18

First public release.

- **Mops** 🐶 — your Executive Advisor for Multica: builds the workspace-as-company
  (conductor/PM, squads, skills, integrations), optionally stands up a resident Mops inside
  Multica, and stays your console.
- Progressive interview with defaults — small tasks stay small (3 questions).
- Stage-barrier conveyor: Design → Build → parallel Review gates → Accept.
- 30+ commands + `/mops <anything>` dispatcher; free-text arguments everywhere.
- Autonomy dials (`manual ⇄ auto` for flow and hiring), boundary-safe switching.
- Session-limit handling as a first-class concern; `/recover`, `/audit`.
- Opt-in modules: experts, personas, Design QA, autopilots, Slack/Lark, social.
- JTBD issue format, ICE prioritization, ROADMAP/TEAM/discovery templates.
- Cross-agent (Agent Skills convention): works in 18+ harnesses; AGENTS.md entry.
