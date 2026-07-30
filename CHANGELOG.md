# Changelog

Newest first. Each entry leads with what you can now do, not with which files moved. This is
also the migration map `/multica-ops:upgrade` reads.

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
