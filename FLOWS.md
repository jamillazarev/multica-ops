# Flows — the procedures Mops runs

Loaded when one of these actually runs. Each is rare or heavy: standing a company up,
joining an existing one, or touching the live workspace's plumbing. Day-to-day work
(a feature, a ship, a budget question) is in SKILL.md itself.

## Contents

Interview · Stand up · Joining an existing setup · Health, upgrades & runtime changes

## Interview progressively — small things must stay small

Never front-load a giant questionnaire. Open with one question: **"What are we
making, and is this a quick job or a company we're building?"** Then branch:

- **Quick job** (a utility, one deliverable): 3 questions max — deliverable, repo,
  language. One conductor + 1–2 executors. Done. Everything else uses defaults.
- **Company/product**: walk the full checklist below, but **every question carries a
  default** the user can accept with one word; bundle related questions; skip what
  the context already answers. Ask in waves (next wave only when the previous
  matters), not as one wall.

**Express setup:** the user can say **"defaults"** at any point — every remaining
question takes its default, skipped opt-ins still land in `docs/LATER.md`.

**"Later" is recorded, not dropped:** every "no / not now" in the interview (and any
time after) lands in `docs/LATER.md` with a revisit trigger — see "Later is a list".

**Every choice accepts "other":** each question below carries a default AND an open
door — the user can name any tool/format/provider not listed; you research it and
wire it the same way (MCP/env for access, a guide rule for conventions). **Wiring
includes studying**: for any tool that enters the project — named by you or the user —
research how to work with it *well* (its idioms, token/asset workflow, best practices),
**Default preference order** when several options fit: **free → open source →
self-hostable/local → embeddable in the repo → agent-drivable (MCP, CLI, or API)** — the
managed/paid option must earn its place with a reason. Full ladder: STACKS. Then
**place that knowledge by scope, never in the guide** (the guide is every agent's cached
prefix — tool operations there are paid by everyone, forever). Three homes:
**registry** → `docs/TOOLING.md` (what · for what · access · how wired · plan +
free-tier ceiling · link to its runbook); **runbook** → `docs/tooling/<tool>.md`, the
routine operations and failure modes (*purge the cache · add an edge region · rotate the
key · what it looks like when it breaks*), read by whoever is about to use the tool;
**skill** → when it's substantial or reused across projects, shape it with skill-creator
and attach it **only to the agents that touch that tool**. The guide carries one pointer
line, never the content — the same core-plus-load-on-trigger split this skill uses on
itself. Options in
this file are seeds, never a closed menu.

Full checklist — **detail and defaults in `BOOTSTRAP.md §16`**; ask in
waves, each with a default, skipping what context already answered:

1 deliverable & repo · 2 disciplines & depth · 3 DoD per discipline · 4 stage ladder ·
5 capacity, models **& budget** · 6 integrations · 7 docs home · 8 assets home · 9 avatars ·
10 experts & personas · 11 design system & brand · 12 resident Mops · 13 operating mode ·
14 autopilots/Slack · 15 language & tone · **16 control & expertise** · **17 governance**

Two of these shape every later interaction, so never skip them: **#16 control & expertise**
— how much the owner wants to be in the loop (*hands-on* · **checkpoints** (default) ·
*hands-off*) and **what they're actually expert in** (recorded in `TEAM.md`: consulted as
an expert there, taught-and-recommended elsewhere; agents apply the same across squads).
Asked at `/init`, re-asked in the `/join` delta, changed any time — `/reviews` takes
effect **immediately**, `/autonomy` is **boundary-safe**, `/stop` is the instant halt.
**#17 governance** — who may direct Mops and which flows need a named human's sign-off.


## Stand up, in this order

Step detail and CLI recipes: **`BOOTSTRAP.md §15`**.

1. **Workspace = company** — one per company/owner; projects = directions; agents shared
   across them. Fill workspace details (description, logo).
2. **Conductor first**, made the project lead, with git/GitHub rights.
3. **Guide skill + find-skills on every agent** — language/tone, incremental commits, DoD,
   handoff = @mention, evidence-over-opinion, **docs follow decisions**, self-improvement,
   limit/cancel conventions, and who Mops is. Escalation: agent → squad leader → conductor
   → **Mops** → user (Mops in Multica off → the vertex collapses to conductor → user).
4. **Roles from the interview** — ROLES.md templates, else the **role-builder**: research
   the craft → find **skills · tooling (MCP registries first) · resources**, broadening the
   search rather than giving up on a miss → propose → create. Every agent also gets the
   **baseline kit** (guide · find-skills · handoff · caveman · Context7 where relevant ·
   the docs it must know) — ROLES.md. Designers and engineers join from the first
   decisions, not only at their stage.
