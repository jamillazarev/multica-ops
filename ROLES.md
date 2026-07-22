# Roles — typical agents, their skills, and how to create them

Templates, not a mandate: create only the roles the interview named. Every agent gets
the **project guide skill + find-skills** (invariants) on top of its row below.

## Skill sources (import URLs)

```sh
multica skill import --url <URL> --on-conflict skip
```
| Pack | URL prefix | Notes |
|---|---|---|
| find-skills | `github.com/vercel-labs/skills/tree/main/skills/find-skills` | invariant, every agent |
| Matt Pocock engineering | `github.com/mattpocock/skills/tree/main/skills/engineering/<name>` | implement, code-review, tdd, diagnosing-bugs, codebase-design, domain-modeling, research, resolving-merge-conflicts, wayfinder, triage, to-tickets, grill-with-docs, prototype |
| Matt Pocock productivity | `github.com/mattpocock/skills/tree/main/skills/productivity/<name>` | handoff, grill-me, writing-great-skills |
| Anthropic | `github.com/anthropics/skills/tree/main/skills/<name>` | docx, pdf, xlsx, brand-guidelines, canvas-design, frontend-design, theme-factory, webapp-testing, skill-creator |
| emilkowalski (design/motion) | `github.com/emilkowalski/skills/tree/main/skills/<name>` | apple-design, animation-vocabulary, improve-animations, review-animations, emil-design-eng |
| Corey Haines (marketing) | `github.com/coreyhaines31/marketingskills/tree/main/skills/<name>` | copywriting, copy-editing, content-strategy, seo-audit, analytics |
| obra/superpowers | `github.com/obra/superpowers/tree/main/skills/<name>` | verification-before-completion, using-git-worktrees, systematic-debugging |
| impeccable (UI craft) | `github.com/pbakaus/impeccable/tree/main/plugin/skills/impeccable` | root 502s; this exact path works |
| Context7 (live docs) | `context7-skill` (github.com/netresearch/context7-skill) or the Context7 MCP | **invariant for any agent writing version-sensitive code** — pulls current library/framework/OS-SDK docs so agents don't build from a stale training cutoff |
| clawhub.ai (searchable) | find by name: `multica skill search "<name>"`; broader discovery: `awesome-agent-skills` (github.com/VoltAgent/awesome-agent-skills) + `awesome-{topic}` search | Storybook, Storybook Component Doc, Component Library Audit, Design System Patterns, SVG, Logo Creator, Svg Animation — design-system & vector pack; Security Review, Frontend Security Review, OWASP Top 10 AI, VibeSafe — security pack |
| extract-design-system | `github.com/arvindrk/extract-design-system/tree/main/skills/extract-design-system` | |
| taste-skill / brandkit | `skills.sh/leonxlnx/taste-skill/brandkit` | brand-from-zero: identity, palette, voice — for Brand Designer when no brand exists |
| caveman (token economy) | `skills.sh/juliusbrussee/caveman/caveman` | compressed reasoning/output; attach to ALL agents, default lite mode |
| phuryn pm-skills | `github.com/phuryn/pm-skills/tree/main/<pack>/skills/<name>` | packs: pm-execution (prioritization-frameworks, create-prd, pre-mortem, release-notes, user-stories, okrs…), pm-product-discovery (prioritize-features, metrics-dashboard, interview-script, opportunity-solution-tree…), pm-product-strategy (lean-canvas, pricing-strategy, product-vision…), pm-marketing-growth (north-star-metric, positioning-ideas, value-prop-statements, marketing-ideas, product-name), pm-go-to-market (gtm-strategy, growth-loops, ideal-customer-profile, competitive-battlecard, beachhead-segment), pm-data-analytics (ab-test-analysis, cohort-analysis, sql-queries) |

URL must point at the folder containing `SKILL.md` (repo root 502s — BOOTSTRAP §4).
The `skills.sh/{owner}/{repo}/{skill}` form also works and resolves the folder itself.
Bake the common set from this file into roles at creation (deterministic); **find-skills
covers the long tail** — agents discover anything else and ask the conductor to import.

## Role templates

`handoff` for everyone is cheap insurance (compact context before a session dies).
Model tiers: **top** = strongest reasoning model, **mid** = balanced, **text** = a
cheap/text-oriented runtime (translations, boilerplate legal).

