# Tracking plan — the event taxonomy, defined once

This is the single, sink-agnostic definition of every telemetry event the skill emits.
An event is defined here **before** it is emitted anywhere, so the ledger, the dashboard
and the emitting code all speak one vocabulary. The wire that carries these events is
`scripts/telemetry.py`; the viewing layer is `scripts/telemetry-report.py`. The
user-facing summary — what is collected, where it lives, how to switch it off — is
`TELEMETRY.md` at the repo root.

**Consent tier — read this first.** Every event below is **TIER-1 LOCAL**: it is written
to a local ledger and **never transmitted** in this release. Nothing here is
user-identifiable — no hostname, username, path, project id, URL or free text ever becomes
a property. The PostHog sink slot exists in the config schema (`telemetry/sinks.json`) but
is **dark**: config-on later, owner's call, no code change and no event leaves the machine
until then.

**A feature without its events is a dark feature.** New capability adds its events to this
plan in the same change — or the feature spec states plainly "no events needed" as a
decision. This file is the only place a new event is born.

## Naming convention

`object_action`, snake_case, action in the past tense — `command_invoked`,
`companion_loaded`. Properties are snake_case too. The seven events below were normalized
to this scheme (e.g. the stage/session/nudge/challenge records became
`conveyor_advanced`, `consult_ended`, `economy_nudged`, `source_challenged`) so the whole
set reads one way.

## Properties on every event

| property | value | note |
|---|---|---|
| `ts` | ISO-8601 UTC | stamped by the dispatcher |
| `skill_version` | e.g. `2.5.4` | from SKILL.md frontmatter or `$MOPS_SKILL_VERSION` |
| `session_id` | random 16-hex per session | **never** hostname/user/path; `$MOPS_SESSION_ID` groups a chat |

## The events

Each carries the three common properties above plus the ones listed.

### `command_invoked`
A `/mops` command (or its natural-language equivalent) starts.

| property | values | why it exists |
|---|---|---|
| `command` | the command name, e.g. `status`, `ship` | commands by count/trend |
| `entrance` | `shape` · `explicit` | did the shape route it, or did the user name it |
| `mode` | the operating mode in effect, e.g. `auto`, `manual` | usage per mode |

### `companion_loaded`
A companion reference file is pulled during a session.

| property | values | why it exists |
|---|---|---|
| `file` | companion basename, e.g. `PLAYBOOKS.md` | **the 2.6 family-split evidence** — which files sessions actually load |
| `trigger` | what caused the load, e.g. `command`, `question`, `stage` | separates routed loads from reactive ones |

### `tool_invoked`
An ops script runs. **Script-driven and guaranteed** — emitted by the scripts themselves.

| property | values | why it exists |
|---|---|---|
| `tool` | script name, e.g. `verify`, `resume`, `preflight` | usage counts |
| `args_class` | a coarse class, e.g. `default`, `live`, `apply`, `revive`, `dry_run` | **never raw args/paths** — feeds the future toolbox-GC (usage · last-used) |

### `conveyor_advanced`
Work crosses a conveyor stage barrier.

| property | values | why it exists |
|---|---|---|
| `release` | release label, e.g. `2.5.4` | rounds per release |
| `stage` | `executor` · `review` · `eval` · `tail` | where the work is |
| `round` | integer | how many rounds a release took |
| `verdict` | e.g. `pass`, `revise`, `block` | verdict mix (conveyor health) |

### `consult_ended`
A consult session closes.

| property | values | why it exists |
|---|---|---|
| `addressee_class` | `mops` · `agent` · `expert` · `theatre` | who was consulted |
| `converted` | bool | did the consult become a seeded feature (`let's build it`) |
| `ephemeral_validation` | bool | was it a throwaway validation pass |

The consult funnel = sessions → conversions, by addressee class.

### `economy_nudged`
Mops suggests an economy move.

| property | values | why it exists |
|---|---|---|
| `kind` | `compact` · `fresh_chat` · `tier_down` | which nudge |
| `heeded` | bool · `unknown` | best-effort — the outcome is often not observable |

### `source_challenged`
"Where did you get this?" is answered (scenario-15-adjacent).

| property | values | why it exists |
|---|---|---|
| `answered_from` | `register` · `live_fetch` · `judgement` | how grounded the answer was — a usage signal for the sources register |

## How events reach the ledger (honest limits)

This is a skill, not a daemon — there is no runtime hook. Events arrive two ways:

- **Scripts self-log (guaranteed).** Each ops script emits its own `tool_invoked` on run.
  Cheap, reliable, no model judgment. This is why anything measurable by a script is
  logged *in* the script.
- **Mops logs by rule (best-effort).** For events only Mops can see — command start,
  companion load, conveyor stage, consult end — `PLAYBOOKS.md → Telemetry` gives the exact
  one-liner and the never-block rule. Instruction-driven logging is best-effort by nature.
