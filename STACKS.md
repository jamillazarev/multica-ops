# Stacks — default services & libraries for digital products

Seeds with generous free tiers, not a closed menu — **every choice accepts "other"**
(the user names it, you research and wire it). Per service: connect-or-create
(BOOTSTRAP §12), access via `mcp_config`/`custom-env`, destructive/outward actions
still gated by the owner. Offer only what the interview's needs actually name.
**Free tier is the default plan** — a ✅ means the project can genuinely start (and often
stay) on it; `—` means usage- or purchase-priced from the first call.

## Services by need

| Need | Default | What you'd use it for | Free tier |
|---|---|---|---|
| **Version control** | GitHub | repo = company monorepo; PRs are the conveyor's merge gate; webhooks feed autopilots | ✅ |
| **Backend / DB** | Supabase | Postgres + auth + storage + realtime + edge functions in one; RLS for permissions; good MCP | ✅ |
| **All-in-one client DB** | InstantDB | Firebase-alternative: realtime relational DB + auth + presence + storage; CLI-first, built for AI agents to drive without dashboards; offline-first multiplayer UIs | ✅ |
| **Offline-first sync** | PowerSync | syncs Postgres/MongoDB/MySQL/SQL Server into in-app SQLite; kills hand-rolled state-over-API plumbing; web, RN/Expo, Flutter, Swift, Kotlin | ✅ |
| **Deploy / hosting** | Vercel (web) · **Railway** (backends/workers/DBs) | web apps & sites with preview deploys per PR (Design QA loves them), edge functions, cron; Railway when you need long-running services, queues, or a hosted Postgres/Redis beyond serverless | ✅ |
| **CI/CD & release automation** | **GitHub Actions** + the **official GitHub MCP server** | build/test/deploy on push/PR — and, via MCP, agents **read workflow runs, analyze build failures, manage releases** (the feedback loop that lets the QA gate fix its own red builds). Alternatives with agent-readable CI: **CircleCI** (official MCP — pipeline graph, build history, failure logs, artifacts) · **Buildkite** (heavy parallelism, managed Anthropic model provider) · **Dagger** (containerized pipelines that run identically locally and in CI, so an agent reproduces a failure on its own machine). Publishing: **Fastlane** (OSS, store submission/signing) · **EAS Build/Submit** (Expo) · Xcode Cloud · electron-builder / tauri-action + notarization (desktop). Versioning: Changesets or semantic-release. Gates the launch checklist | ✅ (free for public repos; private repos are build-minute capped — the ceiling that bites first) |
| **CDN & media delivery** | **Cloudflare** (free tier CDN + R2 storage with **no egress fees**) · **bunny.net** (cheap, pay-as-you-go, image optimizer + video) · **jsDelivr** (free for public/OSS assets) | serving images, video, downloads and static assets fast and cheaply — egress is what actually bills you, so start with a no-egress-fee or free-tier origin; Vercel/Netlify already CDN their own deploys, this is for **your media**, which is where the assets-home decision lands | ✅ (Cloudflare, jsDelivr) |
| **Domains** | Namecheap | buy domains cheap; DNS can stay here or move | — |
| **DNS** | Vercel DNS *or* Cloudflare | if the site lives on Vercel, its DNS is simplest (per-subdomain, zero config); Cloudflare when you want a proxy/WAF/workers in front or many non-Vercel services | ✅ |
| **Payments** | Stripe | cards/subscriptions/invoices, full control (needs your own tax handling); for solo digital products a Merchant-of-Record may fit better (MoR handles VAT): **Polar** (dev-first, OSS-friendly) · Lemon Squeezy · Paddle; pricing/entitlements layer over Stripe → **Autumn** (useautumn.com) | — |
| **Auth + billing** | Clerk | drop-in auth UI (social, MFA, orgs) + subscription billing glued to it; fastest path for SaaS | ✅ |
| **Email** | Resend | transactional + marketing sends from code; React Email templates | ✅ |
| **Analytics** | PostHog | product events, funnels, session replay, feature flags, A/B; pairs with the Analyst role's whitelist. Scale-up path: **Jitsu** (OSS event pipeline) → **ClickHouse** (OSS warehouse) when volumes outgrow product analytics | ✅ |
| **Error tracking** | Sentry | crash/error reports with releases + sourcemaps; wire alerts to an autopilot triage sweep | ✅ |
| **Cache / queues** | Upstash | serverless Redis + QStash (queues/cron over HTTP); rate limits, sessions, job fan-out | ✅ |
| **Vectors / memory / recall** (for the *product*) | pgvector (Supabase) for small; Pinecone for scale; mem0 / Supermemory (managed agent memory) or Memori (SQL-native) for per-user recall; Memgraph when **relationships** dominate | RAG, semantic search, long-term/per-user memory, a knowledge graph — only if the app you're building needs it. Pick by shape: vector = similarity, graph = relationships | mixed |
| **Dashboards** (product + team) | **Metabase** or **Grafana** (both OSS, self-host) · PostHog's built-in boards for product events · repo-first: a generated `docs/analytics/` page | one place answering "is it working, and what did it cost": product metrics (North Star + supporting, funnels) **and team metrics** (throughput, cycle time, cost per feature from the ledger, limit-killed runs). Start with the analytics tool's own boards; add Metabase/Grafana when you need to join sources or track team numbers next to product ones |
| **Product docs & API reference** | repo-first docs site (VitePress et al.) · **Mintlify** (managed, free tier) · **Scalar** (free OpenAPI API reference) | user/product documentation and a live API reference; repo stays the source of truth, managed hosting is the mirror | ✅ |
| **Short links & attribution** | **Dub** (OSS, free tier) · short.io | campaign/marketing links with UTM + click analytics; feeds `/measure` alongside product metrics | ✅ |
| **Design system catalog** | Storybook | living catalog of UI components + their states; tokens live as files in the repo (CSS vars / style-dictionary) and Storybook renders them; native apps → SwiftUI Previews / a catalog target; non-digital → template library or brand book in `docs/design-system/`; **official Storybook MCP** (github.com/storybookjs/mcp) lets agents drive the catalog directly | ✅ |
| **i18n / localization** | **Weblate** (OSS, self-host) · Crowdin / Lokalise (free tiers) · i18next / ICU MessageFormat in code | translation workflow + the library that actually formats plurals/dates; agents translate, humans review via `/reviews`; string extraction belongs to the build, not to copy-paste |
| **Support & feedback inbox** | **Chatwoot** (OSS, self-host) · Crisp (free tier) | where `/feedback` signal physically arrives — chat/email/social in one inbox; wire an autopilot to triage it into the backlog |
| **Status page & uptime** | **Uptime Kuma** (OSS, self-host) · BetterStack / Instatus (free tiers) | post-launch essentials: synthetic checks on key flows + a public status page; failures feed `/measure` and `/health` |
| **Privacy & compliance** | **Klaro** (OSS cookie consent) · policy generators · a DPA template; PostHog/Plausible self-host when data must stay yours | GDPR-style basics for anything public: consent, privacy policy, data-processing agreements, retention. Legal Counsel owns the texts, Security the implementation |
| **SEO & discoverability** | Google Search Console (free) · Ahrefs Webmaster Tools (free) · sitemap + schema.org in the build; deeper tactics: `awesome-seo` | complements the `seo-audit` skill with actual measurement; run before and after `/ship` |
| **Visual / node-based pipelines** | **ComfyUI** (OSS — image/video generation graphs) · **n8n** (fair-code, automation with AI steps) · **Flowise** · **Langflow** · **Dify** (OSS LLM apps + RAG + observability) · **Rivet** (OSS, local, embeddable agent graphs) | two distinct uses: (a) an **asset pipeline** the design squad runs (ComfyUI for brand/marketing imagery at volume), (b) **AI features inside the product you're building**. All self-hostable and free |
| **AI gateway** | OpenRouter | one API to 400+ models / 70+ providers, OpenAI-SDK-compatible; fallbacks when a provider is down; per-model data policies; credit-based | — |

