# Use cases — situation → what to say

You never need a command: **say it in plain language** and Mops routes it. The commands
are shortcuts for when you already know the name. Both columns do the same thing.

## Getting started

| Situation | Just say | Or run |
|---|---|---|
| "I have an idea and no team yet" | *"I want to build a macOS app for X — set up a team"* | `/init` |
| "I already have a Multica workspace" | *"take over this workspace, see what's missing"* | `/join` |
| "Small job, I don't want a whole company" | *"quick job: a landing page, that's all"* | `/init` → answer *quick job* |
| "Just use sensible defaults, don't interview me" | *"defaults"* | — |

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
