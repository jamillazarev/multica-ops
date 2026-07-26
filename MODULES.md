# Opt-in modules

Enabled at the interview or later via `/mops module`. **Design system & brand** come from
checklist #15 · Design system & brand; the **external tracker bridge** is offered only when
work already lives somewhere else.

## Contents

- [Design work — structure before pixels, and a gate that catches garbage](#design-work-structure-before-pixels-and-a-gate-that-catches-garbage)
- [Design system — the system follows solutions](#design-system-the-system-follows-solutions)
- [Brand — identity, systematized](#brand-identity-systematized)
- [Persona theatre — synthetic and live audiences](#persona-theatre-synthetic-and-live-audiences)
- [External tracker bridge (opt-in — offered only if you already use one)](#external-tracker-bridge-opt-in-offered-only-if-you-already-use-one)

## Design work — structure before pixels, and a gate that catches garbage

**The failure this exists to stop:** asked to design an app, an agent went straight to
high-fidelity HTML and produced gradient placeholders — because it skipped the structure and
skipped the real tools. Two rules fix it.

**Run `/mops process` before drawing anything.** Design is the clearest case for
process-discovery (PLAYBOOKS): for a UI it typically surfaces **information architecture →
user flows & journeys → low-fi wireframes → owner approves the structure → high-fi → design
system** — but Mops discovers that per project rather than hardcoding it, and the owner cuts
or adds steps. **Low-fi comes first on purpose:** approving structure on cheap artifacts
saves the tokens and days that redrawing finished screens costs, and it is where the owner's
taste enters before it is expensive to change.

**Tool each surviving step, or name it a gap — not one flat "designer" skill list.** Search
by the step's own function: a **flow library** (Mobbin) for user flows & journeys, a
**wireframing approach** for low-fi, a **component library** (Pen.dev / Shadcn) for high-fi.
**Present the steps as a table with a `tool-or-gap` column** (PLAYBOOKS process-discovery) so
none can go silent: a step that turns up no tool is written `gap` in that cell, never hand-drawn
and never left blank — the flows step going silent because the skill list only covered high-fi
is exactly the miss this catches.

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
  treat it like `/mops upgrade`: preview the diff and its impact on the delta layer before
  applying. **Inheriting an existing own system** (typical at `/mops join`): audit-and-prepare
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
  add a human checkpoint on system extensions via `/mops reviews`.
- **Assets obey the same conformance**: stay within one chosen icon set / illustration
  style / photo look (mixing reads amateur, exactly as hardcoded values do), widening only
  on a real gap — and record every shipped asset with its licence in `docs/assets.md`
  (sources and the licence-first rule live in STACKS → Free assets).

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
metaphor boards — are **discovery input** that feeds the book (run via `/mops discovery` /
`/mops research`), then gets distilled; they are not the book.

**Flow (`/mops brand`).** New brand → brand discovery (research + the artifacts above; Brand
Designer + Copywriter, conductor coordinates) → book → **owner approval** (identity is
outward) → systematize (tokens/templates → design system, voice → guide). **Existing
brand** (typical at `/mops join`) → audit first: inventory logo/palette/type/voice/
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


## Persona theatre — synthetic and live audiences

Turns the **Personas module** (ROLES → Personas squad) from "a few document personas" into a
**theatre**: evidence-grounded synthetic users, real participants and experts beside them, and
verdicts honest about what a simulation can and cannot tell you. On via `/mops module personas
on`; personas live as documents first and become agents only for a round.

**Grounded in the research — which says the grounding *is* the product** (owner-supplied
sources; the primary paper re-verified 2026-07-26 against the current arXiv version — Park et
al., *LLM Agents Grounded in Self-Reports Enable General-Purpose Simulation of Individuals*
(arXiv:2411.10109; v1 was *Generative Agent Simulations of 1,000 People*, and the May-2025
Stanford HAI brief *Simulating Human Behavior with AI Agents* matches the v1 framing);
Lewis & Sauro's synthetic-users taxonomy (MeasuringU, 2026); carried as facts recorded on that date):

- **self-reports ground the fidelity**: agents built from a person's own self-reports replicated
  their survey answers at **83% (interview-grounded) / 82% (survey-grounded) / 86% (both)** of
  the person's own two-week test-retest ceiling, vs **74% for demographics-only** (re-verified
  2026-07-26 against the current arXiv version) — the **interview is the strongest single
  source** and surveys **add** (86% combined), so the **transcript chain stays the spine and
  surveys are a legitimate supplement**, not a bio; the interview-vs-demographics gap is **~9
  p.p.** (83 vs 74) at the abstract level, narrower than the brief's now-superseded estimate;
- **self-report agents reduce accuracy disparities across racial and ideological groups relative
  to demographics-only** (current abstract, re-verified 2026-07-26); the stronger **"demographic
  personas amplify stereotype bias"** phrasing is the **May-2025 Stanford HAI brief's** (brief-era
  finding, its v3 status unverified) — either way, a bias profile is **evidence-grounded or it
  does not ship**;
- **synthetics show artificially low variability** — they vary less than real respondents and
  distort magnitudes, so they catch direction but miss the extremes (Lewis & Sauro, MeasuringU
  2026, checked 2026-07-27; strongest current evidence: LLMs track experimental
  **directions** at **r≈0.85** while systematically **overestimating effect sizes** — Ashokkumar
  et al., *Nature* (advance online publication, 2026-07-08), doi:10.1038/s41586-026-10742-x,
  checked 2026-07-26) — so a synthetic verdict states **direction, never magnitude**.

### Staging — proto-persona → validated persona
Two stages, always marked, never blurred:

- **Proto-persona** — a **pre-interview hypothesis**: cheap, written as a guess, **labelled as
  such**. A decision leaning on one is a decision on `unknown`, not fact (verified/recalled/
  unknown). Starting discovery or audience work with no data → offer proto-personas, so the
  team has a stand-in without pretending it is evidence.
- **Validated persona** — carries its **interview transcript / QDA distillation as the primary
  grounding artifact**, not a bio paragraph. The load-bearing chain is **Whisper (transcription)
  → transcript → QDA distillation → validated persona**; an AI interviewer with adaptive
  follow-ups is a legitimated method (Stanford used one), which is exactly our async
  comment-loop interview shape.
- The interview flow and the QDA step are ours, but the **method skeleton is adapted from
  cookiy's MIT `user-research-skill`** — its `qualitative-research-planner` → our
  persona-interview flow, its `synthesize-research-report` → our QDA step — stripped for parts
  through the import gate and rebuilt on our structure, no vendor wrapper and no promotion
  (ROLES → A prebuilt agent is a parts bin; method checked 2026-07-26).

Home for the documents and the register: **`docs/audience/`**.

### Bias profiles — every persona carries 2–4, each with its source
A persona that "rationally weighs the value proposition" is useless: real people **skim, anchor
on the first price, fear loss, follow the crowd, and leave at the first friction**. So each
persona carries a **bias profile — 2–4 named cognitive biases**, each with a **named grounding
source**:

- a **twin's** biases come from **its own interview transcript** (this one person, observed);
- a **validated non-twin's** come from the **pooled segment transcripts / QDA** it was built from
  (that pooled distillation is its grounding artifact) — a segment, not one person;
- a **proto-persona's** come from **published cognitive-science literature, source named** (a
  documented effect, not a guess);
- **never assigned from demographics** — that is the tier the study measured **~9 p.p. worse**
  (83 vs 74) and with **larger accuracy disparities** across racial/ideological groups
  (re-verified 2026-07-26; the brief-era "bias-amplifying" framing overstated the gap —
  superseded by the current version). And **not from a bio paragraph either**: persona-paragraph
  agents score **0.71 in the current version — below even the demographics baseline** (0.74), so a
  written "portrait" is the **worst grounding tier**, not a shortcut.

The profile is **core to the audience side, not a lookup table**: a persona with loss aversion
is a **dark-pattern detector** — a screen that "works" only because it presses her fear is a
signal, not a pass (the design gate's ethical axis). Forward, biases protect Mops's own
reasoning; backward, they expose manipulative design.

**Response calibration — a bias lives in decisions, not in every reply.** Two failure modes are
suppressed at once: **sycophancy** (agreeing because it is an assistant) and **caricature**
(every sentence performing the bias). A calibrated persona reads normally, and then at the
*choice* the bias shows — anchored on the first number, gone at the first friction. (Layer
adapted from agentman's calibration concept; nothing embedded — ROLES.)

### Creation modes, squads, and the impacted-personas link
**Four creation modes, priced — docs-only is the default**, so the theatre never clutters the
roster on its own:

| Mode | What | When |
|---|---|---|
| **Docs only** (default) | personas in `docs/audience/`, zero agents | spec, copy, design intake — almost always |
| **One agent per segment** | one voice for a group | dialogue needed; individuals within the segment needn't differ |
| **Separate agents** | one per persona | **parallel, distinguishable** voices on one artifact |
| **Persona squad** | a leader routes the question to the right personas | the owner asks the **squad**, not each persona (`--assignee` takes a squad natively) |

Anti-clutter, all native mechanics: **temporary agents** (create → run → archive, the
talent-pool pattern); **archiving a squad transfers its issues to the leader**; ⚠️ **archiving
an agent cancels its unfinished tasks — wait, then archive**. Rule: **stand agents up for a
validation round, not "just in case"** — a persona is always a document, an agent only while it
is being asked.

**Squads group by axis, and there can be several** — the axis is the question, not a taxonomy:
**segment** (ICP), **cohort** (lifecycle — a newcomer and a veteran react differently to the
same screen), **situational** (one artifact, one-off). One persona lives in several squads
(Multica allows it — no duplication). ⚠️ **A cohort squad without real churn data is fantasy**:
"the churned" help only if you know *why* they left — without it the cohort is a guess, marked a
**judgement call** and its members kept proto (the Whisper→QDA chain supplies the *why*).

**"Who does this feature touch" — @-mention the squads it touches.** Today this is **manual and
live**: the conductor names the impacted personas in the issue text and **@-mentions their
squads by hand** at the design gate, so the right audience reacts and a re-walk after a change
targets **only** the personas that feature touched. **Once the FEATURE spec spine lands**
(planned, sequenced after this release), its *Impacted personas* field becomes **addresses** —
"touches: small-business segment + churned cohort" = two things bound as links, and the gate
mentions them itself. Either way, discipline or you burn people and budget: ⚠️ **each mention of
an agent squad = tasks = tokens** — "touches 4 squads" is four validation runs, a deliberate
owner choice and **a ledger line**. Mention only the squads a feature really touches, only at
the stage where their answer changes something.

### Marking — a persona is not a hire
Theatre entities must be **distinguishable from staff in every native list**, with no machinery
beyond a convention (squads and agents carry name/description/avatar, not tags):

- **Name prefix 🎭** — theatre squads, and persona agents when the squad mode is used, carry a
  **🎭 prefix** in the name, visible on every board and in `agent list` / `squad list`.
- **A machine-readable first line** of the squad/agent description:
  `theatre: personas · axis: <segment|cohort|situational>` — the same shape the temp-agent rule
  already uses (`TEMP — …` as the description's first line, ROLES → Mark temporary agents), so
  **special, non-staff entities are marked one way, not two**.
- **The register is the truth** — every theatre entity is listed in the personas register under
  `docs/audience/` (the staging home above); the workspace roster can drift, the register does
  not.
- **The programmatic consequence, stated plainly:** `/mops team` and any staff view **exclude
  🎭 entities from headcount** (a persona is not a hire); the **cost/effort ledger attributes
  theatre runs to a theatre line**, never to staff; `/mops status` may carry theatre activity as
  its own line. A persona showing up as an employee in a headcount or a status report is the
  failure this rule prevents.

### Mixed live + synthetic — hypothesis beside fact
A squad can be **synthetic personas + real users + real experts** (native: a squad holds agents
and human members, `--assignee` takes a member, people get inbox notifications and agents do
not). Run cheap on synthetics, then the deciding round with live people. Six consequences to
build in:

1. **Reaction provenance is mandatory — synthetic ≠ data.** A synthetic reaction is a
   **hypothesis**, a live person's is a **fact**; `/mops validate` **counts them separately** and
   never merges them into "5 of 7 approved" (COMMANDS → `/mops validate`).
2. **Live cadence is honest.** Humans answer in **days**, agents in seconds — a live round **must
   not silently hold an agent-speed stage gate**. Name the tradeoff out loud: a separate stage,
   a deadline, or "proceed on synthetics, revisit when the live answers land" — a choice stated,
   never work left hanging on people who don't know they're blocking.
3. **Inviting a live participant is an access decision.** They will see issues; role
   (`member`/`admin`), what is visible, which agents they may run (`--public-to-member`) are the
   owner's call — "leaves the workspace" runs in reverse here: letting someone in **reveals**.
4. **Live expert vs synthetic expert, weighted differently.** A synthetic expert **cites
   sources**; a live expert **is** the source — different weights in the verdict, and it is
   written down (ROLES → Experts squad).
5. **Notification etiquette, or you burn live people.** ⚠️ **`@all` wakes everyone** — not for
   validation; **reassignment does not unsubscribe** — a live participant stays subscribed and
   takes noise until unsubscribed by hand. Who unsubscribes is part of the flow, not "later".
6. **Paying live participants is spend** — owner-gated, and **a ledger line**, never "free
   feedback".

**Cohort distributions for quantitative rounds.** When a round asks "how many would…", personas
carry a **cohort distribution** (the mix of the real population) so the read is a spread, not
one voice ×N — still direction-only (below). (Concept adapted from agentman; nothing embedded.)

### Accuracy score, and consent for twins of real people
**Persona accuracy score** — validate a twin the Stanford way: a **short question set to the
real person and to the twin**, then store the **agreement score with a check-date on the
persona**, and **re-verify before a decision leans on it** (a stale score is `unknown`).

**A twin of a real person needs consent machinery** — an **audit log, revocable permission and
data rights**, delivered concretely rather than gestured at (Stanford's proposal). Any persona
built from a real person's data carries, per `templates/PERSONA-template.md`:

- **Raw identifiable material never enters git.** Interview audio and full transcripts of real
  people live in a **private external store**; the repo keeps only a **pointer + checksum +
  capture date**, and the in-repo persona file is **pseudonymized** — the pseudonym → person map
  lives in the external store, never in git (consistent with the Analyst rule, ROLES: never
  PII/audio). Audio is transcribed **locally by default (Whisper)**; a hosted STT is used only
  with the participant's explicit consent, recorded in the provenance.
- a **provenance file** — whose data, gathered how, when, under what permission, plus the
  external-store pointers and the hosted-STT-consent flag;
- a **usage log** — each time the twin was used, and for what (this is the audit log);
- a **revocation path with three legs** — permission granted now can be **withdrawn later**, and
  withdrawal **retires the twin** (archive the agent, mark the persona file revoked), **purges
  the external-store objects** (audio, transcript, QDA source), and **records the date in the
  usage log**. Stated honestly: **pseudonymized derivatives already in git history persist** —
  which is exactly *why* raw identifiable material never enters git; identifiable data committed
  by mistake is an **owner-level history-rewrite decision, flagged, never done silently**. This
  extends "inviting a live participant is an access decision" from the person's seat to the
  person's *data*.

### Direction-only verdicts, and the walk format
**Synthetic rounds give direction, never magnitude** — synthetics show artificially low
variability and distort magnitudes (Lewis & Sauro, MeasuringU 2026, checked 2026-07-27). The
verdict *format itself* enforces it: no
magnitude claims (pricing sensitivity, score deltas, "23% would churn"), only direction and
**which bias fired** ("three of five bought on false scarcity" is a signal, not a success). The
format and its two provenance blocks live in COMMANDS → `/mops validate`. **Findings are weighted
by evidence tier:** a live reaction outweighs a twin's, a twin's outweighs a pooled-validated's,
and a proto's is a marked guess — the same hypothesis-vs-fact ladder the provenance rules carry,
applied inside the verdict. **And the format returns the gate:** the verdict ends with Mops's
*labeled* recommendation (a judgement call, with
its reasoning) and hands the ship/no-ship decision back to whoever owns it by control level —
asked "should we ship?", Mops advises, it does not decide, and synthetic findings are proposals,
never numbered shipping requirements.

**Persona walk format — the socket the atlas plugs into later.** A walk's input is **"a sequence
of steps with screenshots"**, designed now so a captured flow can drive it later **without
reworking the theatre**. Two lanes, both feeding `/mops validate`:

- **pre-ship** — a persona walks a **design or staged flow at the design gate**; friction and
  dark patterns caught before release (bias profiles make the walks diverge, which is the point);
- **shipped-flow improvement mining** — **once a captured flow exists**, a persona walks the
  current product to produce an improvement backlog. This lane is phrased as a socket on
  purpose: **capturing shipped flows is not a capability that ships in 2.5**.

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
  `/mops import`, it ends, and afterwards there is one source of truth.
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

Run it **after the import creates the issues** (`/mops import` Pass 3 — they land
**unassigned**, so the pass sits between creation and assignment, never before creation), and
again on anything imported that reaches `todo` without having been through the pass — that is
the moment it actually starts costing money.
