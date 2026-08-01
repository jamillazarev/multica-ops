# Commands

**You never need a command** — plain language in any language works; Mops parses intent and
asks when ambiguous. **Every command is namespaced** (`/multica-ops:<verb>`) because that is
how plugin commands work: the prefix is what stops two plugins colliding over one verb. There
is **no bare `/<verb>`**, and outside Claude Code there are no slash commands at all.

**Eighteen doors, and the palette is the point.** A verb earns a door when it is **its own
flow, reached by name, repeatedly** — never as a synonym for another door, and never as a
phase inside one. Everything else is **a sentence to the dispatcher**, which costs nothing to
keep and is listed further down so the capability stays findable.

**`/multica-ops:mops <anything>`** is that dispatcher: free text, any language, any of the
flows below (`/multica-ops:mops brand`, `/multica-ops:mops move crossfeed to the next release`).
*Where* column: 🖥️ console (heavy/machine/interactive) · 🏢 Mops in Multica (presence/async) ·
⇆ either.

## The eighteen

| Command | Where | Routes to |
|---|---|---|
| `/multica-ops:mops <anything>` | ⇆ | **the front door** — free text, or nothing at all: day zero, then read what you have and route. Also the way to every flow in *Everything else* below |
| `/multica-ops:init` | 🖥️ | bootstrap from zero: **day zero** (BOOTSTRAP §0) → three routing questions → shaping → interview → stand up. Full procedure: FLOWS |
| `/multica-ops:join` | 🖥️ | join an existing setup — audit + interview delta, then gaps → fixes; reconcile an existing Mops in Multica. Full procedure: FLOWS |
| `/multica-ops:import` | 🖥️ | bring a backlog in from another tracker (Linear, Jira, GitHub Issues, Trello, CSV): extract → show the mapping → create parents then children, **unassigned**, with `source_id` in metadata so a rerun resumes. **Its own door because declaring a crossing turns on two rules** — the mapping is shown before anything is written, and the imported text is treated as untrusted. PLAYBOOKS |
| `/multica-ops:quick <task>` | 🖥️ | **the quick-job shape, direct** — 3 questions (deliverable · repo · language), 1–2 agents, build → review, **none of the company machinery**; whatever it outgrows is added later |
| `/multica-ops:consult [who] <question>` | ⇆ | **a question, not a build**: answered as an advisor with **zero standing footprint** — no workspace, issue, team or doc created, nothing persisted unless you ask. Address Mops (default), any team agent, an expert, or the theatre. *Nothing will be created* is worth being able to demand. Full flow: FLOWS |
| `/multica-ops:status` | ⇆ | the console read, opening with a **countable state line** ("3 need you · 2 running · 4 closed since Tuesday"), then two parts that differ in kind: **needs you** — open requests with their **age and what the wait costs**, staying until answered — and **happened** — events since your last look, ageing out by themselves. Drift is reported separately. Plus spend and **ripe deferrals**; **offered unprompted when you return after time away** |
| `/multica-ops:next` | ⇆ | start the next feature from ROADMAP.md — the manual flow's main button |
| `/multica-ops:feature <text>` | ⇆ | add a feature mid-flight — raw description is fine: the conductor grills you into a spec → **ICE** against the backlog → proposed release slot → your approval → queued. Too fuzzy to spec? It offers discovery first |
| `/multica-ops:ship [release]` | 🖥️ | the **go-live step — whatever "live" means here**: ship code, launch a flavour, publish an episode, send the batch. Gates green → release → notes → tag → announce (deploy and announce are outward → **owner-confirmed**); writes the **cost/effort ledger** and marks it shipped |
| `/multica-ops:bug <text>` | ⇆ | the **urgent lane that jumps the queue** — a defect, recall or correction. Minimal spec → **Build (first sub-step: a reproduction / pass-fail signal, before any fix) + Review**, owner notified; not ICE-prioritized |
| `/multica-ops:recover` | 🖥️ | revive after limits — rerun interrupted work, revive marker-less cancels; **a rerun resumes, it does not restart** |
| `/multica-ops:hire <role\|person>` | 🖥️ | add to the team — Mops asks **agent or real person**. Agent → the role-builder. Person → `workspace member invite` (owner-confirmed, outward) → access and review checkpoints → recorded in TEAM.md |
| `/multica-ops:fire <agent\|member>` | 🖥️ | offboard — **surface the risk first** (open issues, squad leadership, sole-owner skills, held checkpoints) → reassign → archive. **Removing a real member is the owner's own action in the Multica app**, and Mops says so |
| `/multica-ops:audit` | 🖥️ | health **and** opportunities: token burn, limit-killed runs, tier misfits, stalled work, hygiene, mention cycles, secrets, design-system drift · **process improvements** · **integrity checks** (facts past their check-date, gates where author and reviewer coincide, edits to locked surfaces, unsourced ICE scores) · **the waste slices** (PLAYBOOKS → ledger) · **the gates table** (each `enforced_by` still true — PLAYBOOKS → Gates). Pulls in the health sweep. Output: finding → recommendation → impact |
| `/multica-ops:report <text>` | ⇆ | **something went wrong, or made the work harder — and you do not have to know whose defect it is.** Decided from the evidence: a defect in **your product** goes to the urgent lane (`bug`); friction in **your workspace** becomes a line in `docs/FIELD-NOTES.md`, swept at the next `audit`, an issue on the **second** occurrence with both named; friction in **this skill or Multica** is packaged from evidence, de-identified, and **written to a file outside your repository** with its path said and the routes named. **You post it, never us** |
| `/multica-ops:upgrade [skill\|all]` | 🖥️ | **the one command for getting current**, four layers: this skill's bytes (**Mops runs it; content applies on next read** — a restart only for a new or renamed command or a hook), the workspace migration, imported skills, and the CLI locally and on runtimes — **reported, not run**, and only when `active_task_count` is 0. Re-screen → dry-run → back up → apply → reconcile → verify/rollback, then the plain-language tour of what changed |
| `/multica-ops:skill <create\|import\|optimize\|release>` | 🖥️ | the toolkit's lifecycle: **create** (a routine seen twice), **import** (screen for danger and injection → trim → attach with provenance), **optimize** (fail-closed compression; `NOT_COMPRESSIBLE` is a valid answer), **release** (proven → de-identified → its own repo → re-imported). PLAYBOOKS |
| `/multica-ops:cli <command>` | 🖥️ | **raw Multica CLI escape hatch** — run or explain any `multica …` command directly, no methodology assumed. Backed by REFERENCE §10; destructive and outward commands still need owner sign-off |

