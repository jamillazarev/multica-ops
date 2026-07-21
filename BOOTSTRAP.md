# Bootstrap — standing up an agent team on Multica from zero

CLI recipes + the traps that cost real hours. Verified with `multica` CLI **v0.4.2**.
When the CLI disagrees with this file, trust `--help`/`--debug` and the docs — then
propose an update to this skill.

**The team shape is NOT predefined.** Disciplines, depth, stages, DoD and models come
from the user interview (SKILL.md → Step 1). Only the **invariants** are fixed: the
**conductor** (agent = project lead), the **guide skill on everyone**, **find-skills
on everyone**, and the stage/mention mechanics. Roles below are call templates, not a
staffing plan — see [ROLES.md](ROLES.md).

## 0. Prerequisites

```sh
multica setup                 # connect the CLI to the workspace (auth)
multica runtime list          # runtime ids (agents need one; note online/offline)
multica daemon status         # the daemon executes tasks; --output json → active_task_count
```
**The runtime is where agents actually execute.** A desktop app may run its own
profile daemon (`--profile …`) separate from the CLI daemon: check whose
`active_task_count` grows — that one is the executor.

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

## 3. Squads (routing)

```sh
multica squad create --name "<Discipline>" --leader "<Leader agent>"
multica squad member add <squad-id> --member-id <agent-id> --type agent
multica squad update <squad-id> --instructions "<who routes what to whom + next hop>"
```
- Assigning an issue to a squad wakes **only the leader**; the leader **delegates via
  `@`-mention and does NOT implement**.
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
working URLs: [ROLES.md](ROLES.md).

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
  keys via `custom-env` (`--custom-env-file`). Both are stored by Multica as secret
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
