# Sources register

The evidence behind the skill's slow-rotting claims. Every claim the skill makes about the
outside world that will **not** change week to week has an entry here; Mops answers *"where did
you get this?"* — in any phrasing — from this file (REFERENCE §7, SKILL "Say what you know").
**It is read by whichever flow needs it, and it is read first** — a register entry serves every
flow that meets its need, and the live web is where the register runs out, not where it starts
(FLOWS → *a shelf serves every flow*).

**What belongs here — and what never does.** The register holds **slow-rotting canon only**:
findings, methods and standards that age in years. **Fast-rotting facts never enter** — a price, a
current API limit, a competitor's live feature stay *fetch-at-decision-time* rules, quoted with
their check-date at the moment of use, never cached here to rot.

**One fixed form per entry**, so a wrong entry is visibly wrong:
**id · full citation · live URL/DOI/arXiv · archive link · licence · one-paragraph distillate
(our words) · check-date · cited-by**

**`Reads against` is the field that stops a register becoming a pile.** A register that can only
answer *"what do we have on X"* will hold two entries pulling opposite ways and never say so. The
field names the entries this one must be read beside **and what the tension is**, or one of two
words that are not the same answer: **`none found`** — looked, nothing here pulls against it — or
**`not checked`**, honest ignorance. An empty field is a defect; the two words are not. **It is
symmetric**, and `python3 scripts/fetch-source.py --verify-reads` refuses the pair that only points
one way. **Ported from the sibling 2026-09-10, where it caught two one-way pairs on its first run**;
here it reported **15 of 15 still `not checked`** on arrival, which was a fact about this register
rather than a defect in it. The first pair to name each other is the tool-format pair at the end.

**A back-pointer names a section and proves what it said** — `file.md#anchor (sha:…, checked …)`
— minted by `scripts/fetch-source.py --cite <file.md>#<anchor>`. A line number names a *position*,
and a position moves the next time a paragraph is inserted above it: **measured 2026-08-07, 11 of
23 line-number pointers no longer landed on their claim**, with no edit to this register in
between. The hash earns the rest — a passage rewritten *underneath* its citation makes the fact
`unknown` and says so, where a line number cannot even see it. The one thing the anchored form
cannot cite is a passage with no heading above it; that is a reason to give a load-bearing
passage a heading, and until then the line form is used and marked as such.

**Licence tiers** (they decide what we may hold): **free** — an open licence (MIT, CC, a public
standard); a copy may be carried later. **copyrighted** — citation + archive link + our own
distillate, never the text itself. **math** — a formula recorded by name, which is not
copyrightable. Each entry states its tier.

**Upkeep.** `scripts/fetch-source.py` builds and checks these entries: `--resolve <doi|arxiv|url>`
prints a skeleton, `--archive <url>` triggers a Wayback snapshot, `--verify` walks every live URL.
`--verify-citations` walks the **other** edge — every cited-by back into the doc that cites it —
naming any pointer a rewrite left behind, and any entry the skill no longer cites at all (one
parked for a later release stays named every run, which is the point: a deferral nobody is
reminded of is a deletion). Both run each release (AGENTS.md → Cutting a release).

---

## Persona theatre — grounding, fidelity, and the limits of synthetic audiences

### park-self-reports · Park et al., self-report-grounded individual simulation
- **Citation:** Park, J.S., et al. "LLM Agents Grounded in Self-Reports Enable General-Purpose Simulation of Individuals." arXiv:2411.10109 (2024; v1 was "Generative Agent Simulations of 1,000 People").
- **Live:** https://arxiv.org/abs/2411.10109
- **Archive:** http://web.archive.org/web/20260726212521/https://arxiv.org/abs/2411.10109
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Agents built from a person's **own self-reports** reproduce that person's survey answers at **83%** (interview-grounded) / **82%** (survey-grounded) / **86%** (both) of the person's two-week test-retest ceiling, versus **74%** for demographics-only; a free-text "persona paragraph" scores **0.71**, below even the demographics baseline (0.74). Self-report grounding also **reduces accuracy disparities** across racial and ideological groups. The takeaway the skill leans on: the grounding artifact — the interview transcript — *is* the product, not a written bio.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#persona-theatre-synthetic-and-live-audiences (sha:070ca2bf, checked 2026-09-11), MODULES.md#staging-proto-persona-validated-persona (sha:f8ca5f73, checked 2026-08-07), templates/PERSONA-template.md#bias-profile-24-named-biases-each-with-its-source (sha:80d2a6dd, checked 2026-08-07)

