# Backlog — ideas past the current version

Not commitments. Each carries enough to pick it up cold and a reason it isn't done yet.

## Dogfood: run multica-ops on itself, inside Multica

**The idea.** Stand up a Multica company whose product *is* this skill — the maintainer,
the reviewer, and the four audit lenses as agents — and let it improve the skill under the
same methodology the skill teaches. The strongest possible eval: the gap between "as
written" and "as it behaves" shows up on us first.

**Why it's compelling.** Every defect this session's audits found was of one kind — a
sentence that parsed, linked and was false. A company running the skill over the skill
would hit those the way a user does, not the way an author rereads. And it closes the loop
the skill already implies: `/mops skill release` sends a proven skill to its own repo; this is
that repo maintained by a Multica company.

**What it needs before it's safe or useful — this is why it's backlog, not done:**

1. **Resource type = `github_repo`.** The repo is public, so this is free, and it is the
   only way the four lenses run in parallel — `local_directory` would serialise them
   (REFERENCE §1). Non-negotiable.
2. **The CLI on the daemon machine.** `preflight.sh` and `verify.py` need `multica` present;
   `verify --live` needs it authenticated. An agent runtime without the CLI can edit the
   markdown but cannot check its own work.
3. **A locked gate on the skill editing itself.** A skill that rewrites its own rules is
   literally "the author moves the bar it's measured against" (REFERENCE §8). The skill's
   own `SKILL.md`, the preflight scripts and the evals must be **locked surfaces**: an agent
   proposes, a human merges. Without this, the safest-sounding self-improvement is the most
   dangerous.
4. **The lenses as temporary agents.** create → run → archive (the talent-pool pattern),
   not a standing squad — they read, they don't maintain.
5. **A merge gate that is real, not prose.** This repo now installs branch protection
   (BOOTSTRAP §15); the dogfood company must use it, because the thing being merged is the
   methodology everyone else inherits.

**Open questions to settle first:**
- Does the resident Mops editing this skill create a version-identity problem — it is
  running vN while proposing vN+1 of itself? Probably fine (the running copy is bytes on
  disk, the proposal is a diff), but worth a paragraph before trying.
- How does `/mops upgrade` behave when the workspace *is* the skill's own repo? The migration
  map is the file being edited.

**Verdict:** worth doing, high signal, but only after (1)–(5). Attempting it without the
locked-gate rule would be the single riskiest thing this skill could do.

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