**Selection ladder — the default preference order.** When several options cover the
need, prefer in this order, and say out loud when you skip a rung:

1. **Free** — no card, no ceiling surprise (then: name the ceiling, below).
2. **Open source** — inspectable, forkable, no vendor exit tax.
3. **Self-hostable / local** — runs on the owner's machine or box; no third party in the
   loop, nothing to leak.
4. **Embeddable in the repo** — config/tokens/templates live as files under git, so the
   repo stays the source of truth and everything is versioned and reviewable.
5. **Agent-drivable** — an **MCP server**, a clean CLI, or a documented API, so agents
   operate it without a human clicking a dashboard.

A managed or paid option is fine — it just has to **earn the exception** with a stated
reason (the free/OSS one can't do it, ops burden outweighs control, compliance demands
it). Record the reason in `docs/TOOLING.md` next to the tool.

Decision rules the assistant applies:
- **Fewest services that cover the need** — Supabase already gives auth/storage/
  pgvector; add Clerk/Pinecone only when its specific strength is needed.
- **MoR vs Stripe**: selling globally as a solo/indie → MoR handles sales tax;
  platform features/marketplaces → Stripe.
- **DNS**: site on Vercel → Vercel DNS; otherwise Cloudflare.
- **Product memory ≠ team memory.** The memory row above is for the *product you build*.
  The **agent team's own** memory is the **repo + issues** (git-versioned, the source of
  truth) — never add a memory store as a second source. If a very large history ever needs
  semantic recall, add a vector index as a **derived index rebuilt from the repo/issues**,
  never something agents write to independently.
