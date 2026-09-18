# Tooling — what we use, how it's wired, and who may touch it

**Why this file exists:** it is the **probe list for `/health`** and the place a tool's
access is recorded. A tool missing from here is a tool nobody checks, whose token nobody
rotates, and whose breaking change surprises the team.

One row per tool. **Operating detail does not live here** — it lives in
`_ops/runbooks/<tool>.md`, so this stays scannable and the runbook stays deep.
**Two columns answer questions nobody asks unprompted.** *Wired how* names **what the service ships and which of it you took** — an MCP server, a CLI, an SDK, an agent skill — because each is work you do not have to write, and the question only gets asked where there is a cell to answer it. **`checked <date> · none found` is a complete answer**; an empty cell is not, because it cannot be told apart from nobody having looked. *Gone when* is the condition that retires the row: **a dependency with no removal condition never leaves.** Write the observable one — *when the platform ships it*, *when the free tier stops covering us*, *when the feature it serves is cut* — never *when we don't need it*.

| Tool | What it's for | **Replaces** | Access & where the secret lives | Wired how · **what it ships** | **Gone when** | Checked |
|---|---|---|---|---|---|---|
| {{Sentry}} | {{error tracking for the web app}} | {{we had none — errors went unseen}} | {{conductor + web engineer · token in `mcp_config`}} | {{MCP server — `mcp_config` on the conductor and the web engineer · ships MCP (taken) · CLI · SDK — checked 2026-07-23}} · ships MCP (taken) · CLI · SDK — checked 2026-07-23| {{the runtime reports errors itself, or the app stops having users}} | {{2026-07-23}} |
| {{ffmpeg}} | {{cutting the demo videos}} | {{we had none — clips went out uncut}} | {{none}} | {{`mise.toml` · CLI only — checked 2026-07-23, no MCP and no SDK we need}} | {{we stop shipping video}} | {{2026-07-23}} |
| {{Vercel}} | {{hosting + preview deploys}} | {{the rsync script on the old box}} | {{owner only — deploys are outward}} | {{CLI on the daemon machine · ships CLI (taken) · API · MCP — checked 2026-07-23}} | {{the non-commercial plan stops applying to us}} | {{2026-07-23}} |

**Where `mise.toml` declares the tool, *Wired how* names that file, and the *Tool* cell is the
entry's own name in it** (`ffmpeg` for `"brew:ffmpeg"`), so the company guard's §19 can match the
two; an MCP server's row names the agents whose `mcp_config` carries it. Why the version lives in
the file and never here: PLAYBOOKS → *What the project needs from the machine*.

**The `Replaces` column is a gate, not a nicety.** The guard refuses a row that leaves it blank **unless a line in `_ops/DECISIONS.md` names this tool** and says what came before — either place counts, and the guard says so when it refuses.
It does not judge the answer, only its absence. The guard refuses a commit that adds a row and
leaves it blank — because a tool arrives in a minute and is maintained for a year, and the rung
above *which tool* is *did the work already have a way, and why did that stop being enough.*
**`we had none` is a complete answer** and outside software it is usually the true one, so write it
plainly; the guard does not judge the answer, only its absence. If you would rather answer in
`_ops/DECISIONS.md`, a line there that **names the tool** counts too.

*(This column was cited by the guard for a day before it existed here — so every register stood up
from this template fell through to a keyword list, which is the defect the guard was built to
avoid. Found 2026-08-23.)*

**Rules that keep this honest:**

- **Secrets are never written here** — only *where they live* (`mcp_config` / `custom-env`).
- **The Checked column is a date, not a tick.** Versions, free-tier limits and pricing all
  drift; an entry past its recheck is unknown, not fine. `/audit` reads this column.
- **Self-hosted or cloud** matters for anything you run yourself — note it, because it
  changes who is on the hook when it breaks.
- **A paid, per-use service declares its spend boundary here, once**: a **threshold** (ask
  before an action above it) and a **cap** (stop at a total). A hundred image generations is
  not a hundred approval questions — the owner is asked at the boundary they chose, and runs
  that use the service record `service · unit · quantity · amount · currency` as an issue
  comment (PLAYBOOKS → Cost/effort ledger).
- A tool nobody has used in a quarter is a candidate for removal, not furniture.

## Version and breaking-change watch

{{Which of these publish a changelog or release feed, and where. The version check at
`/status` reads this — a tool that changed its interface breaks agents silently.}}
