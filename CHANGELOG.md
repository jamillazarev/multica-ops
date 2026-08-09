# Changelog

Newest first. Each entry leads with what you can now do, not with which files moved. This is
also the migration map `/multica-ops:upgrade` reads.

## 0.4.5 — 2026-08-09

**The claim under W012 stops being an assertion and carries its measurement.** 0.4.4 said the
form Snyk quotes — `multica skill import --url github.com/jamillazarev/multica-ops` — is a
command that does not work. True, and undated, and unmeasured, which by this repository's own
freshness law makes it a claim wearing the clothes of a fact. **Measured `2026-08-09`**: the
bare root returns **HTTP 502**, body *"SKILL.md not found at the root of
jamillazarev/multica-ops@main. For multi-skill repositories, point to a specific directory
using …/tree/main/&lt;skill-dir&gt;"*.

**The control is the part that makes it evidence.** The pinned install line was run **at the same
moment and succeeded**, so the 502 is the shape of the URL and not a service interruption —
without that second run this page would have recorded a possible outage as a defect in an
address, which is the same error in the opposite direction from the one 0.4.4 fixed.

**And the response carries a second finding that is not ours.** Multica answers a plainly
client-side mistake with a **5xx**, which the CLI renders as *"the service is temporarily
unavailable"* — so an actionable message (*point at a directory*) reaches the user as a false
claim that the service is down. Recorded on the security page rather than left in a
conversation, because the next person to mistype that URL reads the same wrong cause. Worth
reporting upstream; the row says so.

**Eval state**: **not run** — a patch that dates a claim and adds no behaviour. Corpus checks
green and every guard suite passes.

## 0.4.4 — 2026-08-09

**The security page said something false about itself, and a security page is the worst place for
that.** Answering the 2026-07-30 Socket and Snyk audits, it swept three findings into one sentence
— *"none of those paths exists in this repository at any commit"* — which is true of
`commands/skill.md` and of the `scripts/install-alias.sh` that Socket's hooks alert points at
(**zero commits each, at any ref**) and **false of `hooks/hooks.json`, which exists and has four**.
The substance was right and the claim was wrong, which is precisely the defect class AGENTS.md
names as the expensive one: *a statement that parsed perfectly, linked correctly, and was false*.

**Every finding now gets its own row and its own answer**, because they do not deserve the same
one: a path that never existed · a file that exists whose flagged script never did · a quoted
command that does not run, against an install line that pins a tag for exactly that reason and a
preflight that fails the release when the pin drifts · and two findings that are **accurate
descriptions of what the skill is for**, answered by the page rather than argued with. Verified
against `git log --all` on 2026-08-09.

**And the live half of the hooks finding is answered instead of dodged.** A `SessionStart` hook
does run a script from `${CLAUDE_PLUGIN_ROOT}` — so: that variable is **the runtime's own**, and
an attacker who can set it has already replaced the plugin, which no in-plugin check survives;
every wired hook is a **two-line shell wrapper** exec'ing a Python file beside it, 64–227 bytes,
readable in a minute, and that is the intended way to check them; each is **mutation-tested on
what it refuses**; and the upgrade flow exists so that re-reading the diff from a pinned tag is
the default rather than a discipline. **Dismissing a finding because its filename is wrong leaves
the part that was right standing.**

**Eval state**: **not run** — a patch that corrects a claim and adds no behaviour. Corpus checks
green and every guard suite passes.

## 0.4.3 — 2026-08-09

**Six shelf rows, and two of them close doors that were open in only one direction.** Nothing
else moved: a row is offered when a need names it and is never loaded before that (STACKS head),
so no flow got longer and **no company owes a migration**.

