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

## Growing out

A companion that other agents want on its own = a candidate for its own skill. A skill that
proved itself across projects = a candidate for release (PLAYBOOKS → Release). This scaffold
makes both cheap: the seams already exist.
