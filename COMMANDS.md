# Commands

**You never need a command** — plain language in any language works; Mops parses intent
and asks when ambiguous. Commands are optional thin aliases (a plugin nicety), grouped
below, aliases in parentheses; **arguments are free text** (`/mops move the crossfeed thing
to the next release` is fine). **`/multica-ops:mops <anything>`** is the free-text dispatcher (plugin commands are namespaced). A short **`/mops`** is installed on first run by the plugin's SessionStart hook — check it exists before quoting either form, and outside Claude Code there are no slash commands at all
(collision-proof vs Claude Code built-ins; namespaced `/multica-ops:<cmd>` also works) —
Mops the pug is the skill's mascot. *Where* column: 🖥️ console (heavy/machine/
interactive) · 🏢 Mops in Multica (presence/async) · ⇆ either.

**How to read this table.** Each row is **the command you type** — `/mops <name>` (e.g.
`/mops feature …`), shown in full so you copy it, not translate it. `/multica-ops:<name>`
reaches the same flow, and plain language always works, so you never truly need one. There
is **no bare `/<name>`** (that is the one form that doesn't exist); outside Claude Code there
are no slash commands at all, only plain language.

**Setup**
| Command | Where | Routes to |
|---|---|---|
| `/mops init` | 🖥️ | bootstrap from zero: **day zero** (BOOTSTRAP §0) → three routing questions → shaping → interview → stand up. Full procedure: FLOWS |
| `/mops crew` | 🖥️ | **crew mode**: executors and gates, the owner is the product manager — no conductor, discovery or roadmap ceremony. Default offer after `/mops import`; adding a conductor later is an upgrade, not a redo |
| `/mops join` | 🖥️ | join an existing setup — `/mops audit` + interview delta, then gaps → fixes; reconcile an existing Mops in Multica. Full procedure: FLOWS |

**Features & roadmap**
| Command | Where | Routes to |
|---|---|---|
| `/mops research <question>` | ⇆ | point research without a feature: market, competitor, tech, pricing — cited findings land in `docs/research/`; feeds discovery, specs, and expert reviews |
| `/mops brand` | ⇆ | create or evolve the brand: new → brand discovery → book → owner approval → systematize (tokens/templates → design system, voice → guide); existing → audit with a complete/add/rework verdict per piece |
| `/mops audience` (`/mops personas`) | ⇆ | audience work: segments, ICP, personas as documents (and, if the Personas module is on, matching agents); built/refreshed from research, used by design and marketing |
| `/mops validate <what>` | ⇆ | run an artifact past the validators: **Experts squad** gives an evidence-backed verdict (spec, architecture, pricing, roadmap), **Personas squad** reacts as the audience (mockup walkthrough, copy, onboarding). Neither exists? Say so and offer to enable them (`/mops module experts on`, `/mops module personas on` — hires the lineup with your confirmation) |
| `/mops discovery <text>` | ⇆ | spin up a fuzzy idea: research · competitors · team brainstorm → proposal; flows into `/mops feature` |
| `/mops feature <text>` | ⇆ | add a feature mid-flight — raw description is fine: the conductor grills the user with questions → spec → **ICE** prioritization vs the backlog → proposed release slot → user approval → queued. Too fuzzy to spec? Offer to route through `/mops discovery` first |
| `/mops next` | ⇆ | start the next feature from ROADMAP.md (manual flow's main button) |
| `/mops ship [release]` (`/mops release`, `/mops launch`, `/mops deliver`) | 🖥️ | the **go-live step — whatever "live" means for this project**: ship code, launch a snack flavor, publish an episode, send the batch. Confirm gates green → do/hand off the release → release notes → tag → announce (deploy/announce are outward → **owner-confirmed**); writes the **cost/effort ledger** (below) and marks it shipped in ROADMAP |
| `/mops measure [feature\|release]` | ⇆ | close the loop: the Analyst pulls the success metrics set at discovery, compares to target, reports the outcome, files a **Learn** item back to the roadmap, and records the **cost/effort ledger** (tokens · $ · time · per agent/human) from `issue usage` |
| `/mops bug <text>` (`/mops urgent`, `/mops hotfix`, `/mops incident`) | ⇆ | the **urgent lane that jumps the queue** — a defect, recall, or correction (broken build, wrong label on a batch, bad copy live). Minimal spec → straight to Build + Review, owner notified; not ICE-prioritized like `/mops feature` |
| `/mops feedback <text>` | ⇆ | log an **incoming signal from users/customers** — a complaint, request, review, or idea — then **triage** it (assess/sort) and file it: small → backlog, bigger → a `/mops discovery`. Feeds the next `/mops roadmap` |
| `/mops roadmap` (`/mops prioritize` = its rescoring pass) | ⇆ | view / rebuild the release plan; re-run ICE scoring across backlog/releases; **release surgery**: cut a release (features → backlog), extend it (pull from backlog or `/mops feature` new ones), reprioritize |
| `/mops move <feature> <release\|backlog>` | ⇆ | move one feature between releases or to the backlog |
| `/mops drop <feature>` | ⇆ | remove a feature: cancel with a `Cancel reason: …` comment (or park to backlog if it may return) |

**Team**
| Command | Where | Routes to |
|---|---|---|
| `/mops team` | ⇆ | roster: agents, roles, models, squads, who is on what |
| `/mops hire <role\|person>` (`/mops invite`) | 🖥️ | add to the team — Mops asks **agent or real person**. Agent → role-builder. Person → `workspace member invite <email>` (owner-confirmed, outward) → ask title/tasks → set `/mops access` + `/mops reviews` → record in TEAM.md |
| `/mops fire <agent\|member>` (`/mops retire`) | 🖥️ | offboard — first **surface the risk**: what they own/block (open issues, squad leadership, sole-owner skills/integrations, review checkpoints held) → propose a new owner and reassign → then **agent**: remove from squads/routing, archive; **person**: Mops does the prep, but **says plainly that removing a real member is the owner's own action in the Multica app (no CLI)** — it never removes a human itself, and firing a human is owner-only via their own Mops |
| `/mops update <agent\|member>` (`/mops role`, `/mops edit`) | 🖥️ | reconfigure an existing member — **agent**: `agent update` (name/description/instructions), skills, squad, model tier; **person**: TEAM.md role + `/mops access` + `/mops reviews`. Also reassign a **project lead** (`project update --lead`) |
| `/mops squad` | 🖥️ | create/reshape squads: members, leader, routing instructions |
| `/mops module <name> on\|off` | 🖥️ | toggle an opt-in module (resident Mops (in Multica), design system & brand, experts, personas, Design QA, social…) |
| `/mops budget [amount/period]` | 🖥️ | set or show the envelope: amount + period, currency (USD default), credits/grants with expiries, what counts; reports burn, runway and cost per shipped feature, and re-proposes the stack if the number changes |
| `/mops access <member> <full\|features\|status\|…>` | 🖥️ | set what a workspace member may direct Mops to do; owner always full; destructive/spend always → owner |
| `/mops reviews` | ⇆ | manage human sign-off checkpoints: which flows/stages @mention which person before proceeding (image-gen, publish, a stage, every feature); add / remove / list |

**Autonomy & automation**
| Command | Where | Routes to |
|---|---|---|
| `/mops pace [careful\|balanced\|fast]` | 🖥️ | the parallelism dial, changeable on the fly: how hard to fan work out vs. how careful — trades throughput against cost and blast radius, capped by the ~3–5 concurrent ceiling and by the resource (`local_directory` serialises regardless). REFERENCE §7 |
| `/mops autonomy [manual\|auto]` (`/mops hiring [manual\|auto]` = its hiring dial) | 🖥️ | presets: manual = user-started features + confirmed hires; auto = non-stop + autonomous hiring. Fine dials: `/mops autonomy flow auto`, `/mops autonomy hiring manual`. Switches are boundary-safe (see Operating modes) |
| `/mops autopilot` | 🖥️ | create/list/delete scheduled automations (cron/webhook): nightly sweeps, PR-merged hooks, social cadence — set up here, they *run* inside Multica |

**Operations**
| Command | Where | Routes to |
|---|---|---|
| `/mops status` | ⇆ | Mops digest: in flight, finished, stuck & why, waiting on the user, spend snapshot, **ripe deferrals from LATER.md**, and **pending owner approvals batched into one digest** (not scattered pings) — Mops in Multica answers this natively |
| `/mops recover` (`/mops continue`) | 🖥️ | revive after limits (rerun interrupted, revive marker-less cancels) |
| `/mops start` · `/mops stop` | 🖥️ | daemon start / stop (local runtime) |
| `/mops workspace [name]` | 🖥️ | list your workspaces / switch the active one (`workspace switch`); Mops confirms which company it's acting on when several exist |
| `/mops health` (`/mops runtimes`) | 🖥️ | full-circle check: runtimes (online/stale + affected agents), integrations & MCP reachability, API tokens/secrets (presence + probe + expiry), **branch protection where a remote exists** — a fence nobody installed is exactly the failure this skill warns about, daemon, limits → component → status → who it blocks → fix |
| `/mops upgrade [skill\|all]` | 🖥️ | **the one command for getting current** — four layers: this skill's bytes on your machine (**Mops runs the update itself and asks you to restart** — a skill can fetch new bytes but can't apply them to its own running self), the workspace migration, imported skills, and the CLI locally and on runtimes **only when `active_task_count` is 0**. Update = new bytes; upgrade = your workspace moves to them. Diagram: WORKFLOW. Then: **re-screen the new version first** (an upgrade ships unreviewed third-party code and instructions — diff it against the version you screened, and read what changed in the prose, not only the scripts) → dry-run impact report (skill + dependent agents/squads/autopilots/guide) → commit current to `docs/skill-backups/` (git = history; pre-upgrade SHA logged in `UPGRADES.md`) → apply → reconcile → verify/rollback |
| `/mops switch <role\|all> <provider>` | 🖥️ | reassign runtime/model/thinking-level per agent, or an assisted whole-provider migration (install/auth/daemon + tier remap + smoke test) |
| `/mops audit` | 🖥️ | health **and** opportunities — not just defects: token burn, limit-killed runs, model-tier misfits, stalled/blocked issues, hygiene (guide/find-skills/instructions/labels), mention cycles, secrets, **design-system hygiene** (unsystematized one-offs, token drift, convention violations — Component Library Audit helps); **plus process improvements** (better stage/gate design, tier savings, skills worth creating, routing tweaks, automation candidates) and **integrity checks** (facts past their check-date, a missing or stale `ARCHITECTURE.md`/`DECISIONS.md`, gates where author and reviewer coincide, edits to locked surfaces, **always-loaded skill weight per agent** — over the ceiling means a role wants splitting, not pruning; **unsourced ICE scores**, and rankings that flip when a score moves by one); pulls in `/mops health`. Output: finding → recommendation → impact |
| `/mops connect <service>` (`/mops integration`) | 🖥️ | integrations: connect-or-create + **check the MCP registries first** (mcpservers.org, mcp.so, awesome-mcp-servers; mcpmarket.com leaderboards as the maintained-and-popular signal — an existing server beats hand-wiring) + **study the tool** (idioms/best practices → guide) + agent access (mcp_config/custom-env) + permission rules + register in `docs/TOOLING.md` |
| `/mops whatsnew [version]` | ⇆ | **onboard yourself into the release** — read the CHANGELOG between the version the workspace was on and the current one, and explain in plain language what changed, why it helps, and what (if anything) the owner should now do differently. Offered automatically right after a successful `/mops upgrade`: *"want the tour of what's new?"* |
| `/mops cli <command>` | 🖥️ | **raw Multica CLI escape hatch** — run or explain any `multica …` command directly, no methodology assumed (use it framework-free). Backed by the full surface in REFERENCE.md §10; Mops confirms flags via `--help`, and destructive/outward commands still need owner sign-off |
| `/mops import` | 🖥️ | bring a backlog in from another tracker (Linear, Jira, GitHub Issues, Trello, CSV): extract → show the mapping → create parents then children, **unassigned**, with `source_id` in metadata so a rerun resumes. PLAYBOOKS |
| `/mops process [task]` | 🖥️ | **discover a process, then tools for it** — research how this craft does the work well, draft the steps with their why, let the owner cut/add/reorder, then find a skill/MCP per step by function (broadening on empty). Run whenever a task's process isn't obvious; the design flow uses it. PLAYBOOKS |
| `/mops skill <create\|import\|optimize\|release>` | 🖥️ | the toolkit's lifecycle, conductor-owned: **create** (a routine seen twice → skill-creator → tested on a fresh agent → optimized → attached), **import** (screen for danger and injection → trim → attach **with provenance**), **optimize** (fail-closed compression; verbatim commands/paths/numbers, independent reviewer, `NOT_COMPRESSIBLE` is a valid answer), **release** (a proven skill → de-identified → the owner's own repo outside the workspace, owner-confirmed → re-imported as external so nothing drifts). PLAYBOOKS |
| `/mops sync` | 🖥️ | **two-way reconcile:** detect drift (skills/agents/squads/autopilots/labels/integrations changed outside Mops — e.g. the user imported a skill or edited an agent), study & record it into TEAM.md/guide/roadmap, flag conflicts and ask/fix; then push derived state (team snapshot, workspace details, Mops-in-Multica's instructions). The routine sibling of `/mops join`'s one-time audit |
| `/mops help` | ⇆ | list these commands and what Mops in Multica can do |

In the workspace the user talks to **Mops in Multica** (subtitle *"Executive Advisor ·
resident"*) — no commands needed, plain chat; Mops in Multica answers `/mops status`-style
questions natively and, for anything 🖥️, points the user back to the console.
