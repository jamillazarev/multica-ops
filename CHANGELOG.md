# Changelog

Newest first. Each entry leads with what you can now do, not with which files moved. This is
also the migration map `/multica-ops:upgrade` reads.

## 0.3.0 — 2026-08-01

**Carried across from the sibling project `opsinist`, where each of these was measured — against
its corpus, not this one's.** Same mechanics, different substrate: the workspace lives in Multica,
the company's record lives in git. **Almost nothing here has been measured against this corpus**,
and `evals/runs/0.3.0.md` says which is which rather than implying: **scenario 23 failed and then
passed after one change (N=1 each side); scenario 24 was run three times and only half of it was
ever presented** — the board lacked the closed and in-flight issues the scenario requires, so
three of its five expectations measured nothing. The other twenty-two have no round in this
release.

**Reviewed by the four lenses before tagging, by someone who did not write it — sixteen findings,
four blocking, all fixed.** The blocking ones are worth naming because each would have misfired
in a live workspace: the new *documents arrive when they have content* rule **contradicted
`company-preflight.sh`**, which fails a commit when a stand-up document is missing, so an obedient
workspace could not have committed; the rule's **mechanism did not travel** (a hook holds it next
door, nothing holds it here — it is `prose-only` now, and says so); the migration **outcome was
written before it could be known**; and *"swept at the next audit"* **named a sweeper that does
not sweep**. A carried number had also been flattened toward its worse value, and is restored to
what was measured.

---

**`/multica-ops:report` — you do not have to know whose defect it is.** The moment someone wants
to report a problem is the moment they least want to compose a request, and the capability is one
they have no reason to know exists. **A door is how a capability is found.** Three destinations,
decided from the evidence: a defect in **your product** goes to the urgent lane; friction in
**your workspace** becomes a line in `docs/FIELD-NOTES.md`, swept at the next audit, earning an
issue on the **second** occurrence with both named; friction in **this skill or in Multica** is
packaged from evidence, de-identified, and **written to a file outside your repository** — the
defect is not in your product, so it does not belong in your history — with its path said out
loud and the routes named. **You post it, never us.** Multica has no feedback mechanism of its
own (checked in its docs the same day), which is what makes this worth a door here.

**And the file is written before anything is missing.** Scenario 23 caught the first version
refusing to invent a task record it did not have — correctly — and then **stopping to ask for it,
leaving the report as chat text**, which is the single outcome this flow exists to prevent.
Anything unknown is now marked `unknown` in the file, and the offer to fill it comes after. **A
missing field is not a reason to withhold the artefact.**

**A migration you never ran is noticed on any message, not only on a command.** `UPGRADES.md`
having no line for the running version now reaches the session as a fact, before the first
message, from a hook that **only ever reports what the log says** — it makes no claim you could
forge, and it is silent when the log is current. The law that a project is checked before it is
acted on lives in the always-loaded core rather than in a companion, for a reason measured here:
scenario 24 asked *"what's next?"* against exactly that state and the run **read no companion at
all**, so the rules it needed were in a file nothing had opened. **A rule in a file nothing routes
to is a rule nothing executes.** After the change the same question produced the whole flow —
delta, log line, guide bumped, additions needing nothing named as such. **Once**, on a mid tier;
`evals/runs/0.3.0.md` carries what argues against reading it as more.

**A migration that creates every document the release names makes the workspace worse.** Two
places said *"create every docs file the new version expects"*; they now say **name** them and
**create only the ones with something to hold**, listing the rest as **available, not missing**.
Measured in the sibling project on the tier owners actually use: standing a workspace up produced
**ten to thirteen files before any work existed**, and the first unit of work arrived in the
third turn.

**The delta is one list, split by *does this need you?*** Mechanical items are applied on approval
and reported; items needing an answer are asked **in one batch**; items needing nothing are named
so the silence is visible. **A mixed list makes the owner read every line to find the two that
concern them.**

**"You do not have X" is three facts, and only two are findings.** Newly added · never used and
now load-bearing · **already declined**. The middle is an **adoption**, not a migration — offered
with its price and **declinable for good**, recorded against a moment rather than re-raised next
release.

