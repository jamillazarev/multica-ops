# Changelog

## 1.9.0

- **Epistemic protocol**: every substantive claim is labelled **verified** (checked now,
  with a source), **recalled** (from training, may be stale) or **unknown** — recalled is
  never dressed up as verified, and gaps are never filled with a confident guess.
  **Reads are free** (looking things up needs no permission — asking is the dispatcher
  trap in miniature); **permission is asked when it costs or changes configuration** —
  attaching a skill/MCP server, a paid source, or a research run heavy enough to eat the
  shared limit. Dead end → say so, name what's missing, offer `/connect`, the
  role-builder, or `LATER.md`.
- **preflight**: detects CLI drift (installed vs pinned) and adds **`--regen-cli`** —
  verifies §10 against the installed CLI, re-pins only when the surface matches and the
  CLI is newer, and lists what changed otherwise. **Never rewrites the pin silently** —
  a bumped version over a stale §10 would be a false claim of currency.

## 1.8.0

- **"Assume incompleteness" promoted to the first principle** — the frame for everything
  else: no skill can enumerate what every company/craft needs and its lists age, so every
  catalog is a seed, and for *this* project you go look (awesome-{topic}, MCP registries,
  skill search, official docs, live `--help`) and prefer the just-verified over the
  remembered. *Not knowing is normal; not looking is the failure.*
- **`scripts/preflight.sh`** — a pre-commit check (also runs in CI) that keeps the skill
  coherent: version sync (SKILL ↔ plugin.json), a CHANGELOG entry for the version, README
  listing every companion file, no broken internal links, every command backed by a
  plugin file, and a **10k-token budget on the always-loaded core** so it can't quietly
  bloat. Install with `bash scripts/preflight.sh --install`.

## 1.7.0

- **Role-builder now hires the whole package** — skills **and tooling and resources**:
  `awesome-{craft}` alongside skills.sh, **MCP registries first** for the role's
  instruments (obeying the selection ladder), and reference galleries/standards as the
  sources it must consult; everything registered in `TOOLING.md` and `TEAM.md`.
- **Empty search is no longer a dead end**: an explicit broadening ladder — rephrase into
  the industry's own words → parent domain → adjacent crafts → decompose into tasks →
  only then draft a skill, logging the gap in `LATER.md`.
- **Baseline kit made explicit** — every agent, whatever the role, gets the guide skill,
  find-skills, handoff, caveman (lite), Context7 where version-sensitive, and the docs it
  must know (ROADMAP · TEAM · TOOLING · LATER + brand/design-system when on).

## 1.6.0

- **Token economy documented with real numbers** (REFERENCE §12): on a live workspace
  **~89% of all tokens were cache reads**, and caching was already saving **74%** of cost.
  The actionable rule: **keep the cached prefix (guide + agent instructions) stable** —
  churning it costs a cache write (dearer than input) *and* forfeits cheap reads, so
  batch guide edits at `/sync`. `/audit` now watches the **cache-hit ratio**.
- Pointers added where they belong: `awesome-generative-ai-guide` (AI features),
  `awesome-seo` (SEO). Other awesome lists stay tail — found via `awesome-{topic}` search.

## 1.5.1

- **Fixed a broken CI watcher**: it polled `multica-ai/multica-cli` (404 — releases live
  in `multica-ai/multica`) and, silenced by `2>/dev/null`, would never have fired. Now it
  reads the right repo and **fails loudly** instead of exiting quietly.
- CLI surface re-verified against the current release and re-pinned **v0.4.4 → v0.4.8**
  (no command-surface changes — only the version was stale).
- README's "What's inside" listed 6 of 12 files — now complete, with a note that
  everything but `SKILL.md` loads on demand.
- Docs site: overview now mentions stacks/audio/i18n and links Stacks and Modules.

## 1.5.0

- **Selection ladder** made explicit: free → open source → self-hostable/local →
  embeddable in the repo → agent-drivable (MCP/CLI/API); a paid or managed option must
  **earn the exception** with a stated reason recorded in `docs/TOOLING.md`.
- **Load-routing table** replaces the old file list: every companion file now has an
  explicit trigger ("load X when Y"), and the index finally includes STACKS, MODULES and
  COMMANDS — progressive disclosure is now stated, not assumed.

## 1.4.0

- **SKILL.md slimmed 12k → 7.6k tokens (−36%)** — the file that loads on *every*
  invocation. Extracted to load on demand: **COMMANDS.md** (the full command table),
  **MODULES.md** (design system & brand — opt-in, no reason to load when off), and
  stand-up detail into **BOOTSTRAP §15**. No rules lost; pure progressive disclosure.
- **Stacks gaps closed**: i18n/localization (Weblate, Crowdin, i18next), support &
  feedback inbox (Chatwoot, Crisp — where `/feedback` lands), status page & uptime
  (Uptime Kuma, BetterStack), privacy & compliance (Klaro consent, DPA, GDPR basics),
  SEO & discoverability (Search Console, Ahrefs Webmaster Tools).
- **Visual / node-based pipelines**: ComfyUI, n8n, Flowise, Langflow, Dify, Rivet — with
  the rule that they build *the product's* AI features and asset pipelines, never a
  second orchestration layer over Multica.

## 1.3.0

- **Audio & DSP stack** added: frameworks (JUCE · iPlug2 · DPF · HISE · NIH-plug) with
  **licence-first** decision rule, formats (CLAP/VST3/AU/AAX/LV2 — CLAP via
  clap-juce-extensions until JUCE 9), permissive DSP libraries and primitives (FFT,
  resampling, libebur128), FAUST/Cmajor prototyping, **pluginval + auval** validation,
  **RTSan** realtime safety, distribution/notarization.

## 1.2.2

- **Free tier first — and name the ceiling**: proposing a service now states where its
  free tier ends (build minutes, MAU, rows, events, seats) and what happens there;
  the plan + ceiling are recorded in `docs/TOOLING.md`, `/health` watches headroom,
  `/audit` flags what's close, and crossing into paid is owner-gated spend.
- Honest CI/CD free-tier note (free for public repos; private repos minute-capped).

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
