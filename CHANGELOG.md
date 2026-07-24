# Changelog

## 2.3.2 — the command table now says how to type a command

- **How to read the commands table.** `/feature` in the docs is a *flow name*, not something
  you type literally — reach it as `/multica-ops:feature`, `/mops feature …`, or plain
  language. The table never said so, and a first user read `/feature` as a command that
  doesn't exist. The Commands page and the Getting Started routing now both spell out the
  three forms; there is no bare `/<name>`, and outside Claude Code there are no slash commands at all.
- **Docs-site information architecture.** Introduction now leads (the *why* and the mental
  model) and Getting Started follows (install and first run) — the two had drifted into
  overlapping how-tos. Introduction drops the duplicated install and upgrade steps and points
  to Getting Started for them.

## 2.3.1 — a real on-ramp, and tests that keep themselves honest

- **A Getting Started page** on the docs site — the friendly on-ramp a first-time user
  needs, walking install → sign-in → day-zero checks → "just say what you're making." The
  gap the first outside user-test surfaced ("downloaded Multica, now what") was covered as Mops *behaviour* but not as
  a page to read; now it is the top of the sidebar.
- **One canonical list for drift.** The workspace fingerprint is now the single source of
  truth for which structural objects exist; `/sync`, `/join` and `/upgrade` all reconcile
  against it rather than each carrying their own — add a class in one place and all three
  cover it. `verify.py` guards it, so one check protects every flow that reads it.
- **The evals caught up and stay caught up.** 2.3's flagship behaviours had no regression
  test — the design flow, `/process`, "you decide", the adaptive interview. Added, including
  the exact run that shipped garbage. preflight now **warns when the version bumped and the
  evals didn't**, and `AGENTS.md` carries a **release checklist**: refresh the evals, run the
  four review lenses, and keep the guards themselves current — they rot too.

## 2.3.0 — it finds the process, not just the tool

Built on a first outsider's run, which produced a beautiful discovery doc and then
**gradient-placeholder garbage for the design** — because it searched skills for "designer",
found nothing usable, and hand-drew HTML for 2–5 minutes a screen. Everything here traces back
to that.

### One decision loop, named once
Every real decision now runs the same shape — team and Mops alike: **frame** (what would make
one option better) → **search, don't recall** → **compare, each claim sourced** → **choose and
say why, then check it survives being wrong** → **record in `DECISIONS.md`** → **act.**
Process-discovery, the role-builder, the stack ladder and prioritisation are all instances of
it, so the method is followed, not reinvented per decision.

### Find the process before the tools (`/process`) — the flagship
"Method over encyclopedia" now applies to *how work is done*, not only which tool to pick.
Given a task whose process isn't obvious, Mops **researches how the craft actually works**,
drafts the steps each with a why, lets the owner cut/add, then finds a **skill or MCP per step
by function** — broadening on empty instead of giving up. A literal "designer" misses Mobbin's
flow library; "map the user journeys" finds it. The skill carries the *method*, so its own
checklists are examples, never the only process. Applies everywhere there's a "how", not just
design.

### Design stops producing garbage
- **Where design is drawn** is now a real stack row with the ladder: **Pen.dev** (repo-embedded,
  a full MCP, components + importable libraries) · **Penpot** (OSS) · Figma (cloud, MCP) · plain
  HTML (free, but no affordances — this is what produced the placeholders). **Compose from a
  component library, don't hand-write screens.**
- **Structure before pixels**: `/process` for a UI surfaces IA → flows → low-fi → **owner
  approves** → high-fi, discovered not hardcoded. Low-fi first because approving structure on
  cheap artifacts saves redrawing finished screens.
- **Design intake is asked, never guessed**: style, colour, references, anti-references.
- **The design gate rejects bad work; Mops never signs off design itself** — the owner does.

### The interview adapts, and stops running hands-off by accident
The bug: an agent ran a whole project hands-off because it never established the control level.
Now the interview is a **source of topics, not a script**; **control & expertise and governance
are hard gates** that propagate to every checkpoint (checkpoints ⇒ the owner signs the design
before high-fi); options offered are **a prompt, not a menu** — free answers win. **"You decide"**
is a first-class answer: Mops proposes a full reasoned config for the owner to confirm or edit,
without delegating the owner-gated floor. **Model preference is asked in plain outcomes**
(stronger / medium / light — quality *and* speed), mapped onto the runtime's real models, so a
squad isn't all one tier because nobody asked.

### Speed, pace, and a heartbeat
- **`/pace`** (careful · balanced · fast) dials parallelism on the fly — honestly capped at
  ~3–5 concurrent, and doing nothing on a `local_directory`, which serialises regardless.
- **Star lays the foundation, routine fans out below it** — a top agent on the hard 20%, a
  cheaper grade on the repetitive 80%, per feature.
- **Nothing runs silently**: before a long operation Mops states the duration and emits a
  progress line per completion — silence during a 20-minute run reads as a hang.

### Shapes and slices
- The front door now separates **three entrances** (init/join/import, by what you have) from the
  **shape** chosen inside (company / crew / quick job) — quick job has no command **on purpose**.
- **Owning a slice**: a frontender on one feature, a designer on one surface — crew narrowed to a
  part, laid over any route.
- **A site with features *and* content** is one project with two issue *types* (the stage ladder
  follows the type, not the project), two projects only when content is its own stream.

### Guards that never forget
`verify.py` now checks the **fingerprint hashes every structural object the CLI exposes** — a new
object type raises a warning instead of becoming a silent blind spot. The `/join` delta and
command reachability were already guarded. A tidy **mermaid theme** on the docs site; the
quick-job diagram redrawn; the examples page's last example given its missing takeaway.

## 2.2.1 — the update path a human can actually walk

A follow-up to 2.2.0, from the first question every user asked after it: *how do I get the
new version?*

- **Mops runs the update itself.** It has your shell, so with a yes it fetches the new bytes
  (`claude plugin marketplace update` + `plugin update`, or `npx skills add`) — the one
  manual step is **restarting Claude Code**, because a running skill can't replace its own
  plugin under itself. Then it migrates the workspace, re-screens imported skills, and
  offers the CLI update only when the team is idle. The README and docs site now open with
  a **First run** and an **Updating** section instead of leaving it to be discovered.
- **`/whatsnew`** — Mops onboards you into a release: it reads the changelog between your old
  and new version and explains, in your terms, what changed, why it helps, and what to do
  differently (usually nothing — it says so). Offered automatically after `/upgrade`.
- **`/help` reads the live command table** instead of carrying a frozen list, and a hook
  check keeps it that way — a help that lists commands from memory is a help that goes stale.
- **BACKLOG.md** captures the two ideas worth doing next: running the skill on itself inside
  Multica (with the five preconditions that make it safe), and re-checking whether persona
  simulation still earns its cost on current models.

## 2.2.0 — a front door, a team you can size, and gates that are real

