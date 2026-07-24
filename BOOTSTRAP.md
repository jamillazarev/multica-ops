# Bootstrap — standing up an agent team on Multica from zero

CLI recipes + the traps that cost real hours. The version these are pinned to lives in
one place — REFERENCE §10 — and `python3 scripts/verify.py` re-checks every recipe here
against the CLI you actually have.
When the CLI disagrees with this file, trust `--help`/`--debug` and the docs — then
propose an update to this skill.

**The team shape is NOT predefined.** Disciplines, depth, stages, DoD and models come
from the user interview (SKILL.md → Step 1). Only the **invariants** are fixed: the
**conductor** (agent = project lead), the **guide skill on everyone**, **find-skills
on everyone**, and the stage/mention mechanics. Roles below are call templates, not a
staffing plan — see `ROLES.md`.

## Contents

- [0. Day zero — from nothing to a working CLI](#0-day-zero-from-nothing-to-a-working-cli)
- [1. Project](#1-project)
- [2. Agents](#2-agents)
- [3. Squads (routing)](#3-squads-routing)
- [4. Skills](#4-skills)
- [5. Labels](#5-labels)
- [6. Issues, sub-issues, stages](#6-issues-sub-issues-stages)
- [7. Capacity and session limits (the big one)](#7-capacity-and-session-limits-the-big-one)
- [8. CLI traps (all hit in production)](#8-cli-traps-all-hit-in-production)
- [9. Ops scripts (set up immediately)](#9-ops-scripts-set-up-immediately)
- [10. Launch checklist](#10-launch-checklist)
- [11. Multica docs — go there, don't guess](#11-multica-docs-go-there-dont-guess)
- [12. External services — connect-or-create, access, secrets](#12-external-services-connect-or-create-access-secrets)
- [13. Slack / Lark (optional)](#13-slack-lark-optional)
- [14. Workspace = company · multiple members · local runtimes](#14-workspace-company-multiple-members-local-runtimes)
- [15. Stand-up order (detail)](#15-stand-up-order-detail)
- [15b. The short command — installed, not offered](#15b-the-short-command-installed-not-offered)
- [16. Interview checklist (detail)](#16-interview-checklist-detail)

## 0. Day zero — from nothing to a working CLI

**Start here on every first contact, before `/init` and before any question about the
project.** Most people arrive having installed Multica and no idea what comes next; the
answer is six checks that take seconds, and Mops runs them rather than asking the owner to.
Each has one repair, and the repair is offered — installing or updating software on
someone's machine is their call, not a side effect of saying hello.

| Check | Broken looks like | Repair |
|---|---|---|
| **1. Installed?** `multica version` | `command not found` | `brew install multica-ai/tap/multica`, or the install script from multica.ai. **Ask which they prefer** — someone who downloaded from the site does not expect a Homebrew formula appearing in their setup |
| **2. Current?** compare with the latest release | old version, subtle CLI drift | `multica update` — offer it, don't run it |
| **3. Signed in?** `multica auth status` | not authenticated | `multica setup cloud`, or `multica setup self-host --server-url …` for their own server |
| **4. A workspace?** `multica workspace list` | empty, or several | create one, or **confirm which** — never guess when there is more than one |
| **5. Daemon up?** `multica daemon status` | stopped | `multica daemon start`. Nothing executes without it, and the symptom is silence, not an error |
| **6. Runtimes?** `multica runtime list` | empty, or all `offline` | the daemon auto-detects agent CLIs on PATH: install one, then `daemon restart`. **Agents cannot be created against a runtime that isn't there** |

**Report the whole ladder at once, not one rung per message** — six sequential yes/no
prompts is exactly the experience this skill exists to avoid. State what's missing, what
each fix costs, and let the owner say "do it all".

```sh
multica version && multica auth status      # 1-3
multica workspace list --output json        # 4
multica daemon status && multica runtime list   # 5-6
```

**The runtime is where agents actually execute.** A desktop app may run its own
profile daemon (`--profile …`) separate from the CLI daemon: check whose
`active_task_count` grows — that one is the executor.

### Cloud or self-hosted — ask once, it changes almost nothing

Multica runs as **cloud** (`api.multica.ai`) or **self-hosted** — Docker Compose, or the
Helm chart `oci://ghcr.io/multica-ai/charts/multica` for k8s; the server is a Go backend +
Next.js frontend on **PostgreSQL 17 with pgvector**. Point the CLI with a first-class
command, not by hand:

```sh
multica setup cloud
multica setup self-host                                   # localhost:8080 / :3000
multica setup self-host --server-url https://api.internal.co --app-url https://app.internal.co
multica setup self-host --server-url … --callback-host <ip>   # CLI on a different machine than the server
```

It writes `server_url` / `app_url` into `~/.multica/config.json` (also settable via
`config set`, or `MULTICA_SERVER_URL` / `MULTICA_APP_URL`), authenticates and starts the
daemon.

**Why this barely touches the methodology: execution is already local either way.**
`runtime list` shows `MODE=local` — the daemon runs on **your machine**, and your agent
CLIs, model subscriptions, keys and code stay there. Self-hosting moves the **control
plane** (issues, board, orchestration, the web app), not the work. So everything in this
skill holds unchanged; what does change is operational and worth stating at `/init`:

- **You own uptime and backups now** — Postgres is the company's memory. Add it to
  `/health` and put a restore drill in the launch checklist.
- **Upgrades are yours to run** (`docker compose pull && up -d`; pin `MULTICA_IMAGE_TAG`).
  `/cli` still checks the CLI, but the **server version is a separate thing to track** —
  and CLI/server skew is a real failure mode, so upgrade the server first.
- **Email**: verification codes need `RESEND_API_KEY`, otherwise codes come from backend
  logs. Fine for a solo instance, a blocker the moment you invite someone.
- **Signup controls** (`ALLOW_SIGNUP`, `DISABLE_WORKSPACE_CREATION`) are the on-prem
  equivalent of workspace access — set them before the instance is reachable.
- **Never set `MULTICA_DEV_VERIFICATION_CODE`** on anything publicly reachable.
- Self-hosting changes **nothing about model spend** — that's still your provider
  subscriptions. It changes where *data* lives, which is usually the reason to do it.

Mops records which mode a workspace is in (fingerprint + `docs/TOOLING.md`), because it
changes who to call when the board is down: the vendor, or you.

## 1. Project

```sh
multica project create --title "<Name>" --icon "🎧" --lead "<Agent|Human>" \
  --description "…" --output json          # lead may be an AGENT (the conductor)
multica project resource add <project-id> --type github_repo --url <repo>
```

## 2. Agents

```sh
multica agent create --name "<Role name>" --model <model-id> --runtime-id <rt> \
  --visibility workspace --max-concurrent-tasks 3 \
  --description "<one line>" --instructions "<role system prompt>" --output json
multica agent avatar <agent-id> --file <png>       # see ROLES.md → Avatars
multica agent update <agent-id> --model <…> --instructions "<…>"
```
- **Profession-style names** ("QA Engineer", "Product Manager") — clearer in mentions.
- **Model tiering is mandatory** — see §7: not every role needs the top model.
- `agent update` takes a **UUID**, not a name.

**What belongs in `--instructions` — and what must not.** These load on every run this agent
makes, so they are the most expensive text you write per role. Six short blocks, no prose:

1. **Craft and scope** — what this role does, in one line.
2. **Owns / doesn't own** — the boundary the fit-check tests against. Being explicit here is
   what makes "this isn't mine, handing back" a normal move rather than a confession.
3. **Escalation thresholds** — what goes up (ambiguous, architectural, high blast radius) and
   what goes down (routine, below this role). **Never the grade as a label**: an agent told it
   is "junior" performs junior. The grade lives in `TEAM.md` as a routing fact (ROLES).
4. **DoD specifics for this craft** — the general shape lives in the guide; here go the parts
   only this craft can state (what evidence a design gate needs, what a test must cover).
5. **Next hop** — who receives the handoff, who is the escalation target.
6. **Tools this role drives**, if any are role-specific — with a pointer to the runbook, not
   the runbook itself.

**Never** restate the guide (it is attached to everyone and is the cached prefix — duplicating
it doubles the cost and creates two versions to keep in sync), and never restate native
platform behaviour: leader routing, mention triggers, stage barriers and project-lead
accountability all work without being described (REFERENCE §6). If an instruction would apply
to every role, it belongs in the guide; if it applies to one task, it belongs in the issue.

## 3. Squads (routing)

```sh
multica squad create --name "<Discipline>" --leader "<Leader agent>"
multica squad member add <squad-id> --member-id <agent-id> --type agent
multica squad update <squad-id> --instructions "<who routes what to whom + next hop>"
```
- Assigning an issue to a squad wakes **only the leader**; the leader **routes and does not implement that feature** — delegating via `@`-mention.
  Assigned *directly*, the same agent works like anyone else: routing is a mode, not a career.
- A solo discipline (no second specialist) → assign the **agent directly**, no squad.

## 4. Skills

```sh
multica skill create --name <n> --content-file <md>          # your own (team guide)
multica skill import --url github.com/<owner>/<repo>/tree/main/<skill-folder> \
  --on-conflict skip
multica skill list --output json
multica agent skills add <agent-id> --skill-ids <id1,id2>    # append
multica agent skills set <agent-id> --skill-ids <ids>        # replace all (no remove)
```
**Trap:** for multi-skill repositories the URL must point at the **folder containing
`SKILL.md`**, not the repo root. The root returns 502 while the CLI prints "service
temporarily unavailable" — run `--debug` to see the real cause. Curated packs and
working URLs: `ROLES.md`.

## 5. Labels

```sh
multica label create --name <n> --color "#3b82f6"     # workspace-level
multica label list --output json
multica issue label add <issue-id> <label-id>
```
Create a discipline set (green), a type set (amber) at bootstrap; agents self-label
and create missing ones. **Never label the stage** — it lives in the `--stage` field.

## 6. Issues, sub-issues, stages

```sh
multica issue create --project <pid> --title "<feature>" --description-stdin < spec.md
multica issue create --parent <feature-id> --stage 1 --assignee "<Squad|Agent>" --title "<task>"
multica issue update <id> --stage 2 --assignee "<…>" --priority low
multica issue assign <id> --to "<Agent|Squad>"     # ⚠ assignment = a RUN (spends budget)
multica issue status <id> <backlog|todo|in_progress|in_review|done|blocked|cancelled>
multica issue rerun <id>                            # = the UI's "Retry task"
multica issue comment add <id> --content-stdin      # @-mention = native trigger
```
- **Two levels only**: `issue → sub-issues`. `stage` is a number on a sub-issue, not
  a nesting level.
- **`--stage N` is a barrier**: the parent wakes only when ALL stage-N sub-issues are
  `done`.
- **There is no `--depends-on` between issues** — keep feature order in an external
  backlog document.
- Don't pre-assign everything: assignment triggers a run.

## 7. Capacity and session limits (the big one)

- **All agents on one runtime share ONE plan's session limit.** N agents on premium
  models burn the window in a single pass and the whole team stalls.
- **A limit hit = run `failed`, reason `agent_error`** + a comment "You've hit your
  session limit · resets HH:MM". **Non-retryable** — nothing retries itself.
  Recovery = `issue rerun`. **Retrying before the reset fails again.**
- Levers: model tiering (top model for the core only) · spread agents across runtimes
  · a second account = a second runtime · a larger plan · an API runtime (pay-per-token,
  no session cap) · lower concurrency.
- `cancelled` is **NOT a limit** — it's someone's decision. Convention: an intentional
  cancel always carries a "Cancel reason: …" comment; marker-less ones are accidental.

## 8. CLI traps (all hit in production)

| Trap | Workaround |
|---|---|
| `issue list` caps at **100 per page** (`--limit 500` ignored) | paginate with `--offset`, watch `has_more` |
| Raw control characters in descriptions **break JSON parsing** | `re.sub(r'[\x00-\x1f]',' ',out)` before `json.loads` |
| Several projects with similar names | handle **all** matches, not the first |
| `daemon status` "running" ≠ work happening | watch **`active_task_count`** (json) |
| Autopilot triggers | **cron/webhook only**, never "stage finished" |
| Agents can @-mention agents | indirect cycles are NOT blocked — don't write circular instructions |

## 9. Ops scripts (set up immediately)

Generic versions live in [scripts/](scripts/) — run from the project repo root:
- **status.sh** — counters by status + assigned/in-flight list.
- **resume.sh** — `issue rerun` for **interrupted** (`in_progress`/`in_review`) only.
  ⚠ never rerun `todo`/`backlog` — they wait on stage barriers.
  `--revive-cancelled` also revives `cancelled` **without** a "Cancel reason" marker.
- **health.sh** — for indicators: waiting / limit-stuck / reset time (from run `error`).
- **issues.py** — paginated, corruption-tolerant issue listing. Use it instead of raw
  `issue list` whenever you need the whole board: it walks `--offset` past the 100-row cap
  and sanitizes control characters that otherwise break `json.loads` (both traps are §8).
- **import-issues.py** — resumable creation from a normalized JSON file, for `/import`;
  parents before children, `source_id` in metadata, nothing assigned. See PLAYBOOKS.
- Team rule: **commit incrementally** — `rerun` resumes from the repo, not from chat.

## 10. Launch checklist

0. **Interview** (SKILL.md Step 1): domain/repo/backlog, disciplines, depth (≥2 →
   squad, solo → lone agent), DoD per discipline, stage ladder, capacity/models,
   avatars, autopilots (usually "later"), language. **Build nothing before answers.**
1. `multica setup`; runtime online; daemon up.
2. Project + repo; **lead = the conductor agent (create it first)**.
3. **Project guide skill + find-skills** → attach to **everyone** (invariant).
4. Roles **from the interview** (ROLES.md): agents, model tiers, instructions, avatars.
5. Squads only where a discipline has ≥2 members: routing leader + members +
   `squad update --instructions`; per-role skills.
6. Labels (discipline/type).
7. Features as issues (description from the spec); staged sub-issues are the
   conductor's job.
8. The human starts the **first** feature via the assistant. The conveyor takes it
   from there.

## 11. Multica docs — go there, don't guess

Root: **https://multica.ai/docs**. Key pages:
`/docs/how-multica-works` · `/docs/issues` · `/docs/projects` · `/docs/agents` ·
`/docs/squads` · `/docs/skills` · `/docs/assigning-issues` · `/docs/mentioning-agents`
· `/docs/tasks` · `/docs/autopilots` · `/docs/daemon-runtimes` · `/docs/cli` ·
`/docs/github-integration`. The CLI evolves fast — when a flag or behaviour differs
from this file, the docs and `--help`/`--debug` win.

## 12. External services — connect-or-create, access, secrets

Inventory first ("what already exists?"), then per service:
- **Exists → connect** (GitHub repo → `project resource add`; Figma file → link +
  token; PostHog project → API key). **Missing → create it**, then connect. Same rule
  for GitLab, analytics, image-gen (3D/upscale/vectorize) — any provider.
- **Agent access**: MCP servers via the agent's `mcp_config`
  (`multica agent update <id> --mcp-config-file <json>` — file mode 0600), plain API
  keys via `custom-env` — at creation with `--custom-env-file`, afterwards via `agent env set` (owner/admin only, audited, and it replaces the whole map). Both are stored by Multica as secret
  material and never enter the repo.
- **Generated artifacts** (images, 3D, vectors) go through the same review gates as
  any work — a designer reviews a generated logo like QA reviews code.
- **Permissions**: reads free; writes by role; **destructive/outward actions
  (delete, publish, send, spend) → @mention the user and wait for a yes.**
- Multica's own **API tokens** (Settings → API tokens) are for external systems
  calling INTO Multica — not needed for agent→service access.
- Secrets hygiene: never in repo/issues/comments; repos private by default; a key
  that appeared in a chat or log is rotated.

## 13. Slack / Lark (optional)

Per-agent bots: each agent can get its own Slack app (Bot token `xoxb-` + App token
`xapp-`, Socket Mode — no public URL). Members DM the bot, @-mention it in channels,
or `/issue` to file issues from Slack. Only workspace members can use it (Slack
identity links to the Multica account on first use). Lark has an analogous
integration. Offer at setup; connect any time later.

## 14. Workspace = company · multiple members · local runtimes

- **Workspace is the company**: agents, skills, labels, and the session limit are
  workspace-level and shared across its projects (= directions: app, site,
  marketing…). Fill workspace details (`multica workspace update` — description,
  logo avatar); assistant and agents keep them current (rebrand → new logo). Don't
  mix unrelated ventures in one workspace — that breeds an agent junkyard.
- **Members**: the cloud stores issues/comments/metadata; **code, keys, and CPU stay
  on each member's machine**. Several members each run their own daemon for the same
  workspace. Keep `docs/TEAM.md`: humans and agents, who owns what, which features.
  Several PMs = one project lead per direction; Mops in Multica coordinates.
- **Runtimes are local**: auto-detected from PATH when each member's daemon starts
  (16 supported tools). Adding one = install the tool + `multica daemon restart`.
  Audit with `multica runtime list` (note online/offline and which machine).
- **Monorepo default**: repo = company; `apps/ site/ marketing/ docs/` = projects;
  `docs/` opens as an Obsidian vault (plain markdown + Mermaid; GitHub renders the
  same files). Notion, when requested, is a mirror — the repo stays the source of
  truth. Split repos only for separate deploy/access/open-source boundaries.

## 15. Stand-up order (detail)

1. **Workspace = company.** One workspace per company/owner; projects = directions
   (app, site, marketing…); agents are shared across projects — that's the point.
   Create or rename it, fill **workspace details** (description, logo as avatar) via
   `workspace update`; you and the agents keep them current (rebrand → new logo).
2. **Conductor** — create first, make it the **project lead**. Give it git/GitHub
   rights. Several directions may each get their own PM as that project's lead; Mops
   (Mops in Multica if present, else the console) coordinates across them.
3. **Guide skill + find-skills on every agent** — language/tone first line; incremental
   commits; DoD; handoff = @mention; evidence-over-opinion; **docs follow decisions**:
   when a discussion (issue thread, brainstorm, review) lands on a decision that changes
   the spec/roadmap/guide, the agent who owns the change updates the affected doc **in the
   same task** — docs carry current state only (no "was/changed to" history; the comment
   thread *is* the history), and a decision that isn't written into the doc doesn't exist
   for the next agent; the self-improvement rule
   (a routine repeated twice → shape it into a skill via skill-creator → conductor
   attaches it); limit/cancel conventions; **who Mops is**: the owner's
   representative, first after the user. Escalation runs agent → squad leader →
   conductor → **Mops (Executive Advisor)** → user; agents bring blockers and questions to
   Mops, and only Mops (or a destructive-action rule) escalates to the user. **If the
   Mops in Multica is off**, the vertex collapses to conductor → user, and the console/owner covers
   the advisor role when open.
4. **Roles from the interview** — ROLES.md templates where they fit; for any role not
   in the catalog (pastry chef, accountant, scrum master…) run the **role-builder**:
   research current best practices, find/import skills, collect the sources the role
   needs, propose, create. Designers and engineers join **from the first decisions**
   (discovery, spec review), not only at their stage.
5. **Experts & personas (opt-in)** — composition depends on the project; propose 2–4
   experts relevant to the domain (e.g. domain specialist, market/growth, architect)
   as an **Experts squad**; user-simulation personas (built from the PM/UX research)
   as a **Personas squad** used in usability passes. Only Mops in Multica stays squadless. The user may decline both.
6. **Stand up Mops in Multica (opt-in — checklist #16 · Resident Mops)** — if enabled: install this skill
   into the workspace and assign it **only to the Mops agent** (other agents carry the
   *guide* skill, not this one — multica-ops is Mops's brain), so Mops in Multica *is* the
   same Mops:
   - **Install idempotently, never blindly.** First `multica skill list` — if `multica-ops`
     isn't there, `multica skill import --url github.com/jamillazarev/multica-ops`. If it
     **already exists** (re-run, or a teammate imported it), **compare versions**: same →
     skip; older → refresh through `/upgrade` (backup current to `docs/skill-backups/` →
     `import --on-conflict overwrite`), **never a second copy**. (`import` supports
     github/skills.sh/clawhub URLs.) Then `multica agent create` the agent named
     **Mops**, `multica agent skills` to attach the imported skill (+ find-skills),
     `multica agent avatar` matching the chosen library — except **Mops in Multica, which always uses `assets/mops-avatar.png`** from this repo, subtitle *"Executive Advisor ·
     resident"*. Grant rights per the user's autonomy choice (advisor-only → narrow;
     ongoing operator → the CLI plus a token scoped to issues, comments
   and status). **Never workspace admin.** The resident is the agent with the widest
   untrusted-input surface — it reads issues, imported tickets and web research — so giving
   it `agent env set`, `skill import` or member invites turns any successful injection into
   a full workspace takeover. A genuinely admin-level action escalates to the owner; that is
   what the escalation vertex is for.
   - Seed the **kickoff**: pinned "Project kickoff" issue + Mops-in-Multica's first message =
     the decisions summary (see "Two seats of Mops"). Tell the user: *"from here you can
     talk to Mops inside Multica — chat, issues, any device; I remain in the CLI for the
     heavy work."*
   - If declined: skip; Mops lives in the console only, and `/help` says so.
7. **Labels** (discipline/type; never the stage) and **docs skeleton**: `docs/ROADMAP.md`,
   `docs/TEAM.md` (who owns what — agents *and* people; essential once several humans join),
   `docs/TOOLING.md` (every tool: what · for what · access · where its secret lives · when
   it was last checked — this is the probe list `/health` reads), `docs/DECISIONS.md`
   (**append-only**: what was tried or proposed and rejected, with the evidence — so the
   same idea isn't rediscovered every quarter) and, once there's code, `docs/ARCHITECTURE.md`
   (what lives where, entry points — every task starts in a fresh worktree, so an unwritten
   map is re-derived by every agent on every run). The cloud holds issues/comments; code and
   keys stay on members' machines. **Start each from its template in `templates/`** rather than
   improvising the shape — a doc nobody can predict the shape of gets skimmed, not used.
   **Protect the default branch — actually run this, don't just intend it.** Merge is the
   conductor's terminal step when the gates are green; the protection is what keeps that from
   being a sentence anyone can ignore.

   ```sh
   gh api -X PUT repos/<owner>/<repo>/branches/main/protection \
     -f "required_pull_request_reviews[required_approving_review_count]=0" \
     -F "enforce_admins=true" -F "allow_force_pushes=false" -F "allow_deletions=false" \
     -f "required_status_checks[strict]=true" -f "required_status_checks[contexts][]=" \
     -f "restrictions=" 2>&1 | head -3
   ```

   Three honest caveats, because a control you misunderstand is worse than none:
   **(a)** this stops force-push and deletion, not a bad merge — **our review gates are Multica
   sub-issues judged by agents, not CI status checks**, so nothing wires a gate verdict to a
   commit status. If the project has CI, add its job to `contexts` and the two systems finally
   agree. **(b)** `enforce_admins=true` matters most here: without it the conductor, which holds
   git rights, can simply step around the fence. **(c)** With **no remote at all** — the
   documented default when the owner is unsure — there is no branch to protect and the merge
   rule really is only a sentence. Say that out loud rather than implying a gate exists.
   Re-checked at `/health`.
   Then **install the docs guard** — `templates/company-preflight.sh` as the repo's
   pre-commit hook (PLAYBOOKS): a skeleton is only useful while it stays true.
   `LATER.md` and `ECONOMICS.md` are the two without a template: their shape is stated where they
   are defined (a deferral is *what · why · revisit trigger*; economics is the ledger
   rolled up — PLAYBOOKS).

## 15b. The short command — installed, not offered

Claude Code namespaces plugin commands, so this skill's are `/multica-ops:mops`,
`/multica-ops:status` and so on. **User-level commands are not namespaced**, so a file at
`~/.claude/commands/mops.md` is a real `/mops` in every project.

**A SessionStart hook installs it on first use** (`hooks/hooks.json` →
`scripts/install-alias.sh`) rather than asking. Asking would teach the long form first and
the short one later, leaving the user to remember which they have — and this is a file in
their own Claude config: local, private, and removable with one `rm`, which is a different
class of thing from acting on an outside system.

It is deliberately timid about everything else:

- **Never overwrites** an existing `/mops` — it may be theirs, and it records that it saw it.
- **Never recreates one the user deleted.** A marker at `~/.claude/.multica-ops-alias`
  remembers that the decision was already made, so removal is permanent.
- **Prints once**, naming the `rm` that undoes it, then stays silent forever.

**When it isn't there, say the long form.** Someone who declined it, or is in another
harness entirely, must hear `/multica-ops:mops` — quoting a command the reader does not have
is how the *"Unknown command: /mops"* report happened in the first place. And in Cursor,
Codex or any non-plugin install there are **no slash commands at all**: plain language is
the way in, and that is worth saying out loud rather than leaving them to discover it.

## 16. Interview checklist (detail)

Each item with its default, as walked in `/init` and re-asked in the `/join` delta.

1. **Where the code lives — ask, never assume, and never create anything on the owner's
   accounts uninvited.** Three separate questions, in this order: *does a repo already
   exist?* (then use it — do not init a new one beside it); *if not, do you want one, and
   **where**?*; *and is a remote wanted at all?* **Creating a repository on the owner's
   GitHub is an outward action on their account** — it lands under whatever identity their
   `gh`/git is authenticated as, which is very often their **employer's**. It is
   owner-confirmed, out loud, naming the account it would land in: *"this would create
   `acme-corp/swipy` under your work account `r-tagiyev` — right one?"*. A local git repo
   with no remote is a legitimate end state and the correct default when the owner is
   unsure; nothing in this methodology needs a remote except per-task parallelism.
2. **Control & expertise** — two questions that shape every later interaction.
    **(a) How much do you want to be in the loop?** *hands-on* (approve each feature) ·
    **checkpoints** (approve at named gates — default) · *hands-off* (only
    destructive/spend, plus a digest). Set globally or per flow; it maps onto `/autonomy`
    and `/reviews`. **(b) What are you actually expert in?** Record it in `TEAM.md`:
    inside those areas you are **consulted as an expert** — terse, technical, real
    decisions routed to you; outside them Mops **explains and recommends** with tradeoffs
    instead of dumping a choice on you. The same courtesy governs agents talking across
    squads: explain in the other craft's terms, don't fling jargon over the fence.
3. **Deliverable & repo shape** — monorepo by default (repo = company; `apps/ site/
   marketing/ docs/` = projects); separate repos only for separate deploy/access.
4. **Disciplines & depth** — only crafts the project names; ≥2 specialists → squad
   with a routing leader, solo → lone agent.
5. **DoD per discipline** — objective gates (default: tests/review for code,
   mockup-fidelity + a11y for design, fact-check for content).
6. **Stage ladder** — default Build → Review → Accept; prepend Design when design
   precedes build; parallel gates inside Review.
7. **Where Multica itself runs** — **cloud by default**; ask once, because on a
   self-hosted server backups, upgrades, email and signup controls become the owner's
   (§0). Record the answer — it changes who to call when the board is down.
8. **Capacity & models** — audit `runtime list` (runtimes are **local**: auto-detected
   from PATH on each member's machine; several machines can serve one workspace).
   **Ask preference in plain outcomes, not model names** — the owner may not know which model
   is which. Offer tiers by what they *do*: **stronger** (best results, slower, pricier — for
   the hard core) · **medium** (the everyday default) · **light** (fast and cheap — for
   routine and bulk). Name the trade the owner actually feels: **quality *and* speed**, since
   a top model can be the wrong pick for a screen that just needs to be fast. Then map those
   tiers onto **this runtime's** actual models and say which is which (the catalogue differs
   per provider), so the owner chooses by outcome. **The tiers are a prompt, never a menu** —
   the owner can always answer freely ("all top", "Sonnet for everything except the core",
   "you pick"), and Mops honours the free answer over the three buckets. A squad that is all
   one tier because nobody asked is the bug the first user-test hit. In Multica a model is bound to
   the agent (per-role), so the preference shapes who is created at which tier; a task can't
   pick a model at assign time, only the graded agent can (REFERENCE §7). Missing tool →
   install + `daemon restart`.
9. **Anything you already want used** — before proposing anything, ask outright: *are there
   skills, MCP servers or tools you already use and want this team to have?* People arrive
   with favourites and with things already wired; discovering them on day three means the
   team was built around a worse choice. Each named one goes through the same gate as any
   import (screen → trim → attach with provenance), and "no, you pick" is a fine answer.
10. **Integrations inventory** — "what already exists?" (GitHub/GitLab, Figma,
   analytics, Mobbin, image-gen APIs…). Per service: **connect-or-create** (exists →
   connect; missing → create). Access via `mcp_config` / `custom-env` (BOOTSTRAP §12). For digital products,
   default service & library picks live in **`STACKS.md`** — offer the
   matching seeds, accept "other" as always.
11. **Docs home** — default **local-first markdown in the repo**: `docs/` is designed
   to open as an **Obsidian vault** (plain relative links + Mermaid — readable on
   GitHub and in Obsidian alike; roadmap, team, specs all browsable). Options: Notion
   mirror (via MCP; repo stays the source of truth), Figma (cloud) vs Pen (pen.dev, local)
   for design — or both. As everywhere: the user may name any other tool — research and connect it.
12. **Assets home** (when the project accumulates media — images, video, 3D):
   small volumes → in the repo (Git LFS); large → **research the best current
   provider for the project's actual needs** (object storage, media CDN, or an
   all-in-one backend) and propose — never keep a hardcoded provider list, the
   market moves. Wire the chosen one via `mcp_config`/`custom-env`; generated
   assets still pass the usual review gates.
13. **Avatars** — default DiceBear (one seed per agent name); or user's images.
14. **Experts & personas** — offer, per project, both opt-in (see below). Default: none.
15. **Design system & brand** — opt-in (see the two sections below). Ask: does the
    project produce a repeatable form (UI, covers, packaging, letters)? Default: **on
    when a design discipline exists**. And: does it face the world — is there a brand
    (existing / to create / not needed)? Existing → audit, don't rebuild. Homes:
    `docs/design-system/` (tokens as files) and `docs/brand/` (the brand book).
16. **Resident Mops (Mops in Multica)** — opt-in (see "Two seats of Mops"). Default: **on** for a
    company (a running team needs an in-workspace advisor + escalation vertex when the
    user is away); **off** for a quick job. Declining means Mops lives in the console
    only.
17. **Operating mode** — see next section. Default: `manual` (a human starts each feature).
18. **Autopilots / Slack / Lark** — default "later"; connect on request (BOOTSTRAP §13).
19. **Language & tone** — confirm the chat language as the working language; artifacts
    in it or English? Tone (business / friendly / terse-technical)? Both go into the
    guide skill, first line, absolute — including every agent's first greeting.
20. **Governance** (see below) — who can direct Mops (default: all members full; owner
    always full; destructive/spend always → owner) and which flows need a named human's
    sign-off (default: none beyond the destructive gate; ask what the user wants to
    review — image-gen, publishing, every feature…). Multiple human members are normal.
