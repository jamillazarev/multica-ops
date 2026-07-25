# Backlog — ideas past the current version

Not commitments. Each carries enough to pick it up cold and a reason it isn't done yet.

## Dogfood: run multica-ops on itself, inside Multica

**Promoted (2.4.0).** All five preconditions landed and the recipe is now
**PLAYBOOKS → "Running a company on this skill itself (dogfood)"**, with the resident's
operating context in `templates/SELF-MAINTENANCE-brief.md`. What remains here is only the
open question worth watching in practice: version identity during long features (one version
per feature is the rule; see the playbook).


## Running the platform update, not just reporting it

Day zero and `/mops upgrade` now *report* a newer Multica and hand over the line; Mops does not
run it. Doing it properly means more than `multica update`: the daemon has to be idle, runtimes
updated too, and on a **self-hosted** server it is a deployment (Compose or Helm, image tag
pinned) where **CLI↔server skew is a real failure mode and the server must go first**. That is
an ops flow with a rollback story, not a one-liner — worth building once the rest is stable.

## Guided install (cloud vs self-host vs desktop)

Day zero stops at rung 1: no `multica` on the machine means Mops hands the owner a link and
waits. That is deliberate — the three ways in (cloud, self-hosted server, desktop app that
bundles the CLI) have different consequences, and a self-hosted install is a Postgres, a
Docker Compose or a Helm chart plus signup controls and email keys, not a one-liner. Guiding
that well means asking what they're optimising for (data residency, uptime ownership, cost)
and then walking a real install — a proper flow, not a check. Worth doing once the rest is
stable; the cost of getting it wrong today (installing the wrong shape on someone's machine)
is higher than the cost of waiting for them.

## One resident Mops per person

Today the workspace gets **one** resident Mops, created `public_to workspace` so everybody
reaches the same agent. With several humans that means one shared thread and no per-person
memory of what was discussed. A per-person resident (`--permission-mode public_to
--public-to-member <user-id>`) would fix both, at the cost of N agents to keep in sync — same
skill, same instructions, N copies drifting. Worth doing only once per-person memory exists to
justify it; until then the shared resident plus a memory keyed by person is the cheaper shape.

## Persona simulation is thin on new models

Noted from user feedback: role-play of competence levels ("you are a junior") has stopped
helping on current models and can hurt (2.2.0 removed grade-as-identity). The Personas
squad still leans on persona-as-instructions. Worth re-checking whether synthetic-user
simulation earns its cost on current models, or whether it should become a lighter
research-synthesis step rather than standing agents.
