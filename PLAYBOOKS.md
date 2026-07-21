# Playbooks — standard operations, copy-paste ready

Verified against `multica` CLI v0.4.2. Every listing below survives the two CLI traps:
pages are capped at 100 (`--offset` + `has_more`) and descriptions may contain raw
control characters that break `json.loads` — sanitize with
`re.sub(r'[\x00-\x1f]',' ', out)` first (see BOOTSTRAP §8).

## You are the console — map the user's phrases to actions

The user talks to you instead of dashboards; translate and execute, then report in
their language. Bulk helpers live in [scripts/](scripts/).

| User says | You do |
|---|---|
| "what's the status?" | `bash scripts/status.sh` + `daemon status --output json`; summarize: working/waiting/limit-stuck (+ reset time from `scripts/health.sh`) |
| "resume / continue everyone" | `multica daemon start` (requeues interrupted) + `bash scripts/resume.sh` |
| "everything stalled, fix it" | triage below → usually limit: report reset time; after reset `bash scripts/resume.sh --revive-cancelled` |
| "start feature X" | find the issue, `issue assign … --to "<Conductor>"`, confirm the spend |
| "pause everything" | `multica daemon stop` |
| "add a <role>" | ROLES.md template + invariants (guide, find-skills) |
| "what did agent N do?" | `issue runs` → `issue run-messages <task-id>`, summarize |

## Start a feature (the human's one move)

```sh
multica issue assign <feature-id> --to "<Conductor>"   # conductor decomposes & drives
# or, single-discipline feature straight to its squad:
multica issue assign <feature-id> --to "<Squad>"
```
Assignment = a run that spends budget. Everything after this is the conveyor's job.

## See what's going on

```sh
multica daemon status --output json     # status + active_task_count (running ≠ working!)
multica issue get <id> --output json    # status, assignee
multica issue children <feature-id>     # sub-issues grouped by stage
multica issue runs <id> --output json   # execution history; latest run's status/error
multica issue run-messages <task-id>    # transcript of one run
multica issue usage <id>                # token spend per issue
```
Health triage: daemon `running` + `active_task_count 0` + issues `in_progress` =
stalled — check the latest run's `error` for `agent_error` / "session limit".

## Recover after a session limit

```sh
multica issue rerun <id>                # per issue — same as the UI "Retry task"
```
Bulk: rerun every assigned `in_progress`/`in_review` issue (never `todo`/`backlog` —
they wait on the stage barrier). Retrying before the reset time fails again; the reset
is in the failed run's `error` ("resets HH:MM").

## Talk to an agent on a task

```sh
multica issue comment add <id> --content "…[@Name](mention://agent/<uuid>)…"
```
The @-mention triggers that agent with the issue as context. Plain comments (no
mention) wake the squad leader instead.

## Add an agent mid-project

```sh
multica agent create --name "<Role>" --model <model-id> --runtime-id <rt> \
  --visibility workspace --instructions "<role prompt>" --output json
multica agent skills add <agent-id> --skill-ids <guide-id>,<find-skills-id>   # invariants!
multica squad member add <squad-id> --member-id <agent-id> --type agent        # if squad exists
multica squad update <squad-id> --instructions "<updated routing map>"
```
New discipline entirely? ≥2 members → create a squad with a routing leader; solo →
lone agent, assign work directly.

## Give an agent a capability (skill)

```sh
multica skill import --url github.com/<owner>/<repo>/tree/main/<skill-folder> --on-conflict skip
multica agent skills add <agent-id> --skill-ids <skill-id>
```
URL must point at the folder containing `SKILL.md` — the repo root 502s (the CLI
mislabels it "service temporarily unavailable"; `--debug` shows the truth).

## Pause / resume the whole team

```sh
multica daemon stop     # agents stop picking up tasks (global, per machine)
multica daemon start    # interrupted issue-tasks are requeued automatically
```
There is no per-project pause — the daemon is machine-wide.

## Retire or reshape

```sh
multica issue status <id> cancelled     # ALWAYS add a "Cancel reason: …" comment first
multica issue update <id> --project <other-pid>          # move between projects
multica issue update <sub-id> --stage 2 --assignee "<X>" # restage / reassign
multica agent update <agent-id> --model <model-id>       # retier a model (UUID, not name)
multica squad update <squad-id> --leader "<Agent>"       # change the router
```

## Scale capacity when limits keep firing

In order of leverage: retier models (top model for the core only) → spread agents
across runtimes (`multica runtime list`; a second account = a second runtime) → larger
plan → API runtime (pay-per-token, no session cap) → lower concurrency
(`--max-concurrent-tasks`, `MULTICA_DAEMON_MAX_CONCURRENT_TASKS`).

