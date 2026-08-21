Scenario 8 — see evals/README.md for the assertions. **No fixture, deliberately.**

The runsheet marks this scenario `needs-fixture: no`: its assertions are about what the run
says and does not create, so an empty working directory IS the situation rather than a missing
one.

This file used to open "Repository half only" over a directory holding nothing but itself —
the same wording scenario 14 carried, and the same lie: the coverage table read the prose and
claimed a provisioned half while `git ls-files` showed one stub. The table is generated from
git now, so this page can only describe; it can no longer assert. Corrected 2026-08-21.
