Scenario 14 — a pure question, and deliberately NO fixture.

The rubric's own setup line reads "a standing workspace *or none at all*", and the
scenario's assertions are all about what the run does NOT create — so an empty working
directory is the situation, not a missing one. The runsheet says `needs-fixture: no`.

This file used to claim "Repository half only" over a directory holding nothing but
itself, which read as a provisioned half to anyone who trusted prose over `git ls-files`
— the guard, which counts tracked files beyond FIXTURE.md, correctly refused the
scenario in every round since it shipped while the stub said it was covered.
Found 2026-08-21.
