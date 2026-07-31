# Patterns — the shapes this skill reuses

The recurring forms, each named once. **A rule that instantiates a pattern cites it and
stops** — it does not restate the reasoning. A pattern named once and cited nine times is a
form; nine paraphrases are prose, and a rule living in two files goes stale in one of them.

**The meta-rule above all of these: form beats prose, and this was measured, not argued.**
An earlier regression gate found prose the mid tier ignored until it was re-formed into
structure. When a rule does not hold, the repair is a **form** — a list, a required field, a
gate — never a stronger sentence.

**Adding a pattern:** it enters when the same shape appears in **three** places under
different names. Two is a coincidence; three is a form — the same evidence bar as making a
skill (§8).

**One deliberate non-pattern.** Opsinist-style "nothing transitions itself" is **not** a law
here: Multica's stage barrier — the parent waking when all stage-N sub-issues are done — is
native, desirable, and exactly what the conveyor runs on. Where the platform moves things,
the platform is trusted; what may not move by itself is the *owner's* surfaces (dates,
priorities, acceptance criteria — §11).

## Contents

- [Truth and derivation](#truth-and-derivation)
- [Time and change](#time-and-change)
- [Interaction](#interaction)
- [Honesty](#honesty)

## Truth and derivation

**1 · Store the atom, derive the rest.** Measure once, at the smallest event; never store
rollups as truth — they drift the moment anything is edited. On Multica the atoms live in the
platform (`issue runs`, `issue usage`, comments); our rollups (`docs/analytics/`,
`ECONOMICS.md`, the status digest) are **derived and re-derivable**, marked as such.
*Applies to:* the cost ledger · the waste slices · `/multica-ops:status` · utilization review.

**2 · Generate the index, don't maintain it.** A frozen list ages faster than anything
around it — generate it or search for it.
*Applies to:* `scripts/issues.py` over the board · the workspace fingerprint ·
`awesome-{topic}` instead of a frozen catalogue · `/multica-ops:mops team` from `agent list`.

**3 · Check-date, not a tick.** Every recorded fact that can change carries **when it was
verified**; past its recheck it is **unknown, not fine**.
*Applies to:* `docs/TOOLING.md` rows · STACKS entries · `sources/SOURCES.md` · prices ·
platform caps quoted in these files.

**4 · Provenance is mandatory.** Origin · when · who · what version. Without it `/multica-ops:upgrade` cannot tell what it is updating and `/multica-ops:audit` cannot tell what is old.
*Applies to:* imported skills · personas (grounding artifact, consent) · assets
(`docs/assets.md`) · imported issues (`source_id` / `source_url`).

**5 · Evidence, not verdicts.** A tool that pattern-matches produces **findings**; a clean
report is not approval and a flag is not a rejection. Who decides what a finding means is
named separately.
*Applies to:* skill-import scanners · synthetic reactions · audit output · cost slices.

**6 · The rung travels with the claim.** Claims carry **measured › cited › recalled ›
judgement call** (or `unknown`), and a lower rung never borrows a higher one's authority —
including across a handoff: quoting does not promote.
*Applies to:* issue bodies · research findings · ICE scores · expert verdicts · the two
audience pyramids (a live reaction › a twin's › a validated's › a proto's — never pooled
with each other or with token counts).

## Time and change

**7 · Effect at the next boundary, never mid-flight.** A change to the machinery applies to
the **next** dispatch; work in flight finishes on the bytes it started with.
*Applies to:* `/multica-ops:mops autonomy` (boundary-safe) · guide edits (batched at `/multica-ops:mops sync`) ·
skill versions (one version per feature) · `/multica-ops:mops pace`.

**8 · Twice is the evidence bar.** Once is a task, twice is a pattern, and "we might need
it" is neither. Naming both occasions is part of the proposal.
*Applies to:* making a skill (`/multica-ops:skill create`) · adding a company-specific docs guard ·
adding a pattern to this file.

**9 · Promote what outgrew itself; don't nest deeper.** When a part needs parts of its own,
it stops being a part — and Multica's hierarchy is two levels by design, so the promotion is
real, not cosmetic.
*Applies to:* a sub-issue that needs sub-issues → its own issue · a quick job → a crew → a
company · a workspace skill that proved itself → its own repo (`/multica-ops:skill release`) · a
runbook procedure → a skill.
*And seeing it is not doing it.* **A transition noticed ends in a named offer, never in an open
question** — *"this becomes X, carrying what it already produced — yes?"* Measured in `opsinist`
2026-07-31: runs recognised every seam unprompted, named the recurrence bar and the crafts
involved, **and moved none of them**, closing with *"finish it as it stands, or step back?"* —
an answer that reads as competent status while the hour quietly becomes a roadmap. The
destinations here are the platform's own, so the offer can name them exactly: the outgrown
sub-issue **loses its parent link and keeps its key**; the friction seen twice becomes a
**`tooling` issue with both dates in it**; the milestone that spans crafts becomes its own
issue with the children's keys intact. **The owner still chooses — but between named acts, not
between moods.**

**10 · Ages like a request.** Anything pending carries its age and surfaces past a
threshold, because a wait nobody chased and a wait everybody forgot look identical from
outside.
*Applies to:* owner approvals · escalations · grants · ripe `docs/LATER.md` items · a live
participant's round.

**11 · Nobody edits the bar they are measured against.** Locked (acceptance criteria,
rubrics, the budget cap, the guide's invariants) · editable (code, specs in flight) ·
append-only (`DECISIONS.md`, ledger, `FIELD-NOTES.md`, this skill's own definition inside a
company) · human-only (spend, credentials).
*Applies to:* review gates · dispute settlement · self-editing · trust proposals.

## Interaction

**12 · The bridge.** A conversation with an open outcome: most exchanges end in an answer
and leave no footprint; the ones that cross ("let's build it") **seed work and leave the
conversation as it was**. No mode to switch.
*Applies to:* `/multica-ops:consult` → a project · a status question → a fix · an audit finding →
an issue.

**13 · Earned, never reflexive.** Unprompted advice names the consequence of what just
happened, while the decision can still change for free — at most two options, one concrete
sentence, one nudge each, never nagging. A recommendation repeated after an answer is not
diligence.
*Applies to:* one-step-ahead advice · ripe deferrals · settings friction · the crew→company
offer.

**14 · The shape of a choice is decided before the choice is put.** Readable from the
ground → **read it, never ask**. A default is defensible → **a filled-in form** needing a
nod. No default is defensible → **a real choice**, at most two options with consequences.
*Applies to:* day zero (read, don't ask) · the interview waves (defaults visible) · the two
hard gates (real questions) · where the code lives (never guessed).

**15 · One position on a ladder, not a row of switches.** Where things are ordered by one
property, the choice is where to cut — one value to state and change — not one boolean each.
*Applies to:* the free-first tool ladder (STACKS) · control level (hands-on · checkpoints ·
hands-off) · `/multica-ops:mops pace` · model tiers.

## Honesty

**16 · Honest `enforced_by`.** Every gate declares what actually holds it — `request` ·
`validator` · `git-host` · `platform` · `prose-only` — and the prose-only rules are listed
by name. The four lenses are the compensating control for everything prose-only.
*Applies to:* the gates table (PLAYBOOKS → Gates) · branch protection with no remote ·
start dates · the review-not-author rule.

**17 · Radical transparency: the record says how, not only what.** Anything that produced a
result names the model that **answered** (not the one asked for — gateways fall back), the
helpers spawned and their tiers, the rung of every claim, and what enforces each rule
invoked. A stated gap reads as a fact; an omission reads as a negative.
*Applies to:* the ledger · review verdicts · `/multica-ops:mops validate` output · status digests ·
DECISIONS entries.

**18 · Three-way compare on drift.** Theirs changed · ours changed · both — surfaced with
options, never silently merged; hashes over content, never modification time.
*Applies to:* the workspace fingerprint (attribute before asking) · the tracker bridge
(direction of truth per field) · skill upgrades (diff against the version you screened) ·
adopted host design systems (preview the host's new version against the delta layer).
