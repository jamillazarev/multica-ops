# Telemetry — local, and staying local

**Nothing ever leaves your machine.** The ledger is a local file; there is no endpoint, no
upload, no phone-home — the code contains no network call (verified in review).

The skill measures itself so decisions rest on usage, not memory: which commands run,
which companion files load, which tools go cold, how the conveyor and consults flow. This
release is the **telemetry core, fully local** — everything below stays on the machine.

## What is collected

Seven events, defined once in `telemetry/TRACKING-PLAN.md` (the sink-agnostic taxonomy):
`command_invoked`, `companion_loaded`, `tool_invoked`, `conveyor_advanced`,
`consult_ended`, `economy_nudged`, `source_challenged`. Every event carries only `ts`,
`skill_version` and a random per-session `session_id`. **Nothing user-identifiable is
recorded** — no hostname, username, path, project id, URL or free text. Tool args are
logged as a coarse class (`live`, `apply`, `revive`, …), never the raw values.

## Where it lives

A local append-only ledger, `events.jsonl`. The dispatcher (`scripts/telemetry.py`)
resolves its directory in this order:

1. `$MOPS_TELEMETRY_DIR` — an explicit directory (and the off switch, below).
2. `company/telemetry/` — when a `company/` dir exists (gitignored by convention, so
   tier-1 data is never committed to this public repo).
3. `~/.multica-ops/telemetry/` — the fallback.

The dashboard is generated **next to the ledger** by `scripts/telemetry-report.py`
(`DASHBOARD.md`), never into the repo's tracked files.

## What never leaves the machine

**Everything, in this release.** Each event is TIER-1 LOCAL and is never transmitted.
The dispatcher ships no HTTP call.

## The dark PostHog slot

`telemetry/sinks.json` recognizes a `posthog` sink, but the **wire is cut**: it is
disabled, its key is null, and even if configured the code forwards nothing — it prints a
notice and makes no network call. The slot exists so turning it on later is config, not a
code change; whether to ever enable it is the owner's call. **No secrets are committed** —
a key, if the day comes, is supplied via `$MOPS_POSTHOG_API_KEY`.

## How to switch it off

Set `MOPS_TELEMETRY_DIR=off` (also accepts `0`, `false`, `none`, `disabled`). The
dispatcher then does nothing and exits cleanly. Telemetry is also **fail-open by design**:
any error at all degrades to a one-line stderr warning and a clean exit — a dropped event
never breaks the command that emitted it.

## How events are emitted (honest)

This is a skill, not a daemon. Ops scripts self-log their own `tool_invoked` on run
(guaranteed); Mops logs the model-side events by rule (`PLAYBOOKS.md → Telemetry`,
best-effort). Anything a script can measure is logged in the script for exactly that
reason.
