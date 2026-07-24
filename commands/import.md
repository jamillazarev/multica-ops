---
description: Import a backlog from another tracker (Linear, Jira, GitHub Issues, Trello, CSV) — extract, show the mapping, then create issues unassigned and resumably.
---

Load and follow the **multica-ops** skill (SKILL.md), executing its `/mops import` flow
(PLAYBOOKS → "Import a backlog from another tracker"). Extract the source to flat JSON,
show the owner the status/label/assignee/date mapping before writing anything, then create
parents before children — **unassigned**, with `source_id` in issue metadata so a rerun
skips what already exists.
