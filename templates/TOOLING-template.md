# Tooling — what we use, how it's wired, and who may touch it

**Why this file exists:** it is the **probe list for `/health`** and the place a tool's
access is recorded. A tool missing from here is a tool nobody checks, whose token nobody
rotates, and whose breaking change surprises the team.

One row per tool. **Operating detail does not live here** — it lives in
`_ops/runbooks/<tool>.md`, so this stays scannable and the runbook stays deep.

| Tool | What it's for | **Replaces** | Access & where the secret lives | Wired how | Checked |
|---|---|---|---|---|---|
| {{Sentry}} | {{error tracking for the web app}} | {{we had none — errors went unseen}} | {{conductor + web engineer · token in `mcp_config`}} | {{MCP server}} | {{2026-07-23}} |
| {{Vercel}} | {{hosting + preview deploys}} | {{the rsync script on the old box}} | {{owner only — deploys are outward}} | {{CLI on the daemon machine}} | {{2026-07-23}} |

**The `Replaces` column is a gate, not a nicety.** The guard refuses a commit that adds a row and
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
