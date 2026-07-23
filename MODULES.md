# Opt-in modules

Enabled at the interview or later via `/module`. **Design system & brand** come from
checklist #15 · Design system & brand; the **external tracker bridge** is offered only when
work already lives somewhere else.

## Contents

- [Design work — structure before pixels, and a gate that catches garbage](#design-work-structure-before-pixels-and-a-gate-that-catches-garbage)
- [Design system — the system follows solutions](#design-system-the-system-follows-solutions)
- [Brand — identity, systematized](#brand-identity-systematized)
- [External tracker bridge (opt-in — offered only if you already use one)](#external-tracker-bridge-opt-in-offered-only-if-you-already-use-one)

## Design work — structure before pixels, and a gate that catches garbage

**The failure this exists to stop:** asked to design an app, an agent went straight to
high-fidelity HTML and produced gradient placeholders — because it skipped the structure and
skipped the real tools. Two rules fix it.

**Run `/process` before drawing anything.** Design is the clearest case for
process-discovery (PLAYBOOKS): for a UI it typically surfaces **information architecture →
user flows & journeys → low-fi wireframes → owner approves the structure → high-fi → design
system** — but Mops discovers that per project rather than hardcoding it, and the owner cuts
or adds steps. **Low-fi comes first on purpose:** approving structure on cheap artifacts
saves the tokens and days that redrawing finished screens costs, and it is where the owner's
taste enters before it is expensive to change.

**Ask the design intake up front — never guess it.** Before a pixel: *style and mood ·
colour direction · references the owner likes · anti-references (hard no)*. An agent that
asks only "what stack?" and starts drawing has skipped the questions that decide whether the
output is theirs or generic. This is part of the control level (SKILL → interview): at
*checkpoints* or *hands-on*, the owner sees and signs the structure before high-fi begins.

**Compose, don't hand-draw.** Screens are assembled from a **component library** (Pen.dev,
Shadcn — STACKS → where design is drawn), not written as one-off HTML. Hand-written screens
are both slower (2–5 min each) and worse; a library makes a screen composition, not
generation.

**The design gate rejects, it doesn't rubber-stamp.** A review that passes bad design is not
a review. The gate checks the work against the **approved structure, the intake and the
design system** — mismatch fails it — and **Mops never signs off design itself**: the owner
does, at the checkpoint their control level set. "It rendered" is not "it's good."

## Design system — the system follows solutions

Any project that ships a repeatable form accumulates a **design system**: **tokens/
variables** (color, type, spacing, motion — or a channel's palette and cover grid),
**components/templates** (UI parts, thumbnail layouts, packaging, letter formats) and a
**catalog** (Storybook for digital — see STACKS; a template library or brand book
elsewhere). Home: `docs/design-system/` in the repo — tokens as files are the source of
truth. **Curator = the Design squad lead** (or the sole designer).

- **Reuse-first gate at spec time.** Discussing *any* solution, the conductor/designer
  answers explicitly: *covered by the existing system, or does it need an extension?*
  Default is reuse; an extension is a deliberate, argued decision recorded in the spec
  (what's added and why the existing pieces don't fit). The system grows by argument,
  never as a side effect.
- **A system has three origins — build · adopt · inherit.** Building your own is the
  default flow here. **Adopting a ready-made host system** (Material, Apple HIG, Fluent —
  or non-digital: a franchise brand book, a publisher style guide, a platform's content
  format): the host's guidelines become **law**; `CONVENTIONS.md` records *host + version
  + our delta layer*. Extensions then live in a **separate, documented "our extensions"
  layer** that follows the host's own philosophy and naming — never restyle or reinterpret
  host semantics, that is exactly how teams drift away from the host. Host ships a new version →
  treat it like `/upgrade`: preview the diff and its impact on the delta layer before
  applying. **Inheriting an existing own system** (typical at `/join`): audit-and-prepare
  exactly like the join delta — inventory tokens/components/templates, verdict per piece
  (complete / needs additions / needs rework), wire the conventions, only then extend.
- **Systematize in the same feature.** A shipped solution that introduced new patterns
  gets a systematization sub-task in that feature: new tokens documented, one-offs
  promoted to components (or marked exceptions), stale pieces pruned.
- **Systematization is conveyor work, with a review.** It's built by whichever craft owns
  the medium — code tokens/Storybook components → an **engineer**, cover templates → a
  designer, voice guide → a copywriter — and then passes a **systematization review by
  the curator** before merging into the system. Same pattern in every domain: whoever
  systematizes, the curator reviews.
- **One component standard, fixed at enablement.** Turning the module on, the curator
  seeds `docs/design-system/CONVENTIONS.md`: naming, **one props convention** (borrowed
  from the chosen stack's idioms — e.g. shadcn/Radix patterns for web), state names, and
  a **single documentation shape** per component (`templates/COMPONENT-template.md`:
  anatomy · props table · variants · states · tokens used · do/don't). Every component —
  agent- or human-made — is documented to that shape; mixed conventions (one component
  hook-style, another ad-hoc) are exactly what this kills. Useful skills (find via
  `multica skill search`): *Storybook*, *Storybook Component Doc* (doc standard),
  *Component Library Audit* (catches prop/convention drift), *Design System Patterns*
  (token hierarchies). **Naming/API reference: component.gallery** — real-world design
  systems and component patterns; consult before inventing component names or APIs.
  **Tokens format:** default **W3C DTCG JSON** under `docs/design-system/tokens/`,
  transformed per platform via **Style Dictionary**; Figma sync via Tokens Studio;
  Pen.dev or any other tool → study its token workflow first (see `docs/TOOLING.md`).
- **Design QA checks against the system**: implementations use tokens/components, not
  hardcoded values; a deviation is either fixed or argued into the system. The owner can
  add a human checkpoint on system extensions via `/reviews`.

## Brand — identity, systematized

A company that faces the world needs a **brand**, and Mops treats it as a first-class,
systematized artifact — not a folder of moodboards. Home: `docs/brand/` (the brand book,
`templates/BRAND-template.md`); its **formal elements flow into the design system**
(palette/type → tokens, formats → templates) and its **verbal rules into the guide**
(every agent writes in the brand voice).

**The brand book — what's load-bearing:** positioning statement (for whom · what ·
against what · why believe) · **archetype** (one of 12 — a shorthand agents act on) ·
**personality/style sliders** (5–8 axes, recorded positions) · **tone of voice** (3–5
tone words + a sample paragraph per register — executable examples, not adjectives) ·
values (short) · **references & anti-references** (anti = hard bans) · tagline + naming
rules. Reference galleries for brand/design research (free-first, Mobbin-fallback): **STACKS**. Workshop artifacts — competitor teardowns, "what we dislike about the old brand",
metaphor boards — are **discovery input** that feeds the book (run via `/discovery` /
`/research`), then gets distilled; they are not the book.

**Flow (`/brand`).** New brand → brand discovery (research + the artifacts above; Brand
Designer + Copywriter, conductor coordinates) → book → **owner approval** (identity is
outward) → systematize (tokens/templates → design system, voice → guide). **Existing
brand** (typical at `/join`) → audit first: inventory logo/palette/type/voice/
positioning, verdict per piece — **complete / needs additions / needs rework** — fill
only the gaps the user confirms; an existing brand is incumbent convention, respected.
**Rebrand** (rework verdict) gets its own discovery pass: critique of the current brand
("what do we dislike and why") · a **change-magnitude score 1–10** (evolution vs
revolution — it scopes everything downstream) · "which brands feel close to where we're
going" (reference elicitation) · an explicit **keep/change list** — then 3–5 candidate
positionings/taglines, and the **owner votes**.
A **creator/blogger** gets the same structure scaled down: positioning + voice + a
visual kit + **material templates** (story, post, cover formats) living in the design
system.


## External tracker bridge (opt-in — offered only if you already use one)

Most companies don't need this, so it is **not part of the skill's floor** — nothing
references it until you turn it on. Turn it on when a backlog, a roadmap or an intake queue
lives in Linear (or Jira, or GitHub Issues) and will keep living there.

**Wiring.** The vendor's **MCP server** is the cheapest path: registered in `mcp_config`
with a token that lives there and nowhere else, granted to the conductor and to Mops rather
than to everyone — a tracker connection is an access change, so it follows the same gate as
any other (owner-confirmed). Registered in `docs/TOOLING.md` with its runbook. For a large
one-off migration, prefer the GraphQL API over the MCP: it paginates, and it doesn't spend
an agent's context on every ticket.

**Two shapes, and they behave differently:**

- **One-off migration** — the backlog moves here and the old tracker is archived. This is
  `/import`, it ends, and afterwards there is one source of truth.
- **Standing bridge** — the tracker stays authoritative for some slice (a client files
  tickets there; marketing plans there). Then decide the **direction of truth per field**
  and write it down: who owns status, who owns the description, what happens when both
  change. A bridge without that written down produces two half-true boards, and the team
  stops trusting either. Sync runs on an autopilot; conflicts become an issue for the
  conductor, never a silent overwrite.

### After an import, the work is not yet ours

Tickets arrive written to **someone else's standard** — often a title and a sentence. Left
alone they propagate that standard: agents pick them up, ask nothing, and produce work
nobody can accept or reject. So an import is followed by a **quality pass**, in batches:

Mops reads the imported issues against the bar the company actually holds (EXAMPLES.md) and
reports, per issue, which of these is missing — **the why** (what problem, for whom, with
what evidence), **a success predicate** in one sentence, **what does not count**, a **DoD**,
**dates** the source carried but didn't map, and a **rewrite** where the title describes a
solution rather than a problem. Then it proposes: *rewrite · extend · leave · drop*.

Three rules keep this from becoming vandalism:

- **Never silently rewrite someone's ticket.** The proposal is shown, the owner approves in
  batches, and the original text survives in `source_url` metadata — the source is the
  archive.
- **Triage before polish.** A dead backlog doesn't deserve a rewrite; the first question is
  *does this still matter*, and dropping is a legitimate answer that costs nothing.
- **Fix what blocks work, not what offends taste.** An issue an agent can start on is done
  being edited. Rewriting for elegance burns budget and changes nothing.

Run it right after `/import`, and again on anything imported that reaches `todo` without
having been through the pass — that is the moment it actually starts costing money.