## Everything else is a sentence

These are **flows, not commands** — every one is reached with `/multica-ops:mops <verb>` or
plain language in any language. They lost their door because a door is paid for in every
session by every agent, and these are not the ones people reach for by name.

**Planning and the product**

- **`roadmap`** — view or rebuild the release plan, re-run ICE, release surgery (cut, extend, reprioritize). *"show me the roadmap"*
- **`move` · `drop`** — one feature between releases or to the backlog · cancel with a reason (or park it). *"push crossfeed to the next release"*
- **`map`** — the product as a map, not the repo as a tree: `docs/MAP.md`, the things and the moves in the product's own words, current state only, ending honestly with *not mapped yet*. *"map the product"*
- **`measure`** — pull the success metrics set at discovery, compare to target, file a **Learn** item, record the ledger. *"did it move the metric?"*
- **`research`** — point research without a feature; cited findings land in `docs/research/`, each carrying the date it was true. *"look into how competitors price this"*
- **`discovery`** — spin up a fuzzy idea: research, competitors, team brainstorm → proposal. *"I'm thinking about onboarding"*
- **`feedback`** — log an incoming signal, then triage into **accept · decline with a reason · duplicate · snooze**; declining is a normal, cheap outcome. *"a customer says export is confusing"*
- **`process`** — discover a craft's real process, then a tool per step by function. *"how should we run this kind of work?"*

**The team and its shape**

- **`team` · `squad`** — the roster (🎭 theatre entities excluded from headcount) · create and reshape squads and their routing. *"who's on what?"*
- **`update`** — reconfigure an agent or a person: instructions, skills, squad, tier, or a project lead. *"make the copywriter own localization too"*
- **`crew`** — crew mode: executors and gates, **no conductor**, the owner is the PM. The default offer after an import when no conductor stands. *"just execute, I'll prioritise"*
- **`module`** — toggle an opt-in module (resident Mops, design system & brand, experts, personas, Design QA, social). *"turn on personas"*
- **`audience`** — segments, ICP, personas as documents, staged proto or validated, with live participants asked about explicitly. Full theatre: MODULES
- **`validate`** — an artifact past the validators; synthetic and live reactions **counted separately**, synthetic verdicts **direction-only**, and the gate handed back to whoever owns it
- **`brand`** — create or evolve the brand book; an existing brand is audited, not rebuilt

**Governance and cost**

- **`access` · `reviews`** — what a member may direct Mops to do · which flows need a named human's sign-off. *"anna can start features but not spend"*
- **`budget`** — the envelope: amount, period, currency, credits with their expiry cliffs; it **shapes advice, not only caps it**. *"$50 a month"*
- **`autonomy` · `pace`** — who starts the next feature and whether hiring needs a yes · how wide to fan work out. *"go non-stop"* · *"faster"*
- **`autopilot`** — scheduled or webhook automations; **a webhook URL is all four owner-gated kinds at once**

**Operations**

- **`health`** — the silent-failure sweep: runtimes, integrations, tokens, free-tier headroom, branch protection, daemon, limits. Folded into `audit`
- **`sync`** — two-way reconcile of drift the fingerprint caught, attributed before it is asked about
- **`start` · `stop`** — the local daemon. *"stop everything"*
- **`workspace`** — list or switch the active workspace; Mops confirms which company it is acting on
- **`switch`** — reassign runtime, model or thinking-level per agent, or an assisted whole-provider migration
- **`connect`** — integrations: MCP registries first, study the tool, wire access, register in `docs/TOOLING.md`

In the workspace the user talks to **Mops in Multica** (subtitle *"Executive Advisor ·
resident"*) — no commands needed, plain chat; it answers status-style questions natively and,
for anything 🖥️, points back to the console.
