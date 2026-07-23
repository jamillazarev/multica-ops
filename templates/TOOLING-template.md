# Tooling — what we use, how it's wired, and who may touch it

**Why this file exists:** it is the **probe list for `/health`** and the place a tool's
access is recorded. A tool missing from here is a tool nobody checks, whose token nobody
rotates, and whose breaking change surprises the team.

One row per tool. **Operating detail does not live here** — it lives in
`docs/tooling/<tool>.md`, so this stays scannable and the runbook stays deep.

| Tool | What it's for | Access & where the secret lives | Wired how | Checked |
|---|---|---|---|---|
| {{Sentry}} | {{error tracking for the web app}} | {{conductor + web engineer · token in `mcp_config`}} | {{MCP server}} | {{2026-07-23}} |
| {{Vercel}} | {{hosting + preview deploys}} | {{owner only — deploys are outward}} | {{CLI on the daemon machine}} | {{2026-07-23}} |

**Rules that keep this honest:**

- **Secrets are never written here** — only *where they live* (`mcp_config` / `custom-env`).
- **The Checked column is a date, not a tick.** Versions, free-tier limits and pricing all
  drift; an entry past its recheck is unknown, not fine. `/audit` reads this column.
- **Self-hosted or cloud** matters for anything you run yourself — note it, because it
  changes who is on the hook when it breaks.
- A tool nobody has used in a quarter is a candidate for removal, not furniture.

## Version and breaking-change watch

{{Which of these publish a changelog or release feed, and where. The version check at
`/status` reads this — a tool that changed its interface breaks agents silently.}}