**Issues are not one pile.** **Closed issues are never rewritten** — a closed issue records what
happened under the shape then in force. **An issue with a task in flight is not touched and not
even offered**, because the offer would interrupt a running agent. Started-but-idle is the
owner's choice; open-and-unstarted converts with the batch. **The counts go in the list
separately.**

**`UPGRADES.md` becomes a migration log, not only a restore point.** Every line now carries an
outcome — `applied` · `nothing-required` · `declined` · `deferred` · `failed`. **Swapping the
skill files is not migrating the company**, and until now nothing could tell the two apart: a
workspace whose migration never ran looked identical to one that migrated cleanly. **A check that
finds nothing still writes its line**, or *checked and clean* and *never checked* leave the same
trace.

**The one tier no setting can raise is Mops's own, because Mops *is* the session.** Dispatched
work is tiered by its agent's configuration — and it is tempting to treat tier as the runtime's
problem precisely because everything else here is. Anything Mops performs in its own turn says so
**before** starting and offers the moment to switch, **named as a tier, never as a product**. An
offer, not a gate. Measured next door: three migration scenarios one tier up moved `0/5 → 3/5`
and `0/5 → 4/5` **with no change to the text they read**.

**And the anchor is load-bearing at both ends of the model range.** A light model may not open
the skill because it does not connect the request to it; **a strong one may not open it because
it does not need to** — three runs of a build request on a high tier invoked nothing and read
nothing, writing and compiling the app instead. **Capability suppresses recourse to a
methodology.**

