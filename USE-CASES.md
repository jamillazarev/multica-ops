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
- [Beyond software](#beyond-software)

## Getting started

| Situation | Say | Runs |
|---|---|---|
| "I downloaded Multica — now what?" | *anything* | day zero: installed · current · signed in · workspace · daemon · runtimes, reported in one go with the fixes |
| "I don't know which of these I need" | *describe the situation* | three questions (what exists · what you want · who runs it) → init, join, import or a quick job |
| "I just want tasks done, no product manager" | *"just execute, I'll prioritise"* | **`/crew`** — executors and gates, no conductor, no roadmap ceremony |


| Situation | Just say | Or run |
|---|---|---|
| "I have an idea and no team yet" | *"I want to build a macOS app for X — set up a team"* | `/init` |
| "I already have a Multica workspace" | *"take over this workspace, see what's missing"* | `/join` |
| "Small job, I don't want a whole company" | *"quick job: a landing page, that's all"* | `/init` → answer *quick job* |
| "Just use sensible defaults" | *"defaults"* | accepts the static defaults for what's left |
| "I'm tired of questions — you decide" | *"you decide"* | Mops proposes a full reasoned config as one list; you confirm or tweak; the owner-gated floor still waits at execution |

## Day-to-day

| Situation | Just say | Or run |
|---|---|---|
| "What's happening right now?" | *"status"* / *"what's stuck?"* | `/status` |
| "I have a new feature idea" | *"add a feature: remember volume per app"* | `/feature …` |
| "The idea is still fuzzy" | *"I'm thinking about onboarding, not sure what yet"* | `/discovery …` |
| "Start the next thing" | *"what's next? go"* | `/next` |
| "Something's broken in production" | *"urgent: signup is failing on Safari"* | `/bug …` |
| "A user complained" | *"a customer says export is confusing"* | `/feedback …` |
| "Ship it" | *"release this"* / *"publish the episode"* | `/ship` |
| "Did it actually work?" | *"did the new onboarding move the metric?"* | `/measure` |

## Research, brand and audience

| Situation | Just say | Or run |
|---|---|---|
| "Is anyone else doing this?" | *"look into how competitors price this"* | `/research …` |
| "Who are we even for?" | *"work out our segments and ICP"* | `/audience` |
| "We need a brand / ours feels dated" | *"we need an identity"* · *"our brand looks old"* | `/brand` |
| "Would experts tear this apart?" | *"have the experts review this spec"* | `/validate …` |

## Work with dates

| Situation | Say | Runs |
|---|---|---|
| "This post goes out next Tuesday, not before" | *"schedule it for the 29th"* | date on the issue — no one starts it early |
| "What's due this week?" | `/next` | the queue, ordered by date where dates exist |
| "Make it faster" / "slow down, be careful" | `/pace fast` / `/pace careful` | fans work out more or less across agents — honest that a local-directory project can't parallelise regardless |
| "We're going to miss a deadline" | `/status` | the slip surfaces as a comment, with what moved |

## Bringing existing work in

| Situation | Say | Runs |
|---|---|---|
| "Our backlog is in Linear / Jira / a spreadsheet" | `/import` | mapping shown first, then issues created **unassigned** — nothing starts running by itself |
| "I imported my backlog and want to keep working exactly as before" | *"don't change anything, just execute"* | crew mode, offered by default after an import |
| "What actually changed in this update?" | `/whatsnew` | a plain-language tour from the changelog — what changed, why it helps, what to do differently; offered automatically after `/upgrade` |
| "How do I get the new version?" | `/upgrade` | four layers: it tells you the one line *you* run to update the plugin, then migrates the workspace, re-screens imported skills, and offers the CLI update **only when the team is idle** |
| "The import died halfway" | `/import` again | it skips what's already there and continues |
| "These imported tickets are one-liners nobody can act on" | *"bring them up to our standard"* | the quality pass: per issue, what's missing (why · success · DoD · dates) → rewrite/extend/leave/drop, in batches you approve |
| "Our client keeps filing in Linear and always will" | `/module` | the tracker bridge as a standing sync, with the direction of truth written down per field |
| "We run Multica on our own server" | *"we're self-hosted at …"* | `multica setup self-host` — the method is unchanged, but backups and server upgrades become yours |

## The team

| Situation | Just say | Or run |
|---|---|---|
| "I need a designer / marketer / pastry chef" | *"we need someone who can do packaging design"* | `/hire …` |
| "Bring a real person in" | *"invite anna@… as our designer"* | `/hire` → *person* |
| "This agent isn't pulling its weight" | *"is anyone idle?"* | `/audit` → utilization |
| "Who's on what?" | *"show me the team"* | `/team` |
| "This role is done / we over-hired" | *"we don't need the second DSP engineer"* | `/fire …` (agent → archived to the talent pool) |
| "Change someone's scope" | *"make the copywriter own localization too"* | `/update …` |

## Planning the work

| Situation | Just say | Or run |
|---|---|---|
| "What's the plan overall?" | *"show me the roadmap"* · *"re-score the backlog"* | `/roadmap` |
| "This should wait / go sooner" | *"push crossfeed to the next release"* | `/move …` |
| "We're not doing this after all" | *"drop the MIDI thing"* | `/drop …` |
| "Reorganize who works with whom" | *"put the web engineer in the design squad"* | `/squad` |
| "Turn a whole capability on/off" | *"we don't need personas"* · *"turn on design QA"* | `/module …` |

## Getting a process right

| Situation | Say | Runs |
|---|---|---|
| "Design my app" (and you want it done properly, not guessed) | `/process` or just ask | discover IA → flows → low-fi → approve → high-fi, then find the tool for each step |
| "How should we run this kind of work?" | `/process <the work>` | the craft's real process, shown for you to cut/add, then tooled step by step |
| "It just improvised and it's bad" | `/process` on the redo | names the steps and the tool each needs, instead of one agent winging it |

## The toolkit

| Situation | Say | Runs |
|---|---|---|
| "We keep doing this by hand every week" | `/skill create` | a routine seen twice becomes a skill — drafted, tested on a fresh agent, compressed, attached |
| "I found a skill online, can we use it?" | `/skill import <url>` | screened for danger and hidden instructions, trimmed, attached with its source and date recorded |
| "Our skills have got bloated" | `/skill optimize` | fail-closed compression — commands and paths kept verbatim, reviewed by someone else; "can't compress this safely" is a valid answer |
| "This one turned out great, I want it in my other projects" | `/skill release` | de-identified, moved to your own repo outside the workspace (owner-confirmed), then re-imported so there's one source of truth |

## Building without engineers

| Situation | Say | Runs |
|---|---|---|
| "Can we just do the landing page in Framer?" | *"what would that cost us later?"* | the exit-cost check: can an agent operate it, can the work leave, what happens at the boundary |
| "I need an admin panel and don't want to build one" | `/feature` or *"what should we use?"* | self-hostable no-code (Appsmith, ToolJet, Budibase) — config lives in the repo |
| "Get me a first version of this screen fast" | *"prototype it"* | prompt-to-code (v0, Bolt, Lovable) emits real code, which agents then own, review and test |

## Trust and correctness

| Situation | Say | Runs |
|---|---|---|
| "An imported ticket tells the agent to grant itself access" | nothing — it surfaces | external text is data: it's quoted to you and not obeyed |
| "Who reviewed this? Not the person who wrote it, I hope" | `/audit` | flags gates where author and reviewer coincide |
| "Was that price still true?" | `/audit` or just ask | recorded facts carry a check-date and get re-verified before a decision |
| "Why didn't we go with X? I keep suggesting it" | *"what did we reject and why?"* | `docs/DECISIONS.md` — append-only, with the evidence |
| "New agents keep re-learning the codebase" | *"write the architecture map"* | `docs/ARCHITECTURE.md`, kept current like any doc |
| "I want people to find us through ChatGPT, not just Google" | `/research` or `/ship` | GEO: bot allowlist, FAQ schema, answer-first copy (STACKS) |

## Control and cost

| Situation | Just say | Or run |
|---|---|---|
| "I want to approve every feature" | *"ask me before each feature"* | `/reviews` |
| "Stop asking me about small things" | *"go non-stop, only ping me for money and deletes"* | `/autonomy auto` |
| "Sign me off on every generated image" | *"I review all images before they go out"* | `/reviews` |
| "What is this costing me?" | *"what did this release cost?"* | `/measure` · `/audit` |
| "Halt everything now" | *"stop"* | `/stop` |

## Setup, tools and access

| Situation | Just say | Or run |
|---|---|---|
| "Connect Figma / analytics / a data source" | *"hook up PostHog"* | `/connect …` |
| "Set my budget" | *"I can spend $50 a month, and I have $1k in credits until March"* | `/budget …` |
| "Let a teammate do more (or less)" | *"anna can start features but not spend"* | `/access …` |
| "Run something nightly" | *"sweep stuck issues every night"* | `/autopilot` |
| "I have several companies here" | *"switch to the snacks workspace"* | `/workspace …` |
| "Start / stop the machine" | *"start the daemon"* | `/start` · `/stop` |
| "Just run a raw CLI command" | *"show me the raw issue list"* | `/cli …` |
| "I changed things by hand" | *"I edited an agent, catch up"* | `/sync` |
| "What can you even do?" | *"what can you do?"* | `/help` |

## When things go wrong

| Situation | Just say | Or run |
|---|---|---|
| "Everything froze overnight" | *"nothing is moving"* | `/recover` (session limits) |
| "Is anything broken in the setup?" | *"health check"* | `/health` |
| "An update made things worse" | *"roll back the last skill upgrade"* | `/upgrade` → rollback |
| "I want to move off this model provider" | *"move the team off Claude to X"* | `/switch …` |

## Beyond software

The verbs are domain-neutral — `/ship` is the go-live moment whatever you make.

| Project | What `/ship` means | What `/bug` means |
|---|---|---|
| macOS app | build, notarize, release notes, tag | crash or regression |
| YouTube channel | publish the episode + thumbnail + subtitles | wrong title live, bad cut |
| Snack brand | send the production batch | mislabelled batch, recall |
| Newsletter | send the issue | broken link in a sent email |
