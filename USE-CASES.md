# Use cases — situation → what to say

You never need a command: **say it in plain language** and Mops routes it. The commands
are shortcuts for when you already know the name. Both columns do the same thing.

## Contents

- [Getting started](#getting-started)
- [Day-to-day](#day-to-day)
- [Research, brand and audience](#research-brand-and-audience)
- [Work with dates](#work-with-dates)
- [Bringing existing work in](#bringing-existing-work-in)
- [The team](#the-team)
- [Planning the work](#planning-the-work)
- [Getting a process right](#getting-a-process-right)
- [The toolkit](#the-toolkit)
- [Building without engineers](#building-without-engineers)
- [Trust and correctness](#trust-and-correctness)
- [Control and cost](#control-and-cost)
- [Setup, tools and access](#setup-tools-and-access)
- [When things go wrong](#when-things-go-wrong)
- [Something went wrong and you do not know whose fault it is](#something-went-wrong-and-you-do-not-know-whose-fault-it-is)
- [Beyond software](#beyond-software)

## Getting started

| Situation | Say | Runs |
|---|---|---|
| "I downloaded Multica — now what?" | *anything* | day zero: installed · current · signed in · workspace · daemon · runtimes, reported in one go with the fixes |
| "I don't know which of these I need" | *describe the situation* | three questions (what exists · what you want · who runs it) → init, join, import or a quick job (a bare question routes to `/multica-ops:consult` instead, by shape) |
| "I just want tasks done, no product manager" | *"just execute, I'll prioritise"* | **`/multica-ops:mops crew`** — executors and gates, no conductor, no roadmap ceremony |
| "I just have a question — not a thing to build" | *"what do you make of switching trackers?"* | **`/multica-ops:consult`** — an answer as an advisor; nothing created, no company set-up as a reflex |


| Situation | Just say | Or run |
|---|---|---|
| "I have an idea and no team yet" | *"I want to build a macOS app for X — set up a team"* | `/multica-ops:init` |
| "I already have a Multica workspace" | *"take over this workspace, see what's missing"* | `/multica-ops:join` |
| "Small job, I don't want a whole company" | *"quick job: a landing page, that's all"* | **`/multica-ops:quick`**, or `/multica-ops:init` → answer *quick job* |
| "Just use sensible defaults" | *"defaults"* | accepts the static defaults for what's left |
| "I'm tired of questions — you decide" | *"you decide"* | Mops proposes a full reasoned config as one list; you confirm or tweak; the owner-gated floor still waits at execution |

## Day-to-day

| Situation | Just say | Or run |
|---|---|---|
| "What's happening right now?" | *"status"* / *"what's stuck?"* | `/multica-ops:status` |
| "What's waiting on **me**?" | *"what needs me?"* | `/multica-ops:status` → the **needs-you** part: open requests with their age and what the wait costs |
| "I was away a week — catch me up" | *"I'm back — what happened?"* | `/multica-ops:status` opens with the countable line ("3 need you · 4 closed since Tuesday"), then needs-you / happened / what drifted — offered unprompted, not waited for |
| "I have a new feature idea" | *"add a feature: remember volume per app"* | `/multica-ops:feature …` |
| "The idea is still fuzzy" | *"I'm thinking about onboarding, not sure what yet"* | `/multica-ops:mops discovery …` |
| "Start the next thing" | *"what's next? go"* | `/multica-ops:next` |
| "Something's broken in production" | *"urgent: signup is failing on Safari"* | `/multica-ops:bug …` |
| "A user complained" | *"a customer says export is confusing"* | `/multica-ops:mops feedback …` |
| "Ship it" | *"release this"* / *"publish the episode"* | `/multica-ops:ship` |
| "Did it actually work?" | *"did the new onboarding move the metric?"* | `/multica-ops:mops measure` |

## Research, brand and audience

| Situation | Just say | Or run |
|---|---|---|
| "Is anyone else doing this?" | *"look into how competitors price this"* | `/multica-ops:mops research …` — cited findings land in `_ops/research/` |
| "Who are we even for?" | *"work out our segments and ICP"* | `/multica-ops:mops audience` |
| "We need a brand / ours feels dated" | *"we need an identity"* · *"our brand looks old"* | `/multica-ops:mops brand` |
| "Would experts tear this apart?" | *"have the experts review this spec"* | `/multica-ops:mops validate …` |
| "Where does that video say it?" | *"get me the transcript"* | the caption track first, the audio transcribed only when there is none — nobody pays GPU time for words already written down |
| "Turn this into a deck" | *"make the slides"* | markdown in the repo, so the deck diffs and reviews like everything else; a `.pptx` only when a person outside the repo must edit it |

## Work with dates

| Situation | Say | Runs |
|---|---|---|
| "This post goes out next Tuesday, not before" | *"schedule it for the 29th"* | date on the issue — no one starts it early |
| "What's due this week?" | `/multica-ops:next` | the queue, ordered by date where dates exist |
| "Make it faster" / "slow down, be careful" | `/multica-ops:mops pace fast` / `/multica-ops:mops pace careful` | fans work out more or less across agents — honest that a local-directory project can't parallelise regardless |
| "We're going to miss a deadline" | `/multica-ops:status` | the slip surfaces as a comment, with what moved |

## Bringing existing work in

| Situation | Say | Runs |
|---|---|---|
| "Our backlog is in Linear / Jira / a spreadsheet" | `/multica-ops:import` | mapping shown first, then issues created **unassigned** — nothing starts running by itself |
| "I imported my backlog and want to keep working exactly as before" | *"don't change anything, just execute"* | crew mode, the default offer after an import **when no conductor is standing** |
| "How do I get the new version?" | *"upgrade"* (or `/multica-ops:upgrade`) | plain language works on **any** install — even an install with no slash commands at all; it tells you the one line *you* run to update, then migrates the workspace, re-screens imported skills, and offers the CLI update **only when the team is idle** |
| "The import died halfway" | `/multica-ops:import` again | it skips what's already there and continues |
| "These imported tickets are one-liners nobody can act on" | *"bring them up to our standard"* | the quality pass: per issue, what's missing (why · success · DoD · dates) → rewrite/extend/leave/drop, in batches you approve |
| "Our client keeps filing in Linear and always will" | `/multica-ops:mops module` | the tracker bridge as a standing sync, with the direction of truth written down per field |
| "We run Multica on our own server" | *"we're self-hosted at …"* | `multica setup self-host` — the method is unchanged, but backups and server upgrades become yours |

## The team

| Situation | Just say | Or run |
|---|---|---|
| "I need a designer / marketer / pastry chef" | *"we need someone who can do packaging design"* | `/multica-ops:hire …` |
| "Bring a real person in" | *"invite anna@… as our designer"* | `/multica-ops:hire` → *person* |
| "This agent isn't pulling its weight" | *"is anyone idle?"* | `/multica-ops:audit` → utilization |
| "Who's on what?" | *"show me the team"* | `/multica-ops:mops team` |
| "This role is done / we over-hired" | *"we don't need the second DSP engineer"* | `/multica-ops:fire …` (agent → archived to the talent pool) |
| "Change someone's scope" | *"make the copywriter own localization too"* | `/multica-ops:mops update …` |

## Planning the work

| Situation | Just say | Or run |
|---|---|---|
| "What's the plan overall?" | *"show me the roadmap"* · *"re-score the backlog"* | `/multica-ops:mops roadmap` |
| "How does the product actually flow?" | *"map the product"* · *"what does a user walk through?"* | `/multica-ops:mops map` — the things and the moves in the product's own words; honest about what is not mapped yet |
| "This should wait / go sooner" | *"push crossfeed to the next release"* | `/multica-ops:mops move …` |
| "We're not doing this after all" | *"drop the MIDI thing"* | `/multica-ops:mops drop …` |
| "Reorganize who works with whom" | *"put the web engineer in the design squad"* | `/multica-ops:mops squad` |
| "Turn a whole capability on/off" | *"we don't need personas"* · *"turn on design QA"* | `/multica-ops:mops module …` |

## Getting a process right

| Situation | Say | Runs |
|---|---|---|
| "Design my app" (and you want it done properly, not guessed) | `/multica-ops:mops process` or just ask | discover IA → flows → low-fi → approve → high-fi, then find the tool for each step |
| "How should we run this kind of work?" | `/multica-ops:mops process <the work>` | the craft's real process, shown for you to cut/add, then tooled step by step |
| "It just improvised and it's bad" | `/multica-ops:mops process` on the redo | names the steps and the tool each needs, instead of one agent winging it |

## The toolkit

| Situation | Say | Runs |
|---|---|---|
| "We keep doing this by hand every week" | `/multica-ops:skill create` | a routine seen twice becomes a skill — drafted, tested on a fresh agent, compressed, attached |
| "I found a skill online, can we use it?" | `/multica-ops:skill import <url>` | screened for danger and hidden instructions, trimmed, attached with its source and date recorded |
| "Our skills have got bloated" | `/multica-ops:skill optimize` | fail-closed compression — commands and paths kept verbatim, reviewed by someone else; "can't compress this safely" is a valid answer |
| "This one turned out great, I want it in my other projects" | `/multica-ops:skill release` | de-identified, moved to your own repo outside the workspace (owner-confirmed), then re-imported so there's one source of truth |

## Building without engineers

| Situation | Say | Runs |
|---|---|---|
| "Can we just do the landing page in Framer?" | *"what would that cost us later?"* | the exit-cost check: can an agent operate it, can the work leave, what happens at the boundary |
| "I need an admin panel and don't want to build one" | `/multica-ops:feature` or *"what should we use?"* | self-hostable no-code (Appsmith, ToolJet, Budibase) — config lives in the repo |
| "Get me a first version of this screen fast" | *"prototype it"* | prompt-to-code (v0, Bolt, Lovable) emits real code, which agents then own, review and test |

## Trust and correctness

| Situation | Say | Runs |
|---|---|---|
| "An imported ticket tells the agent to grant itself access" | nothing — it surfaces | external text is data: it's quoted to you and not obeyed |
| "Who reviewed this? Not the person who wrote it, I hope" | `/multica-ops:audit` | flags gates where author and reviewer coincide |
| "Was that price still true?" | `/multica-ops:audit` or just ask | recorded facts carry a check-date and get re-verified before a decision |
| "Why didn't we go with X? I keep suggesting it" | *"what did we reject and why?"* | `_ops/DECISIONS.md` — append-only, with the evidence |
| "New agents keep re-learning the codebase" | *"write the architecture map"* | `_ops/ARCHITECTURE.md`, kept current like any doc |
| "I want people to find us through ChatGPT, not just Google" | `/multica-ops:mops research` or `/multica-ops:ship` | GEO: bot allowlist, FAQ schema, answer-first copy (STACKS) |

## Control and cost

| Situation | Just say | Or run |
|---|---|---|
| "I want to approve every feature" | *"ask me before each feature"* | `/multica-ops:mops reviews` |
| "Stop asking me about small things" | *"go non-stop, only ping me for money and deletes"* | `/multica-ops:mops autonomy auto` |
| "Sign me off on every generated image" | *"I review all images before they go out"* | `/multica-ops:mops reviews` |
| "What is this costing me?" | *"what did this release cost?"* | `/multica-ops:mops measure` · `/multica-ops:audit` |
| "Halt everything now" | *"stop"* | `/multica-ops:mops stop` |

## Setup, tools and access

| Situation | Just say | Or run |
|---|---|---|
| "Connect Figma / analytics / a data source" | *"hook up PostHog"* | `/multica-ops:mops connect …` |
| "Set my budget" | *"I can spend $50 a month, and I have $1k in credits until March"* | `/multica-ops:mops budget …` |
| "Let a teammate do more (or less)" | *"anna can start features but not spend"* | `/multica-ops:mops access …` |
| "Run something nightly" | *"sweep stuck issues every night"* | `/multica-ops:mops autopilot` |
| "I have several companies here" | *"switch to the snacks workspace"* | `/multica-ops:mops workspace …` |
| "Start / stop the machine" | *"start the daemon"* | `/multica-ops:mops start` · `/multica-ops:mops stop` |
| "Just run a raw CLI command" | *"show me the raw issue list"* | `/multica-ops:cli …` |
| "I changed things by hand" | *"I edited an agent, catch up"* | `/multica-ops:mops sync` |
| "What can you even do?" | *"what can you do?"* | `/multica-ops:mops` |

## When things go wrong

| Situation | Just say | Or run |
|---|---|---|
| "Everything froze overnight" | *"nothing is moving"* | `/multica-ops:recover` (session limits) |
| "Is anything broken in the setup?" | *"health check"* | `/multica-ops:mops health` |
| "An update made things worse" | *"roll back the last skill upgrade"* | `/multica-ops:upgrade` → rollback |
| "I want to move off this model provider" | *"move the team off Claude to X"* | `/multica-ops:mops switch …` |


## Something went wrong and you do not know whose fault it is

| Situation | Just say | What happens |
|---|---|---|
| "this is broken and I think it's your fault, not mine" | *"report this"* — or `/multica-ops:report` | **you are not asked to classify it.** From the evidence: your product's defect → the urgent lane · your workspace's friction → a field note, swept at the checkpoints PLAYBOOKS names, an issue on the **second** occurrence · **this skill's or Multica's** → packaged from evidence, de-identified, **written to a file outside your repository** with its path said and the routes named |
| "I hit this twice now" | *"it happened again"* | the second occurrence is what earns an issue — **once is a note, twice is a pattern**, and both occasions are named in it |
| "I don't want to file anything publicly" | *"keep it"* | **a complete answer.** The file stays where it was written, the friction is recorded, and it can go later |

## Beyond software

The verbs are domain-neutral — `/multica-ops:ship` is the go-live moment whatever you make.

| Project | What `/multica-ops:ship` means | What `/multica-ops:bug` means |
|---|---|---|
| macOS app | build, notarize, release notes, tag | crash or regression |
| YouTube channel | publish the episode + thumbnail + subtitles | wrong title live, bad cut |
| Snack brand | send the production batch | mislabelled batch, recall |
| Newsletter | send the issue | broken link in a sent email |