- **Voice became a ladder, because the top rung is free.** YouTube and most platforms ship a
  caption track, and **transcribing a video that already has one is paying twice** — in GPU time
  and in wall clock. `youtube-transcript-api` and **yt-dlp** first, Whisper when there is no
  track, hosted only for scale or a synthetic voice. Rung 1's real limit is in the row:
  unofficial, so `RequestBlocked`, cloud-IP blocks and parser breakage when the markup moves —
  a research pass on a laptop, not a standing pipeline.
- **Presentations, picked by who owns the deck afterwards.** **Marp** is the default because it
  is the only rung where a deck still diffs, reviews and gates like everything else; Slidev when
  the slides execute, Quarto when a paper shares the source, the `pptx` skill when a person
  outside the repo must edit the file. `academic-pptx-skill`'s **action titles** — a heading
  states the finding, not the topic — is a form worth stealing whatever you generate with.
  **`anydoc` from 0.4.2 is the same door running inward**, so the two releases are halves of one
  thing: decks arrive as `.pptx` and leave as markdown.
- **Style presets, filed as a vocabulary and not a machine.** Fooocus's JSON is the format
  everyone ports and is worth having as *two hundred named looks to point at* when briefing an
  owner. It is not a style system: these are SDXL-era suffixes, the hosted models answer to plain
  description and a reference image, and a preset picked per image is a moodboard folder in JSON.
  **What makes two images match is the recipe kept beside the asset** — model, prompt, seed,
  reference, in `_ops/assets.md` next to the licence.
- **Image → prompt, starting from the model you already pay for.** Claude or GPT-4o vision beats
  standing up CLIP Interrogator unless the batch is big or the images must not leave the machine
  — the same two reasons as local Whisper. Its real uses are salvage, turning a client's
  reference deck into words the register can hold, and alt text.
- **Where skills live**, the step before screening one: SkillsMP leads because it shows the
  `SKILL.md` **before** installing, and a directory that shows neither instructions nor code is
  an advertisement.
- **`last30days`** joins the demand-signal row with both of its limits: *"no keys"* is true of a
  slice (X wants cookies, three networks go through a paid third party), and **engagement
  weighting is not representativeness** — the top of the signal pyramid handed over as the base.
- **Skill Vetter joins the screening row, because it fails in the opposite direction** to the
  scanner. Patterns cannot read intent and cannot be argued with; a model-executed checklist
  reads intent and **can be talked out of it by the very file it is screening**. Neither is the
  gate.

**And a defect the runsheet had warned about itself.** Its own header says *regenerate after
adding a scenario — the runsheet went one behind when 26 landed*; it was one behind again, with
**scenario 27 in the rubric and absent from the sheet**. It is a row now, marked `TO-AUTHOR`
because the rubric describes a situation with no utterance and writing the opening line is
writing part of the test.

**What this release deliberately does not carry, and why it is a patch.** The asset **recipe** —
model, prompt, seed and reference as required fields, with a company-preflight refusal behind
them — was built and is **held back**. It is a capability, and a capability here owes a form, a
mutation test, a scenario and a door; the form and the suite exist, but a minor is not tagged
without `evals/runs/<version>.md` and the four lenses, and neither was run. **Shipping it as a
patch would have been shipping the shape of the bar without the bar.** The two rows above that
depend on the idea say it in plain words instead of citing a section that does not exist yet.
It lands whole, as a minor, when the round has been run. *(The sibling `opsinist` carries the
same mechanic at 0.2.5 with its own measurement behind it.)*

**Eval state**: **not run** — a patch that adds no behaviour, so no round is owed. Corpus checks
green and every guard suite passes, which is evidence about the corpus and about what the
holders refuse, never about behaviour.

## 0.4.2 — 2026-08-09

