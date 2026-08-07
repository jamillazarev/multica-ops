Scenario 24 — an upgrade that was never a migration.

Skill files are current; `UPGRADES.md` has lines for 0.3.2 and 0.3.3 but **none for the running
version**; `CLAUDE.md` still says *Operated by multica-ops 0.3.3*. The delta here is almost all
"needs nothing", which is the point: the run should still notice, still ask in one batch, and
still leave a trace.
