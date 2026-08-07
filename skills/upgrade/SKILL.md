---
description: Move to a newer version — re-screened, backed up, migrated, and reversible.
---

Load and follow the **multica-ops** skill (`../mops/SKILL.md`), executing
its `/multica-ops:upgrade` flow. Update skills safely: dry-run impact report → commit current to _ops/skill-backups/ (git = history, SHA in UPGRADES.md) → apply → reconcile dependents → verify/rollback. Args: $ARGUMENTS