- **Need an API or a free tier?** Check **public-apis** (github.com/public-apis/public-apis)
  for a ready data/API source and **free-for.dev** for free-tier services before paying —
  both pair with the free-first rule here.
- **Free tier first — and name the ceiling.** Default to the free plan, and when
  proposing a service **say where its free tier ends** in the unit that will actually bite
  (build minutes, MAU, rows/storage, events, seats, emails/day) and what happens at that
  edge — throttle, hard stop, or auto-charge. Record the chosen plan + that ceiling in
  `docs/TOOLING.md`; `/health` watches headroom and `/audit` flags what's close. Crossing
  into paid is **spend** — owner-gated like any other, never a silent upgrade.
- **Node-based tools build the product, not the team.** ComfyUI/Rivet/Flowise/Dify are
  for **asset pipelines and the AI features you ship** — never a second orchestration
  layer over Multica. Multica *is* the agent framework here (agent = model + skills +
  instructions + runtime; orchestration = squads + stage barriers + @mentions); wiring a
  visual flow engine on top would create a competing source of truth, the same
  anti-pattern as a second memory store. Product-side, they're a normal stack choice.
- **Pick CI your agents can read.** For an agent team the decisive feature isn't build
  speed, it's whether failures come back as **structured, fetchable context** (an MCP
  server or a clean logs API). A pipeline agents can't read turns every red build into a
  human errand — exactly the dispatcher trap this skill exists to remove.
- **Verify currency at wiring time.** These are seeds, and the market moves — before
  connecting any of them, sanity-check it's still the right pick for this project (same
  research-first rule as assets-home in the interview).
- Anything here can be swapped by naming an alternative — research, compare, wire.

## Default libraries — AI-fluent stacks

LLMs write best in what they've seen most; picking mainstream stacks measurably
cuts hallucinated APIs and review churn. Defaults (override any via interview):

| Platform | Default stack | Why |
|---|---|---|
| **Web app / site** | TypeScript + React + Next.js + Tailwind + **shadcn/ui** (Radix under the hood) | deepest LLM training coverage; shadcn is copy-in code agents can edit directly; **21st.dev** — community shadcn-style components to copy from before building anew |
| **Mobile** | React Native + Expo (cross-platform) · SwiftUI (iOS-native) · Jetpack Compose (Android-native) | Expo for one codebase; native pairs when the product demands platform depth |
| **Desktop** | Tauri (light, Rust shell + web UI) · Electron (max ecosystem) · SwiftUI/AppKit (macOS-native) | pick by footprint vs ecosystem vs nativeness |
| **API / backend** | TypeScript (Next.js API/Hono/Fastify) or Python (FastAPI) | both are LLM home turf; match the team's main language |
| **CLI / tooling** | TypeScript (commander) or Go | distribution ease vs single-binary |
| **AI features** | Vercel AI SDK (+ OpenRouter as the gateway) | streaming/tool-calling glue LLMs know well; patterns & evals reference: `awesome-generative-ai-guide` |