| Role | Squad | Model tier | Recommended skills | Notes |
|---|---|---|---|---|
| **Conductor / Product Manager** | — (project lead) | top | grill-with-docs, to-tickets, triage, wayfinder, research, skill-creator, **prioritization-frameworks, create-prd, prioritize-features, pre-mortem, release-notes, job-stories, user-stories**, handoff | owns intake→spec→stages→accept; git/GitHub rights; owns `skill import`; prioritizes the backlog with explicit frameworks (ICE by default), pre-mortems risky features |
| **Engineer** (per platform: core/app/web) | Eng squad(s) | top for core, mid for app/web | implement, code-review, tdd, diagnosing-bugs, codebase-design, domain-modeling, resolving-merge-conflicts, using-git-worktrees, verification-before-completion, handoff | ≥2 per squad enables peer review |
| **Web Engineer** | Eng/Web | mid | + frontend-design, theme-factory, webapp-testing, seo-audit, animation set | if a site/landing exists |
| **Product Designer** | Design (leader) | mid | impeccable, apple-design (or platform equivalent), animation-vocabulary, improve/review-animations, extract-design-system, canvas-design, prototype, **Storybook Component Doc, Design System Patterns** (when the DS module is on), handoff | leads design squad; runs Design QA gate; **design-system curator** |
| **Brand Designer** | Design | mid | brand-guidelines, canvas-design, theme-factory, extract-design-system, apple-design, **brandkit** (when no brand exists yet), **SVG, Logo Creator, Svg Animation** (vector work), handoff | identity, icons, visuals; brandkit bootstraps identity from zero; owns `/brand` artifacts |
| **Design System Engineer** (opt-in, larger digital products) | Eng or Design | mid | implement, Storybook, Storybook Component Doc, Component Library Audit, code-review, handoff | builds/maintains tokens & the component catalog in code; the curator reviews |
| **UX Researcher** | Design | top | grill-me, research, prototype, review-animations, handoff | usability/a11y reviewer, injection gate |
| **QA Engineer** | Quality (leader) | top | code-review, tdd, diagnosing-bugs, webapp-testing, verification-before-completion, handoff | external review gate for every code feature |
| **Security Engineer** | Quality | top | research, diagnosing-bugs, verification-before-completion, **Security Review, Frontend Security Review, OWASP Top 10 AI (when AI features), VibeSafe** (pre-flight for agent-written code), handoff | injection gate: privacy/entitlements/licenses/secrets; runs the security defaults from STACKS |
| **Copywriter / Localization** | Content (leader) | text | copywriting, copy-editing, content-strategy, seo-audit, **positioning-ideas, value-prop-statements**, docx, handoff | EN source + translations; positioning & value props for landing copy |
| **Legal Counsel** | Content | text | docx, pdf, research, handoff | policies, terms, compliance pages |
| **Marketing Manager** | — (cross, or Content) | mid | marketing-ideas, positioning-ideas, value-prop-statements, product-name, north-star-metric, gtm-strategy, growth-loops, ideal-customer-profile, competitive-battlecard, beachhead-segment, + Corey Haines pack (social, emails, ads, launch, cold-email, referrals), handoff | GTM strategy pre-launch; post-launch owns channels. **Social automation**: content calendar as issues; a scheduled **autopilot** drafts posts on cadence; publishing via the platform's API/scheduler tools (import via find-skills) with human approval until trust is earned |
| **Domain / Market / Tech Expert** (opt-in) | Experts squad | top | research, critique, brainstorming, handoff | advisors, not executors: pulled into specs, discovery, acceptance by `@`-mention; composition per project — see "Experts squad" below |
| **Persona** (opt-in) | Personas squad | cheap | handoff | user simulation built from research; used in usability passes and Design QA walkthroughs — see "Personas squad" below |
| **Analyst** | — (cross) | top | analytics, xlsx, research, **north-star-metric, metrics-dashboard, ab-test-analysis, cohort-analysis**, handoff | event taxonomy, funnels, north-star, cohorts/AB; never PII/audio |

Create:
```sh
multica agent create --name "<Role>" --model <model-id> --runtime-id <rt> \
  --visibility workspace --max-concurrent-tasks 3 \
  --description "<one line>" --instructions "<language rule + role + routing>" --output json
multica agent skills add <agent-id> --skill-ids <guide>,<find-skills>,<role-skills…>
```
Instruction skeleton per agent: (1) the language rule first and absolute — including
the very first greeting; (2) the role and its slice of the codebase/product; (3) who
reviews it and whom it hands off to; (4) leaders additionally get the routing map via
`multica squad update --instructions`.

## Avatars

Ask which style; all are name-stable and upload the same way
(`multica agent avatar <id> --file <png>`). **Mops-in-Multica's avatar matches the
chosen library**: DiceBear → `mops-avatar-less-details.png`, Multiavatar →
`mops-avatar-multiavatar.png`, memoji → `mops-avatar-memoji.png` (all in
[assets/](assets/)).

- **DiceBear** (default; default style `notionists` unless the user picks another —
  the API has dozens):
  `https://api.dicebear.com/9.x/notionists/png?seed=<AgentName>&size=256&scale=130&backgroundColor=<hex>`
  — `scale=130` keeps faces from looking tiny inside avatar circles, and give **each
  squad its own `backgroundColor`** (one hex per squad, e.g. Audio `b6e3f4`, Design
  `ffd5dc`, Quality `c1f4d4`) so the board reads by team at a glance.
