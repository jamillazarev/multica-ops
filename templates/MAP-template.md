# Product map — how {{the product}} is walked

**Why this file exists:** `docs/ARCHITECTURE.md` says **where the implementation lives** — a
worker's map of the tree. This one says **how the product is walked** — the moves and the
things, in the product's own words. Reasoning about a flow from the architecture map lands a
change in the right file and the wrong journey; this map is what the conductor reads at
decomposition, the design gate reads at review, and a persona walks at validation.

## The things

One line per thing a user meets — **in this product's own words** (screens for an app,
pickup slots for a bakery, corridors for a venue, rubrics for a channel):

- {{**Library** — every recording the user owns; entry point after sign-in}}
- {{**Player** — one recording: playback, transcript, sharing}}
- {{**Search** — reached from Library; returns into Player}}

## The moves

One flow per heading, as the steps a user actually takes — each step names a thing above:

### {{Find an old recording}}

{{Library → Search (types a participant's name) → results → Player. Friction seen in
tickets: no way to disambiguate two people with one name (issue #204).}}

## Not mapped yet

{{The parts nobody has walked or written down — named as `unknown`, never left blank:
the sharing flow after the redesign · everything behind the admin toggle.}}

**Rules that keep this honest:**

- **Every node names something that exists.** A planned screen is not on the map — the
  roadmap points at nodes it will change; it never draws on the map.
- **Current state only.** No "was/changed to" history — the issue threads are the history.
- **Flows climb a ladder** (docs follow decisions): a task's working draft of a flow stays
  in the task; **what ships graduates to the map in the same task that ships it**.
- **A feature names the map nodes it touches** in its spec — impact nobody derived is a
  guess wearing a field; where the touched ground is unmapped, the spec says that instead.
- **Ends honestly.** *Not mapped yet* is a section, not an apology — a claim of `unknown`
  beats a map that looks complete.