**Prioritisation names its alternatives and their questions.** ICE stays the default; **RICE**
(reach known and sourced), **WSJF** (what to do next under a constraint where delay costs
differently), **Kano** (whether to build at all), **MoSCoW** (a scope being negotiated) and
**Eisenhower** (a person's day, not a roadmap) each carry the question they answer. **The
framework is chosen before the scores** — running two and keeping the flattering answer is a way
of arriving where you were already going.

---

## 0.2.1 — 2026-08-01

**A correction release. Two things 0.2.0 published were wrong, and both were wrong in the same
way — a cause asserted without looking at the evidence that was available.**

**Why nothing embeds, correctly this time.** 0.2.0 blamed the blank Figma frame on the provider's
`X-Frame-Options`. The console says otherwise: `200 (OK)` beside `net::ERR_FAILED`, and
*"Access to script at 'https://www.figma.com/webpack-artifacts/…' from origin `null` has been
blocked by CORS policy"*. The documents were served and the browser then refused their own
bundles, because the attachment sandbox has no `allow-same-origin` and therefore presents origin
`null`. **It is Multica's sandbox, not the provider's framing policy** — so no choice of embed URL
fixes it, and links stay links.

**HTML is a half-open door.** An attached `.html` is `srcdoc` inside
`<iframe sandbox="allow-scripts">`: a **self-contained** page works — its own markup and CSS,
inline SVG, a plain `<img>` from any host, self-contained JavaScript — while a third-party embed
starves on the same `origin: null`. The other edge is unchanged and now stated plainly in
SECURITY.md: **an HTML file you did not write runs its author's JavaScript when someone opens the
issue.**

**Agents can read reactions and cannot leave one.** No verb anywhere in the CLI writes one — every
subcommand's help was swept — but a comment's `reactions` array populates with `emoji`, `actor_id`,
`actor_type` and `created_at`. **Issues carry no reactions field at all**, so *"wait for a 👍 on the
issue"* is unimplementable while the same rule on a comment is fine.

**Choosing a visual tool is choosing whether an agent can ever show its work.** Because links do not
embed and only images, PDF, HTML and text render, *agent-drivable* now has a stricter reading for
anything visual: **is there an official export to an image, and what does it require?** Four tiers
with measurements — a headless API (Figma's `GET /v1/images/:key`, no desktop app, 32 MP, assets
expiring after 30 days), an **editor bridge** that needs a person with the app open (Pen.dev's MCP
refuses with `failed to connect to running Pencil app`), **another runtime** (the OpenPencil CLI is
Bun-only; `npx` dies with `Bun is not defined`), and **no official export at all** (Rive), where the
picture is a human deliverable. Mermaid needs none of it, since a fence renders in the comment.

**Also:** the `.pen` format is not "plain JSON you can read" — the vendor states those files are
encrypted and are to be read only through its tools; the one examined happened to be readable, which
is a property of that file.

## 0.2.0 — 2026-08-01

**Everything below was measured against the live platform, and the entries that matter most are
the ones that corrected something this skill already said.**

---

**The install line on the front page had stopped working.** `multica skill import --url
github.com/jamillazarev/multica-ops` answers *"The Multica service is temporarily unavailable"* —
this CLI mislabelling a 502 — because the URL must point at the folder holding `SKILL.md`.
Corrected everywhere to `…/tree/v0.2.0/skills/mops`, and **pinned to the tag rather than `main`**:
an imported skill becomes agent instructions, so a moving ref means the content behind your agents
can change without you moving. Preflight now fails if that line drifts from the released version.
Two sentences explaining it were false in the same way — `skills/mops/SKILL.md` does not sit at
the repository root and never has; the real mechanism is the plugin manifest at the root beside a
corpus in `skills/mops/`.

**An audit is dispatched, not performed in the turn.** An autopilot in `create_issue` mode,
triggered manually, returns in about a second with the issue it created while the agent works on —
measured end to end: trigger at 00:21:59, finding written at 00:23:30, console free throughout.
**The second half of that instruction is `--subscriber`**, and it is the half that gets dropped:
the autopilot's issue is authored by the agent, your own actions don't notify you, and subscribers
are **members only** — the resident Mops cannot be subscribed to its own audit. Four flag facts
came with it, including `--priority`, which is accepted at create and update, appears in `--help`,
and is stored nowhere.

**The resume after a limit can be scheduled instead of waited for.** A limit hit at 02:10 that
resets at 07:00 costs five hours of a stopped team and needs only a person at the console. Cron is
exactly five fields, a pinned date is annual rather than one-shot, and the resumer has exactly one
shot because an autopilot task never auto-retries — so it is scheduled *after* the reset and its
trigger is deleted once it fires. **`next_run_at` promises nothing**: a disabled trigger and a
paused autopilot both keep reporting one.

**Waiting work stopped looking alive.** `blocked` is a status someone set, with a reason — and it
was being listed beside `in_progress` with no age anywhere, while the `/status` door promised
"ages and what the wait costs". `status.sh` now has a *Waiting on a human* section, oldest first,
and the age is named for what it measures: `updated_at`, i.e. last touched, because the platform
stores no status-change timestamp.

**A hire has no project to sit quietly in.** `agent create` has no project flag, nor does `agent
update` or `squad create` — so every role in a proposal names the work that needs it now, and
anything justified by "we'll need it" is listed in `LATER.md` instead. And a hire is not finished
when the agent exists: `mcp_config` and `custom_env` are per-agent with no workspace level, so an
agent hired into a team that already uses a tool arrives with none of it and stalls on its first
task looking capable.

**Five of the six sorts are readings; only `position` was written by anyone.** Priority is opt-in,
dates beat priority, and inflation is counted rather than forbidden. Measured: a new issue lands at
the *top* of its column, the authored order is per column (`reorder --before` across columns is
refused), and the position number survives a status change, so a move silently re-ranks against
different neighbours.

**`SECURITY.md`, written for whoever audits this.** What it reaches, what is actually gated with
an honest `enforced_by`, what is `prose-only` by name, where credentials live and how they sit at
rest, and a plain note on the 2026-07-30 scans: two of those alerts name files that have never
existed in this repository at any commit.

**`INSTALL.md`, and a site that cannot drift again.** The docs site carried two hand-written pages
with no source in the repo; they were two days behind it, which is how a front page came to publish
a broken command. Both are generated now, and the generator refuses any page without a source.

**What the platform shows, and what it only stores.** Measured across 39 attachments on one
issue, because the documentation says only *"Comments support formatting, code blocks, links,
and attachments"*. **A diagram is shown by writing it, not by attaching it.** A ` ```mermaid ` fence **in the comment
body renders as a drawn diagram**, and clicking it opens a viewer with zoom, a source/render
toggle, copy and download. The same Mermaid **attached as a file never renders** — `.mmd`,
`.mermaid`, `.txt` and `.md` all arrive `text/plain` and open a modal showing the source as text,
and a fence *inside* an attached `.md` is not rendered either. SVG previews inline, so a vector
diagram is a legitimate second route. `text/html` is rendered as **live HTML** in the comment,
which is in SECURITY.md because it changes what attaching a file from outside means. And a real
`.pen` is **JSON text**: readable in the preview as its own source, never a rendered design, so
the picture is an exported PNG or SVG with the `.pen` beside it.

Extension and sniffed type can disagree, and the inline renderer trusts the extension: Mermaid
text saved as `.png` renders as a **broken image**, while a real PNG saved as `.pen` renders as
the picture. A wrong name breaks visibly rather than quietly.

**Also:** the release title format is in the ritual now (0.2.0 shipped as a bare `0.2.0` above a
named 0.1.0 and was renamed the same day) · `SECURITY.md` gained the Contents its length requires.

**Also:** the urgent lane skips the queue and not the gates · a sync may not overwrite columns the
platform has no field for (craft, grade, *Owns* exist nowhere in a workspace) · "import" separated
into a move, a conversion, and "make ours better", which is not an import · a quick job reads the
project's own record before it asks · a synthetic round says what it cannot give *before* it
spends · derived surfaces regenerate from the tagged ref · eval scenario 22, and an honest run
record that names the debt it did not pay.

## 0.1.0 — 2026-07-31

**First release.** One version, one entry, and it says what it means: complete enough to run a
company on, young enough to change. Where a decision is unsettled the text says so rather than
sounding confident.

---

**Meet a front door, not a questionnaire.** A bare `/multica-ops:mops`, a "hi" or a description of a
situation routes itself: day zero checks (installed · signed in · workspace · daemon ·
runtimes) reported as one ladder, then three routing questions — build (`/multica-ops:init`),
continue (`/multica-ops:join`), bring a backlog (`/multica-ops:import`), or just ask (`/multica-ops:consult`,
which creates nothing). Two questions are never skipped — control level and governance —
and everything else has a default meant to be left alone. **Small stays small:** a quick job
gets three questions, one or two agents, build → review, and deliberately none of the
machinery; a crew is a standing team with no conductor, for owners who are the PM.

**Eighteen doors, and everything else is a sentence.** A verb earns a command when it is its
own flow, reached by name, repeatedly — never a synonym, never a phase inside another flow.
The other thirty flows are reached through `/multica-ops:mops <anything>` or plain language,
unchanged in what they do. **Commands are namespaced** (`/multica-ops:status`), always, because
that is how plugin commands work and the prefix is what stops two plugins colliding over one
verb; there is no bare `/mops`, and an earlier short alias installed by a session hook is
retired — delete `~/.claude/commands/mops.md` if you still carry it. The reason is a number:
**a door costs 30–110 tokens in every session of every agent, whether or not anyone uses it**,
and the palette as shipped costs **~820 always-on** rather than the ~3,288 it would with a
door per verb and paragraph-long descriptions (measured 2026-07-31 with `claude plugin details`).

**Run the conveyor on Multica's own primitives.** Workspace = company; the conductor (an
agent as project lead) grills intake into a spec, decomposes into staged sub-issues, and
accepts at the end; squad leaders route work addressed to their squad; `--stage` barriers
sequence; `@`-mention hands off. Native-first throughout: permission modes, properties,
resolvable comments, subscribers, labels — used, not re-invented.

