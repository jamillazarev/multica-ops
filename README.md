<p align="center">
  <img src="assets/mops-docs.png" alt="Mops — your Executive Advisor" width="240">
</p>

<h1 align="center">multica-ops</h1>

<p align="center">
  Meet <b>Mops</b> 🐶 — your Executive Advisor for <a href="https://multica.ai">Multica</a>.<br>
  Say what you need; it shapes the work <b>before</b> staffing it, runs the company, and stays your console.<br>
  Built on the platform's own primitives, not beside them — gates that name what enforces them, evidence on every claim.
</p>

<p align="center">
  <a href="https://ai.jamillazarev.com/skills/multica-ops/overview"><img alt="docs" src="https://img.shields.io/badge/docs-ai.jamillazarev.com-black"></a>
  <a href="https://github.com/jamillazarev/multica-ops/releases/latest"><img alt="release" src="https://img.shields.io/github/v/release/jamillazarev/multica-ops?label=release&amp;color=black"></a>
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/github/license/jamillazarev/multica-ops?label=license&amp;color=black"></a>
  <a href="https://github.com/jamillazarev/multica-ops/actions/workflows/preflight.yml?query=branch%3Amain"><img alt="preflight" src="https://github.com/jamillazarev/multica-ops/actions/workflows/preflight.yml/badge.svg?branch=main"></a>
  <a href="https://ai.jamillazarev.com/skills/multica-ops/coverage"><img alt="coverage map" src="https://img.shields.io/badge/coverage-map-black"></a>
</p>

---

Most "agent team" tooling is a prompt and a hope. This is **an operations department in
markdown, sitting on a real platform** — Multica owns the issues, agents, squads, stage barriers
and runs; this skill owns the method that uses them. Sixteen trigger-loaded files you can read,
diff and delete, **including the parts it admits nothing enforces**.

---

## One minute in

```sh
claude plugin marketplace add jamillazarev/multica-ops
claude plugin install multica-ops@multica-ops
```

Then say what you need — no command required, any language. Mops runs day zero itself
(installed · signed in · a workspace · daemon up · runtimes), reports the whole ladder at once
with the fixes, and takes the right entrance:

| What you have | Where it goes |
|---|---|
| nothing yet | the work is shaped first, then staffed — `/multica-ops:init` |
| a Multica workspace already | an audit, then fixes in batches you approve — `/multica-ops:join` |
| a backlog in Linear or Jira | a mapping shown before anything is written — `/multica-ops:import` |
| a list of tasks and no tracker | executors and gates, no PM layer — `/multica-ops:mops crew` |
| one job, no team | three questions and none of the machinery — `/multica-ops:quick` |
| a question | an answer, and nothing is created — `/multica-ops:consult` |

**Two questions are never skipped** — how much you want to be in the loop, and what you are
actually expert in. Everything else has a default good enough to leave alone, and **"defaults"**
takes all of them at once.

Every other install route — skills.sh for any harness, Gemini CLI, Codex, Antigravity, and
importing the skill into a Multica workspace — is in **[INSTALL.md](INSTALL.md)**, each measured
end to end rather than assumed.

---

## Different, by design

- **Native-first, not a parallel universe.** Squads, stage barriers, @mention handoffs,
  permissions and branch protection are Multica's real primitives; where the platform already
  does a thing, the skill uses it instead of growing a copy that drifts.
- **The work is shaped before it is staffed** — a team proposed for work nobody scoped is how
  you get twelve agents and no product.
- **Gates say what actually holds them** — a request a human answers, a validator that refuses,
  branch protection, the platform itself, **or `prose-only`, which means nothing does** — and
  the prose-only rules are listed by name. A gate believed in but not enforced is worse than a
  stated rule.
- **Every claim carries how it is known** — measured · cited · recalled · a judgement call, or
  `unknown` — and the rung travels with the claim, so nobody promotes another's guess into a
  fact by quoting it.
- **Every decision runs one loop** — frame it, **search rather than recall**, compare, choose
  and say why, then check it survives being wrong. Prioritisation, tool choice, the role-builder
  and process discovery are all that same loop.
- **It finds the right *process*, not just the right tool.** Asked to design an app it
  researches how the craft works — architecture, flows, low-fi, **your approval of the
  structure**, then screens composed from a real component library — and the design gate
  *rejects* instead of rubber-stamping. Mops never signs off design; you do.