- **Multiavatar** (colorful, 12B variants, open source): `https://api.multiavatar.com/<AgentName>.png`.
- **Tapback memojis** (Apple-style, github.com/wimell/tapback-memojis): cleanest look,
  finite set (watch collisions on big teams); the PNGs carry generous transparent
  padding — **trim + zoom ~20% before upload** (`sips`/ImageMagick) or faces read tiny.
- **Own images**: any square PNG per agent.

## Autopilots (usually "later")

Autopilots are cron/webhook only — they never react to "a stage finished". Offer, and
if the user says "later", skip: they can add them through the assistant anytime.
```sh
multica autopilot create --title "<name>" --mode run_only --agent "<Agent>" \
  --description "<task prompt>"
multica autopilot trigger-add <id> --cron "0 9 * * 1-5" --timezone <tz>
```
Useful ones: a nightly sweep that reruns stalled issues; a GitHub-webhook trigger on
merged PRs.

## Baseline kit — what every agent gets, whatever the role

Before any role-specific skill, every agent is given the same floor:

- **The project guide skill** — language/tone, DoD, handoff = @mention, escalation,
  docs-follow-decisions, system-follows-solutions, brand voice, limit/cancel conventions,
  which modules exist. (This is the **cached prefix** — batch its edits, see REFERENCE §12.)
- **find-skills** — so the agent can close its own capability gaps instead of stalling.
- **handoff** — compact the context before a session dies; cheap insurance for everyone.
- **caveman** (lite) — terse reasoning/output; token economy is measurable, not cosmetic.
- **Context7** — for any role that writes version-sensitive code or config: current
  library/SDK/OS docs instead of a frozen training cutoff.
- **The docs it must know**: `ROADMAP.md` · `TEAM.md` · `TOOLING.md` (tools, access,
  target versions) · `LATER.md`, plus `brand/` and `design-system/` when those modules
  are on. Referenced from the guide, not copy-pasted into instructions.

## Any role from conversation — the role-builder

The catalog above is a seed, not a ceiling. For any role the interview names that isn't
here (pastry chef, accountant, scrum master, hardware engineer…), build the **whole
package — skills · tooling · resources**, not just skills:

1. **Research the craft.** Current best practices, 2–3 sources; what a competent
   practitioner actually does day to day, and what they'd be blamed for missing.
2. **Skills.** `multica skill search` (clawhub/skills.sh) · `find-skills` ·
   **`awesome-{craft}`** on GitHub.
3. **Tooling.** The role's instruments, not just its knowledge: check the **MCP
   registries first** (mcpservers.org · mcp.so · awesome-mcp-servers; mcpmarket
   leaderboards for the maintained ones), then CLIs/APIs. Wire via `mcp_config` /
   `custom-env`, register in `docs/TOOLING.md` — and obey the **selection ladder**
   (free → OSS → self-host → in-repo → agent-drivable).
4. **Resources.** What the role must consult: standards bodies, official docs, datasets,
   and the **reference galleries in STACKS** (design/brand/UX). Links go into its
   instructions; data access via `mcp_config`.
5. **Propose the package** (model tier · skills · tooling · resources · squad) → create
   on approval → record in `TEAM.md` and `TOOLING.md`.

**Search came back empty? Broaden — don't give up at the first miss:**
1. **Rephrase into the industry's own words** — practitioners' terms, in English, since
   that is where the catalogs are. This matters most when the working language isn't
   English: a title like *видеомонтажёр* finds nothing, *video editing · post-production*
   finds everything; likewise *продажник* → *sales development · outbound*.
2. **Go one level up** to the parent domain (`awesome-{parent}`), then scan its sections.
3. **Adjacent crafts** that share tools (a pastry chef ↔ food safety, recipe development,
   kitchen ops).
4. **Decompose the role into tasks** and search per task — tooling usually exists per
   task even when the job title has no list.
5. Only then **draft a small skill with skill-creator** from step 1's research — and log
   the gap in `LATER.md` so it gets revisited when the ecosystem catches up.

Designers and engineers join from the first decisions (discovery, spec review) — not
only at their build stage. Bake "tokens / design system / Storybook" style practices in
via step 1's research, not by hardcoding this file.

## Experts squad (opt-in, composition per project)

Advisors, not executors: they review decisions, not produce artifacts. Offer 2–4
picked for the domain (examples: Domain Expert — audio/confectionery/…, Market &
Growth Expert, Tech/Design Architect, Compliance Expert). Group them as an **Experts
squad** (leader = the most central expert); they're pulled into specs, discovery, and
acceptance via `@`-mention. Load each with the project's reference resources. The
user may decline; they can be added any time later.

## Personas squad (opt-in, user simulation)

Built AFTER research exists: the PM/UX turn audience research into 2–3 personas
(documents first), then — if the user opts in — matching agents whose instructions
are the persona (goals, habits, frustrations, vocabulary). Grouped as a **Personas
squad**; used in usability passes and Design QA ("persona walks the flow" runs), not
in the build pipeline. Cheap models suffice. Decline-able, addable later.
