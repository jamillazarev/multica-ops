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
- [13. Slack / Lark · Autopilots (optional)](#13-slack-lark-autopilots-optional)
- [14. Workspace = company · multiple members · local runtimes](#14-workspace-company-multiple-members-local-runtimes)
- [15. Stand-up order (detail)](#15-stand-up-order-detail)
- [15b. Commands are namespaced — say the full form](#15b-commands-are-namespaced-say-the-full-form)
- [16. Interview checklist (detail)](#16-interview-checklist-detail)

## 0. Day zero — from nothing to a working CLI

**Start here on every first contact, before `/multica-ops:init` and before any question about the
project.** Most people arrive having installed Multica and no idea what comes next; the
answer is six checks that take seconds, and Mops runs them rather than asking the owner to.
Each has one repair, and the repair is offered — installing or updating software on
someone's machine is their call, not a side effect of saying hello.

| Check | Broken looks like | Repair |
|---|---|---|
| **1. Installed?** `multica version` | `command not found` | **Stop and hand it back.** Point at **https://multica.ai** — cloud, self-hosted or the desktop app (which bundles the CLI) are genuinely different choices with different consequences, and installing the wrong one for someone is worse than waiting. Say what to install, why the options differ, and that you'll pick up the moment `multica version` answers. **Mops does not install Multica itself** |
| **2. Current?** compare with the latest release | old version, subtle CLI drift | **Report it, don't perform it.** Say what's newer and hand over the line (`multica update`) or the app's own updater. **Cloud vs self-hosted differs:** on cloud the vendor moves the server and only the CLI is yours; **self-hosted, the server is yours to update** (`docker compose pull && up -d` with `MULTICA_IMAGE_TAG` pinned, or the Helm chart) and **CLI↔server skew is a real failure mode — update the server first** |
| **3. Signed in?** `multica auth status` | not authenticated | `multica setup cloud`, or `multica setup self-host --server-url …` for their own server |
| **4. A workspace?** `multica workspace list` | empty, or several | create one, or **confirm which** — never guess when there is more than one |
| **5. Daemon up?** `multica daemon status` | stopped | `multica daemon start`. Nothing executes without it, and the symptom is silence, not an error |
| **6. Runtimes?** `multica runtime list` | empty, or all `offline` | the daemon auto-detects agent CLIs on PATH: install one, then `daemon restart`. **Agents cannot be created against a runtime that isn't there** |

**Report the whole ladder at once, not one rung per message** — six sequential yes/no
prompts is exactly the experience this skill exists to avoid. State what's missing, what
each fix costs, and let the owner say "do it all" — **except rung 1**, which is theirs: with no
`multica` on the machine there is nothing to run day zero *with*, so the honest move is a link
and a pause, not a guess at how they want it installed.

```sh
multica version && multica auth status      # 1-3
multica workspace list --output json        # 4
multica daemon status && multica runtime list   # 5-6
```

**The runtime is where agents actually execute.** A desktop app may run its own
profile daemon (`--profile …`) separate from the CLI daemon: check whose
`active_task_count` grows — that one is the executor.

**The desktop app bundles its own CLI, so a machine can hold two.** `multica version` reports
whichever is on `PATH`, which may not be the one the app's daemon executes with — so a version
answer is only true *for the daemon you named*. When both exist, say which you checked, and
update **both** (the app through its own updater or the store — again reported, never run by
Mops), because a stale bundled CLI produces failures that look like the agent's fault.

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
skill holds unchanged; what does change is operational and worth stating at `/multica-ops:init`:

- **You own uptime and backups now** — Postgres is the company's memory. Add it to
  `/multica-ops:mops health` and put a restore drill in the launch checklist.
- **Upgrades are yours to run** (`docker compose pull && up -d`; pin `MULTICA_IMAGE_TAG`).
  `/multica-ops:cli` still checks the CLI, but the **server version is a separate thing to track** —
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
  --permission-mode public_to --public-to-workspace --max-concurrent-tasks 3 \
  --description "<one line>" --instructions "<role system prompt>" --output json
multica agent avatar <agent-id> --file <png>       # see ROLES.md → Avatars
multica agent update <agent-id> --model <…> --instructions "<…>"
multica agent copy <source-agent-id> --name "<Role name>"   # a near-twin: fork, don't retype
```
**A second agent almost like an existing one is a `copy`, not a re-typed `create`** (CLI v0.4.12).
It carries instructions, description, avatar, permission mode and allow-list, attached skills,
`max_concurrent_tasks`, and — only while the runtime is unchanged — model, thinking level and
service tier. **Secrets never travel**: `custom_env`, `mcp_config` and `runtime_config` are not
copied, which is the behaviour you want; supply fresh values with the same secret-safe flags as
`create`. Forking onto a different runtime (`--runtime-id`) **requires `--model`** (`--model ""`
takes the target's default) and drops thinking level and service tier unless you set them.
- **Profession-style names** ("QA Engineer", "Product Manager") — clearer in mentions.
- **Model tiering is mandatory** — see §7: not every role needs the top model.
- `agent update` takes a **UUID**, not a name.

**Who may invoke an agent is Multica's own setting — use it, don't invent one.** The app shows
it as *Access* on an agent; the CLI is `--permission-mode`, on `create` and `update`:

| Intent | Flags | The app calls it |
|---|---|---|
| only its owner runs it | `--permission-mode private` | *Only me* |
| any member runs it | `--permission-mode public_to --public-to-workspace` | *Entire workspace* |
| named members run it | `--permission-mode public_to --public-to-member <user-id>` (repeatable) | *Specific people* |

`--visibility private|workspace` still works but is **legacy** — it just maps onto the above,
and it cannot express *Specific people*. Prefer `--permission-mode`; it is authoritative when
both are given, and changing it on an existing agent is **owner-only**.

**Do not confuse it with `/multica-ops:mops access`.** This one is Multica's: *who may run this agent*.
`/multica-ops:mops access` is ours: *what a human member may direct Mops to do*. A workspace with several
people needs both — team agents public to the workspace, anything holding credentials or
spend kept `private` or narrowed to named people.

**Three per-agent dials most teams never touch — and should.**

| Flag | What it does | When to reach for it |
|---|---|---|
| **`--thinking-level`** (Claude: `low·medium·high·xhigh·max`; other runtimes take their own set) | reasoning effort, **a second axis beside the model** | a cheap model at high effort often beats an expensive one at default — tier **both**, not just the model |
| **`--custom-args`** (JSON array, appended to the tool's command line) | e.g. `--max-turns`, `--append-system-prompt` | capping runaway loops per role. **Some flags are blocked** (the daemon owns `-p`, permission mode, effort), and long lists slow startup — keep under ~10 |
| **`--custom-env`** (+ `-file` / `-stdin`) | secrets for this agent only | prefer `--custom-env-file` (mode 0600) or stdin; a value on the command line is visible to shell history and `ps`. `PATH`/`HOME`/`USER`/`SHELL`/`TERM`/`CODEX_HOME` and anything `MULTICA_*` are **silently ignored** |

**Agents inherit the runtime's local skills and MCP servers — inventory them, don't assume.**
The workspace's skills are not the whole picture: whatever is installed on the runtime machine
is merged in, and `disabled_runtime_skills` is how you switch specific ones off per agent. So
"everything this company uses is in the repo" is only true once you have looked. Do it at
creation, and re-check at `/multica-ops:audit` and `/multica-ops:mops sync`.

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

- **JSON output is not one shape, and write-commands prefix it with prose.** Hit in
  production twice in one day: list commands return **either a bare array or a wrapper
  object** (`issue list` → `{issues:[…], has_more, …}`, `autopilot list` →
  `{autopilots:[…], total}`), and write-commands print a **human line before the JSON**
  ("Comment added to issue X." then `{…}`) even with `--output json`. Rules: parse lists
  defensively — `d if isinstance(d, list) else` the first list-valued key; for writes,
  **check the exit code instead of parsing stdout**, and if you need the id, cut from the
  first `{`. The shipped `scripts/issues.py` does this (`_clean`) — copy its pattern.
- **`workspace switch` can fail while your script keeps going — and your objects land in
  whatever workspace was active.** Hit in production: a failed `create` (slug conflict) made
  the following `switch` a no-op, and three projects were created in the wrong company.
  Two rules: **batch creation always passes `--workspace-id` explicitly on every command**
  (a wrong default becomes impossible), and interactive work **verifies before creating**
  (`workspace get` → compare the id → only then create). A cleanup is `project delete`,
  but the rule is to never need it.

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
- **resume.sh** — `issue rerun` for **interrupted** (`in_progress`/`in_review`) work **and** for
  `todo` issues rolled back by an `agent_error` run (`issue runs` tells those apart).
  ⚠ never touches *untouched* `todo`/`backlog` — they wait on stage barriers.
  `--revive-cancelled` also revives `cancelled` **without** a "Cancel reason" marker; `--dry-run`
  prints the selection without firing.
- **health.sh** — for indicators: waiting / limit-stuck / reset time (from run `error`).
- **issues.py** — paginated, corruption-tolerant issue listing. Use it instead of raw
  `issue list` whenever you need the whole board: it walks `--offset` past the 100-row cap
  and sanitizes control characters that otherwise break `json.loads` (both traps are §8).
- **import-issues.py** — resumable creation from a normalized JSON file, for `/multica-ops:import`;
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

## 13. Slack / Lark · Autopilots (optional)

Per-agent bots: each agent can get its own Slack app (Bot token `xoxb-` + App token
`xapp-`, Socket Mode — no public URL). Members DM the bot, @-mention it in channels,
or `/issue` to file issues from Slack. Only workspace members can use it (Slack
identity links to the Multica account on first use). Lark has an analogous
integration. Offer at setup; connect any time later.

### Autopilots

Scheduled or event-driven runs — **not** conveyor reactions; an autopilot never fires on "a
stage finished" (that is @mentions and barriers). Offer at setup, default "later".

- **The runbook is read on every run**, so an edit takes effect next run with no redeploy.
  Output mode is either **`create_issue`** (default, recommended — the run lands as an issue on
  the board, visible and reviewable) or **`run_only`** (fire-and-forget, **invisible on the
  board** — use it only when the effect lives elsewhere and you don't need the trace).
  **`--priority` is accepted and stored nowhere** (measured 2026-08-01): it is in `--help` on
  both `create` and `update` with a default of `none`, it never appears in `autopilot get`, and
  an issue created after `autopilot update --priority urgent` came out `priority: none`. An
  autopilot's issues arrive unprioritised — set it on the issue, or it is not set.
- **Cron is five fields, one-minute granularity, in an IANA timezone** (`Europe/Warsaw`, never a
  bare offset). The server scans schedules roughly every 30 s, so a run can **start up to ~30 s
  late** — fine for sweeps, wrong for a hard deadline.
- **A webhook trigger's URL *is* the credential** — holding it is enough to fire the autopilot.
  Rotation exists (`autopilot trigger-rotate-url`), but **anyone who can see the autopilot sees
  its URL**, so treat it like a secret and rotate on member changes. The event filter matches a
  name resolved in order — the envelope `event` field, then provider headers (`X-GitHub-Event`…),
  then body fields, then `webhook.received` as the fallback. Responses: `200` accepted;
  `400`/`401`/`404` rejected; `413` over 256 KiB; `429` throttled.
- **Failures are silent** — an autopilot task **neither auto-retries nor posts to the inbox**
  (REFERENCE §7). So run it in `create_issue` mode and **subscribe the owner**, or a broken
  autopilot goes unnoticed indefinitely.
- **The platform tells you when it will fire, and not whether anything will run.**
  `autopilot trigger-add <id> --kind schedule --cron … --timezone …` (**the id is positional —
  `--id` is rejected**) returns **`next_run_at`**, a concrete UTC instant. Quote it back rather
  than saying *"weekly"* — a promise with a timestamp can be checked. **But `active` plus a
  `next_run_at` means the server will wake it, not that work will happen**: the assignee runs on
  a runtime, and **a `local` runtime is a process on somebody's machine**. Before promising a
  schedule, confirm the executor answers — **`runtime list`**, status `online` with a fresh
  `last_seen`, **not `daemon status`**, which reports on the CLI's own profile and says
  `stopped` while the desktop app's daemon keeps six runtimes online (REFERENCE → readiness,
  measured 2026-08-01). **Verified end to end the same day**: created in `create_issue` mode,
  scheduled, `next_run_at` returned, then deleted — the mechanism is real, and so is the
  condition.
- **`next_run_at` is cron arithmetic, not a promise — there are three independent switches and
  the timestamp reflects none of them.** Measured 2026-08-01: a trigger set to
  `enabled: false` still reported `next_run_at: 2026-08-02T05:05:00Z`, and pausing the whole
  autopilot did not change it either. So **read `enabled` on the trigger and `status` on the
  autopilot before quoting the instant** — three things must be on (autopilot `active`, trigger
  `enabled`, the assignee's runtime answering), and the timestamp is computed from the cron
  alone. **`paused` is a real off-switch on both paths**: a paused autopilot refuses a manual
  run too — `Invalid request: autopilot is not active` — which makes it the way to stop a
  misbehaving autopilot without losing its runbook.
- **Cron here is exactly five fields, and a pinned date is annual rather than one-shot.** A
  six-field expression is rejected outright (`parse cron: expected exactly 5 fields, found 6`),
  the timezone conversion is done for you (`5 7 2 8 *` in `Europe/Warsaw` → `next_run_at`
  `2026-08-02T05:05:00Z`), and a date already past **rolls to next year** (`0 0 1 1 *` →
  `2027-01-01`). So a schedule pinned to a one-time moment fires again in twelve months unless
  its trigger is deleted after it runs.
- **The trigger verbs do not take the same arguments.** `trigger-add <autopilot-id>` takes one
  positional; **`trigger-update` and `trigger-delete` take two — `<autopilot-id> <trigger-id>`**,
  and passing only the trigger id fails with `accepts 2 args, received 1`. `--enabled` is a
  boolean that defaults to true, so **disabling requires `--enabled=false`**: the space form is
  read as a third positional and dies with `accepts 2 args, received 3`.
- **A manual `autopilot trigger` is tagged source `manual`, and it is how work gets dispatched
  out of a conversation.** An autopilot needs **no trigger to exist** — created with
  `triggers: []` it is already `status: active`, and `autopilot trigger <id>` fires it,
  returning in about a second with `{"status":"issue_created","issue_id":…}` while the agent
  runs on. A schedule is for the sweeps nobody is watching; the same object serves both
  (measured 2026-08-01 → PLAYBOOKS *The audit is dispatched*). Not reachable from the CLI
  (checked v0.4.12): HMAC signing on the trigger, an IP allowlist, API-based triggers — do not
  design as if they exist. **Signing is in the data model and not in the CLI**: a webhook
  trigger comes back carrying `has_signing_secret: false`, `signing_secret_hint: null` and
  `provider: "generic"`, and no flag on `trigger-add` or `trigger-update` sets any of them. Read
  that as *the platform intends to have it*, not as *we have it* — the URL is still the whole
  credential today.
- **Assignee gap, verify live:** the app offers an autopilot assignee of **agent *or* squad**,
  while the docs describe only an agent — confirm on the workspace before promising a
  squad-assigned autopilot.

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
- **Three roles, and the CLI cannot grant the top one.** `owner` · `admin` · `member`:
  day-to-day work (issues, comments, using agents) is open to all three. **Only an owner can
  invite another owner or delete the workspace**; admins invite and remove members and admins
  but cannot touch an owner. `workspace member invite --role member|admin` — **`owner` is not
  offered**, and **there is no member removal in the CLI at all** (the app only). A workspace
  always keeps at least one owner, and the last one cannot demote themselves. **Email invites
  expire after 7 days.** So `/multica-ops:hire <person>` must ask which role, and say plainly what it
  cannot do.
- **Runtimes are local**: auto-detected from PATH when each member's daemon starts
  (the supported list grows — check `/docs/providers` rather than quoting a count).
  Adding one = install the tool + `multica daemon restart`.
  Audit with `multica runtime list` (note online/offline and which machine).
- **A second machine is the honest way to raise the ceiling.** The caps (6 per agent, 20 per
  daemon) are **per daemon**, so another computer is another ceiling — plus its own local tool
  subscriptions. Setup is the owner's two lines on that machine: the install script from
  multica.ai, then `multica setup` (browser sign-in, daemon in the background); it appears as a
  runtime by itself. No browser there → `multica setup … --callback-host <ip>`. **Mops hands
  over the lines; it does not install.** An always-on machine is what a scheduled pipeline needs.
- **Monorepo default**: repo = company; `apps/ site/ marketing/ docs/` = projects;
  `docs/` opens as an Obsidian vault (plain markdown + Mermaid; GitHub renders the
  same files). Notion, when requested, is a mirror — the repo stays the source of
  truth. Split repos only for separate deploy/access/open-source boundaries — and when you do,
  it is **native, not a workaround**: `multica repo add|list|remove` keeps a workspace registry,
  and `project create --repo` takes the flag **repeatedly**, so a project can carry several.

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
   as an **Experts squad**. **Personas are docs-first:** opting into the theatre seeds the
   **register and persona documents** in `docs/audience/` (proto or validated per the data that
   exists — MODULES → Persona theatre); persona **agents/squads stand up per validation round
   and retire after**, never as standing roster at bootstrap. Only Mops in Multica stays
   squadless. The user may decline both.
6. **Stand up Mops in Multica (opt-in — checklist #16 · Resident Mops)** — if enabled: install this skill
   into the workspace and assign it **only to the Mops agent** (other agents carry the
   *guide* skill, not this one — multica-ops is Mops's brain), so Mops in Multica *is* the
   same Mops:
   - **Install idempotently, never blindly.** First `multica skill list` — if `multica-ops`
     isn't there, `multica skill import --url github.com/jamillazarev/multica-ops/tree/v0.3.0/skills/mops`. If it
     **already exists** (re-run, or a teammate imported it), **compare versions**: same →
     skip; older → refresh through `/multica-ops:upgrade` (backup current to `docs/skill-backups/` →
     `import --on-conflict overwrite`), **never a second copy**. (`import` supports
     github/skills.sh/clawhub URLs.) Then `multica agent create` the agent named
     **Mops**, `multica agent skills` to attach the imported skill (+ find-skills),
     `multica agent avatar` matching the chosen library — except **Mops in Multica, which always uses `assets/mops-avatar.png`** from this repo, subtitle *"Executive Advisor ·
     resident"*. Create it **`--permission-mode public_to --public-to-workspace`**: the
     resident exists to be reachable by whoever is in the workspace, so a private one
     defeats the point (one resident serves the team; per-person residents are not a thing
     today). Grant rights per the user's autonomy choice (advisor-only → narrow;
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
   - If declined: skip; Mops lives in the console only, and `/multica-ops:mops` says so.
7. **Labels** (discipline/type; never the stage) and the **repo layout**. This table is the
   layout — **every path the methodology prescribes**; a project's own directories are not
   listed here, they are mapped in `docs/ARCHITECTURE.md`. Rows
   marked *stand-up* are created now; the rest appear when their condition fires, and an
   agent should never invent a home for something already listed here. **Start each from its
   template** rather than improvising the shape — a doc nobody can predict the shape of gets
   skimmed, not used.

   | Path | Holds | Created | Template | Guarded by |
   |---|---|---|---|---|
   | `apps/ site/ marketing/` | the product itself — one dir per project (§14) | stand-up | — | mapped in ARCHITECTURE |
   | `docs/ROADMAP.md` | story map → release plan; the conductor's queue | stand-up | ROADMAP | exists |
   | `docs/TEAM.md` | who owns what — agents **and** people | stand-up | TEAM | exists |
   | `docs/TOOLING.md` | every tool: what · for what · access · where its secret lives · **when last checked** — the probe list `/multica-ops:mops health` reads | stand-up | TOOLING | exists · stale check-dates warn |
   | `docs/DECISIONS.md` | **append-only**: what was tried or rejected, with the evidence, so the same idea isn't rediscovered next quarter | stand-up | DECISIONS | exists · **append-only enforced** |
   | `docs/LATER.md` | deferrals — *what · why · **revisit trigger*** (a moment, not a date) | stand-up | — (shape is here) | exists |
   | `docs/FIELD-NOTES.md` | append-only stumbles — `date · flow · symptom · evidence · fix-candidate`; swept into the backlog at checkpoints (PLAYBOOKS) | **first stumble** | — | append-only by convention |
   | `docs/ARCHITECTURE.md` | what lives where, entry points — every task starts in a fresh worktree, so an unwritten map is re-derived by every agent on every run | once there's code | ARCHITECTURE | warns if code exists without it · must mention every top-level dir |
   | `docs/MAP.md` | **how the product is walked** — the things and the moves, in the product's own words; current state only, ends with *Not mapped yet* (`/multica-ops:mops map`). ARCHITECTURE answers *where the implementation lives*; this answers *how it is used* | first walkable flow (at discovery for an existing product) | MAP | — |
   | `docs/BUDGET.md` | the envelope: amount · currency · credits with expiries | `/multica-ops:mops budget` | BUDGET | — |
   | `docs/ECONOMICS.md` | burn · runway · cost per shipped feature | first `/multica-ops:ship` | — | — |
   | `docs/analytics/<release>.md` | the cost/effort ledger for that release | each `/multica-ops:ship` | — | — |
   | `docs/assets.md` | every asset actually used: what · source · **licence** · where | first asset | — | — |
   | `docs/research/` | cited findings from research, discovery, usability sessions, persona runs — **one document per question, each pointing back at what produced it and carrying the date it was true** | first discovery | discovery | — |
   | `docs/audience/` | persona register + persona documents | theatre module on | PERSONA | — |
   | `docs/design-system/` | tokens, components, `CONVENTIONS.md` | design-system module on | COMPONENT | — |
   | `docs/brand/` | the brand book | brand module on | BRAND | — |
   | `docs/skill-backups/` | pre-upgrade copies of skills | `/multica-ops:upgrade` | — | — |
   | `docs/.workspace-state.json` | the state fingerprint per object class + the git HEAD it was taken at | after every Mops operation | — | — |

   **Where bytes physically live.** The repo carries text, code and config. **Files and big
   blobs — video, raw media, datasets — go to object storage with a pointer in the repo, never
   into the DB and never into git** (STACKS); what was used is still logged in `docs/assets.md`,
   because provenance is portability. The cloud holds issues and comments; code and keys stay
   on members' machines.

   **A document nobody links is a document nobody reads** — anything added under `docs/`
   beyond this table is linked from the doc it belongs under, and the guard warns when it
   isn't.
   **Protect the default branch — actually run this, don't just intend it.** Merge is the
   conductor's terminal step when the gates are green; the protection is what keeps that from
   being a sentence anyone can ignore.

   ```sh
   printf '%s' '{"required_status_checks":{"strict":true,"contexts":[]},
     "enforce_admins":true,
     "required_pull_request_reviews":{"required_approving_review_count":0},
     "restrictions":null,"allow_force_pushes":false,"allow_deletions":false}' \
     | gh api -X PUT repos/<owner>/<repo>/branches/main/protection --input - | head -3
   ```

   The body goes as **JSON via `--input`, not `-f` flags** — the API validates types
   strictly (booleans, integers, `null`), and string-typed `-f` fields now 422
   (measured 2026-07-30). A rejected push reads "repository rule violations" even when
   the blocker is classic branch protection, not a ruleset.

   Three honest caveats, because a control you misunderstand is worse than none:
   **(a)** this stops force-push and deletion, not a bad merge — **our review gates are Multica
   sub-issues judged by agents, not CI status checks**, so nothing wires a gate verdict to a
   commit status. If the project has CI, add its job to `contexts` and the two systems finally
   agree. **(b)** `enforce_admins=true` matters most here: without it the conductor, which holds
   git rights, can simply step around the fence. **(c)** With **no remote at all** — the
   documented default when the owner is unsure — there is no branch to protect and the merge
   rule really is only a sentence. Say that out loud rather than implying a gate exists.
   Re-checked at `/multica-ops:mops health`.
   Then **install the docs guard** — `templates/company-preflight.sh` as the repo's
   pre-commit hook (PLAYBOOKS): a skeleton is only useful while it stays true.
   `docs/LATER.md` and `ECONOMICS.md` are the two without a template: their shape is stated where they
   are defined (a deferral is *what · why · revisit trigger*; economics is the ledger
   rolled up — PLAYBOOKS).

## 15b. Commands are namespaced — say the full form

Claude Code namespaces plugin commands: this skill's are **`/multica-ops:mops`**,
**`/multica-ops:status`**, **`/multica-ops:ship`** and so on. The prefix is not decoration —
it is what stops two plugins colliding over one verb, so there is no bare `/mops` and
nothing installs one. **Quote the namespaced form**, every time: quoting a command the reader
does not have is what produced the first *"unknown command"* report.

**An earlier version shipped a short `/mops`** as a user-level command file, installed by a
SessionStart hook. It is retired: it taught one form while the palette showed another, left a
file in the owner's global config that this skill then had to explain and defend, and bought
nothing plain language does not already give. **Anyone still carrying it can delete it** —
`rm ~/.claude/commands/mops.md` — and nothing here depends on it.

**Outside Claude Code there are no slash commands at all.** Cursor, Codex, Windsurf and the
rest reach every flow through plain language, and so does the plain word: *"mops, status"*
works everywhere, which is why no flow is ever only reachable by a command.

## 16. Interview checklist (detail)

Each item with its default, as walked in `/multica-ops:init` and re-asked in the `/multica-ops:join` delta.

1. **Where the code lives — ask, never assume, and never create anything on the owner's
   accounts uninvited.** Three separate questions, in this order: *does a repo already
   exist?* (then use it — do not init a new one beside it); *if not, do you want one, and
   **where**?*; *and is a remote wanted at all?* **Creating a repository on the owner's
   GitHub is an outward action on their account** — it lands under whatever identity their
   `gh`/git is authenticated as, which is very often their **employer's**. It is
   owner-confirmed, out loud, naming the account it would land in: *"this would create
   `acme-corp/swipy` under your work account `r-tagiyev` — right one?"*. **Mops states the
   visibility as it creates** — *"creating it private"* — since repos are **private by
   default** (§12); **turning one public is itself an outward action**, owner-confirmed like
   any of the four owner-gated kinds, never a silent flip. A local git repo
   with no remote is a legitimate end state and the correct default when the owner is
   unsure; nothing in this methodology needs a remote except per-task parallelism.
2. **Control & expertise** — two questions that shape every later interaction.
    **(a) How much do you want to be in the loop?** *hands-on* (approve each feature) ·
    **checkpoints** (approve at named gates — default) · *hands-off* (only
    destructive/spend, plus a digest). Set globally or per flow; it maps onto `/multica-ops:mops autonomy`
    and `/multica-ops:mops reviews`. **(b) What are you actually expert in?** Record it in `TEAM.md`:
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
8. **Capacity & models** — the tier is **model × thinking-level**, asked together and in
   outcomes (stronger/medium/light — quality AND speed; a free answer wins): a cheaper
   model at high effort often beats a dearer one at default, so `--thinking-level` is set
   per role right here, not later. Audit `runtime list` (runtimes are **local**: auto-detected
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
    **Personas are docs-first** — opt-in seeds the register + documents; agents stand up per
    validation round, not at bootstrap.
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
19. **Language & tone** — three layers, only one of which is a real question:
    - **Talking to Mops in the CLI needs no setting** — it mirrors whoever is speaking,
      message by message.
    - **The working language** (agent comments, shared threads) — *confirm* the chat
      language; issues are read by the whole team, so agents hold it steady rather than
      mirroring each writer. The resident's 1:1 chat MAY mirror instead — one line in its
      instructions, offer it when the owner is multilingual.
    - **Artifacts** (issues, docs, code comments, content) — in the working language or
      English? **Derive the suggested default, don't hardcode it**: a public or
      international audience suggests English; a local product suggests the chat language.
      Say which you derived and why; the owner confirms.
    Tone (business / friendly / terse-technical)? Everything chosen goes into the guide
    skill, first line, absolute — including every agent's first greeting. With several
    humans in the workspace the language is company-wide today; a per-member preference
    is a `docs/LATER.md` item, not a hidden promise.
20. **Governance** (see below) — who can direct Mops (default: all members full; owner
    always full; destructive/spend always → owner) and which flows need a named human's
    sign-off (default: none beyond the destructive gate; ask what the user wants to
    review — image-gen, publishing, every feature…). Multiple human members are normal.
    **Asked in the opening hard-gates wave alongside #2 (control & expertise), not left for
    position 20** (see FLOWS).