- **"Remember this" lands in a file, never in the chat's memory** — a guide line, a decision, a
  register — and the home is named back to you.
- **A persona is not a hire.** Synthetic rounds give **direction, never magnitude**, said before
  anything is spent; 🎭 entities are excluded from headcount and billed to their own line.
- **Cost is sliced so waste is a number, not a feeling** — per agent, per feature, and *spent on
  work that produced nothing*, all from `issue usage` and `runtime usage` at list prices.
- **A run that dies resumes** — what was committed, applied and remains is read back from the
  record, and **applied work is never redone**.
- **Autonomy is earned and can go down**, and no history buys the four gated kinds — spending,
  outward acts, destruction, reshaping the team.
- **It knows when the tree is not its own.** `_ops/` is a door shared with the sibling project
  `opsinist`, deliberately — a successor finds the predecessor's record where it would have put
  its own. So ownership is read from a marker before anything is written, and a tree operated by
  another system is **named and handed back, untouched**.
- **It works outside software** — *ship* is an episode published, a batch sent, a letter mailed;
  a bakery has no deploys.
- **It maintains itself through its own machinery** — proposed, never self-merged, with
  validators in CI refusing what prose cannot.

The full inventory lives in **[the docs](https://ai.jamillazarev.com/skills/multica-ops/overview)**:
start at [the skill](https://ai.jamillazarev.com/skills/multica-ops/the-skill), then
[use cases](https://ai.jamillazarev.com/skills/multica-ops/use-cases) and
[commands](https://ai.jamillazarev.com/skills/multica-ops/commands).

---

## Honest about the ceiling

Stated rather than wished away — every number carries where it came from:

| Limit | What it means | How it is known |
|---|---|---|
| **6 tasks per agent · 20 per daemon** | the tighter one wins; fan-out past it just queues | measured |
| **a `local_directory` serialises** | one task at a time, forever, however wide you decompose | cited (REFERENCE §object model) |
| **`workspace delete` is not in the CLI** | Mops cannot remove a workspace it created, and says so | measured, CLI v0.4.26 (2026-08-15) |
| **autopilot failures are silent** | no auto-retry, no inbox post — run them in `create_issue` mode and subscribe the owner | measured |
| **start dates are enforced by the team** | nothing on the platform stops an agent beginning early | cited |
| **some rules are `prose-only`** | nothing enforces them; they are listed by name rather than believed in | measured |

**27 stratified eval scenarios** — from a job too small to deserve a company to an import
carrying a hidden instruction — judge the **end state, not the route**, with a player that never
saw the rubric and a judge that did not write the transcript. Each release records its run in
`evals/runs/<version>.md` with `not run` listed rather than omitted, and **a minor or major is
not tagged without one**. The pass-rate is deliberately **not** treated as success: it detects
regression, it is not evidence the behaviour was ever good.

---

## How you would know it is working

**Success here shows up as an absence.** Nothing decided twice. Nothing rebuilt that was already
built. No bill nobody saw coming. Nobody asking *"who chose this, and why?"* and getting silence.
The tests worth being judged on:

- **Can a stranger continue?** Hand over the repo and the workspace, give them a task. If they
  can start without asking what was meant, the record is real.
- **Did the dead run resume** without redoing work that was already applied?
- **Is the waste share falling?**
- **How often do you go behind it** — re-reading the diff because you don't believe "done"?
  Each time is a failure even with every gate green, because **a console you audit is not a
  console.**

---

## Two seats, one advisor

Mops is one advisor with one name, in two places. **In the CLI** — full machine reach (shell,
git, the `multica` CLI, deploy), instant chat, its own quota. **In Multica** — an optional
resident agent carrying this same skill, present while you are away: async, sharing the team's
session limit, best for status and `@Mops` advice on an issue. They share no live chat memory,
so **the bridge is written state**. The test that keeps it honest: the project must rebuild from
repo + workspace alone.

## Works beyond Claude Code

Plain **SKILL.md + markdown** — the Agent Skills convention. [skills.sh](https://skills.sh)
installs it into Claude Code, Cursor, Codex, Windsurf, Gemini CLI, Copilot and the rest;
**[AGENTS.md](AGENTS.md)** routes any agent that lands in the repo, **[GEMINI.md](GEMINI.md)**
does the same for Gemini CLI, and **[CLAUDE.md](CLAUDE.md)** carries the session loop for anyone
*developing* the skill rather than using it. Slash commands are a Claude Code plugin bonus
(namespaced `/multica-ops:…`); everywhere else plain language reaches the same flows.

> **Layout note:** the corpus is at **`skills/mops/SKILL.md`**, one folder per verb beside it —
> the plugin layout where **the folder name becomes the command** (`skills/init/` →
> `/multica-ops:init`). A single `SKILL.md` at the repository root is the *one-skill* form and
> silently suppresses every other command, which is the defect this layout fixes (measured
> 2026-07-31).

## Why a skill, not another CLI agent

The value is the **operating doctrine** — the decision loop, the gates, verify-first — not the
agent loop underneath it, and that loop is commoditising: as a skill, Mops inherits every harness
improvement for free and bills through the harness you **already pay for**. The two-seats design
needs Mops to be a guest *inside* Multica, which hosts instructions and skills, not third-party
binaries. And a skill is **auditable text** with no dependency tree of its own — the trust it
does ask for is named in **[SECURITY.md](SECURITY.md)**.

---

## What's inside

| File | Purpose |
|---|---|
| [SKILL.md](skills/mops/SKILL.md) | **the always-loaded core** — interview → stand up → conveyor → console |
| [INSTALL.md](INSTALL.md) | every install route, day zero, first run, updating |
| [SECURITY.md](SECURITY.md) | what this reaches, what is gated, what is `prose-only` |
| [COMMANDS.md](COMMANDS.md) | every command, its aliases, and the surface it runs best on |
| [USE-CASES.md](USE-CASES.md) | situation → what to say → which command |
| [EXAMPLES.md](EXAMPLES.md) | the same issue, handoff, review or ledger done weakly and done well |
| [GLOSSARY.md](GLOSSARY.md) | one word, one meaning — and the pairs that look alike and are not |
| [PATTERNS.md](PATTERNS.md) | the recurring forms, named once |
| [FLOWS.md](FLOWS.md) | the full procedures — init, join, health, upgrade, switch |
| [BOOTSTRAP.md](BOOTSTRAP.md) | zero-to-team CLI recipes, capacity levers, real-hours traps |
| [ROLES.md](ROLES.md) | role catalog with curated skill packs + the generic role-builder |
| [PLAYBOOKS.md](PLAYBOOKS.md) | daily operations, copy-paste ready |
| [STACKS.md](STACKS.md) | services, libraries, testing, security, evidence and reference shelves |
| [MODULES.md](MODULES.md) | opt-in: design work · design system · brand · persona theatre · tracker bridge · HQ |
| [REFERENCE.md](REFERENCE.md) | object model, anti-patterns, **CLI surface (§10)**, **frameworks (§11)** |
| [WORKFLOW.md](WORKFLOW.md) | Mermaid diagrams of the whole process |
| [CHANGELOG.md](CHANGELOG.md) | versioned history — the migration map `/multica-ops:upgrade` reads |
| [evals/](evals/) | the 27 scenarios, plus `runs/` — the recorded verdicts per release |
| [templates/](templates/) · [scripts/](scripts/) | guide · roadmap · brand · component docs · decisions · architecture · tooling · team · **a docs guard for the companies Mops builds** · ops helpers · resumable backlog import |

Everything but `skills/mops/SKILL.md` loads **only when its trigger fires**.

**Contributing?** Run **`bash scripts/preflight.sh --install`** once — the pre-commit hook holds
the invariants this repo has actually broken before, and **[AGENTS.md](AGENTS.md)** is the
contract. What no hook can check is whether a claim is still *true*; that is `verify.py`, run
against the world rather than the text:

```sh
python3 scripts/verify.py --live
```

`--live` executes reads only — never a create, update, assign or delete — so it is safe against
a real workspace.

## Roadmap

Forward-only: what shipped lives in the body of this file and in the
[CHANGELOG](CHANGELOG.md), never as a checked box here.

---

Works against **Multica cloud or a self-hosted server** — execution is local either way, so only
backups and upgrades change hands. Verified with `multica` CLI v0.4.12; the surface claims were
re-checked against v0.4.26 on 2026-08-15 (REFERENCE §10 carries the pin and the caveat). Code is
**[Apache-2.0](LICENSE)**; the names "Mops" / "multica-ops" and the avatar are reserved — see
**[TRADEMARKS.md](TRADEMARKS.md)**.
