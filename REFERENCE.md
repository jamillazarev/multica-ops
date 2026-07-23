# Reference — an autonomous agent team on Multica

Deep companion to `multica-ops`. Project-agnostic process logic, reusable in
any Multica workspace.

Principle: **lean on Multica's native primitives; write instructions only where the
platform can't help itself.**

## Contents

- [1. Objects](#1-objects)
- [2. Four trigger paths](#2-four-trigger-paths)
- [3. Roles and what's native](#3-roles-and-whats-native)
- [4. Feature structure and stages](#4-feature-structure-and-stages)
- [5. The full flow (Kanban)](#5-the-full-flow-kanban)
- [6. Minimal custom layer (only the platform's gaps)](#6-minimal-custom-layer-only-the-platforms-gaps)
- [7. Operational practices](#7-operational-practices)
- [8. Anti-patterns](#8-anti-patterns)
- [9. The human's role](#9-the-humans-role)
- [10. Multica CLI — the full command surface](#10-multica-cli-the-full-command-surface)
- [11. Frameworks — picked per task, never one-size](#11-frameworks-picked-per-task-never-one-size)
- [12. Token economy — what actually moves the needle](#12-token-economy-what-actually-moves-the-needle)

## 1. Objects

| Object | What it is |
|---|---|
| **Workspace** | Top container: projects, issues, agents, members |
| **Project** | A group of issues. Has a **lead** — a human OR an agent |
| **Issue** | A unit of work. May have **sub-issues** (one nesting level). Carries native **start date · due date · priority** — dates are constraints, not decoration |
| **Sub-issue** | A child task with one executor; its **`stage`** number groups it into a barrier |
| **Agent** | An autonomous worker (model + skills + instructions + runtime) |
| **Squad** | A group of agents with one **leader**. Assigned *as a squad*, the leader **routes and does not implement**; the same agent assigned **directly** does its own craft — routing is a mode, not a separate career |
| **Project resource** | **Two types exist, verified against the CLI**: `--type` documents `github_repo` and `local_directory`, and `--url` is accepted only for the former — no GitLab, Gitea or self-hosted git today, so say that plainly rather than "I haven't checked". (`--ref` takes a generic JSON payload, so the server may accept more than the CLI exposes; that is a question for the vendor, not a guess to act on.) What a project's agents work on: **`github_repo`** (cloned per task into an isolated worktree → unlimited parallelism) or **`local_directory`** (a folder on one daemon's machine, **serialized by a per-directory lock** — one task at a time, forever; max one per project+daemon) |
| **Task** | One agent run (queued → dispatched → running → completed/failed); every trigger = a new task |

The hierarchy is exactly two levels: `issue → sub-issues`. `stage` is a number on a
sub-issue, not another level.

**Operating-mode switches.** **Switching is boundary-safe — nothing running is ever killed, no stop needed.** Flow changes take effect at the next feature boundary in both directions: the in-flight feature finishes as started, then either the conductor pulls the next one (manual→auto) or the conveyor parks and waits (auto→manual). An immediate halt is a different thing — `/stop`. Hiring switches apply to future hires at once, and on returning to manual Mops in Multica reports every hire made meanwhile. Mechanics: update the mode section in the guide skill plus the conductor's and Mops-in-Multica's instructions — no daemon restart, subsequent runs read the new state.

**Two seats — lanes.** **Lanes — each seat redirects to the other's strength:** Multica → console for the heavy/machine/interactive (build, hire, integrations, secrets, git/deploy, ops); console → Multica for living with the running team (the board, an agent in its thread, reviewing in context, staying reachable, autopilots). The guide encodes both redirects. **The *Where* tag is a recommendation, not a lock.** Mops in Multica is a real runtime with a workdir — it *can* push/deploy/shell **if creds and tooling are wired in**; the seat difference is what's already wired plus the costs (async, shared limit, blast radius of keys in an agent's env). No computer at hand → run a console job from Multica and name the cost. Truly console-only = what's bound to the user's own machine (local files, personal SSH, the daemon). Never refuse a doable action over the "wrong" seat.

**Multiple workspaces.** A user can have several workspaces (separate companies). The console operates on **one at a time** — the profile's default (`workspace list` shows them). When more than one exists, Mops **confirms which workspace it's acting on** before doing anything, and switches on request: `workspace switch <id>` (or `--workspace-id` per command) — `/workspace [name]`. Each workspace is its own company — own team, roadmap, and, if enabled, its own resident Mops in Multica; nothing crosses between them. A Mops in Multica lives in exactly one workspace, so switching is a console-only notion.

## 2. Four trigger paths

1. **Issue assignment** — to a squad wakes only the leader; to an agent runs it.
2. **`@`-mention** — `[@Name](mention://agent/<uuid>)` / `mention://squad/<uuid>`;
   agents may mention agents. Direct self-loops are blocked; indirect cycles are not.
   Editing a comment does not re-trigger.
3. **Chat** — a standalone conversation outside issues.
4. **Autopilot** — cron/webhook only; never "a stage finished".

## 3. Roles and what's native

| Process role | In Multica | Native? |
|---|---|---|
| Conductor (backlog, decomposition, acceptance) | Agent = project lead + instructions | lead is native; behaviour is custom |
| Discipline lead | Squad leader | ✅ |
| Executor | Agent, squad member | ✅ |
| Review gate / cross-cutting reviewer | Agent invoked by `@`-mention | ✅ |

Nuance: **when woken as the squad**, a leader does not implement — it delegates via mention and records
`multica squad activity`. Solo work goes to an agent directly. At the **sub-issue**
level everyone executes, including leads — "the lead doesn't code" applies only to a
feature assigned to the squad.

What Multica does NOT have natively: an auto-conductor for the whole backlog. That
single gap is closed by the conductor's instructions + a human starting features
(later: a scheduled autopilot).

## 4. Feature structure and stages

Sub-issues are grouped by stages (`--stage N`). Barrier: the parent wakes when ALL
stage-N sub-issues are `done`, then releases N+1.

```
Feature (issue) — owner: owning squad or the conductor
├─ stage 1  Build    implementation sub-issues → executors/squad
├─ stage 2  Review   verification/review       → QA/review squad (parallel gates)
└─ stage 3  Accept   accept + merge + archive  → conductor (terminal)
```
Cross-discipline features prepend a stage: `1 Design → 2 Build → 3 Review → 4 Accept`.
Gates that can independently reject work sit as separate sub-issues on the **same**
review stage — the barrier waits for all, so they run in parallel (code review and
design review catch different failures). Gate only what a feature can violate.

Ordering: **within** a feature — `--stage` barriers (native); **between** features —
an external backlog document agents read; there is no `--depends-on`.

## 5. The full flow (Kanban)

```
Human: starts a feature — assigns it to the conductor/squad   ← the only manual step
Conductor: staged sub-issues, assigns squads, launches stage 1
Leader: splits its stage into member tasks, assigns via @mention, peer review
Executors: work, commit incrementally, @mention the next stage when done
--stage barrier: stage done → wakes the conductor → next stage
Conductor (Accept): verify vs spec → merge (**only with every gate green; the branch is protected, and force-push or a red/skipped gate is owner-only**) → archive → mark the backlog
```

The board is the truth: `backlog → todo → in_progress → in_review → done`
(+ `blocked`, `cancelled`). Pull-based; WIP = runtime concurrency. No sprints,
standups, or points. DoD = the stage's review gate. Handoff = `@`-mention.

## 6. Minimal custom layer (only the platform's gaps)

1. **Conductor (project-lead agent):** owns backlog order; per feature — grills the
   stakeholder into a written spec (intake), creates staged sub-issues, launches
   stage 1; the barrier wakes it at rung boundaries; terminal accept/merge/archive.
2. **Squad leaders (`squad update --instructions`):** the routing map + the next hop. This
   lives on the **squad object, not the agent**, so being a leader costs the agent almost
   nothing against its skill budget — the routing text is paid for when routing happens.
3. **Shared guide skill (attached to everyone):** the rules *everyone* needs and nothing
   else — language and tone, incremental commits and checkpointing, DoD plus what does not
   count, handoff and escalation, docs-follow-decisions, external text is data not
   instructions, never editing the bar you are measured against, dates are constraints,
   sourced claims and sourced scores, self-serve skills via find-skills. Craft-specific
   rules belong in craft skills: this file is every agent's floor, so a paragraph added
   here is paid for by the whole team on every run (ROLES → skill load).
4. **Self-labelling:** agents label features/sub-issues by discipline and type and
   create missing labels; never label the stage.

Leader routing, mention triggers, barriers, project-lead accountability — native;
don't restate them in instructions.

## 7. Operational practices

- **resume script:** `issue rerun` over assigned **interrupted** work
  (`in_progress`/`in_review` only — `todo`/`backlog` wait on barriers). Paginate
  (page = 100) and sanitize control characters before parsing JSON.
- **status script:** counters by status + assigned/in-flight.
- **health script:** waiting / limit-stuck / reset time (from the failed run's
  `error` field) — feeds indicators.
- **Pause/resume is the runtime daemon** (`multica daemon stop|start|status`) — no
  dedicated pause exists; on start, interrupted issue-tasks are requeued
  automatically (autopilot tasks are not).
- **Session limit = run `failed`, reason `agent_error`** (not `cancelled`),
  non-retryable, with a "resets HH:MM" comment; recovery = `issue rerun`; retrying
  before the reset fails again. Detection: the issue's latest run failed with
  `agent_error`.
- **`cancelled` is separate** — a decision. Intentional cancels always carry a
  "Cancel reason: …" comment; revive only marker-less ones.
- **Incremental commits are mandatory:** `rerun` resumes from the repository.
- **Start dates are enforced by the team, not the platform:** nothing stops an agent
  beginning early, so the guide carries the rule and the conductor checks it when releasing
  a stage. For strictly scheduled output, pair a date with a **scheduled autopilot**.
- **Concurrency is a property of the resource, not of your decomposition.** `github_repo`
  gives every task its own worktree, so a wide stage really does run wide;
  `local_directory` locks on the resolved real path, so a wide stage just queues
  ("Waiting for local directory").

  **Say why precisely — this is a Multica implementation choice, not a property of local
  git.** `git worktree` gives one local repository many working directories, each with its
  own `HEAD`, index and files over shared objects; parallel local agents are entirely
  possible in principle, and that is exactly what Multica itself does for `github_repo`.
  What `local_directory` does is run the agent **directly in the path you gave**, with no
  worktree and no copy — so the only safe thing left is a lock on that path. Telling an
  owner "local repos can't parallelise" is wrong and ages badly; tell them "**Multica's
  `local_directory` doesn't create worktrees, so it serialises**".

  Today's options if someone needs local *and* parallel: one Multica project per manually
  created worktree (works, but scatters sub-issues across projects), or several
  daemons/runtimes each holding its own worktree (routing becomes manual — Multica does not
  balance). Both are workarounds; the clean fix is a resource type that pools worktrees, and
  that is a feature request worth filing rather than a limitation to design around.
  Choose `local_directory` only when the work genuinely cannot leave one machine.

**Heartbeat on long runs.** A run that goes quiet for minutes reads as a crash. Two homes:
in the **CLI**, before a long operation state the expected duration and how to check, then
poll (`issue run-messages`, the board, `daemon status active_task_count`) and print a
progress line as each sub-issue finishes — not a silent wait for the whole thing. When the
**console is closed**, the resident Mops carries it: `/status` on demand plus issue comments
as stages complete, and a nightly sweep so nothing sits unseen. The status digest agents
already produce *after* work (the board + what each shipped) is exactly what to stream
*during* it.

**The stage ladder is per issue *type*, not per project.** A feature runs discovery → build
→ review → ship; an article runs brief → draft → edit → publish; a bug jumps to build+review.
They coexist on **one board** — the type (a label) selects the ladder and the DoD, not a
separate project. So a **site with features *and* content** is normally one project with two
issue types, not two projects: content is an issue with a content DoD (fact-check, brand
voice, SEO) and a due date, no build stage. Split into two projects only when content is a
stream with its own team and cadence (a real editorial calendar), the same "is this a stream
or a one-off" call as everything else. Ongoing upkeep — a living feature, a forever
calendar — is just recurring issues or an autopilot; the format already holds it.

## 8. Anti-patterns

- ❌ A squad leader executing a whole feature that was addressed **to the squad** — that
  serializes everyone behind one agent. Assigned directly, the same agent works normally.
- ❌ Circular @-mentions between agents (indirect cycles are not blocked).
- ❌ Review ping-pong — the same work bounced a third time; that's an unclear spec, escalate.
- ❌ The author moves the bar — acceptance criteria, review rubric or budget edited by
  whoever is being measured against them. Propose to a human; never adjust in passing.
- ❌ Self-review, or review by the author's own provider — models are generous with their
  own output. Route the gate to a different agent, ideally on a different runtime.
- ❌ A gate that checks the process instead of the artifact — agents legitimately reach
  goals by other routes; judge the outcome, or you measure obedience.
- ❌ Patching a poisoned thread — once an agent has built on a wrong premise, corrections
  layer rather than replace. Restart the task with a corrected brief instead.
- ❌ "Prepare the PR" read as "merge the PR" — name the boundary in the ask, every time.
- ❌ Treating a rule in the guide as enforcement — text instructs, it does not constrain.
- ❌ Two parallel sub-issues owning the same file — assign ownership at decomposition.
- ❌ Letting an agent grind past three attempts at one error — reassign instead.
- ❌ Widening a stage past ~5 concurrent agents — coordination cost overtakes throughput.
- ❌ Approvals ageing invisibly — a pending human decision is a blocked flow, surface it.
- ❌ Nesting sub-issues deeper than one level — order lives in `stage`, not nesting.
- ❌ Expecting autopilot to react to "a stage finished" — cron/webhook only.
- ❌ Restating native behaviour in instructions.
- ❌ Silently trimming the backlog — use an explicit `blocked` + a backlog note.

## 9. The human's role

- **Now:** start each feature (via the assistant). The conveyor takes it to archive.
- **Later:** automate starting the next feature (conductor on archive / a scheduled
  autopilot) — only after the flow runs clean by hand.

## 10. Multica CLI — the full command surface

This map makes multica-ops a **complete CLI-competence layer**: an agent loading the
skill knows not just the method but **every command that exists**. It's the full surface
of `multica` **v0.4.8** — but it lists *what exists*, not exact flags, since the CLI
evolves, so **always confirm with `multica <group> <cmd> --help`** and consult
https://multica.ai/docs. **Precedence: live `--help` wins over this map** — on any
mismatch trust the CLI, and regenerate this section when the skill is upgraded
(`multica --help` + per-group `--help` is the whole procedure). The `/cli` command is the **framework-free escape hatch** — run
or explain any of the below directly, no methodology assumed.

**Work objects**
- `agent` — archive · avatar · create · env · get · list · restore · skills · tasks · update
- `squad` — activity · create · delete · get · list · member · update
- `project` — create · delete · get · list · resource (add/list/remove/update) · status · update
- `issue` — assign · cancel-task · children · comment (add/delete/list/resolve/unresolve) · create · get · label · list · metadata · property · pull-requests · reorder · rerun · run-messages · runs · search · status · subscriber (add/list/remove) · update · usage
- `label` — create · delete · get · list · update
- `property` — archive · create · get · list · unarchive · update (workspace custom issue properties)
- `repo` — add · checkout · list · remove
- `skill` — create · delete · files · get · import · list · search · update
- `autopilot` — create · delete · get · list · runs · trigger · trigger-add · trigger-delete · trigger-rotate-url · trigger-update · update
- `workspace` — create · get · list · member (invite/list) · switch · update
- `attachment` — download · upload
- `chat` — history · thread (**read-only**; scoped to the agent's own current thread)

**Runtime & platform**
- `daemon` — start · stop · restart · status · logs · disk-usage (the local agent runtime)
- `runtime` — activity · delete · list · profile · rename · update · usage
- `setup` — cloud · self-host (configure the CLI, authenticate, start the daemon)
- `auth` — status · logout
- `config` — set · show
- `user` — profile
- `login` · `update` · `version` — sign in · self-update the CLI · print version

**Operating conventions** (aligned with the vendor's official `multica-cli` skill — attach
it to agents that drive the CLI; it owns *how to operate safely*, this map owns *what
exists*):

- **Start safely.** Before operating: confirm the CLI version, that auth is valid, and
  **which workspace/profile is active** — acting against the wrong workspace is the
  expensive mistake.
- **Mentions are not free, and not equal.** Mentioning an **agent or squad enqueues a
  run** — that is a task, spending budget and shared limit. Mentioning a **member or an
  issue does not**. So `@`-mention an agent when you want work done, and reference a person
  or an issue when you only want them informed. Casual agent mentions are how a team
  quietly burns its window.
- **Write comment bodies from a file, not inline.** Use `--content-file` (UTF-8) or
  `--content-stdin`; shell interpretation mangles multi-line and non-ASCII content, and a
  mangled comment is a mangled handoff.
- **JSON first, sanitised.** Parse `--output json`, strip control characters before
  parsing, and paginate — a truncated parse silently loses work.
- **Confirm before writes.** Reads are free; writes have side effects — status changes move
  the board and can release a stage barrier, assignment starts an agent.
- **Link PRs by routable key.** Put the issue key (e.g. `MUL-123`) in the branch or PR
  title so `issue pull-requests` can associate them; an unlinked PR is invisible to the
  conveyor's accept step.
- **Across workspaces, state the context.** An agent operating on a workspace it doesn't
  belong to must pass the workspace explicitly rather than relying on the default profile.

**Usage & cost** (see the cost/effort ledger in SKILL.md): `issue usage` and
`runtime usage` return **tokens** (input/output/cache, per model); `$` and time are
**derived** — the CLI does not return them.

## 11. Frameworks — picked per task, never one-size

The conductor/Mops **names the framework it's using and why** (evidence over opinion);
defaults below, alternatives when the context demands, the choice recorded in the spec.

| Need | Default | Reach for instead when… |
|---|---|---|
| Prioritization | **ICE** — each score citing its basis (analytics · tickets · revenue share · comparable past work from the ledger) or marked a judgement call; ranking re-tested by moving each score ±1, and a top that reorders is reported as undecided rather than presented as an answer | RICE (reach matters, data exists) · Kano (delight vs table-stakes) · MoSCoW (scope negotiation with a client) |
| Success metrics | **North Star + supporting metrics** (set at discovery) | **HEART** (UX quality) · AARRR (funnel/growth). **Choosing** a metric → **GAME** (Goal → Action → Metric → Evaluation — metrics tied to goals, not vanity); **focusing** teams/periods → **OMTM** (one metric that matters per team per period, under the North Star) |
| Goals → work | roadmap releases | OKR (multi-team alignment, quarter horizon) · **Impact Mapping** (Why → Who → How → What: from a goal through actors and impacts to deliverables — bridges strategy to roadmap items) |
| Discovery & risk | JTBD + user stories, pre-mortem | SWOT (strategy review) · Porter (market entry) · Opportunity Solution Tree (map opportunities → solutions before committing to features) |
| Design & UX review | design-system conformance (Design QA) | **Nielsen's 10 heuristics** (usability lens) · WCAG (a11y) · cognitive walkthrough (first-use flows) |
| Retro / learn | `/measure` Learn items | 5 Whys (incident root cause) |

Frameworks are seeds too — an unlisted one the user names gets researched and applied
the same way.

## 12. Token economy — what actually moves the needle

**Worked example — illustrative volumes, real price list.** A twelve-agent company on a
$300/month envelope, one month of steady work:

| | tokens | share |
|---|---|---|
| cache **reads** | 160,000,000 | **88%** |
| cache writes | 16,000,000 | 9% |
| output | 3,600,000 | 2% |
| input | 2,000,000 | 1% |

Per-million list prices (Opus-class): input `$5` · output `$25` · **cache read `$0.50`** ·
**cache write `$6.25`**. That bill comes to **$280**. Priced as if every cache read were
plain input, the same work costs **$1,000** — caching is carrying **72%** of it.

**Consequences, in order of impact:**

1. **Keep the cached prefix stable.** The guide skill + agent instructions are what gets
   cached. Every edit invalidates it: you pay a cache *write* (dearer than input) and lose
   cheap reads until it warms again. **Batch guide/instruction changes** — apply them at
   `/sync` or a module toggle, never as a dribble of small edits mid-flight.
2. **Progressive disclosure.** Only `SKILL.md` is always loaded; companions load on
   trigger (see the routing table). Adding to a companion is nearly free; adding to the
   core is paid on every run, by every agent.
3. **Model tiering.** Top tier for reasoning roles (conductor, QA, security), mid for
   build, cheap/text for translation and boilerplate.
4. **Terse by default.** The `caveman` skill (lite mode) on every agent; issues and
   comments written like a product page — first line is the point, lists over prose.
5. **Don't re-derive.** Read the file you need rather than reconstructing it from memory,
   and commit incrementally so a rerun resumes from the repo instead of redoing work.

**Not our layer:** *model* compression (quantization, pruning, distillation) applies to
teams that host their own models. Consuming an API or a subscription, the lever is
**context economy**, not model weights.