**Always pair with live docs — Context7** (MCP/skill) for current library/framework/OS-SDK
APIs, so agents code against today's versions, not a frozen training cutoff.

Rule of thumb: deviate from these only when the project itself dictates (a DSP app
is C/Swift no matter what LLMs prefer) — and record the deviation in the guide.

## Audio & DSP (plugins, instruments, audio apps)

**License first — it shapes the product.** In audio the framework's licence decides
whether you can ship closed source at all; migrating frameworks later is expensive, so
settle this before the first line of DSP.

| Need | Options | Notes |
|---|---|---|
| **Plugin / app framework** | **JUCE** (GPLv3 **or** paid commercial) · **iPlug2** (permissive, MIT-style) · **DPF** (ISC, minimal core) · **HISE** (GPLv3 or commercial; samplers/instruments) · **NIH-plug** (Rust) | JUCE = biggest ecosystem, tutorials, hosts battle-tested — pay or go GPL. iPlug2/DPF = full control, closed-source-friendly, leaner |
| **Formats** | **CLAP** (MIT, open) · VST3 (GPLv3 or proprietary) · AU/AUv3 (Apple) · AAX (Avid, NDA) · LV2 | CLAP is native in iPlug2 · DPF · NIH-plug; **JUCE has no native CLAP yet — use [clap-juce-extensions](https://github.com/free-audio/clap-juce-extensions)** until JUCE 9 ships it |
| **DSP libraries** (permissive) | Airwindows (MIT) · chowdsp_utils · DaisySP · Maximilian · q | pick MIT/BSD when the product must stay closed |
| **Primitives** | FFT: pffft · KissFFT · Apple **vDSP** · resampling: libsamplerate · r8brain · loudness: **libebur128** (EBU R128) | the pieces a broadcast chain actually needs |
| **Prototyping / codegen** | **FAUST** (functional DSP → JUCE/VST/CLAP targets) · Cmajor · Elementary Audio | design the algorithm, generate the plugin scaffold |
| **Validation & testing** | **pluginval** (Tracktion, free — the de-facto validator) · `auval` (Apple AU) · a host matrix (REAPER, Live, Logic) | plugin QA gate; pairs with the Testing section below |
| **Realtime safety** | **RTSan** (Clang RealtimeSanitizer) · lock-free queues (farbot, moodycamel) | catches allocations/locks on the audio thread — the classic killer |
| **Distribution** | macOS notarization · Packages · Inno Setup (Windows) | feeds the launch checklist |

Deeper catalogs live in `awesome-musicdsp` (github.com/olilarkin/awesome-musicdsp) — the
usual seeds-then-awesome-search rule.

## Testing — every stage of the loop, per platform

Free/OSS-first defaults; as always, seeds not a closed menu.

| Platform | Unit / component | E2E | Visual / a11y / perf |
|---|---|---|---|
| **Web / PWA** | Vitest + Testing Library; Storybook interaction tests | **Playwright** (free, cross-browser) | Playwright screenshots or Chromatic (free tier) for visual regression; axe-core (a11y); Lighthouse (perf + PWA installability/offline audit) |
| **Mobile** | XCTest (iOS) · JUnit/Robolectric (Android) · Vitest (RN logic) | **Maestro** (free, cross-platform flows) · Detox (RN) · XCUITest / Espresso (native) | platform snapshot tests; store-review checklists |
| **Desktop** | per shell: Vitest (Electron/Tauri web core) · XCTest (native macOS) | Playwright (Electron) · WebDriver (Tauri) · XCUITest (macOS) | same visual tools as web for web-shells |
| **API / backend** | Vitest/pytest + supertest/httpx | contract/integration suites against a test DB (Supabase branch DBs) | **k6** (OSS) load tests |

**Where each sits in the loop:**
- **Build** — unit/component tests are part of the code DoD (tests/review gate).
- **Review** — QA gate runs E2E + the platform suite; Design QA reviews visual
  regression against the design system; a11y (axe) and perf (Lighthouse) budgets here.
- **Ship** — smoke E2E on the real build/prod + the launch checklist.
- **Measure** — synthetic checks/uptime (e.g. a cron autopilot hitting key flows) +
  Sentry errors feed `/measure` alongside product metrics.

## Security defaults (digital products)

The Security gate reviews against **standards, not vibes**: **OWASP Top 10** (+ ASVS as
the deeper checklist); AI features → **OWASP LLM Top 10**. Skills: find via
`multica skill search` — *Security Review*, *Frontend Security Review*, *OWASP Top 10
AI*, *VibeSafe* (pre-flight for agent-written code).

**Classic agent/vibe-coding misses the gate always checks:** keys/secrets in the client
bundle or repo · missing RLS/authorization on Supabase-style backends (every table!) ·
no rate limiting on public endpoints · string-built queries (injection) · unvalidated
webhooks · secrets in logs · prompt injection paths in AI features · trusting client-side
checks alone.

**Free tooling:** gitleaks / trufflehog (secret scanning, CI) · semgrep OSS (static
analysis) · CodeQL + Dependabot (free on GitHub) · `npm audit` / osv-scanner (deps) ·
**Arcjet** (free tier) — rate limiting / bot protection / email validation as an SDK,
directly closing the "no rate limiting" classic miss.

## Research & reference galleries (design · brand · visual)

Registered sources so research never blocks: **paid source missing → fall back to the
free set — degrade the tool, never the quality**. These rows are the common cases; for
anything else search **`awesome-{topic}`** on GitHub (e.g. `awesome-fonts`). Most have no MCP — agents use web
fetch/search; Mobbin has an MCP (connect if licensed).

| Need | Sources (free unless noted) |
|---|---|
| UI/product patterns | **Mobbin** (paid, MCP) → free fallback: webdesigninspiration.io, public design-system docs, competitors' live products |
| Per-component patterns | navbar.gallery · footer.design · goodcart.design (carts/checkout) · supahero.io (hero sections) — real-world takes on one component; pairs with component.gallery |
| Case studies & UX teardowns | **growth.design** (interactive product/UX case studies) · thestare.in · uxpamagazine.org (UX practice/research articles) · abtest.design (A/B-test outcomes) — feed discovery and UX research, not just visuals |
| Brand identity & rebrands | Brand New / UnderConsideration (part paid), The Brand Identity, BP&O, rebrand.gallery |
| Style guides | brandingstyleguides.com — real brand guidelines to learn structure from |
| Logos & marks | Logobook, logosystem.co, logggos.club, Logopond, logodesignlove.com (craft essays); **fontinlogo.com** — which font a logo uses |
| Fonts & typography | Google Fonts (free) · `awesome-fonts` — foundries, pairing, licenses · typehunting.com (type ID in the wild) · **practicaltypography.com** — the craft manual agents should actually read |
| Free design assets & mockups | unblast.com — mockups/templates for presenting brand, packaging, screens |
| App icons | iosicongallery.com |
| Boards / collections | Are.na (free tier, has API) — per-project moodboards; seed from public channels (e.g. interface or app collections) |
| Posters & print | 100-beste-plakate.de — poster craft (non-digital media too) |
| Product & packaging | goods.so — curated physical/product design |
| Illustration & visual culture | It's Nice That · Colossal · The Inspiration / Inspiration Grid |
| Architecture, product & design culture | Dezeen · designboom — industrial/interior/architecture reference for physical-world projects |

**Visual styles — method, not a baked-in taxonomy:** per project, run *style discovery*:
pull references from these galleries → **name the style in words** (so agents can
reproduce it) → record as a moodboard + references in `docs/brand/` and encode the
outcome as design-system tokens. The galleries serve any craft — covers, packaging,
slides — not just apps.