### park-hai-brief · Park et al., Stanford HAI policy brief
- **Citation:** Park, J.S., et al. "Simulating Human Behavior with AI Agents." Stanford HAI Policy Brief (May 20, 2025).
- **Live:** https://hai.stanford.edu/policy/simulating-human-behavior-with-ai-agents
- **PDF:** https://hai.stanford.edu/assets/files/hai-policy-brief-simulating-human-behavior-with-ai-agents.pdf
- **Archive:** http://web.archive.org/web/20260412141409/https://hai.stanford.edu/policy/simulating-human-behavior-with-ai-agents (PDF: http://web.archive.org/web/20260607042745/https://hai.stanford.edu/assets/files/hai-policy-brief-simulating-human-behavior-with-ai-agents.pdf)
- **Licence:** copyrighted (Stanford HAI, free to read) — cite + archive + our distillate
- **Distillate:** The policy brief frames the **consent machinery** for simulating individuals and legitimizes the **AI-conducted interview** as the grounding step. It matches the v1 ("1,000 People") framing and carries the stronger **"demographic personas amplify stereotype bias"** phrasing that the current peer-reviewed version later softened to "reduces accuracy disparities" — which is why the skill attributes the sharper claim to the brief, not the paper.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#persona-theatre-synthetic-and-live-audiences (sha:070ca2bf, checked 2026-09-11), templates/PERSONA-template.md#bias-profile-24-named-biases-each-with-its-source (sha:80d2a6dd, checked 2026-08-07)

