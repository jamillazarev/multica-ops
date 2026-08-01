# Glossary — one word, one meaning

Every term this skill uses in a fixed sense, and — the expensive half — the pairs that look
alike and are not. A word that appears here means **exactly this** everywhere in the corpus;
a word that does not appear is ordinary English. A term enters when a **second file** needs
it; a term used in one file is that file's business.

## Confusable pairs — the test tells them apart

| These look alike | …and are not | The test |
|---|---|---|
| **update** · **upgrade** | update = **new bytes arrive**; upgrade = **the workspace moves onto them** | did anything change *here*? |
| **assign** · **@-mention** | assignment is **accountability, and it enqueues a run**; a mention of an agent/squad **also enqueues a run**, of a member or an issue it is **free** | who is accountable — and does anyone wake? |
| **rerun** · **retry** | a CLI `issue rerun` **starts fresh and resets the attempt counter**; a per-row retry in the app **resumes the session and reuses the working directory** | fresh after corrupt state, resume when it's cheaper |
| **threshold** · **cap** | a threshold **asks before an action** above it; a cap **stops when a total is reached** | before each, or at the sum? |
| **grade** · **model tier** | grade is a **routing fact in `TEAM.md`** — who gets the work; the tier is **what the agent runs on**. Grade never enters instructions as an identity | is it about routing, or about compute? |
| **Access** (Multica) · **`/multica-ops:mops access`** | Multica's: **who may run this agent** (`--permission-mode`); ours: **what a member may direct Mops to do** | whose setting is it — the platform's or the methodology's? |
| **conductor** · **Mops** | the conductor **plans and accepts work** (project lead, in the conveyor); Mops **advises and builds the machinery** (never assigned a task) | does it hold work? |
| **crew** · **quick job** | crew = **a standing team without a conductor** — the owner is the PM; a quick job = **1–2 agents, build → review, none of the machinery, then done** | does anything stand after the work ships? |
| **consult** · **research** | consult is **ephemeral advice, zero standing footprint**; `/multica-ops:mops research` **persists cited findings** to `docs/research/` | does anything land in the repo? |
| **module** · **skill** | a module is an **optional capability of the company** (design system, brand, theatre); a skill is **text an agent loads** | toggled for the company, or attached to an agent? |
| **workspace** · **project** | the workspace is **the company** (agents, skills, limits are shared here); a project is **a direction inside it** (app, site, marketing) | do agents cross it? |
| **stage** · **nesting** | `--stage N` is **a number on a sub-issue** — a barrier ordering siblings; nesting is **issue → sub-issue, exactly two levels** | a barrier, or a level? |
| **expert** · **persona** | an expert is **consulted and cites sources** (or *is* the source, when live); a persona **reacts as the audience** — direction-only, 🎭-marked, never a hire | does it advise, or simulate? |
| **blocked** (board) · **stuck** (run) | `blocked` is **a status someone set, with a reason**; stuck is **a failed run** (`agent_error`, limits) that rolled the issue back | a decision, or a failure? |
| **architecture map** · **product map** | `docs/ARCHITECTURE.md` is **where the implementation lives** — a worker's map of the tree; `docs/MAP.md` is **how the product is walked** — the moves and the things, in the product's own words (`/multica-ops:mops map`) | does it name files, or moves? |
| **verified/recalled/unknown** · **measured/cited/recalled/judgement** | **one scale, not two — the three-way labelling is retired.** Claims carry measured › cited › recalled › judgement call, plus `unknown` | — |
| **migration** · **adoption** | a migration moves what a workspace **already has** onto a newer shape; an adoption is taking up something it **never used**, which a release can make load-bearing. The first is applied on approval; the second is **offered with its price and may be declined for good** | is there something to convert, or something to start? |
| **update** · **upgrade** *(bytes vs workspace)* | new bytes arriving on the machine is not the workspace moving onto them — **swapping the skill files is not migrating the company**, and the two are indistinguishable until `UPGRADES.md` says which happened | did anything in the workspace change? |

## Terms with one home

- **the four owner-gated kinds** — spend · outward · destructive · **shape-of-company**;
  route to the owner whoever asks, and no history softens them → SKILL (permissions).
- **evidence rung** — measured › cited › recalled › judgement call, + `unknown`; the rung
  travels with the claim → SKILL (say what you know).
- **request** — anything that needs a person's answer: an approval, a question, an
  escalation, a decision. Carries an **age** and, where knowable, **what the wait costs**;
  a report is where findings go to die → SKILL · PLAYBOOKS (status shape).
- **grant** — `right · grantee · scope · duration`: the only way a gate loosens; visible
  while it lives, expiry evaluated at the gate check → PLAYBOOKS (Gates).
- **`enforced_by`** — `request` · `validator` · `git-host` · `platform` · `prose-only`;
  every gate declares its value honestly → PLAYBOOKS (Gates).
- **waste slices** — outcome · attempt · tier · theatre/system: what was spent on work that
  produced nothing, derived from the same ledger as the spend → PLAYBOOKS (ledger).
- **fingerprint** — the per-class hash of workspace state in `docs/.workspace-state.json`;
  what answers "what changed that we didn't change" → PLAYBOOKS (drift).
- **conveyor** — the pull-based flow: conductor seeds, leaders route, stage barriers
  sequence, @-mention hands off → SKILL.
- **theatre** — the personas module at full size: staged personas, bias profiles, mixed
  live+synthetic rounds, direction-only verdicts → MODULES.