Built on what first users actually hit, then hardened by four independent audit passes over
the result. Several of these were defects in things this skill told people to do.

Built on what first users actually hit. Three of these were bugs in things this skill told
people to do.

### ⚠ Fixes worth knowing about
- **`/mops` was never a real command.** Claude Code namespaces plugin commands, so it is
  `/multica-ops:mops` — and the docs advertised the form that produces *"Unknown command"*.
  A **short `/mops` now installs itself** on first run (one file in your own Claude config,
  removed with `rm ~/.claude/commands/mops.md`); it never overwrites an existing one and
  never comes back if you delete it. Outside Claude Code there are no slash commands at all,
  and the skill now says so instead of quoting one you don't have.
- **Nothing said who creates the repository.** Mops improvised and created one on a user's
  **work** GitHub. Where the code lives is now the **first** interview question, in three
  parts — does one exist, do you want one and *where*, do you want a remote at all — and
  creating a repo on the owner's account is owner-confirmed **naming the account it lands
  in**. A local git repo with no remote is a legitimate end state.
- **The `local_directory` explanation was wrong.** Serialisation is not a property of local
  git — `git worktree` parallelises it fine, and Multica does exactly that for `github_repo`.
  What `local_directory` does is run the agent in that exact path with no worktree. Say it
  that way: it is an implementation choice worth filing a feature request about, not a law.

### One front door — and a bare `/mops` is the door

Nobody should have to pick a command, and the most natural thing a lost user types is
`/mops` on its own. That used to produce *"what do you want?"* — the worst possible answer to
someone who asked precisely because they don't know. Now a bare `/mops`, a "hi" or a vague
"help" runs **day zero** (installed · current · signed in · workspace · daemon · runtimes,
reported as one ladder with its fixes, not six prompts) and then three questions — what
exists · what you want · who runs the work — that route to init, join, import, crew or a
quick job.
Nobody should have to pick a command. First contact is **day zero** — installed · current ·
signed in · a workspace · daemon up · runtimes present, reported as **one ladder with its
fixes** rather than six prompts — then three questions (what exists · what you want · who
runs the work) that route to init, join, import or a quick job.

### Shape the work before you staff it
A company is sized to a plan, not to a sentence. Hiring off *"a macOS app"* produces the team
that sentence suggests, which is a guess. Before anything is created: what it is, who for,
**what is hard about it** (uncertainty is staffing information), what the work is made of —
in *this* domain's words — rough size, and only then a proposed team **with its reasoning
attached**, which the owner can argue with. Re-runnable when scope moves; skipped entirely
for a quick job.

### Crew mode — a team without a management layer

Not everyone wants a company. A developer with a list of tasks **is** the product manager, and
the machinery for deciding *what* to do is overhead. `/crew` is executors and gates with no
conductor, no discovery, no roadmap ceremony — the **default offer after `/import`**, because
someone who just moved their backlog has already decided what the work is.

**And it names what the conductor used to hold.** Removing the planner does not remove four
duties that are not planning: accepting finished work and merging, approving an imported
skill, holding start dates, and settling a third review round. In crew mode all four sit with
the owner, said out loud at stand-up and written into the guide — because an unnamed duty is
an unperformed one.
### "How do I get the new version?" now has one answer
It used to have four, and no command that covered them. **`/upgrade` is the one command**, and
the vocabulary is fixed: *update* means **new bytes arrive** (a newer plugin, a newer CLI),
*upgrade* means **your workspace moves to them** (docs files, guide rules, agent instructions,
renamed commands). New bytes without a migration is how a company ends up running half of one
version and half of another.

It walks four layers: **this skill's copy on your machine** — where Mops prints the one line
*you* run, because a skill cannot replace its own plugin — then the **workspace migration**
from the *new* version's changelog, then **imported skills** each re-screened, then **the CLI**
locally and on every runtime (`runtime update` exists for exactly that and we were barely using
it). The fingerprint is recomputed **after** reconciling, not before, because an upgrade
changes the very objects it hashes.

**And the CLI update waits for idle.** The daemon executes tasks, `daemon stop` has no drain
flag, and replacing the binary under a running agent produces failures that look like the
agent's fault. So `active_task_count` must be 0 and nothing `in_progress`; otherwise Mops says
what is in flight and offers to wait. A diagram in WORKFLOW walks the whole thing.

### Drift detection stopped being partial
The fingerprint hashed five object classes; the platform has eight, plus project resources.
The most expensive omission was **project resources** — the `github_repo` ↔ `local_directory`
switch that decides whether the team can work in parallel at all, changed by hand in the app,
invisible to us. Now nine hashes, with the standing rule that a class nobody hashes is drift
nobody sees.

### Webhook autopilots are an inbound door
A cron autopilot runs on your schedule; a **webhook** autopilot hands anyone holding the URL
the ability to start agent runs — spending budget, consuming the shared window, acting under
the company's identity. It is all four owner-gated kinds at once, so: owner-confirmed to
create, the URL is a **credential** (never a doc or an issue comment), registered in
`docs/TOOLING.md`, and `trigger-rotate-url` exists because a leaked one is rotated, not
debated.

### The gates stopped being sentences
- **Branch protection is installed, not intended.** The skill's own principle is that a rule
  in prose instructs while only a gate constrains — and merge was fenced by a sentence.
  Stand-up now runs the `gh api` call, with three honest caveats: it stops force-push and
  deletion rather than a bad merge (our review gates are Multica sub-issues, not CI checks),
  `enforce_admins` matters most because the conductor holds git rights, and **with no remote
  there is no fence at all** — which is said plainly instead of implied.
- **The company docs guard could be tricked by its own advice.** It refused to overwrite a
  foreign pre-commit hook by looking for its own script name — and the chaining instruction it
  printed put that name into the file, so the next install passed the check and deleted a
  chained gitleaks. It now recognises only a sentinel it wrote itself, refuses in worktrees
  and under `core.hooksPath` instead of reporting a success it didn't achieve, and never
  creates a stray `.git/` outside a repository.
- **The alias installer** no longer writes through a dangling symlink, no longer leaves a
  truncated command behind after an interrupted session, and refuses to run without
  `CLAUDE_PLUGIN_ROOT` rather than copying whatever `./templates/` happens to be nearby.
- **The fourth owner-gated kind reaches the agents who need it.** "Changes the shape of the
  company" was defined in the core — which only Mops loads — while every agent's guide still
  listed three kinds. Squad routing, credentials, another agent's instructions and skill
  attachment were ungated for everyone actually doing the work.

### Two rules that keep it universal
- **Speak the domain's own language.** Software is the standing trap — best documented, so
  its vocabulary leaks everywhere — but a chip maker has no data flows and a bakery has no
  deploys. *If a sentence would sound absurd to someone outside software, the sentence is
  wrong, not the reader.*
