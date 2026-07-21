# Reference — an autonomous agent team on Multica

Deep companion to `multica-ops`. Project-agnostic process logic, reusable in
any Multica workspace.

Principle: **lean on Multica's native primitives; write instructions only where the
platform can't help itself.**

## 1. Objects

| Object | What it is |
|---|---|
| **Workspace** | Top container: projects, issues, agents, members |
| **Project** | A group of issues. Has a **lead** — a human OR an agent |
| **Issue** | A unit of work. May have **sub-issues** (one nesting level) |
| **Sub-issue** | A child task with one executor; its **`stage`** number groups it into a barrier |
| **Agent** | An autonomous worker (model + skills + instructions + runtime) |
| **Squad** | A group of agents with one **leader**; the leader routes, never implements |
| **Task** | One agent run (queued → dispatched → running → completed/failed); every trigger = a new task |

The hierarchy is exactly two levels: `issue → sub-issues`. `stage` is a number on a
sub-issue, not another level.

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

Nuance: a squad leader **does not implement** — it delegates via mention and records
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
Conductor (Accept): verify vs spec → merge → archive → mark the backlog
```

The board is the truth: `backlog → todo → in_progress → in_review → done`
(+ `blocked`, `cancelled`). Pull-based; WIP = runtime concurrency. No sprints,
standups, or points. DoD = the stage's review gate. Handoff = `@`-mention.

## 6. Minimal custom layer (only the platform's gaps)

1. **Conductor (project-lead agent):** owns backlog order; per feature — grills the
   stakeholder into a written spec (intake), creates staged sub-issues, launches
   stage 1; the barrier wakes it at rung boundaries; terminal accept/merge/archive.
2. **Squad leaders (`squad update --instructions`):** the routing map + the next hop.
3. **Shared guide skill (attached to everyone):** language, incremental commits, DoD,
   per-feature-type tracks, self-serve skills (find-skills → conductor imports).
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

## 8. Anti-patterns

- ❌ A squad leader as a feature's executor (it only routes).
- ❌ Circular @-mentions between agents (indirect cycles are not blocked).
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
of `multica` **v0.4.4** — but it lists *what exists*, not exact flags, since the CLI
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

**Usage & cost** (see the cost/effort ledger in SKILL.md): `issue usage` and
`runtime usage` return **tokens** (input/output/cache, per model); `$` and time are
**derived** — the CLI does not return them.

## 11. Frameworks — picked per task, never one-size

The conductor/Mops **names the framework it's using and why** (evidence over opinion);
defaults below, alternatives when the context demands, the choice recorded in the spec.

| Need | Default | Reach for instead when… |
|---|---|---|
| Prioritization | **ICE** | RICE (reach matters, data exists) · Kano (delight vs table-stakes) · MoSCoW (scope negotiation with a client) |
| Success metrics | **North Star + supporting metrics** (set at discovery) | **HEART** (UX quality) · AARRR (funnel/growth). **Choosing** a metric → **GAME** (Goal → Action → Metric → Evaluation — metrics tied to goals, not vanity); **focusing** teams/periods → **OMTM** (one metric that matters per team per period, under the North Star) |
| Goals → work | roadmap releases | OKR (multi-team alignment, quarter horizon) · **Impact Mapping** (Why → Who → How → What: from a goal through actors and impacts to deliverables — bridges strategy to roadmap items) |
| Discovery & risk | JTBD + user stories, pre-mortem | SWOT (strategy review) · Porter (market entry) · Opportunity Solution Tree (map opportunities → solutions before committing to features) |
| Design & UX review | design-system conformance (Design QA) | **Nielsen's 10 heuristics** (usability lens) · WCAG (a11y) · cognitive walkthrough (first-use flows) |
| Retro / learn | `/measure` Learn items | 5 Whys (incident root cause) |

Frameworks are seeds too — an unlisted one the user names gets researched and applied
the same way.