**Say what you know, and how.** Every claim carries its rung — **measured › cited › recalled
› judgement call**, or `unknown` — and **the rung travels with the claim**: an agent may not
promote someone else's guess by quoting it. Prices and caps are fetched at the moment of use,
recorded with price · currency · date · source; a fact past its check-date is unknown, not
fine. Slow-rotting canon traces to `sources/SOURCES.md` with archive links.

**Know what every rule is actually held by.** Gates carry an honest **`enforced_by`** — a
request, a validator, branch protection, the Multica platform, or **`prose-only`, which
means nothing enforces it** — and the prose-only rules are listed by name (PLAYBOOKS →
Gates). Loosening exists only as a **grant** (right · grantee · scope · duration) that
expires by its own terms. Four kinds of action route to the owner whoever asks — spend,
outward, destructive, shape-of-company — and **no history buys them**: trust is earned per
role from its own run record, moves both ways, and a role never loosens its own gate.

**See what work cost, and what it wasted.** A per-release ledger (tokens · $ · time · per
agent and per human) from `issue usage`, with the **waste sliced from the same records**:
runs that produced nothing, reruns beyond the first, expensive tiers that bought nothing.
Runs that drive paid services record their spend outside the model (service · unit ·
quantity · amount · currency) as issue comments, gated by a threshold and a cap declared
once per service. Attribution names the model that **answered**, not the one that was asked
for. The budget shapes advice rather than only capping it; credits are runway with expiry
cliffs, never income.