- **A grade is a routing fact, never a character.** Never write *"you are a junior
  developer"*: a model told it is junior acts junior, and role-play of competence levels has
  stopped helping on current models. Grades decide routing and tier; instructions say what
  the agent owns and when to escalate.

### Interviews stopped being an interrogation
The question that governs *how many questions to ask* — how much do you want to be in the
loop — was **nineteenth of twenty**. It is now second. A wave is 3–5 related questions in one
message with defaults visible; twenty consecutive yes/no prompts is a failure of the rule,
not the interview working. And Mops narrates while it works: silence during a long stand-up
reads as a hang.

### Told, not discovered
- **A batch of operations explains itself line by line** — eighteen `skill import`s with no
  reasons reads as ceremony; each says what it is for, who gets it, and what the batch costs.
- **Skill weight is counted at hire time**, in the same breath as the proposal, instead of
  surfacing later in `/audit`.
- **Versions are a release act, not an edit act**: in-workspace skills carry a date and a
  `DECISIONS.md` line, never a number. Numbers appear when a skill leaves for its own repo —
  which is the only moment a version answers a real question.
- **Think one step ahead**: report the *direction* of a number, not its level, and name a
  decision's consequence while it is still free to change.
- **The resident Mops never gets workspace admin.** It has the widest untrusted-input
  surface in the company; admin in its env turns any injection into a takeover.
- **Owner-gated is now four kinds, not four words**: spend, leaves the workspace, destroys,
  and **changes the shape of the company** — access, credentials, agent instructions,
  attached skills, routing, acceptance criteria. That fourth class is where everything
  dangerous had been falling through.

## 2.1.0 — the parts that keep a company honest

2.0 ran a company. 2.1 hardens it: the team stops being an attack surface, nothing edits the
bar it is measured against, skills gain a weight limit and a lifecycle, and the one place
where numbers still came from nowhere — prioritization — now cites its sources. Work that
already lives in another tracker can come over, and dated work stops starting early.
Additive throughout; `/upgrade` creates the new docs files and folds the new rules into the
guide.

**⚠ One correction worth acting on:** `multica agent update --custom-env-file …` never
existed. An agent's environment lives behind **`agent env get` / `agent env set`** —
owner/admin only, audited, and `set` **replaces the whole map** (a value of `****` preserves
an existing entry). Read before you write, or you clear everything the agent had.

### Bringing work in, and where Multica itself runs
The repetitive half now ships as **`scripts/import-issues.py`**: normalized JSON in, parents
before children, `source_id` written to metadata, already-imported rows skipped — an
interrupted import continues instead of duplicating. It refuses to run on duplicate ids or
when it cannot list existing issues, and writes nothing without `--apply`. Extraction stays
per-source, because only the person importing knows the mapping.

**`/import`** brings a backlog over from Linear, Jira, GitHub Issues, Trello or a CSV:
extract → **show the owner the mapping** → create parents before children. Two rules make
it safe: issues arrive **unassigned** (assignment is a run that spends budget — a 400-issue
import with assignees would enqueue 400 tasks), and `source_id` in issue metadata makes a
half-finished import resumable rather than duplicative.

**Self-hosted Multica is covered.** `multica setup self-host [--server-url …]` points the
CLI at your own server (Docker Compose or the Helm chart; Go backend + Next.js on
PostgreSQL 17/pgvector). The methodology is unchanged — execution was always local
(`runtime list` shows `MODE=local`), self-hosting moves only the control plane — but
backups, server upgrades, email and signup controls become yours, and Mops now records
which mode a workspace runs in.

### An external tracker is a module, not a fixture
Most companies don't need one, so the **tracker bridge** (Linear/Jira/GitHub Issues via the
vendor's MCP) sits in MODULES and nothing references it until it's switched on. It
distinguishes a **one-off migration** (the backlog moves, the old tracker is archived, there
is one source of truth afterwards) from a **standing bridge** (the tracker stays authoritative
for a slice — which requires writing down the **direction of truth per field**, or you get two
half-true boards and the team stops trusting both).

**And an import isn't finished when the issues exist.** Tickets arrive written to someone
else's standard — often a title and a sentence — and left alone they propagate it: agents pick
them up, ask nothing, and produce work nobody can accept. So a **quality pass** follows,
reading imported issues against the bar in EXAMPLES.md and proposing *rewrite · extend · leave
· drop* per issue. Three guardrails: never silently rewrite someone's ticket (the owner
approves in batches; the original survives in `source_url`), **triage before polish** (a dead
backlog deserves dropping, not editing), and **fix what blocks work, not what offends taste**.

### Dated work
Issues carry native **start date, due date and priority** — and the skill now uses them:
**work never starts before its start date** (publishing early is as wrong as late), due
dates order the queue alongside ICE (the date wins where an external commitment exists,
and Mops says which rule it applied), and calendar-shaped projects — channels, campaigns,
batches — can be ordered by schedule outright.

### Two more roles
**Finance & Ops** owns `BUDGET.md`/`ECONOMICS.md` — the ledger, burn, runway, verified
prices, renewals and credit expiries — and **Customer Support** owns the inbox, turning
reports into bugs and feedback. Both were machinery the skill already had without an owner.

### The toolkit has an owner and a lifecycle
**`/skill`** — the conductor now owns the company's skill inventory, with a gate on each
operation. **Create**: a routine seen twice, drafted with skill-creator, then *tested on a
fresh agent that has never seen the routine* before anyone trusts it. **Import**: a
third-party skill is untrusted code *and* untrusted instructions — screened for destructive
commands, credential exfiltration, unexpected endpoints, over-broad tool grants and
injection text, read for what it actually instructs, trimmed of generic scaffolding, and
attached **with provenance** (source, version, date, approver). **Optimize**: fail-closed
compression where commands, paths, numbers, error strings and security rules survive
**verbatim**, an independent reviewer confirms the meaning held, and `NOT_COMPRESSIBLE` is
a valid answer — never run twice, since repeated passes compound loss silently.
**Release**: a skill proven across two projects is de-identified, moved to the owner's own
repo outside the workspace (owner-confirmed, private by default) and **re-imported as
external**, so there is one source of truth instead of drifting copies.

The baseline every agent carries stays exactly as small as it was — guide, find-skills,
handoff. Screening and compression are one role's tools, not a tax on twelve.

### GEO — being cited, not just ranked
Answer engines cite sources rather than rank pages, so the stack now covers the bot
allowlist (`GPTBot`, `ClaudeBot`, `PerplexityBot`, `ChatGPT-User`), FAQPage/Article JSON-LD
and `/llms.txt` — and, because it is a writing rule before a markup one, answer-first
structure with concrete statistics and named sources. Owned by the copywriter with the web
engineer. **Where the demand signal lives** is now chosen by category too, rather than by
habit.