5. **Experts & personas** (opt-in) — squads of advisors / user simulations.
6. **Mops in Multica** (opt-in — checklist #13 · Resident Mops) — install this skill into the workspace **idempotently**
   (check `skill list`; exists → compare versions, refresh via `/upgrade`, never a second
   copy), assign it **only to the Mops agent**, then seed the kickoff (pinned issue + first
   message = the decisions summary).
7. **Labels** (discipline/type, never the stage) and **docs skeleton**: `ROADMAP.md`,
   `TEAM.md`, `TOOLING.md`, `LATER.md`.

## Joining an existing setup

Audit before touching: inventory (projects, agents, squads, skills, labels, statuses,
**and workspace members**) → gap-check against the invariants and this file → report
deltas with recommendations (fix now / later / ignore is the user's call) → **run the
interview delta** (any topic the incumbent setup doesn't already answer — language/tone,
token economy, avatars, opt-in modules, autonomy, docs home, **where Multica itself runs
(cloud or self-hosted)**, integrations, stacks,
resident Mops (in Multica), **brand & design system**, **governance**, **control & expertise**, **budget & currency** — is asked with defaults and wired, exactly as in `/init`;
nothing from bootstrap is skipped just because the project pre-exists) → apply in **approved batches** — full report first, the user can stop after any batch — never duplicating (`--on-conflict skip`; read instructions before
appending). Respect incumbent conventions unless asked to change them.

**Reconcile every human member, not just agents.** Walk `workspace member` and, for each
person, confirm the delta captures them: recorded role/responsibilities in `docs/TEAM.md`,
an **access policy** (`/access` — what they may direct Mops to do; owner always full),
and their **review checkpoints** (`/reviews` — which flows @mention them). Anyone present
in the workspace but missing from the records gets onboarded (ask their role → set access
+ checkpoints → record); anyone in the records but no longer a member gets cleaned up.

**A Mops in Multica already exists? Reconcile, don't duplicate.** If the workspace already has
a Mops agent (common when re-joining a project you built earlier): **update, never
create a second.** Compare the workspace skill's frontmatter `version` against yours —
**older → the workspace itself is a migration target**: run the same migration delta as
`/upgrade` (backup → re-import → **create every docs file the current version expects —
the skeleton in BOOTSTRAP §15 step 7 is the list, never a remembered subset** → update guide rules,
refresh the agent's instructions, surface new/renamed commands) and **report the
adaptations**. Then reconcile the avatar, the *"Executive Advisor · resident"* subtitle,
the guide-lane rules, and its rights per the current autonomy choice; `/sync` after.

## Health, upgrades & runtime changes

All three are **preview-first** (blast radius reported before anything changes), backed
up and reversible where they can break things. Recipes: **PLAYBOOKS**.

- **`/health`** — full-circle sweep of what fails silently: runtimes (+ **which agents
  sit on a degraded one**), integrations/MCP probes (**the probe list = `docs/TOOLING.md`**), API tokens/secrets, **free-tier headroom** (usage vs the ceiling recorded per service), daemon, limits.
  Output: component → status → who it blocks → fix. `/audit` pulls it in.
- **Version checks cover three layers, not one**: **multica-ops** itself, every
  **imported skill**, and the **tooling** registered in `docs/TOOLING.md` (MCP servers,
  CLIs — their own releases and breaking changes). Proactively at `/status` (weekly at
  most) and before any major `/ship`, compare each against its source; something newer → say **what changed and what it would touch**, and
  offer `/upgrade`. Never upgrade unasked.
- **Rollback is a normal outcome, not a failure.** Upgrades and migrations do break
  things; that's why every one commits a restore point first (`docs/skill-backups/` +
  the pre-upgrade SHA in `UPGRADES.md`) — **including a snapshot of agent instructions and
  config**, which live in Multica, not in git, and which the migration itself rewrites.
  Without that snapshot a git rollback restores the skill but leaves the agents rewritten.
  If behaviour regresses after an upgrade — say
  so, re-import from that SHA, and log what broke so the next attempt is informed.
- **An upgrade delivers unreviewed code and unreviewed instructions.** A skill screened
  at import is not screened forever: the new version can add a script, an endpoint, a tool
  grant or a paragraph telling agents to do something. So **re-screen before applying**,
  and diff against the version you screened rather than reading it fresh — the interesting
  part is *what changed*, in the prose as much as in the scripts (STACKS → skill
  screening). A version that adds capability you didn't ask for is a decision for the
  owner, not a detail of the update.
- **`/upgrade [skill|all]`** — skills carry **no workspace-side version history**, so the
  flow is: **re-screen** → dry-run impact report → back up **both halves** (skill files *and* an agent
  config/instructions snapshot) with the pre-upgrade SHA in `UPGRADES.md` → apply →
  reconcile dependents → verify, else restore from that SHA. Steps: PLAYBOOKS. **Upgrading multica-ops itself is a
  migration, not a swap**: read the new version's CHANGELOG/diff → run a `/join`-style
  delta against the workspace (**create every docs file the new version expects — read the
  skeleton in BOOTSTRAP §15 step 7 rather than a list quoted here, which goes stale** —
  update guide rules, refresh Mops-in-Multica's instructions, surface new/renamed
  commands) → report what was adapted. Versions compare via the skill's frontmatter
  `version` + CHANGELOG. **Migrations belong to the NEW version**: updating multica-ops
  (via `/upgrade` or `/join`), first fetch the latest version from the canonical repo
  (github.com/jamillazarev/multica-ops) and follow **its** migration instructions — the
  old version can't know how to migrate forward, only the new one does. The CHANGELOG is
  the migration map: read every entry between the installed and the new version. This
  clause itself is the forward-compat bootstrap — even an old version knows to hand over.
- **`/switch`** — providers auto-appear as runtimes, so switching is reassignment:
  per-agent `agent update --runtime-id --model --thinking-level`; whole-provider =
  assisted migration (install/auth/`daemon restart`, tier remap, smoke test), the full
  remap previewed first.

