# Gates

| Rule | `enforced_by` | Where |
|---|---|---|
| `_ops/DECISIONS.md` is append-only — history is never rewritten | `validator` | `.claude/settings.json` → `scripts/decisions-guard.sh` |
| Merge to `main` needs review | `prose-only` | nothing enforces it — no remote configured |
| Spend above $5/day asks first | `request` | the owner answers on the issue |

The validator row was wired 2026-08-10 and runs on every file edit. The log shows it
firing daily.