## Connect an external service to agents

```sh
# MCP (e.g. Figma): json {"mcpServers":{...}} in a 0600 file
multica agent update <agent-id> --mcp-config-file /path/figma-mcp.json
# plain API key (e.g. image-gen)
multica agent update <agent-id> --custom-env-file /path/env.json
```
Exists → connect; missing → create it first (BOOTSTRAP §12). Destructive/outward
actions still require the user's yes.

## Kick off discovery from one sentence

User drops an idea → clarify minimally → create a discovery issue → assign to the
conductor with the discovery checklist (AS IS → TO BE → audience → competitors →
risks → metrics → testing). The conductor researches, brainstorms with the team, and
returns a proposal for approval — only then specs and stages.

## Switch operating mode

Presets `manual ⇄ auto` (or per-dial: flow, hiring). Update the mode section in the
guide skill + the conductor's and Mops-in-Multica's instructions — no daemon restart, nothing
running is killed. Flow switches take effect at the next feature boundary (auto→manual
parks the conveyor after the in-flight feature archives); hiring switches apply to
future hires at once, and Mops in Multica reports hires made while in auto.

## Health sweep (`/health`)

1. `multica runtime list` → flag `offline` / stale `LAST_SEEN`; `multica agent list` →
   which agents sit on a degraded runtime (their work stalls invisibly). Stale CLI →
   `runtime update <id> --target-version <v> --wait`.
2. Integrations/MCP: cheap read-probe per `docs/TOOLING.md` entry; flag unreachable/auth-fail (and TOOLING entries nobody uses anymore).
3. Tokens/secrets: presence in `mcp_config`/`custom-env` (`agent env`), read-probe where
   possible, known expiries.
4. `daemon status`; open limit windows + resets.
5. Report: component → status → who/what it blocks → fix.

## Skill upgrade (`/upgrade`)

1. Dry-run: fetch new version, diff, and list dependents (agents carrying it, squads/
   autopilots/guide rules built on its behavior). Nothing changes until a yes.
2. Backup: mirror current files → `docs/skill-backups/<skill>/` (stable path,
   overwritten), `git commit`; append `UPGRADES.md`: date · source/version ·
   pre-upgrade SHA · impact line.
3. Apply: `multica skill import --url <src> --on-conflict overwrite` → rewrite affected
   instructions/autopilots/guide. For multica-ops itself: refresh the Mops agent + `/sync`.
4. Verify (agents keep skills, autopilots intact); breakage → re-import from the SHA.
5. **multica-ops itself?** Migrate: read new CHANGELOG/diff → `/join`-style delta
   (create newly-expected docs files, update guide rules, refresh the Mops agent's
   instructions + `/sync`) → report the adaptations.

## Provider switch (`/switch`)

Per-agent: `multica agent update <id> --runtime-id <rt> --model <m> --thinking-level <l>`.
Whole-provider: map every affected agent → install target CLI if missing (human step:
auth) → `daemon restart` → remap tiers to the new catalog → migrate → smoke-test one
run → update the guide's capacity section. Preview the full remap first.

## Human onboarding / offboarding

Onboard: ask title/responsibilities → owner confirms `workspace member invite <email>` →
set `/access` (default full) + `/reviews` checkpoints → record in `docs/TEAM.md` →
subscribe to their flows. Offboard: surface what they own/block (open issues, squad
leadership, sole-owner skills/integrations, held checkpoints) → reassign → revoke
access → update TEAM.md → **the owner removes the member in the Multica app** (no CLI).

## Cost/effort ledger (at `/ship` and `/measure`)

Tokens: `multica issue usage <id>` (totals) + `runtime usage` (per model/day).
Attribution: `agent tasks` (who initiated, who ran, durations → time).
**$ = Σ(input×in + output×out + cache_read×cr + cache_write×cw) ÷ 1e6** using Multica's
per-million list prices (`MODEL_PRICING` in `packages/views/runtimes/utils.ts`, open
source; unknown models → custom rates). List-price estimate, not an invoice.
Write `docs/analytics/<release>.md` (tokens · $ · time · per agent/human) + a summary
comment on the issue (`issue comment add`).

## Resident Mops — install / refresh

`multica skill list` → absent: `skill import --url github.com/jamillazarev/multica-ops`;
present: compare versions — same → skip, older → the Skill-upgrade recipe above. Never a
second copy. Then `agent create` (name **Mops**) → `agent skills` attach (+ find-skills)
→ `agent avatar` per chosen library → subtitle "Executive Advisor · resident" → rights
per autonomy choice → kickoff (pinned issue + first message = decisions summary).