### ashokkumar-nature · Ashokkumar et al., direction not magnitude
- **Citation:** Ashokkumar, A., Hewitt, L., Ghezae, I., Willer, R. Nature (advance online publication, 2026-07-08). doi:10.1038/s41586-026-10742-x.
- **Live:** https://doi.org/10.1038/s41586-026-10742-x
- **Archive:** pending (Save Page Now triggered 2026-07-27; availability: https://archive.org/wayback/available?url=https://doi.org/10.1038/s41586-026-10742-x)
- **Licence:** copyrighted (Springer Nature) — cite + archive + our distillate
- **Distillate:** Across a large replication set, LLM simulations track the **direction** of experimental effects at about **r≈0.85** while **systematically overestimating their magnitude**. This is the evidence for the theatre's hardest rule: a synthetic verdict may state direction, **never a magnitude** (no "23% would churn").
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#persona-theatre-synthetic-and-live-audiences (sha:070ca2bf, checked 2026-09-11)

### ls-types · Lewis & Sauro, a taxonomy of synthetic users
- **Citation:** Lewis, J., Sauro, J. "What Are the Different Types of Synthetic Users?" MeasuringU (2026-06-23).
- **Live:** https://measuringu.com/what-are-the-different-types-of-synthetic-users/
- **Archive:** http://web.archive.org/web/20260624073122/https://measuringu.com/what-are-the-different-types-of-synthetic-users/
- **Licence:** copyrighted (MeasuringU) — cite + archive + our distillate
- **Distillate:** Names five types of synthetic user — AI proto-persona, demographic-based, persona-based, research-grounded, and digital twin — ordered by the **strength of their tie to real human data**. This is the stage vocabulary the theatre uses (proto vs validated vs twin).
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#persona-theatre-synthetic-and-live-audiences (sha:070ca2bf, checked 2026-09-11)

### ls-review · Lewis & Sauro, a review of synthetic-user experiments
- **Citation:** Lewis, J., Sauro, J. "A Review of Experiments with Synthetic Users." MeasuringU (2026-04-14).
- **Live:** https://measuringu.com/review-of-experiments-with-synthetic-users/
- **Archive:** http://web.archive.org/web/20260512065453/https://measuringu.com/review-of-experiments-with-synthetic-users/
- **Licence:** copyrighted (MeasuringU) — cite + archive + our distillate
- **Distillate:** Reviews ~12 recent experiments with synthetic users and finds mixed results, with synthetic responses showing **artificially low variability** and **distorted magnitudes** relative to real respondents — so they can indicate direction but not the size of an effect. (Their framing — low variability and distortion — is what the skill states, *not* "clustering toward neutral.")
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#persona-theatre-synthetic-and-live-audiences (sha:070ca2bf, checked 2026-09-11), MODULES.md#accuracy-score-and-consent-for-twins-of-real-people (sha:59e1ec81, checked 2026-09-11)

<!-- Mahajan restore point: MODULES.md previously credited a "Mahajan synthetic-users taxonomy"
     cited by name only. Research (2026-07-27) could not locate any such work in the checked
     venues (ACM Interactions = Russell; MeasuringU = Lewis & Sauro; NN/g = Rosala & Moran), so
     the low-variability / direction-over-magnitude claims were re-attributed to Lewis & Sauro
     (ls-types, ls-review) above. If the owner supplies the original Mahajan source, add it back
     as its own entry here and restore the MODULES attribution (MODULES.md#persona-theatre-synthetic-and-live-audiences (sha:dbfc6761, checked 2026-08-07), :168, :335). -->

### sharma-sycophancy · Sharma et al., sycophancy is trained in
- **Citation:** Sharma, M., et al. "Towards Understanding Sycophancy in Language Models." ICLR 2024. arXiv:2310.13548 (2023).
- **Live:** https://arxiv.org/abs/2310.13548
- **Archive:** http://web.archive.org/web/20260725125159/https://arxiv.org/abs/2310.13548
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Sycophancy — telling the user what they want to hear — is a **trained-in property** of RLHF'd assistants, consistent across several models and tasks. A persona built on such a model **inherits that compliance**, which is why the theatre's calibration layer suppresses sycophancy explicitly (a synthetic respondent is a pleaser unless corrected).
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#bias-profiles-every-persona-carries-24-each-with-its-source (sha:a01bd41f, checked 2026-08-07)

### tjuatja-biases · Tjuatja et al., LLM response biases ≠ human ones
- **Citation:** Tjuatja, L., et al. "Do LLMs Exhibit Human-like Response Biases? A Case Study in Survey Design." TACL 12 (2024). arXiv:2311.04076 (2023).
- **Live:** https://arxiv.org/abs/2311.04076
- **Archive:** http://web.archive.org/web/20260116061015/https://arxiv.org/abs/2311.04076
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Tests whether LLMs reproduce known **human survey response biases** (acquiescence, question-order effects) and finds their biases **do not reliably mirror human ones** — sometimes absent, sometimes inverted. Caveats how far a synthetic survey respondent can stand in for a human one.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** theatre canon (skill distillation pending 2.7)

### argyle-silicon · Argyle et al., silicon sampling and its diversity limits
- **Citation:** Argyle, L.P., et al. "Out of One, Many: Using Language Models to Simulate Human Samples." Political Analysis (2023). doi:10.1017/pan.2023.2.
- **Live:** https://doi.org/10.1017/pan.2023.2
- **Archive:** pending (Save Page Now blocked HTTP 523 on 2026-07-27; availability: https://archive.org/wayback/available?url=https://doi.org/10.1017/pan.2023.2)
- **Licence:** copyrighted (Cambridge University Press) — cite + archive + our distillate
- **Distillate:** Introduces **"silicon sampling"** — conditioning an LLM on demographic backstories to simulate human survey samples — and shows it can reproduce some subgroup patterns while **collapsing within-group diversity**. Backs the caution that synthetic samples flatten variety rather than represent it.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** theatre canon (skill distillation pending 2.7)

### wang-flattening · Wang et al., identity flattening
- **Citation:** Wang, A., Morgenstern, J., Dickerson, J.P. "Large language models that replace human participants can harmfully misportray and flatten identity groups." Nature Machine Intelligence (2025). arXiv:2402.01908.
- **Live:** https://arxiv.org/abs/2402.01908
- **Archive:** http://web.archive.org/web/20260607174738/https://arxiv.org/abs/2402.01908
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence; journal © Springer Nature) — cite + archive + our distillate
- **Distillate:** Finds that using LLMs to replace human participants can **harmfully misportray and flatten identity groups** — reproducing majority stereotypes and erasing within-group variation. This is the direct evidence for the **never-assign-a-bias-from-demographics** rule: a demographic backstory produces a caricature, not a person.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#staging-proto-persona-validated-persona (sha:f8ca5f73, checked 2026-08-07), templates/PERSONA-template.md#bias-profile-24-named-biases-each-with-its-source (sha:80d2a6dd, checked 2026-08-07)

### kapania-simulacrum · Kapania et al., LLMs as qualitative participants
- **Citation:** Kapania, S., et al. "'Simulacrum of Stories': Examining Large Language Models as Qualitative Research Participants." CHI 2025. arXiv:2409.19430 (2024).
- **Live:** https://arxiv.org/abs/2409.19430
- **Archive:** http://web.archive.org/web/20260411143601/https://arxiv.org/abs/2409.19430
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Treating LLMs as **qualitative research participants** yields plausible but hollow "simulacra of stories" that miss the lived specificity of real interviews. Marks the boundary of synthetic personas in qualitative work — a **supplement, never a replacement** for a real transcript.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** theatre canon (skill distillation pending 2.7)

## Cost routing — cheap-first, conditional on a good verifier

### frugalgpt · Chen, Zaharia & Zou, FrugalGPT
- **Citation:** Chen, L., Zaharia, M., Zou, J. "FrugalGPT: How to Use Large Language Models While Reducing Cost and Improving Performance." arXiv:2305.05176 (2023).
- **Live:** https://arxiv.org/abs/2305.05176
- **Archive:** http://web.archive.org/web/20260722202256/https://arxiv.org/abs/2305.05176
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** A **cascade** that queries cheaper models first and escalates only on low confidence can **match the best single model's accuracy at up to −98% cost**. The evidence for cheap-first-then-escalate routing at decomposition.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** ROLES.md#grades-fit-check-and-the-talent-pool (sha:99e0c8c2, checked 2026-08-07)

### routerbench · Hu et al., RouterBench
- **Citation:** Hu, Q.J., et al. "RouterBench: A Benchmark for Multi-LLM Routing Systems." arXiv:2403.12031 (2024).
- **Live:** https://arxiv.org/abs/2403.12031
- **Archive:** http://web.archive.org/web/20260606022825/https://arxiv.org/abs/2403.12031
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Cascades beat both any individual LLM and a zero-cost router **only when the verifier is good** — judge error **≤0.1**, deteriorating past **0.2**. The load-bearing caveat: cheap-first routing is **conditional on a good verifier**. In the skill, the **review gates are that verifier**, so the condition is already met — the caveat reads as a strength, not a risk.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** ROLES.md#grades-fit-check-and-the-talent-pool (sha:99e0c8c2, checked 2026-08-07)

## Repository context files

### agentsmd-eth · Gloaguen et al., do AGENTS.md files help?
- **Citation:** Gloaguen, T., Mündler, N., Müller, M.N., Raychev, V., Vechev, M. (ETH Zurich). "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?" arXiv:2602.11988 (v2, 2026-06-23).
- **Live:** https://arxiv.org/abs/2602.11988
- **Archive:** http://web.archive.org/web/20260711121106/https://arxiv.org/abs/2602.11988
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** A coding-agent benchmark finds repository-level context files (AGENTS.md) **do not improve task success rates** and add roughly **+20% inference cost**; **LLM-generated** context files perform **slightly worse** than none. The evidence behind "curate the shared guide, don't autogenerate it."
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** skills/mops/SKILL.md:78 *(line form: the claim sits in the core's preamble, above its first heading, so there is no section to anchor to)*

## Method provenance and standards (references, not evidence claims)

### method-provenance · adapted methods, nothing embedded
- **Citation:** cookiy — `user-research-skill` (MIT). agentman — "Synthetic Persona Creator" skill (concepts only).
- **Live:** https://github.com/cookiy-ai/user-research-skill · https://agentman.ai/agentskills/skill/synthetic-persona-creator (owner-confirmed 2026-07-27; page verified live: three-layer persona architecture — identity foundation · context seeding · response calibration — plus cohort distribution)
- **Archive:** http://web.archive.org/web/20260411081018/https://github.com/cookiy-ai/user-research-skill
- **Licence:** free — cookiy's `user-research-skill` is **MIT** (a copy may be carried later; today only the method shape is adapted, nothing embedded). agentman: **no licence stated on the page**; concepts taken, nothing embedded (no code carried, so no licence obligation).
- **Distillate:** Method lineage, not evidence. cookiy's MIT skill supplied the **shape** of the qualitative-research flows (its `qualitative-research-planner` → our persona-interview flow, its `synthesize-research-report` → our QDA step), adapted through the import gate. agentman supplied the **calibration and cohort concepts** behind the persona response-calibration layer. Recorded so every adaptation is auditable and no vendor wrapper is smuggled in.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** MODULES.md#staging-proto-persona-validated-persona (sha:f8ca5f73, checked 2026-08-07), MODULES.md#bias-profiles-every-persona-carries-24-each-with-its-source (sha:a01bd41f, checked 2026-08-07), MODULES.md#mixed-live-synthetic-hypothesis-beside-fact (sha:5f160353, checked 2026-08-07), ROLES.md#any-role-from-conversation-the-role-builder (sha:76e2813c, checked 2026-09-11)

### standards-cluster · named review standards
- **Citation:** Nielsen, J. "10 Usability Heuristics for User Interface Design" (NN/g). W3C, "Web Content Accessibility Guidelines (WCAG)." Wharton, Rieman, Lewis & Polson, "The Cognitive Walkthrough Method" (1994).
- **Live:** https://www.nngroup.com/articles/ten-usability-heuristics/ · https://www.w3.org/WAI/standards-guidelines/wcag/ · (cognitive walkthrough — named method, no single canonical URL)
- **Archive:** http://web.archive.org/web/20260725190416/https://www.nngroup.com/articles/ten-usability-heuristics/ · http://web.archive.org/web/20260726165506/https://www.w3.org/WAI/standards-guidelines/wcag/
- **Licence:** WCAG is a **W3C open standard** (free); Nielsen's heuristics are **copyrighted** (NN/g) — cited, never reproduced; cognitive walkthrough is a **named academic method** (not copyrightable as a procedure).
- **Distillate:** The external rubrics the design lens points at — **not** evidence claims about the world. Nielsen's 10 usability heuristics (the usability lens), WCAG (accessibility), and the cognitive-walkthrough method (first-use flows). Referenced as standards a reviewer applies, never copied into the skill.
- **Check-date:** 2026-07-27
- **Reads against:** `not checked`
- **Cited-by:** REFERENCE.md#1-objects (sha:1711aabc, checked 2026-08-07)

---

## What the tools print — read in their own sources

### mise-outdated · mise, `outdated` — what its JSON means, and what makes it refuse a file
- **Citation:** jdx/mise, `src/toolset/outdated_info.rs` (main branch, read 2026-09-11), and the `mise outdated`, `mise ls` and `mise bootstrap` help of mise 2026.9.5.
- **Live:** https://github.com/jdx/mise/blob/main/src/toolset/outdated_info.rs
- **Archive:** archive: pending  (run: fetch-source.py --archive https://github.com/jdx/mise/blob/main/src/toolset/outdated_info.rs)
- **Licence:** MIT — a copy may be carried; only our distillate is held
- **Distillate:** `mise outdated --json` is an object keyed by tool — `requested`, `current` (null when not installed), `bump`, `latest`, and `release_url` (omitted when the backend publishes none). **`latest` means the newest version inside the pin without `--bump`, and the newest at all with it**; `bump` is the new pin at the old pin's precision (`22` becomes `24`). **A tool whose lookup fails is dropped from the JSON with only a warning on stderr**, so an offline run and a current one both print `{}`. The short `-l` is deprecated and becomes `--local` in 2027.8.5. Measured on 2026.9.5: a `mise.toml` with `[tools]` alone is read on any machine, while one carrying `[bootstrap.packages]` is refused by every command until `mise trust`.
- **Check-date:** 2026-09-11
- **Reads against:** `npm-outdated` — they agree, and that is the finding: npm's *wanted* is mise's *latest* without --bump, npm's *latest* is mise's with it, so one report can sort both by the same line
- **Cited-by:** PLAYBOOKS.md#when-something-it-needs-has-a-newer-version (sha:e94db945, checked 2026-09-11), PLAYBOOKS.md#what-the-project-needs-from-the-machine (sha:91f89498, checked 2026-09-11)

### npm-outdated · npm, `npm outdated` — an update inside the range, and a move beyond it
- **Citation:** npm CLI documentation, *npm-outdated*, and `lib/commands/outdated.js`, npm/cli `latest` branch, read 2026-09-11.
- **Live:** https://docs.npmjs.com/cli/commands/npm-outdated
- **Archive:** archive: pending  (run: fetch-source.py --archive https://docs.npmjs.com/cli/commands/npm-outdated)
- **Licence:** copyrighted (npm, a GitHub company) — cite + our distillate
- **Distillate:** `wanted` is the newest version that satisfies the range in `package.json`; `latest` is the version tagged latest in the registry, and npm's own output colours the first *update now* and the second *proceed with caution*. With `--json` the answer is an object keyed by package name whose value becomes an **array** when one name is outdated in two places; `current` is absent when the package is not installed; the command exits 1 whenever anything is outdated, so its exit code says nothing about whether it answered.
- **Check-date:** 2026-09-11
- **Reads against:** `mise-outdated` — the same line drawn for runtimes and tools: they agree, which is what lets the pin, not the numbering, decide what is routine
- **Cited-by:** PLAYBOOKS.md#when-something-it-needs-has-a-newer-version (sha:e94db945, checked 2026-09-11)

### pep-594 · Python 3.13 removed nineteen standard-library modules
- **Citation:** Python Software Foundation, *What's New In Python 3.13*, "Important removals"; PEP 594, "Removing dead batteries from the standard library".
- **Live:** https://docs.python.org/3/whatsnew/3.13.html
- **Archive:** archive: pending  (run: fetch-source.py --archive https://docs.python.org/3/whatsnew/3.13.html)
- **Licence:** copyrighted (© Python Software Foundation) — cite + our distillate
- **Distillate:** 3.13 removed the nineteen "dead batteries" deprecated in 3.11 — aifc, audioop, cgi, cgitb, chunk, crypt, imghdr, mailcap, msilib, nis, nntplib, ossaudiodev, pipes, sndhdr, spwd, sunau, telnetlib, uu and xdrlib — and the 2to3 tool with lib2to3. A minor version number that breaks any code importing one of them: the reason the line between a routine update and a decision is the project's own pin, not the version's numbering.
- **Check-date:** 2026-09-11
- **Reads against:** `none found`
- **Cited-by:** PLAYBOOKS.md#when-something-it-needs-has-a-newer-version (sha:e94db945, checked 2026-09-11)