**Everything that needs a decision is a request with an age.** `/multica-ops:status` opens with a
countable line ("3 need you · 2 running · 4 closed since Tuesday") and splits what differs
in kind: **needs you** (open requests with age and the cost of the wait — stays until
answered) from **happened** (events that age out), with workspace drift answered separately
by the fingerprint. Incoming feedback triages into four dispositions — accept · decline with
a reason · duplicate · snooze — and declining is a normal, cheap outcome.

**Lose a run without losing the work.** Session limits are recognised (`agent_error` + reset
time), recovery is `issue rerun`, **a rerun resumes rather than restarts** — incremental
commits and progress comments are team law, so state lives in artifacts, not in a dead
session's context.

**Ask the audience without lying to yourself.** The persona theatre: personas staged proto →
validated (interview transcript → QDA distillation as the grounding artifact), bias profiles
of 2–4 named biases each with a source, twins of real people with consent machinery, mixed
live + synthetic rounds where **a hypothesis never pools with a fact**, and verdicts that
state **direction, never magnitude**.

**Work beyond software.** `/multica-ops:ship` is the go-live moment whatever you make — an app
build, an episode, a production batch, a newsletter issue; launch checklists are researched
per medium rather than recalled; dated work respects its start date, which gates the whole
issue, preparation included.

**Keep the machinery honest about itself.** A shared vocabulary (`GLOSSARY.md` — one word,
one meaning, and the confusable pairs) and the recurring forms (`PATTERNS.md` — a rule that
instantiates a pattern cites it and stops). The corpus guards itself: preflight checks
version sync, links, budgets, command coherence and **facts past their recheck window**;
`verify.py` runs the documented CLI surface against the world; the four lenses (deletion ·
adversarial · contradiction · cold-read) read every release, by someone who is not the
author. The company's own docs get the same guard (`templates/company-preflight.sh`):
DECISIONS and FIELD-NOTES append-only, TOOLING check-dates, credential shapes stopped at the
door.

### Known limits

- **Platform caps are stated, not wished away**: 6 tasks per agent, 20 per daemon (tighter
  wins); a `local_directory` resource serialises regardless; `workspace delete` is not in
  the CLI. Verified against `multica` CLI v0.4.12.
- **Autopilot failures are silent** — no auto-retry, no inbox post; run them in
  `create_issue` mode and subscribe the owner.
- **Start dates are enforced by the team, not the platform.**
- **Some enforcement is prose**, and that list is written out by name (PLAYBOOKS → Gates) —
  including the one that cannot be enforced even in principle: that a price was fetched
  rather than recalled.
- **The eval suite is a rubric with recorded runs, not a runner** — scenarios are stratified
  from trivial to adversarial, runs land in `evals/runs/<version>.md` with `not run` listed
  rather than omitted, and the pass-rate is a regression detector, never a success metric.
