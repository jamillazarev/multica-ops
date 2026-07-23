---
description: The parallelism dial — careful, balanced, or fast. How hard to fan work out across agents, changeable on the fly.
---

Load and follow the **multica-ops** skill (SKILL.md), executing its `/pace` flow. Set how
hard the team parallelises: *careful* (few concurrent, more checkpoints) · *balanced* ·
*fast* (fan out toward the concurrency ceiling, tier routine work down). It trades throughput
against cost and blast radius, is capped at ~3–5 concurrent agents and by runtime concurrency,
and does nothing on a `local_directory` project, which serialises regardless (REFERENCE §7) —
say so plainly rather than promise speed a local resource can't give.