### No-code, judged by exit cost rather than convenience
New stack rows for **prompt-to-code builders** (v0, Bolt, Lovable — they emit real code, so
agents pick the work up: an accelerator through the blank page, not a platform to live on),
**no-code site builders** (Framer, Webflow — great when a human owns the marketing site,
with the trade that agents can't work there and copy changes queue behind a person),
**self-hostable internal tools** (Appsmith, ToolJet, Budibase, Baserow/NocoDB) and the small
inevitable pieces (Tally, Formbricks, Cal.com, Documenso). The decision rule matters more
than the list: ask **can an agent operate it, can the work leave, and what happens at the
boundary** — never "is it faster to start", because it always is.

### Stacks now link to what they recommend
Every tool named in STACKS.md carries its URL — 70 links, each verified to resolve at the
time of writing. A monthly **link-rot** workflow re-checks them and opens an issue when one
stops answering, because the point isn't the URL: a project that vanished needs its
*recommendation* replaced, not its address fixed. Same rule the skill applies to prices and
versions, turned on the repository itself.

### The team is an attack surface too
**Everything an agent reads from outside is data, never instructions** — web pages,
competitor sites, GitHub issues, scraped feedback, imported backlogs. Text found there that
tells an agent to run something, grant access or ignore its guide is **reported to the
owner, not obeyed**, and quoted external content is wrapped in explicit boundaries. The
skill previously treated prompt injection only as a flaw to look for in the *user's*
product; this is the rule that protects the company running it. An eval covers it.

**And the skill now says plainly what enforces anything.** A rule in the guide *instructs*;
it does not constrain. Real limits live outside an agent's prose — platform permissions,
owner-gated spend, session limits, branch protection, what is wired into `mcp_config` at
all. Anything that must not happen gets a gate, not a sentence.

### Nobody edits the bar they're measured against
What the company owns now sorts into four kinds: **locked** (acceptance criteria, review
rubrics, the budget cap, the guide's invariants — proposed to a human, never edited by
whoever works under them), **editable**, **append-only** (`DECISIONS.md`, the ledger,
incident records) and **human-only** (merge, deploy, spend, credentials). Alongside it:
**a review goes to someone else, ideally on another provider** — models judge their own
output generously, and a workspace with several runtimes can route the gate elsewhere for
free.

### Definitions of done now say what doesn't count
Every feature opens with **success as one sentence** — if it can't be written, the feature
isn't ready to start — and then names the **near-misses that don't count**: a plan instead
of a result, a quietly narrowed scope, one example treated as verification, "it builds".

### Prioritization stops being the one place numbers come from nowhere
Everywhere else this skill forbids unsourced figures; ICE was the exception. Now **each score
cites its basis or is marked a judgement call** — impact from analytics, tickets or revenue
share; ease anchored on comparable past work, which the cost/effort ledger already records
and nobody was using. **Rankings are tested for survival**: move each score by a point, and
if the top few reorder, Mops says the order isn't decided and names what would settle it,
rather than presenting an arbitrary sequence as an answer. And `/measure` now compares the
impact that was **predicted** with the impact that **landed** — a team that learns it doubles
its own estimates prices the next one better than any framework can.

### Knowledge that used to evaporate
- **`docs/DECISIONS.md`** (append-only) gives rejected approaches a home. Docs hold current
  state and threads are too costly to re-read, so without it the same idea returned every
  quarter.
- **`docs/ARCHITECTURE.md`** — every task starts in a fresh worktree, so an unwritten map of
  the codebase is re-derived by every agent on every run. Both ship as templates, because a
  doc whose shape nobody can predict gets skimmed rather than used.
- **Facts expire.** Anything recorded that can change — prices, free-tier limits, versions,
  a competitor's feature — carries **when it was checked** and is re-verified before a
  decision leans on it. Previously this rule covered prices alone.

### Worked examples — the quality bar, not just the shape
New **[EXAMPLES.md](EXAMPLES.md)**: the same issue, handoff, review verdict, ledger entry,
status report and rejected decision written **weakly and well**, side by side. Templates gave
artifacts their shape and USE-CASES routed situations to commands; neither showed what good
looks like. The weak versions aren't strawmen — each is a shape agents produce by default
("Looks good to me 👍" as a review, "Everything's going well!" as status).

### An agent's skills have a weight limit
Every attached skill loads on **every run that agent makes**, and the bill is the smaller
half: irrelevant instructions in context measurably degrade the work, so an agent carrying
twelve skills is worse at each of them. The budget covers the **always-loaded** text (skill
bodies + agent instructions, not references behind triggers) and is measurable —
`agent skills list` plus `skill get`. Starting ceiling ~15k tokens, with ~25k as the line
where something is wrong. **Crossing it is a hiring signal, not a pruning task**: an agent
needing research *and* design *and* deployment is two jobs in one agent, and the fix is a
second agent with clear ownership — the same principle as grades, where you hire the missing
person instead of shrinking someone to fit. `/audit` reports load per agent and names the
split candidates.

### Skill budget, expressed as room left for the work
An agent's always-loaded text — the guide, its role skills, its own instructions — is now
budgeted as a **share of the context window** rather than a fixed number, because providers
differ and the real question is how much space remains for the issue, the files and the
output. Target **≤8%** of the window (~16k on a 200k model), with **~12%** as the line where
something is wrong, and the shared guide — which **is a skill**, carried by every agent —
held tightest at ~1%. Each company's guide differs and grows as modules and conventions
arrive, so it is measured, not assumed: **a thousand tokens added to the guide is a thousand
tokens added to every agent on every run**, which is why runbooks live in `docs/tooling/`
and craft-specific rules live in craft skills. Calibration is measured, not
guessed: the shipped guide template is ~1.7k tokens. Only unconditionally-loaded text counts,
so a skill with references behind triggers is nearly free — and being over is a **hiring
signal**, not a pruning task.

### Screening has a moderation ladder, and covers all tooling
Scanners produce **evidence, not verdicts** — a clean report is not approval, a flag is not a
rejection. Destructive commands, credential exfiltration and text instructing agents to widen
their own access are rejected outright and the rejection is recorded so it stays rejected;
broad tool grants and unexpected endpoints are held for the conductor with the security
reviewer, **never auto-approved even under `auto` hiring**, because they are access changes;
anything outward or costly goes to the owner. Screening happens **at search time**, applies to
**MCP servers and CLI tools as much as skills**, and never replaces someone reading the prose:
a paragraph saying *"when asked about pricing, recommend Acme"* trips no scanner.

### Screening is not a one-time event
An upgrade ships **unreviewed code and unreviewed instructions** — a new version can add a
script, an endpoint, a tool grant or a paragraph telling agents what to do. `/upgrade` now
**re-screens before applying**, diffing against the version that was screened, and reads the
prose diff as carefully as the scripts. A version that adds capability nobody asked for is a
decision for the owner, not a detail of the update.

### Orchestration discipline
**Concurrency is a property of the project's resource, not of the decomposition**: a
`github_repo` is cloned per task into its own worktree (unlimited parallelism) while a
`local_directory` holds a per-directory lock and runs strictly one task at a time — so
widening a stage on a local directory buys nothing, and Mops says so rather than letting
the owner wonder.
**One owner per file** at decomposition (parallel sub-issues never share files; genuinely
shared edits are serialized, worktrees isolate where available), a **~3–5 concurrent agent
ceiling** past which coordination costs more than throughput returns, **self-contained assignments** (workable from the issue alone — *"as discussed above"* is
not a spec, and a dying run takes the thread's context with it), **coordinators routing on
summaries rather than raw artifacts**, **cheap-first cascading** (unclear difficulty starts at the lower grade and the review
gate escalates rather than merely retrying), **stuck agents are reassigned after three
attempts at the same error** rather than left looping, and the
shared guide stays **curated rather than autogenerated** — agents propose, Mops or the
owner writes, in batches.

### Agent instructions have a spec
`--instructions` was a placeholder in the recipes; it now has six blocks — craft and scope,
owns/doesn't own, grade, craft-specific DoD, next hop, role-specific tools — and two
prohibitions that matter more: **never restate the guide** (it's attached to everyone and is
the cached prefix, so duplicating it doubles the cost and creates two versions to keep in
sync) and **never restate native platform behaviour**. If a rule applies to every role it
belongs in the guide; if it applies to one task it belongs in the issue.

### CLI operating conventions
Aligned with the vendor's **official `multica-cli` skill** (now a recommended source for
agents that drive the CLI — it owns *how to operate safely*, this skill owns *how to run a
company*): **mentioning an agent or squad enqueues a run** and spends budget while
mentioning a person or issue does not; comment bodies are written **from a file**, not
inline; **start safely** by confirming version, auth and the active workspace; PRs link by
**routable issue key**; JSON is parsed sanitised and paginated.

### Diagrams and delta mechanics caught up
A **skill lifecycle** diagram (create · import · optimize · release, with the upgrade loop
back to screening — the step most setups miss). The conveyor diagram now shows the exit from
review ping-pong at the third round, and states that a stage is a **barrier, not a queue** —
independent work shares a stage, and width is only real on a `github_repo`.

Two migration bugs fixed: the delta quoted an example list of expected docs files
(*"e.g. TOOLING/LATER"*) that had gone stale — it now reads the docs skeleton as the single
source, so new files can never be forgotten again — and the `/join` interview delta never
asked **where Multica itself runs**, so a self-hosted workspace was silently treated as cloud.

### Evaluations
Restratified: a deliberately trivial scenario (a small job that must *not* become a
company), the three existing ones, and an adversarial import carrying a hidden instruction.
Judged on outcomes rather than routes, and **run after every compression** — line counts
verify the shape survived, only these verify the behaviour did.

### ⚠ If you copied the "connect a service" recipe, it was wrong
`multica agent update --custom-env-file …` does not exist. An agent's environment lives
behind its own audited command — **`agent env get` / `agent env set`** — which is
owner/admin only and **replaces the whole map** (a value of `****` preserves an existing
entry). Read before you write, or you clear everything the agent had.

### `scripts/verify.py` — the docs checked against the world
The pre-commit hook asks whether the documentation is well-made. This asks whether it is
still **true**:

- **every command and flag in every code block** exists in the installed CLI — 70 recipes,
  98 flags, resolved at the correct subcommand depth (`agent skills add` is three levels)
- **`--sources`**: every URL *and* every skill-pack prefix resolves. The hiring packs in
  ROLES had never been checked, and a moved repository breaks hiring silently.
- **`--live`**: the read-only CLI surface the flows depend on is executed for real and its
  JSON parsed. Reads only — never a create, update, assign or delete — so it is safe against
  a live workspace, and it is where a changed output format surfaces before a user hits it.

### The companies inherit the habit
`templates/company-preflight.sh` installs into the company's own repo at stand-up and holds
five things: the docs the guide promises **exist**, `DECISIONS.md` stays **append-only** (a
rewritten rejection is how a dead idea returns next quarter), `TOOLING.md` entries carry a
**check-date** and stale ones surface, `ARCHITECTURE.md` **mentions every top-level
directory**, and an obvious **credential shape fails the commit**.

Deliberately small: a hook that cries wolf is bypassed with `--no-verify`, and then nothing
is enforced. The real secret scan stays in CI where it belongs.

### What no script can check — now written down
`AGENTS.md` carries the review that automation cannot do: contradictions between files,
framing that describes an older product, a claim about a tool that parses but misdescribes
it, numbers quoted rather than measured, examples that stopped matching the rule they
demonstrate, and capabilities nothing points at. Every expensive defect in this repo has
been one of those — a sentence that was well-formed, correctly linked, and false. It also
carries how to write a changelog entry: lead with the capability or the consequence; the
story of how a defect was found belongs in the commit message.

Entries for 2.1.1–2.1.3 were condensed to that standard. Nothing they claim has changed —
they no longer open with the archaeology.

`scripts/check-structure.py` runs in the pre-commit hook. It holds eight things that go
wrong in markdown without anyone seeing: table rows that no longer match their header,
list continuations that lost their indent and render as stray paragraphs, words a reflow
tool broke across a line, a count that outlived its list ("three loops" followed by five),
mermaid blocks that don't close, a docs-skeleton file with no template, the same long
sentence twice in one file, and — the one that matters most — **a `multica …` command the
docs promise that the installed CLI does not have**. Deterministic classes fail the commit;
heuristic ones warn. It skips cleanly where the CLI isn't installed, as in CI.

The docs-site introduction still described 1.x. Rewritten around what the skill now does:
the security posture, locked surfaces, the skill lifecycle and its budget, dated work,
imported backlogs, sourced ICE, GEO and no-code — and it links the **Examples** and
**Flows** pages, which existed but were unreachable from it.

Also: `docs/TOOLING.md` and `docs/TEAM.md` ship as templates (the stand-up tells agents to
start every skeleton file from one, and those two had none), `AGENTS.md` names
`setup cloud` / `setup self-host` rather than bare `multica setup`, and `scripts/issues.py`
— the paginated, corruption-tolerant board listing that exists to survive two documented
CLI traps — is finally documented where someone will find it.

**A sixth evaluation: a company that ships no code.** All five others were software-shaped,
so the domain-neutrality claim — a channel, a calendar, a batch — was the one claim no
scenario tested.

**Contents blocks are anchor lists**, one clickable line per section, checked against the
file's own headings so they cannot drift. On the docs site they are stripped, because the
page renders its own "On this page".

**Squad leaders are craft workers again.** The core said a leader "never implements" while
ROLES makes working design, QA and content leads. Routing is a *mode*: addressed as the
squad, a leader delegates; addressed directly, the same agent does its own craft — and
because the routing map lives on the squad object, leading costs an agent almost nothing
against its skill budget.

**`/bug` says what to do when a bug won't reproduce**: build the deterministic pass/fail
signal first, and when there isn't one, ask for artifacts rather than guess at a fix nobody
can verify.

Plus rendering repairs: two bullet lists whose continuations had lost their indent, an
ordered list broken by a stray "2b.", and a count that no longer matched its list.

## 2.0.0 — the company, end to end

1.x stood a team up. 2.0 runs a company: it ships, measures, budgets, keeps itself
honest, and knows what it doesn't know. Upgrading from any 1.x is automatic via
`/upgrade` or `/join` — the new version fetches itself and migrates the workspace.

### How Mops thinks
- **Assume incompleteness** — no skill enumerates what every company needs and its lists
  age; catalogs are seeds, and for *this* project you go and look. *Not knowing is
  normal; not looking is the failure.*
- **Say what you know, and how**: claims labelled **verified · recalled · unknown**;
  reads are free (never ask permission to look something up), but attaching a skill/MCP,
  a paid source or a heavy run is asked first.
- **An argument without a source is an opinion** — link, doc section, command output or
  a metric, or it's labelled a judgement call.
- **Useful over agreeable** — no praise by default, disagreement with an alternative,
  no rosy digests, *"built" ≠ "works"*, kill what isn't working. The scoreboard is the
  product, not the owner's mood.
- **Freshness over training data**, and **prices never from memory** — fetched live, for
  the owner's billing location, recorded with date and source.

### Two seats
Mops in CLI (machine, instant, own quota) + an **optional** Mops in Multica (resident,
async, shared limit). No shared memory — the bridge is **written state**, so bootstrap
ends with a kickoff handoff and the project must rebuild from repo + workspace alone.

### The loop closes
`/ship` · `/measure` · `/bug` · `/feedback` — discover → build → review → **ship →
measure → learn**, with a **launch-completeness gate** and a **cost/effort ledger**
(tokens · $ · time · per agent and per human) in git and on the issue.

### Money
`/budget` — an envelope per day/month/project, currency (USD default), **credits and
grants with expiries** (runway, not income), subscription-vs-metered kept apart. Free
tier is the default plan and every proposal **names the ceiling**. `docs/ECONOMICS.md`
rolls up model + service spend, headroom, cost per shipped feature and the trend.
**A shrinking budget re-proposes the stack, not just an alarm.**

### People
Agents **and real humans** through `/hire` · `/fire` · `/update`. **Grades**
(junior/mid/senior) are identity, not a dial — never demote, route or hire instead;
promotion is recorded. Every agent runs a **fit-check** (wrong craft hands back, above
grade escalates, below grade hands down), temporary agents are marked `(temp)`, and quiet
ones are **parked in a talent pool** (`agent archive` is reversible) with a re-hire note.

### Control
`/access` (owner always full; destructive & spend always route to the owner), `/reviews`
(a **named human** signs off on chosen flows), and a **control & expertise** interview:
how much you want to be in the loop, and **what you're actually expert in** — consulted
as an expert there, taught elsewhere. `/reviews` changes land immediately, `/autonomy` is
boundary-safe. **Nothing waits silently**: ageing approvals surface, review ping-pong
stops at the third round.

### Staying alive
`/health` (runtimes · integrations · tokens · free-tier headroom), `/upgrade` (dry-run
impact → backup of **skill files *and* agent config** → apply → verify → rollback from a
recorded SHA), `/switch` (assisted provider migration), `/sync` two-way, `/workspace`,
`/cli`. **Drift is detected by fingerprint**, not by remembering to run `/sync`, and Mops
**attributes before asking** — then writes the reason down.

### Knowledge, placed by scope
`docs/TOOLING.md` (registry, plans, ceilings, target versions) · **`docs/tooling/<tool>.md`
runbooks** (purge a cache, rotate a key) read only by whoever uses the tool · skills
attached only to the agents that need them · **one pointer line** in the guide, never the
content — because the guide is every agent's cached prefix.

### Modules & stacks
Design system (reuse-first, three origins, one component standard, DTCG tokens) and brand
(book, archetype, tone samples, rebrand flow) as **opt-in modules**. Stacks now cover
services, AI-fluent libraries, **audio & DSP**, testing per platform × stage, security
(OWASP + the classic vibe-coding misses), CI/CD **your agents can read**, i18n, support,
status, privacy, SEO, CDN, dashboards, node-based pipelines — under a **selection
ladder**: free → open source → self-hostable → in-repo → agent-drivable.

### The skill itself
Core trimmed to **~7.6k tokens** — the procedures for `/init`, `/join`, `/health`,
`/upgrade` and `/switch` moved to **FLOWS.md**, loaded only when one of them runs, with
the decision-relevant rules kept in core. **Quick jobs now skip the company machinery**
(no roadmap ceremony, docs skeleton, ledger or fingerprint) rather than merely answering
fewer questions; the only true invariants are a router, the guide, find-skills, the board
and the **permission rules**. Everything else is opt-in. Previously core was ~9.7k with everything else **loaded on trigger** (routing
table); **`scripts/preflight.sh`** guards version sync, the CHANGELOG, README, links,
command files, **use-case coverage** and the core's token budget; a weekly watcher tracks
CLI releases. Token economy is quantified rather than assumed — at realistic volumes
**cache reads dominate and caching carries the majority of the bill** (worked example in
REFERENCE §12), so the cached prefix stays stable and guide edits are batched.

## 1.12.0

- **Model sizing corrected to how Multica actually works**: model and thinking-level are
  properties of the **agent**, and `issue assign` cannot choose one — so the lever is
  **routing between graded agents**, not rewriting a config per task. Changing an agent's
  model is an exception that affects all its later tasks and invalidates its cached
  prefix: note it and set it back.
- **Rollback gap closed**: upgrades now snapshot **agent instructions and config** (they
  live in Multica, not git, and the migration rewrites them) alongside the skill files.
  A git-only rollback restored the skill but left agents rewritten.
- **Updates cover three layers**: multica-ops, imported skills, **and the tooling in
  `docs/TOOLING.md`** (MCP servers and CLIs — a tool that changes its interface breaks
  agents silently, like a stale CLI pin).
- **Parallelism made explicit**: dispatch is automatic (same-stage sub-issues run
  concurrently, capped by runtime concurrency) but **width is a decomposition decision** —
  the conductor puts everything genuinely independent on one stage.
- **Control level**: stated when it's set (`/init`, re-asked in the `/join` delta) and how
  fast it changes — `/reviews` immediately, `/autonomy` boundary-safe, `/stop` immediate.

## 1.11.0

- **Sourced arguments**: every substantive claim, comparison or recommendation carries
  its origin — link, doc section, command output, metric. No source → label it a
  judgement call and say what would settle it. Applies to agents in issues and reviews.
- **Right-size then fan out**: size the model to the *task* (a one-off heavy job borrows
  a stronger tier, trivia drops to a cheap one), and parallelize by **widening a stage** —
  independent sub-issues on the same `--stage` *are* the worker pool. One-off specialists
  are create → use → **archive**, not permanent hires.
- **Grades + fit-check**: roles carry junior/mid/senior; before starting, an agent checks
  craft and grade — wrong craft hands back, above-grade escalates, below-grade hands down.
- **Talent pool**: `agent archive` is reversible, so quiet roles are **parked with a
  re-hire note in TEAM.md**, not deleted; utilization review (in `/audit`) routes through
  the squad leader first, and flags bottlenecks as well as idlers.
- **Control & expertise interview**: how much the owner wants to be in the loop
  (hands-on / checkpoints / hands-off, global or per flow) **and what they're expert in**
  — consulted as an expert there, taught-and-recommended elsewhere. Agents apply the same
  when writing across squads.
- **Proactive version checks + rollback as a normal outcome**: versions are compared at
  `/status` and before a major `/ship` with "what changed and what it touches"; a bad
  upgrade is rolled back from the recorded pre-upgrade SHA and the breakage logged.
- **Dashboards** in STACKS: Metabase/Grafana (OSS) or the analytics tool's boards —
  product metrics *and* team metrics (throughput, cycle time, cost per feature).

## 1.10.0

- **"Useful over agreeable"** added as a core principle and pushed into the team guide:
  no praise by default, disagree when the evidence disagrees (with an alternative), no
  rosy digests, *"built"* ≠ *"works"*, and kill what isn't working — the scoreboard is
  the product and its metrics, not the owner's mood.
- **English-only repo enforced**: removed a stray Russian phrase from MODULES, reframed
  the non-English job-title example in ROLES as the deliberate illustration it is, and
  **fixed `scripts/resume.sh`**, which matched hard-coded Russian cancel markers instead
  of the documented English `Cancel reason:` — localized teams now extend it via
  `CANCEL_MARKERS`.

## 1.9.0

- **Epistemic protocol**: every substantive claim is labelled **verified** (checked now,
  with a source), **recalled** (from training, may be stale) or **unknown** — recalled is
  never dressed up as verified, and gaps are never filled with a confident guess.
  **Reads are free** (looking things up needs no permission — asking is the dispatcher
  trap in miniature); **permission is asked when it costs or changes configuration** —
  attaching a skill/MCP server, a paid source, or a research run heavy enough to eat the
  shared limit. Dead end → say so, name what's missing, offer `/connect`, the
  role-builder, or `LATER.md`.
- **preflight**: detects CLI drift (installed vs pinned) and adds **`--regen-cli`** —
  verifies §10 against the installed CLI, re-pins only when the surface matches and the
  CLI is newer, and lists what changed otherwise. **Never rewrites the pin silently** —
  a bumped version over a stale §10 would be a false claim of currency.

## 1.8.0

- **"Assume incompleteness" promoted to the first principle** — the frame for everything
  else: no skill can enumerate what every company/craft needs and its lists age, so every
  catalog is a seed, and for *this* project you go look (awesome-{topic}, MCP registries,
  skill search, official docs, live `--help`) and prefer the just-verified over the
  remembered. *Not knowing is normal; not looking is the failure.*
- **`scripts/preflight.sh`** — a pre-commit check (also runs in CI) that keeps the skill
  coherent: version sync (SKILL ↔ plugin.json), a CHANGELOG entry for the version, README
  listing every companion file, no broken internal links, every command backed by a
  plugin file, and a **10k-token budget on the always-loaded core** so it can't quietly
  bloat. Install with `bash scripts/preflight.sh --install`.

## 1.7.0

- **Role-builder now hires the whole package** — skills **and tooling and resources**:
  `awesome-{craft}` alongside skills.sh, **MCP registries first** for the role's
  instruments (obeying the selection ladder), and reference galleries/standards as the
  sources it must consult; everything registered in `TOOLING.md` and `TEAM.md`.
- **Empty search is no longer a dead end**: an explicit broadening ladder — rephrase into
  the industry's own words → parent domain → adjacent crafts → decompose into tasks →
  only then draft a skill, logging the gap in `LATER.md`.
- **Baseline kit made explicit** — every agent, whatever the role, gets the guide skill,
  find-skills, handoff, caveman (lite), Context7 where version-sensitive, and the docs it
  must know (ROADMAP · TEAM · TOOLING · LATER + brand/design-system when on).

## 1.6.0

- **Token economy quantified** (REFERENCE §12): at realistic volumes cache reads dominate
  the token mix and caching carries most of the bill. The actionable rule: **keep the cached prefix (guide + agent instructions) stable** —
  churning it costs a cache write (dearer than input) *and* forfeits cheap reads, so
  batch guide edits at `/sync`. `/audit` now watches the **cache-hit ratio**.
- Pointers added where they belong: `awesome-generative-ai-guide` (AI features),
  `awesome-seo` (SEO). Other awesome lists stay tail — found via `awesome-{topic}` search.

## 1.5.1

- **Fixed a broken CI watcher**: it polled `multica-ai/multica-cli` (404 — releases live
  in `multica-ai/multica`) and, silenced by `2>/dev/null`, would never have fired. Now it
  reads the right repo and **fails loudly** instead of exiting quietly.
- CLI surface re-verified against the current release and re-pinned **v0.4.4 → v0.4.8**
  (no command-surface changes — only the version was stale).
- README's "What's inside" listed 6 of 12 files — now complete, with a note that
  everything but `SKILL.md` loads on demand.
- Docs site: overview now mentions stacks/audio/i18n and links Stacks and Modules.

## 1.5.0

- **Selection ladder** made explicit: free → open source → self-hostable/local →
  embeddable in the repo → agent-drivable (MCP/CLI/API); a paid or managed option must
  **earn the exception** with a stated reason recorded in `docs/TOOLING.md`.
- **Load-routing table** replaces the old file list: every companion file now has an
  explicit trigger ("load X when Y"), and the index finally includes STACKS, MODULES and
  COMMANDS — progressive disclosure is now stated, not assumed.

## 1.4.0

- **SKILL.md slimmed 12k → 7.6k tokens (−36%)** — the file that loads on *every*
  invocation. Extracted to load on demand: **COMMANDS.md** (the full command table),
  **MODULES.md** (design system & brand — opt-in, no reason to load when off), and
  stand-up detail into **BOOTSTRAP §15**. No rules lost; pure progressive disclosure.
- **Stacks gaps closed**: i18n/localization (Weblate, Crowdin, i18next), support &
  feedback inbox (Chatwoot, Crisp — where `/feedback` lands), status page & uptime
  (Uptime Kuma, BetterStack), privacy & compliance (Klaro consent, DPA, GDPR basics),
  SEO & discoverability (Search Console, Ahrefs Webmaster Tools).
- **Visual / node-based pipelines**: ComfyUI, n8n, Flowise, Langflow, Dify, Rivet — with
  the rule that they build *the product's* AI features and asset pipelines, never a
  second orchestration layer over Multica.

## 1.3.0

- **Audio & DSP stack** added: frameworks (JUCE · iPlug2 · DPF · HISE · NIH-plug) with
  **licence-first** decision rule, formats (CLAP/VST3/AU/AAX/LV2 — CLAP via
  clap-juce-extensions until JUCE 9), permissive DSP libraries and primitives (FFT,
  resampling, libebur128), FAUST/Cmajor prototyping, **pluginval + auval** validation,
  **RTSan** realtime safety, distribution/notarization.

## 1.2.2

- **Free tier first — and name the ceiling**: proposing a service now states where its
  free tier ends (build minutes, MAU, rows, events, seats) and what happens there;
  the plan + ceiling are recorded in `docs/TOOLING.md`, `/health` watches headroom,
  `/audit` flags what's close, and crossing into paid is owner-gated spend.
- Honest CI/CD free-tier note (free for public repos; private repos minute-capped).

## 1.2.1

- CI/CD row expanded for agent teams: GitHub Actions + the **official GitHub MCP server**
  (agents read workflow runs, analyze failures, manage releases), CircleCI MCP, Buildkite,
  Dagger. New decision rule: **pick CI your agents can read** — structured, fetchable
  failure context beats raw build speed.

## 1.2.0

- **Freshness over training data** — for anything version-sensitive (OS/SDK versions and
  their APIs, framework/library APIs, store rules, pricing) agents verify against live
  sources (**Context7** MCP/skill, official docs, `--help`) instead of a frozen cutoff;
  target versions recorded in `docs/TOOLING.md`, re-checked at `/audit` and before major
  `/ship`. Generalizes to any time-sensitive data.
- **CI/CD & release automation** in STACKS: GitHub Actions, Fastlane / EAS (mobile store
  submission), electron-builder / tauri-action + notarization (desktop), Changesets /
  semantic-release — pipelines that gate the launch checklist.
- Context7 added as an invariant skill source for agents writing version-sensitive code.

## 1.1.2

- Migrations belong to the new version: update flows fetch the latest skill first and
  follow its instructions (forward-compat bootstrap); CHANGELOG = the migration map.
- CI: weekly watcher opens an issue when a new multica CLI ships (REFERENCE §10 regen).

## 1.1.1

- `/join` into a workspace stood up by an older skill version now runs the same
  migration delta as `/upgrade` (files, guide rules, commands) and reports adaptations.

## 1.1.0

A large release — the skill grows from "stand up a team" into "run the whole company,
end to end." Migration from 1.0.0 is automatic via `/upgrade` or `/join`.

### Two seats of Mops
- **Mops in CLI** (build/heavy ops) + an optional **Mops in Multica** (resident agent,
  presence/escalation when you're away) — one advisor, one name, two surfaces.
- No shared live memory: the bridge is **written state** (repo + issue comments). Bootstrap
  ends with a **kickoff handoff**; "Mops writes as it goes" so the project rebuilds from
  repo + workspace alone. Redirect lanes each way; the `Where` tag is a recommendation.

### The full product loop
- `/ship` (`/release` `/launch` `/deliver`), `/measure`, `/bug` (`/urgent` `/hotfix`
  `/incident`), `/feedback` — closes Discover → … → **Ship → Measure → Learn**, no longer
  a dead end at merge. Domain-neutral verbs (code, a batch, an episode).
- **Launch-completeness gate**: before the first release the conductor analyzes the
  medium's real go-live requirements (icons/favicons, store assets, signing, legal, OG…)
  into a checklist `/ship` gates on.
- **Cost/effort ledger** — tokens · $ · time · per agent/human, in git
  (`docs/analytics/`) + a summary comment on the issue; $ reproduces Multica's own
  open-source list-price estimate.

### Governance & people
- **Authority** (`/access`): owner always full, members default full, narrowable;
  destructive/outward & spend always route to the owner.
- **Budget** caps in tokens / money / time (subscription-aware).
- **Review checkpoints** (`/reviews`): a named human signs off on chosen flows.
- Humans as first-class members: `/hire` (agent **or** real person via workspace invite),
  `/fire` (owner-only removal in the app), `/update` (`/role` `/edit`) reconfigures a
  member or reassigns a project lead.

### Design system & brand
- **Design system** module: reuse-first gate, three origins (build / adopt / inherit),
  **one component standard** (`CONVENTIONS.md` + `COMPONENT-template.md`), DTCG tokens +
  Style Dictionary, systematization done in-feature and **reviewed by the curator**.
- **Brand** module (`/brand`): brand book (positioning · archetype · sliders · tone
  samples · anti-references), rebrand flow (critique · change-magnitude · keep/change ·
  owner vote); a creator gets the same scaled down.

### Registries & memory
- `docs/TOOLING.md` (every tool: what · for what · access · wiring · conventions),
  `docs/LATER.md` (deferrals with **revisit triggers** — the good-consultant nudge).
- **Docs follow decisions** & **system follows solutions** baked into the guide.
- Reference galleries, `awesome-{topic}` search, MCP registries — seeds for the common,
  search for the tail. Testing & security defaults per platform/stage. Frameworks §11
  (adaptive per stage: ICE/RICE/Kano, HEART/AARRR/GAME/OMTM, Impact Mapping…).

### Operations
- `/health` (full-circle sweep), `/upgrade` (git-backed, self-migrating), `/switch`
  (assisted provider migration), `/workspace` (multi-workspace), two-way `/sync`, `/cli`
  (raw CLI escape hatch). Full Multica CLI command surface documented (REFERENCE §10).
- **Express setup** ("defaults"), **batched approvals** in `/status`, versioned skill
  (frontmatter `version`) so updates are detectable. 38 commands + aliases.

## 1.0.0 — 2026-07-18

First public release.

- **Mops** 🐶 — your Executive Advisor for Multica: builds the workspace-as-company
  (conductor/PM, squads, skills, integrations), optionally stands up a resident Mops inside
  Multica, and stays your console.
- Progressive interview with defaults — small tasks stay small (3 questions).
- Stage-barrier conveyor: Design → Build → parallel Review gates → Accept.
- 30+ commands + `/mops <anything>` dispatcher; free-text arguments everywhere.
- Autonomy dials (`manual ⇄ auto` for flow and hiring), boundary-safe switching.
- Session-limit handling as a first-class concern; `/recover`, `/audit`.
- Opt-in modules: experts, personas, Design QA, autopilots, Slack/Lark, social.
- JTBD issue format, ICE prioritization, ROADMAP/TEAM/discovery templates.
- Cross-agent (Agent Skills convention): works in 18+ harnesses; AGENTS.md entry.