**A document an agent cannot open is not evidence.** The shelf had an answer for web pages
(Crawl4AI, cf-browser) and one for audio (Whisper), and none at all for the file somebody
actually sends you — so a tracker export arriving as a spreadsheet, a primary source that exists
only as a paper, or a segment's own words trapped in someone's deck were each solved from
scratch by whoever hit them, or read by eye and paraphrased.
**[anydoc](https://github.com/firecrawl/anydoc)** (MIT, Rust, local, no key and no model call)
is now the row: docx · pptx · xlsx · odt/ods/odp · rtf · epub · csv and text-based PDFs into
markdown. Home: STACKS → *Reading documents agents can't parse*; `/multica-ops:import` pass 1
cites it rather than restating it.

**Both limits are in the row, because a converter that quietly returns nothing is worse than
no converter**: there is **no OCR** — an image-only or password-protected file is an explicit
`Unsupported`, and the fallback stays the Anthropic `pdf` skill or a real OCR pass — and
**images become their alt text**, so a deck whose argument lives in its pictures arrives without
it. Its speed and coverage benchmarks are the project's own, LLM-judged claims, named as claims
rather than carried as fact.

**Nothing else moved, and no company owes a migration.** A shelf row is offered when a need
names it and is never loaded before that (STACKS head), so no flow got longer. anydoc also
ships as an agent skill; that route arrives through `/multica-ops:skill`'s screen like any other
import, which is where it was already governed.

## 0.4.1 — 2026-08-08

**A gate is not enforced until you have watched it refuse — and on Claude Code, the shape of
the refusal decides whether it holds.** `enforced_by: validator` is a claim, and the cheapest
way to be wrong about your own company is to write a gate, see it run, and never check that it
says no: a hook whose refusal is discarded is indistinguishable from one that works — the tool
exits, the log fills, and the forbidden thing happens anyway. So a gate is accepted only against
a **deliberate violation**, confirmed by the artifact (a stamp file, an absent commit, an
unchanged permission) and never by the runner's account of itself.

**The measured trap** (Claude Code 2.1.220, stamp files on both sides): `exit 2` refuses ·
nested `hookSpecificOutput.permissionDecision` refuses on the plugin path (the settings path was not probed for it) · a **flat `{"permissionDecision":
"deny"}` is executed and ignored on the plugin path *and* through a settings file — the command
proceeds either way.** The flat shape is the natural guess, raises no error, and **is not a
refusal anywhere measured**; the first reading of this blamed the path, and the path is not what
decides. Home: PLAYBOOKS → *A gate is not enforced until you have
watched it refuse*; the dev contract cites it rather than repeating it.

**Nothing in 0.4.0's behaviour changed** — both hooks it ships already refuse with `exit 2`,
and that was watched refusing, not read off their source. What is new is the rule for the gates a company writes for itself, and a check in this
repository that fails the flat shape before it can ship.

## 0.4.0 — 2026-08-07

**The machinery lives under one door now: `_ops/`.** A project's root belongs to the craft
again — its own files, its own `docs/`, its `.claude/` — and everything the methodology owns
sits in a single directory named to sort first and collide with nothing. What `docs/` used to
hold is flat inside it (`_ops/DECISIONS.md`, not `docs/DECISIONS.md`), and `docs/tooling/` is
**`_ops/runbooks/`**, because a runbook is what it holds and `tooling` beside `TOOLING.md` was
one word doing two jobs. **The collision this ends was real, not theoretical**: roughly twenty
paths went into whatever `docs/` a repository already had, and most repositories have one — a
bakery's or a Django project's documentation is not a place to file a decisions ledger.

**Migration map — one command:**
- **`python3 scripts/migrate-layout.py <project-root>`** (`--dry-run` reads without touching)
  moves the claimed paths as history-preserving `git mv`s. **Anything under `docs/` it does not
  recognise stays where it is and is named in the output** — that directory is very often the
  craft's own. A dirty tree is refused so the migration is its own diff; a destination that
  already exists is a named `CONFLICT` and a nonzero exit, never a silent overwrite; a second
  run does nothing and says so.
- **Then re-copy `templates/company-preflight.sh`** over the repo's pre-commit hook — the old
  copy checks paths that have moved. The migration names it rather than rewriting your hook.
- **An unmigrated workspace is recognised, not crashed into**: reading a claimed path that is
  missing, Mops looks once at the old location and, finding the file there, stops and offers
  `/multica-ops:upgrade` rather than silently reading the old layout forever.

**An outward act is stopped by a gate now, not by a sentence.** *Pushing is the owner's* has
been in the core, the gate table and the README for versions — as `prose-only`, and **measured
2026-08-07 it was not merely unenforced but reliably ignored: five runs of five went
`Edit → commit → push` and reported "Done… and pushed".** `hooks/outward-gate.py` is the form:
a `PreToolUse` hook that stops `git push`, `gh release create`, `npm publish`, a `deploy` or a
`docker push`, names the act as one of the four owner-gated kinds, and hands it back. Local work
never trips it, and `--dry-run` is a read. **The retry does not pass** — a first design that
stopped once moved the rate only to 2/5, with the other three simply pushing again, so the
doors are named instead: the owner runs the command, or sets `MOPS_OUTWARD_GATE=off` on
purpose. **5/5 after the repair.** (And the inherited note that plugin `PreToolUse` hooks do
not fire under `claude -p` was checked rather than trusted — they do.)

**A long read with nothing dispatched gets a note** — `hooks/dispatch-nudge.py`, after an
unbroken run of read-only calls. It **reports and never refuses**, because reading is
legitimate. Stated plainly: it did **not** move the measured rate the way the two refusing gates
did, and it is shipped as an aid rather than a repair. What it did produce is a runtime fact
worth having — **a `PostToolUse` hook's stderr never reaches the model; only
`hookSpecificOutput.additionalContext` does.** A note nobody receives is not a weaker gate, it
is no gate, and the first build of this one was exactly that.

**And `_ops/` is a shared door, so ownership is read before anything is written.** The sibling
project `opsinist` runs the same methodology out of files and uses the same directory —
**nine of the twelve documents inside are named identically** (measured 2026-08-07). Sharing the
name is the right trade: a successor finds the predecessor's record exactly where it would have
put its own, where a private directory would make a fully-documented project look like open
ground. What it requires is a marker, not a rename — **`_ops/config.md` with no
`Operated by multica-ops` line in the guide means another system operates this tree**, and it is
named and handed back with nothing touched. `migrate-layout.py` refuses such a tree outright,
and both directions are covered by the suite. Their records are evidence, not our workspace.

**"Remember this" lands in a file, and a gate makes sure of it.** The law shipped in this
release and **did not hold on its own**: scenario 26, five runs of five, wrote the owner's rule
into the runtime's private cross-session memory — outside the repository, unread by every agent
here — and not one named a home back. `hooks/rule-home.py` refuses that write and names the
homes; the attractor is unchanged (every run still reaches for memory first) but the rule now
lands in the guide, **5/5**. Scoped to workspaces with an `Operated by multica-ops` line, so an
ordinary repository's memory is nobody's business but its own, and switchable off by name.

**The homes** — a guide line · the glossary ·
`_ops/DECISIONS.md` · the register · `_ops/LATER.md` — **and never the harness's own agent
memory**. Measured next door on 2026-08-07: told *"remember this"*, two runs of two wrote the
owner's rule into the runtime's private cross-session store — outside the repository, unread by
every worker (opsinist 0.2.2). It is worse here than in a file-only system, because the workers
are agents that read the workspace and the repo and never your laptop.

**A back-pointer names a section and proves what it said.** The sources register cited claims by
`file:line`, and a line number names a *position* — **measured 2026-08-07, 11 of 23 pointers no
longer landed on their claim**, with no edit to the register in between; the docs had simply been
written in. Citations are now `file.md#anchor (sha:…, checked …)`, minted by
`fetch-source.py --cite <file.md>#<anchor>`, and the hash earns the rest: a passage rewritten
*underneath* its citation makes the fact **`unknown` and says so**, which a line number cannot
even see. All twenty-four pointers were converted; the register verifies **20/20** after deduplication (two of them went stale the same day, under passages this release went on to edit — which is the hash doing its job, and they were re-minted).

**The README was cut to be read.** Three hundred and eighty-two lines became two hundred and twenty-eight: one
minute in (two commands, then say what you need, with the six entrances), **fourteen one-line
differences** instead of paragraphs, an honest ceiling table with *how it is known* per row, and
the success-as-absence tests. The pug stays. One number in it was also simply wrong — it
advertised 22 eval scenarios against a rubric that now holds 26.

**Seven rules the sibling project proved, each checked against the platform first.** Three of
them the platform does not do, so they are ours and say so:

- **A role declares what it falls back to.** `agent create --model` takes one identifier and a
  capacity death lands in `agent_error` unretried (CLI v0.4.12), so a role records a fallback
  chain of tiers in `TEAM.md` — **taken and named in the same breath**, never a silent
  downgrade. *No fallback* is a real answer for review and architecture: waiting beats answering
  worse. A chain never reaches below the grade's floor.
- **Silence is not an answer unless a grant said so first.** A request may act on an unanswered
  question only through a grant written **in advance**, carrying `on_timeout` — **`keep-waiting`
  is the default** — and a real window. Authored mid-wait it is the constrained party unlocking
  its own door. The four owner-gated kinds cannot carry `proceed` at all, and what fired is
  recorded on the issue.
- **The owner's hand-edit is offered a home — once.** An edit is the standard stated in the one
  unambiguous way: the finished thing. It is read back once and one home proposed — a guide
  line, the role's instructions, a worked example, or **nothing, which is a real answer**. Not
  on every occurrence, because that turns a correction into an interrogation; and never
  generalised silently, because an inferred standard nobody agreed to is how a company acquires
  conventions its owner never chose.
- **A decomposition states four things once** — what happens when a child fails (**`escalate` by
  default**; Multica has no `on_child_failure`), what it is expected to cost as a **median over
  comparable runs with its sample size** rather than a feeling, where a secret goes (**the owner
  answers "done", never the value**), and that a lesson crossing to another project goes through
  the import gate rather than a shared brain.
- **A product that lives elsewhere is watched, never vendored** — a pointer with its why,
  `version_seen`, and **per-surface check-dates** (repo · site · docs · pricing move at
  different speeds). The watch closes natively: an autopilot in `create_issue` mode with the
  owner subscribed makes each upstream release an issue that **lands in triage and cannot
  fade**. And accepting a move **opens the delta** — `version_seen` moves only once the list of
  what it changes exists.
- **Who is standing on a map node is generated** — `scripts/map-blocks.py` fills marker pairs in
  `_ops/MAP.md` from `touches` metadata and rewrites **only between the markers**. **Two live
  issues on one node is a finding stated inside the block**: a merge conflict arriving a week
  early, while sequencing is still cheap.
- **The migration delta reads both ways.** An upgrade that only adds never notices the other
  half — a rule the workspace already has that the new corpus contradicts. A clash is now **a
  finding with two named sides and the owner decides**, recorded in `_ops/DECISIONS.md` so the
  next upgrade does not re-ask. Only load-bearing clashes surface: a migration that asks twenty
  questions gets answered *yes to everything*.

**Five shelves arrived, and one law about who they serve.** Feature flags and progressive
delivery (OpenFeature · Unleash · GrowthBook · Flagsmith — with the debt trap: **a flag nobody
removes is configuration debt wearing a feature's name, so flags carry an expiry like grants**)
· **hypothesis and usability test methods** ordered by the cost of being wrong, each carrying
its bias on its face · the **experience-measurement ladder** by layer, CES through the Sean
Ellis test to NPS, all of them attitudes that sit *beside* the behavioural numbers and never
instead of them · **agent-web protocols** — Web Bot Auth, Content Signals, Pay-Per-Crawl's 402
— with both sides named, since from **2026-09-15** Cloudflare's default starts blocking agent
bots on ad-bearing pages · and **open-source and skill distribution**, where the listings are
the channel and each has its own bar. Two shelves grew their applied halves: Growth.Design's
**53 case studies** and **abtest.design**, both **a shelf of survivors** — they calibrate what
to try, never what to expect, and they are for citing, never mirroring.

**And the law they instance: a shelf serves every flow that meets its need.** Filed by one
flow, scoped to none — the shelf a review cites is the shelf a build opens and a consultation
answers from, and a pointer handed over once is read wherever it is relevant rather than asked
for again. **The point of a shelf is a shorter search, so it sits at the search's head**: the
register first, the live web where the register runs out, and a find worth keeping lands back
with its why. One home in FLOWS; the catalogue header and the sources register cite it.
**It is called a shelf and never a "resource"**, because on Multica a **project resource** is
already a `github_repo` or a `local_directory` an agent works on — the glossary now tells the
two apart, and the sibling project's word did not survive the border.

**A migration notice now needs a workspace that says it is operated, not one that says the
name.** The session-start check called a tree ours whenever any guide *contained* the string
`multica-ops` — which is true of this skill's own repository, of every fixture, and of any repo
whose README recommends us. **Ownership is an operator line** (`Operated by multica-ops
0.4.0`) or an `UPGRADES.md`, nothing less. If your guide only mentions the skill in passing and
you *want* the check, give it that line. The mutation suite had assumed the strict rule from
the start and asserted it nowhere, so the code had drifted below its own tests in silence.

**The coverage map exists, and it is generated.** `scripts/coverage-map.py` assembles
`evals/COVERAGE.md` from the tree itself — what the corpus says holds each rule, which
validators, hooks and suites ship, how many scenarios the rubric carries and which versions
have a run record — with **rates deliberately not copied**, because a rate belongs where its
date is. It has a page on the site, and the section finally has an **`llms.txt`** — scoped to
the section, so it cannot fight the site root's over what this site says it is.

**Three guards, each closing a defect that shipped somewhere.** The link checker stops filing
false corpses: paren-cut URLs are percent-encoded (and preflight now refuses a raw `(` in a
markdown URL), a transient 5xx gets one retry, and 401 joins 403/429 as bot-blocked rather than
dead. The **version sweep runs over every manifest it can discover**, not the two somebody
remembered — we ship four, and only two were checked. And CI runs the **real** gate suite on
**macOS**, the platform the release is actually cut from, with the badge pinned to `main`.

**The release notes are the changelog entry whole, with the heading collapsed to a bare italic
date** — the title already carries the version and the release's own line. All seven past
Releases were retro-fitted in place; one of them had been published carrying this file's
*header* instead of its entry. **And the tag waits for the owner's word, every release its
own** — that law and the session loop now live in the repo's own `CLAUDE.md`.

**Migration map** — nothing to do for most workspaces: corpus rows, dev furniture and
generated pages. The one exception is the session-start check: **a workspace whose guide only
mentions `multica-ops` will now stay silent**. Add an `Operated by multica-ops 0.4.0` line to
its guide to keep the migration reminder, or leave it silent if the workspace was never ours.

## 0.3.3 — 2026-08-02

**Forty new tools and services, and this file's list is now the same list as the sibling
project's** — 406 links on each side, none only on one, checked mechanically rather than by eye.
The drift ran one way: `opsinist` carried twenty-two this file lacked and this file carried none
it lacked, so the academic sources, licence reading, behavioural reference, saliency work and
structured comparison arrived here as their own **Evidence** section.

**Nine new categories**, picked because they are what a company on this platform keeps building:
**agent and chat interface components** · **icon sets** · **data tables** · **billing and pricing
UI** · **deep research as a bounded job** · **cloning a page you are allowed to clone** · the
**utility layer** between a framework and a component kit · **calling an API by hand** · **review
workflow for stacked changes**.

**Three things are recorded as blockers, not details.** Several agent-UI libraries **state no
licence** — copy-paste components become your source, so that is unlicensed code in the
company's repository. One block library is **paid**, named as the single non-free entry rather
than quietly dropped. **Prisma's licence is read at its repository, not its site**, which sells a
different product.

**"Load the row, not the file."** This is the longest document here and almost none of it is
about the task in hand. The rule is in the file *and* in the core's routing entry, because a rule
inside a long file is only read after paying for the whole file.

## 0.3.2 — 2026-08-02

**Recording that a check ran is not the same act as applying what it found, and only the second
one waits for you.** The log line says somebody looked; the changes need your word. Treating them
as one act is what loses the record: a run that built the whole delta, asked its one real
question and wrote nothing left a workspace **indistinguishable from one nobody had opened**, so
the next session re-derived everything and asked again. Waiting is now `deferred` — what was
found, what waits, on whom — **replaced, not duplicated**, when the answer comes.

**A log entry may wrap, and the check reads entries now rather than lines.** A correct four-line
entry — version on the first line, `Outcome: applied.` on the fourth — was read as **absent**,
which would have nagged forever about a migration that had already happened. **A record's grammar
is a paragraph.**

**The session-start message no longer says approval is not needed, because a run read that as an
attack.** The wording *"recording is not gated on approval"*, arriving cold in a system message,
is **an instruction to push file edits through without the owner's say-so** — the exact shape of
a prompt injection. A run said so, declined to touch anything, and offered to make the edit
visibly if asked. **It was right.** One run in two tripped on it. The hook now carries the
vocabulary and never the claim that permission is unnecessary.

**Scenario 25 joins the rubric**, for a case scenario 24 could not force: a migration that cannot
finish without the owner. `evals/runs/0.3.0.md` records what it measured and — more usefully —
what it **failed** to isolate, since three of its runs judged the blocking item to sit outside
the migration and were defensible in doing so.

**And the rig's isolation now covers the config, not only the workspace**: run under the author's
own configuration, a player answered *"what's next?"* by opening **a different operations skill
installed on the same machine** and running that one's flow instead. **A shared config is how
another plugin gets a vote.**

## 0.3.1 — 2026-08-02

**Your guide now states which version operates this company, and something checks it.** The line
did not exist before — `UPGRADES.md` was the only record, and it is the one a migration writes.
So a run could write the log line, leave everything else, and **the session-start check would go
quiet precisely because the log is what it reads**. The disagreement was not merely unfixed; it
was made invisible.

**Measured, three runs each side.** Before: the guide was bumped **0 of 3**, and two of those runs
wrote their log line anyway. After — a hook that names both files in one fact, a template line
that says what it means, and a flow that makes it the first mechanical item — **2 of 3**. The
hook still only reports what two files say, so there is nothing here a session could forge.

**A delta that stops for your approval now writes `deferred` instead of nothing.** Waiting is
right; waiting silently leaves the same trace as never having looked, and the next session
re-derives the whole delta and asks you again. **One run met that branch after the change and
still wrote nothing** — recorded in `evals/runs/0.3.0.md` as a miss, not as a fix.

**`--thinking-level` runs backwards for reaction personas, and only the tier half was written
down.** A real person gives a landing page thirty seconds; a persona at high effort writes the
considered essay nobody would have written — articulate, plausible, and evidence of nothing. Set
it low for reaction personas; raise it only for the adversarial ones, where taking an argument
apart *is* the job.

**Two harnesses install as a symlink into `~/.agents/skills/multica-ops`.** Found on a real
machine: if no route ever created that directory, Factory's and Pi's links are **broken while
looking installed**. `scripts/find-installs.sh` reports them as `BROKEN`; `INSTALL.md` now says
what to put there.

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
