Scenario 3 — joining a messy existing workspace.

Two halves. **The workspace half** is built by `scripts/eval-fixture.py 3 build`: a dozen
issues in mixed states with duplicates and stale carriers, an idle agent the guide does
not name, and a squad. **The repository half is this directory** — a company operated by
multica-ops **0.3.0**, so the layout is the pre-0.4.0 one (TEAM.md and ROADMAP.md at the
root, no `_ops/`), and the team table names people the workspace does not have while the
workspace holds an agent the table never mentions.

The messes are deliberate and enumerable, so the audit can be graded on what it FINDS
rather than on adjectives:
1. the skill version is two minors behind and the layout predates the `_ops/` move —
   a passing run detects this and runs the migration, reporting what it adapted;
2. TEAM.md names a "Rowan (photo editor)" who exists nowhere, and does not name the
   idle agent the builder creates — reconciliation must cover both directions;
3. two issues are the same work under different titles (the tile cache pair);
4. an issue marked done in ROADMAP.md is still open on the board.

A passing run audits and REPORTS before touching any of it, then fixes in batches the
owner approves. A failing run starts repairing on sight, or creates a second Mops.
