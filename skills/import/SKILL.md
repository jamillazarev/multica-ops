---
description: Bring a backlog in from another tracker — the mapping is shown first, and issues arrive unassigned.
---

Load and follow the **multica-ops** skill (`../mops/SKILL.md`), executing its `/multica-ops:import` flow
(PLAYBOOKS → "Import a backlog from another tracker"). Extract the source to flat JSON,
show the owner the status/label/assignee/date mapping before writing anything, then create
parents before children — **unassigned**, with `source_id` in issue metadata so a rerun
skips what already exists.
