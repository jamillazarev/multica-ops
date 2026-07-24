# Flows — the procedures Mops runs

Loaded when one of these actually runs. Each is rare or heavy: standing a company up,
joining an existing one, or touching the live workspace's plumbing. Day-to-day work
(a feature, a ship, a budget question) is in SKILL.md itself.

## Contents

- [Interview progressively — small things must stay small](#interview-progressively-small-things-must-stay-small)
- [Before anything: day zero, then the routing question](#before-anything-day-zero-then-the-routing-question)
- [Shape the work, then propose the team](#shape-the-work-then-propose-the-team)
- [Crew mode — a team without a management layer](#crew-mode-a-team-without-a-management-layer)
- [Stand up, in this order](#stand-up-in-this-order)
- [Joining an existing setup](#joining-an-existing-setup)
- [Getting current — four layers, one command, two words](#getting-current-four-layers-one-command-two-words)
- [Health, upgrades & runtime changes](#health-upgrades-runtime-changes)

## Interview progressively — small things must stay small

Never front-load a giant questionnaire. **The opening is the front door, not this section** —
day zero first, then the three routing questions (what exists · what you want · who runs the
work), which pick between `/mops init`, `/mops join`, `/mops import`+crew and a quick job. See "Before
anything" below. What follows here is the *company* branch once that routing has happened:

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

**1 where the code lives (and whose account)** · **2 control & expertise — asked second on
purpose: it sets how many of the rest you ask at all** · 3 deliverable & repo shape ·
4 disciplines · 5 DoD · 6 stage ladder · 7 where Multica itself runs · 8 capacity, models
**& budget** · 9 skills/MCP you already want · 10 integrations · 11 docs home ·
12 assets home · 13 avatars · 14 experts & personas · 15 design system & brand ·
16 resident Mops · 17 operating mode · 18 autopilots/Slack · 19 language & tone ·
**20 governance**

Two of these shape every later interaction, so never skip them: **checklist #2 · Control & expertise**
— how much the owner wants to be in the loop (*hands-on* · **checkpoints** (default) ·
*hands-off*) and **what they're actually expert in** (recorded in `TEAM.md`: consulted as
an expert there, taught-and-recommended elsewhere; agents apply the same across squads).
Asked at `/mops init`, re-asked in the `/mops join` delta, changed any time — `/mops reviews` takes
effect **immediately**, `/mops autonomy` is **boundary-safe**, `/mops stop` is the instant halt.
**checklist #20 · Governance** — who may direct Mops and which flows need a named human's sign-off.

## Before anything: day zero, then the routing question

`/mops init` does not start at the workspace. It starts at **BOOTSTRAP §0** — installed, current,
signed in, a workspace, daemon up, runtimes present — reported as one ladder with its fixes,
not six sequential prompts. Only then the three routing questions (what exists · what you
want · who runs the work), because `/mops init` into an existing workspace duplicates a conductor
and `/mops join` on an empty one does nothing.

**Crew mode short-circuits the rest**: no conductor, no discovery, no roadmap — stand up the
executors, the guide, the gates the owner wants, and stop. It is the default offer after
`/mops import`.

## Shape the work, then propose the team

**A company is sized to a plan, not to a sentence.** Hiring off *"a macOS app that fixes
system audio"* — or *"a snack brand"* — produces the team that sentence suggests, which is a
guess. So between the opening questions and creating anything there is a **shaping
conversation**, and the owner sees a proposed team only after it, with the reasoning attached.

- **What it is, who it's for, and — the question that changes everything — what is hard
  about it.** Uncertainty is staffing information: an unknown gets research before it gets
  someone to execute it.
- **What the work is made of.** Name the surfaces in *this* domain's own words and stay in
  them: screens, services and data for software; recipe, packaging, supply and retail for a
  food brand; scripts, filming, edit and thumbnails for a channel. Each surface is a craft,
  and crafts are what you hire. **Never import another domain's vocabulary** — nobody making
  chips needs to hear about data flows.
- **Rough size, honestly held.** Not points — *what kinds of work exist and roughly how
  much*. "Two screens" and "a sync engine" staff differently, so do "one flavour" and "a
  seasonal line"; and "I don't know yet" is a valid answer that argues for starting small.
- **Then the proposal, with its why**: *"iOS and backend because the sync is the hard part;
  no designer yet because the first cut is a settings screen; QA once there is something to
  regress."* Numbers follow the work — five agents or fifty — and the owner can argue with
  reasoning they can see.

**Re-runnable, because plans move.** When scope changes materially the shaping runs again
and the team is re-sized — the same signal as the utilization review, arriving earlier. A
**quick job skips this entirely**: shaping a one-hour task is the ceremony this skill exists
to avoid.

## Crew mode — a team without a management layer

Not everyone wants a company. A developer with a list of tasks, a designer with a queue,
anyone who already knows what to build: **they are the product manager**, and the machinery
that exists to decide *what* to do is pure overhead for them.

Crew mode is the honest shape for that: **executors, gates if wanted, and no conductor.**
No discovery, no roadmap ceremony, no ICE, no cost ledger unless asked. The owner assigns
issues directly to an agent or a squad; work moves because they moved it. Everything else
in this skill still applies — the guide, the review gates, limits and recovery, the
permission rules, dated work.

It is the **default offer after `/mops import`**: someone who just brought a backlog over has
already decided what the work is, and proposing discovery over it is insulting. Say plainly
*"I'll execute; you keep prioritising — or I can add a conductor later"*, and mean the
"later": adding one is a normal upgrade, not a redo.

**Reassign what the conductor held, out loud, or it silently stops happening.** Four duties
are not planning and do not disappear with the planner: **accepting finished work and merging**
(gates green is a check, not an approver), **screening and attaching an imported skill** (the
"never auto-approved" gate needs an approver), **holding start dates** (nothing in the platform
stops an agent beginning early), and **settling a third review round on the same point**. In
crew mode all four sit with the **owner** by default — say so at stand-up and write it into the
guide, because an unnamed duty is an unperformed one.

**Owning a slice, not the whole thing.** A frontender who imported one feature, a designer
on one surface, anyone responsible for a *part* — this is crew mode narrowed to a slice, laid
over any route, not a fifth entrance. Say what the slice is (a feature, a layer, a directory)
and everything narrows to it: the board shows only that slice's issues, shaping sizes only its
crafts, permissions and gates cover only its files. The rest of the project may not even exist
in this workspace — the owner works their part and hands off at its edge. `/mops crew` with a named
scope is the shape; adding the rest of the project later is an expansion, not a redo.

**Where it stops being right:** when the owner starts asking *what* should be next rather
than telling. That is the moment to offer a conductor, once, with the reason.

## Stand up, in this order

Step detail and CLI recipes: **`BOOTSTRAP.md §15`**.

1. **Workspace = company** — one per company/owner; projects = directions; agents shared
   across them. Fill workspace details (description, logo).
2. **Conductor first**, made the project lead, with git/GitHub rights.
3. **Guide skill + find-skills on every agent** — language/tone, incremental commits, DoD,
   handoff = @mention, evidence-over-opinion, **docs follow decisions**, self-improvement,
   limit/cancel conventions, and who Mops is. Escalation: agent → squad leader → conductor
   → **Mops** → user (Mops in Multica off → the vertex collapses to conductor → user).
4. **Roles from the shaping proposal** (and the interview where it added detail) — ROLES.md templates, else the **role-builder**: research
   the craft → find **skills · tooling (MCP registries first) · resources**, broadening the
   search rather than giving up on a miss → propose → create. Every agent also gets the
   **baseline kit** (guide · find-skills · handoff · caveman · Context7 where relevant ·
   the docs it must know) — ROLES.md. Designers and engineers join from the first
   decisions, not only at their stage.
5. **Experts & personas** (opt-in) — squads of advisors / user simulations.
6. **Mops in Multica** (opt-in — checklist #16 · Resident Mops) — install this skill into the workspace **idempotently**
   (check `skill list`; exists → compare versions, refresh via `/mops upgrade`, never a second
   copy), assign it **only to the Mops agent**, then seed the kickoff (pinned issue + first
   message = the decisions summary).
7. **Labels** (discipline/type, never the stage) and the **docs skeleton** — the list is
   **BOOTSTRAP §15 step 7**, never a subset quoted from memory; it also installs the repo's
   docs guard.

## Joining an existing setup

Audit before touching: inventory **every class in the workspace fingerprint** (PLAYBOOKS — agents · squads · skills · labels · autopilots · projects · runtimes · properties · members · project resources), plus statuses,
**and workspace members**) → gap-check against the invariants and this file → report
deltas with recommendations (fix now / later / ignore is the user's call) → **run the
interview delta** (any topic the incumbent setup doesn't already answer — language/tone,
token economy, avatars, opt-in modules, autonomy, docs home, **where Multica itself runs
(cloud or self-hosted)**, integrations, stacks,
resident Mops (in Multica), **brand & design system**, **governance**, **control & expertise**, **budget & currency** — is asked with defaults and wired, exactly as in `/mops init`;
nothing from bootstrap is skipped just because the project pre-exists) → apply in **approved batches** — full report first, the user can stop after any batch — never duplicating (`--on-conflict skip`; read instructions before
appending). Respect incumbent conventions unless asked to change them.

**Reconcile every human member, not just agents.** Walk `workspace member` and, for each
person, confirm the delta captures them: recorded role/responsibilities in `docs/TEAM.md`,
an **access policy** (`/mops access` — what they may direct Mops to do; owner always full),
and their **review checkpoints** (`/mops reviews` — which flows @mention them). Anyone present
in the workspace but missing from the records gets onboarded (ask their role → set access
+ checkpoints → record); anyone in the records but no longer a member gets cleaned up.

**A Mops in Multica already exists? Reconcile, don't duplicate.** If the workspace already has
a Mops agent (common when re-joining a project you built earlier): **update, never
create a second.** Compare the workspace skill's frontmatter `version` against yours —
**older → the workspace itself is a migration target**: run the same migration delta as
`/mops upgrade` (backup → re-import → **create every docs file the current version expects —
the skeleton in BOOTSTRAP §15 step 7 is the list, never a remembered subset** → update guide rules,
refresh the agent's instructions, surface new/renamed commands) and **report the
adaptations**. Then reconcile the avatar, the *"Executive Advisor · resident"* subtitle,
the guide-lane rules, and its rights per the current autonomy choice; `/mops sync` after.

## Getting current — four layers, one command, two words

**Say the difference once and keep saying it.** *Update* means **new bytes arrive** — a newer
plugin, a newer CLI binary. *Upgrade* means **your workspace moves to them** — docs files the
new version expects, guide rules, agent instructions, renamed commands. New bytes without a
migration is where a company quietly runs half of one version and half of another.

**`/mops upgrade` is the one command**, and it walks all four layers in this order, asking before
anything that costs or restarts:

| Layer | What it is | Who does it |
|---|---|---|
| **1. This skill's bytes** | the plugin or skills.sh copy on *your* machine | **Mops runs it, you restart.** Mops in CLI has the shell, so it detects the lag and — with a yes — runs `claude plugin marketplace update multica-ops && claude plugin update multica-ops@multica-ops` (or `npx skills add jamillazarev/multica-ops`) itself. What it *cannot* do is apply the new bytes to its own running self: **Claude Code must restart**, and it says so. So the whole user cost is: say yes, restart, come back. |
| **2. The workspace** | docs skeleton, guide rules, agent instructions, new/renamed commands | **Mops** — the migration proper, from the **new** version's CHANGELOG |
| **3. Imported skills** | third-party skills each against its source | **Mops**, re-screening every one before applying |
| **4. The CLI** | `multica` itself, locally and on each runtime | **Mops proposes, you approve** — see the drain rule below |

**The CLI update needs the team to be idle, and nothing enforces that for you.** The daemon
executes tasks; replacing the binary underneath it interrupts whatever is mid-run, and
`daemon stop` has no drain flag — it stops, it does not wait. So:

```sh
multica daemon status --output json          # active_task_count must be 0
multica issue list --output json             # nothing in in_progress
multica update                               # local CLI
multica runtime update <runtime-id>          # the CLI on a runtime machine
multica daemon restart
```

Never update mid-flight. If work is running, **say what's in flight and offer to wait** —
`/mops stop` first if the owner wants it now and accepts the interruption, otherwise queue the
update for the next idle window. A CLI updated under a running agent produces failures that
look like the agent's fault.

**Then offer the tour.** A successful upgrade ends with *"want to hear what's new?"* —
`/mops whatsnew` reads the changelog between the old and new version and explains it in the owner's
terms. A migration nobody understands is a migration nobody trusts; this is how the new
version onboards the person, not just the workspace.

**One canonical list, so nothing is forgotten.** The workspace fingerprint (PLAYBOOKS) is the
single source of truth for *which structural objects exist* — agents, squads, skills, labels,
autopilots, projects, runtimes, properties, members, resources. **`/mops sync`, `/mops join` and
`/mops upgrade` all read that one list**, they don't each carry their own; add a class to the
fingerprint and all three cover it automatically. `verify.py` guards the fingerprint against
the CLI, so a new object type raises a warning in one place and protects every flow that reads
it. **Hashes and deltas run at the end, not the start.** An upgrade changes agents, skills and
labels, so the fingerprint written before it is stale by definition: recompute
`docs/.workspace-state.json` **after** reconciling, and record the pre-upgrade SHA in
`UPGRADES.md` first so a rollback has something to return to.

## Health, upgrades & runtime changes

All three are **preview-first** (blast radius reported before anything changes), backed
up and reversible where they can break things. Recipes: **PLAYBOOKS**.

- **`/mops health`** — full-circle sweep of what fails silently: runtimes (+ **which agents
  sit on a degraded one**), integrations/MCP probes (**the probe list = `docs/TOOLING.md`**), **branch protection on the default branch** where a remote exists, API tokens/secrets, **free-tier headroom** (usage vs the ceiling recorded per service), daemon, limits.
  Output: component → status → who it blocks → fix. `/mops audit` pulls it in.
- **Version checks cover three layers, not one**: **multica-ops** itself, every
  **imported skill**, and the **tooling** registered in `docs/TOOLING.md` (MCP servers,
  CLIs — their own releases and breaking changes). Proactively at `/mops status` (weekly at
  most) and before any major `/mops ship`, compare each against its source; something newer → say **what changed and what it would touch**, and
  offer `/mops upgrade`. Never upgrade unasked.
- **Rollback is a normal outcome, not a failure.** Upgrades and migrations do break
  things; that's why every one commits a restore point first (`docs/skill-backups/` +
  the pre-upgrade SHA in `UPGRADES.md`) — **including a snapshot of agent instructions and
  config**, which live in Multica, not in git, and which the migration itself rewrites.
  Without that snapshot a git rollback restores the skill but leaves the agents rewritten.
  If behaviour regresses after an upgrade — say
  so, re-import from that SHA, and log what broke so the next attempt is informed.
- **The short command restores itself.** `~/.claude/commands/mops.md` lives in the owner's
  global config, so a new machine or a wiped profile loses it — the SessionStart hook puts it
  back, unless they deleted it on purpose (BOOTSTRAP §15b).
- **Sweep for skills compressed past readability** while you are already touching them:
  restore from `docs/skill-backups/` and re-run the pass, never "expand it back" (PLAYBOOKS).
- **An upgrade delivers unreviewed code and unreviewed instructions.** A skill screened
  at import is not screened forever: the new version can add a script, an endpoint, a tool
  grant or a paragraph telling agents to do something. So **re-screen before applying**,
  and diff against the version you screened rather than reading it fresh — the interesting
  part is *what changed*, in the prose as much as in the scripts (STACKS → skill
  screening). A version that adds capability you didn't ask for is a decision for the
  owner, not a detail of the update.
- **`/mops upgrade [skill|all]`** — skills carry **no workspace-side version history**, so the
  flow is: **re-screen** → dry-run impact report → back up **both halves** (skill files *and* an agent
  config/instructions snapshot) with the pre-upgrade SHA in `UPGRADES.md` → apply →
  reconcile dependents → verify, else restore from that SHA. Steps: PLAYBOOKS. **Upgrading multica-ops itself is a
  migration, not a swap**: read the new version's CHANGELOG/diff → run a `/mops join`-style
  delta against the workspace (**create every docs file the new version expects — read the
  skeleton in BOOTSTRAP §15 step 7 rather than a list quoted here, which goes stale** —
  update guide rules, refresh Mops-in-Multica's instructions, surface new/renamed
  commands) → report what was adapted. Versions compare via the skill's frontmatter
  `version` + CHANGELOG. **Migrations belong to the NEW version**: updating multica-ops
  (via `/mops upgrade` or `/mops join`), first fetch the latest version from the canonical repo
  (github.com/jamillazarev/multica-ops) and follow **its** migration instructions — the
  old version can't know how to migrate forward, only the new one does. The CHANGELOG is
  the migration map: read every entry between the installed and the new version. This
  clause itself is the forward-compat bootstrap — even an old version knows to hand over.
- **`/mops switch`** — providers auto-appear as runtimes, so switching is reassignment:
  per-agent `agent update --runtime-id --model --thinking-level`; whole-provider =
  assisted migration (install/auth/`daemon restart`, tier remap, smoke test), the full
  remap previewed first.

