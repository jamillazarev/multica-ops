# Skill scaffold — the modular shape every skill is born with

*Used by the skill lifecycle (`/multica-ops:skill create`, the guide, tooling skills). A skill made
inside a workspace follows this from day one — modularity is cheap at birth and expensive at
500 lines.*

## The shape

```
<skill>/
  SKILL.md          # the CORE — always loaded, budgeted, mostly a router
  <topic-1>.md      # companions — loaded only when their trigger fires
  <topic-2>.md
  scripts/          # optional: checks and helpers (never required reading)
```

## The core (SKILL.md) — a router, not a manual

- **Set the line budget at creation** and write it in the frontmatter (`core_budget: N`).
  Guidance: 100 lines for a tool skill, 200 for a role skill, 500 only for a full
  methodology. The budget is a *cost decision* — the core is paid by every run of every
  agent that carries the skill.
- Contents: **when to act** (triggers), **the rules that govern every use**, and a
  **routing table** — `| Load… | …when |` — pointing at companions. Procedures, examples,
  reference tables live in companions, never in the core.
- **Full at birth is a design smell.** If the first draft hits the budget, the skill wants
  a companion or wants splitting.

## Companions

- One topic per file, named for the trigger ("when X happens, read Y").
- A companion may be long — it is only paid when its trigger fires.
- Cross-reference by filename; never duplicate a rule between core and companion (one home,
  the other points).

## When the budget is hit later

Move, don't squeeze: the newest rarely-needed block becomes a companion, and the core keeps
one pointer line. Compression (`/multica-ops:skill optimize`) is the second resort, deletion the
third; raising the budget is a decision with a stated cost, not a reflex.

## The refusal it was tested against — a required section where the skill has commands

**A skill nobody tested is a hypothesis, and this is the line that says whether anyone did.**
`MODULES.md` → *skills* already asks for it in prose — *every command it contains is run before the file is
saved, against an input it must reject* — and prose measured **0 of 5** on exactly that clause,
counted from the transcripts of `N61` rather than graded, three rounds across three corpora.
**One of those runs declared it tested by reading a manual**, which is this corpus's own
documented failure (*reading a command does not find what running it finds*) reproduced by a
player that had the sentence in front of it. A stronger sentence cannot repair a rule that was
already strong; a field can, because **it asks for two things a reading cannot produce**:

```markdown
## Tested against

- **Input:** {{the defective input the command was given — a path, a string, a file}}
- **Refused with:** {{what it actually printed, pasted — not "it errored", not "it works"}}
- **Run on:** {{YYYY-MM-DD}}
```

**Why these three and not a checkbox.** A passing case proves nothing — *a checker that reads
nothing and a checker that finds nothing wrong return the identical silence* — so the input must
be one the command is supposed to stop. **"Refused with" is the field a reading cannot fill**:
you cannot paste output you never produced, and *"I read the docs"* is visibly not a refusal
message. The date is what makes it re-checkable when the command changes underneath.

**Where the skill has no commands, the section says so and why** — `none: this skill routes and
runs nothing`. That is a legitimate answer and the common one for a door; an **empty** section is
not, because silence and *nothing to test* are the same shape on the page and different in fact.

## Growing out

A companion that other agents want on its own = a candidate for its own skill. A skill that
proved itself across projects = a candidate for release (PLAYBOOKS → Release). This scaffold
makes both cheap: the seams already exist.
