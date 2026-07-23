# Worked examples — what good output actually looks like

The templates give artifacts their shape and USE-CASES routes a situation to a command.
Neither shows the *quality bar*. These do — each as a **weak version and a strong one**,
because the difference is what teaches. The weak versions are not strawmen: every one is a
shape agents produce by default.

## Contents

- [1. Turning an idea into staged work](#1-turning-an-idea-into-staged-work)
- [2. A handoff comment](#2-a-handoff-comment)
- [3. A review verdict](#3-a-review-verdict)
- [4. A cost/effort ledger entry](#4-a-costeffort-ledger-entry)
- [5. Reporting status](#5-reporting-status)
- [6. Recording a rejected decision](#6-recording-a-rejected-decision)

## 1. Turning an idea into staged work

**The owner says:** *"People can't find their old recordings. Fix search."*

**Weak — a task that looks complete and isn't:**

> **Title:** Improve search
> **Description:** Make search better so users can find recordings.

Nothing here is false and nothing is workable. No definition of "better", no way to know
when it's done, and the whole thing sits on one agent's guess.

**Strong — the intake, then the decomposition:**

> **Title:** Recordings search returns the right result in the first three
>
> **Why:** 38% of support tickets this month are "I can't find my recording" (issue #204).
> Users search by what they remember — a person's name, roughly when — and we only match
> the title they never set.
>
> **Success (one sentence):** searching a participant's name or a month returns the
> intended recording within the first three results, on a library of 500+.
>
> **Does not count:** a plan for search; matching titles only; "works on my 12-item test
> library"; a relevance improvement nobody can measure.
>
> **DoD:** the acceptance query set (20 real searches from tickets, in `docs/research/`)
> passes at ≥90%; p95 latency under 400 ms; recorded before/after numbers on the issue.

Then sub-issues — **everything independent on the same stage** so it runs concurrently:

| Stage | Sub-issue | Owner |
|---|---|---|
| 1 | Index participants and dates into the search table | Backend engineer |
| 1 | Build the 20-query acceptance set from tickets | Analyst |
| 1 | Empty/failed-search states, designed | Product designer |
| 2 | Ranking + query parsing against the acceptance set | Backend engineer |
| 3 | Review: code | QA engineer |
| 3 | Review: design + a11y | Design lead |

Stage 3 is two rows, not one: **a gate that can independently reject work is its own
sub-issue with its own single owner** — that is what makes the gates parallel rather than a
queue. Stage 1 has three items because none of them needs the others. Ranking is stage 2 only
because it genuinely needs the index. The acceptance set is built **before** the ranking
work, by someone else, so the bar isn't authored by the person being measured against it.

## 2. A handoff comment

**Weak:**

> @designer done, please review

The next agent now opens the PR, reads the diff, and reconstructs what happened — paying
in tokens for what one sentence would have carried.

**Strong:**

> **Done:** query parsing + ranking, behind `search_v2` (off in prod).
> **Evidence:** acceptance set 19/20 — [PR #412](…), before/after table in the description.
> The failure is "meeting with Ana" where two participants are named Ana; ranking is
> correct, the UI gives no way to disambiguate.
> **You're up:** the empty and ambiguous-result states — the ambiguous one is new, it
> wasn't in the original design.
> **Not done, on purpose:** typo tolerance. Deferred with a trigger in `LATER.md`
> ("if disambiguation doesn't fix the ticket rate").

It states what was built, what proves it, what is deliberately absent, and what the next
person actually has to decide. It is also **readable without the thread** — which matters
because a rerun loses the thread.

## 3. A review verdict

**Weak:**

> Looks good to me 👍

This is not a review. It carries no evidence and, once it's in the record, nobody can tell
whether the gate ran.

**Strong — a pass:**

> **Verified:** ran the acceptance set locally (19/20, matching the claim), read the
> ranking change, checked the index migration is reversible.
> **Not verified:** load behaviour above 5k recordings — out of scope here, worth its own
> issue before we enable it for the enterprise tier.
> **Verdict:** pass.

**Strong — a fail that escalates instead of ping-ponging:**

> **Third round on the same point**, so this is a spec problem, not a quality problem.
> The disagreement is whether "first three results" counts per-page or overall; the issue
> says one thing and the acceptance set assumes the other.
> **Stopping the loop** and escalating to the conductor to settle the definition. Nothing
> is wrong with the code as written against the reading its author used.

**Strong — a grade signal:**

> The query parsing is fine. The ranking change touches the scoring model, which nobody
> here has changed before, and the third attempt reproduces the same regression.
> **This needs a senior, not another retry** — reassigning up with what's been tried:
> [attempts and outputs].

## 4. A cost/effort ledger entry

**Weak:**

> This release cost about $30.

**Strong:**

| | Tokens | $ (est.) | Time |
|---|---|---|---|
| Backend engineer | 14.2M | $18.40 | 6h 10m |
| Product designer | 3.1M | $4.05 | 2h 30m |
| QA | 2.4M | $3.10 | 1h 45m |
| Analyst | 1.1M | $1.40 | 40m |
| **Total** | **20.8M** | **$26.95** | **11h 05m** |

> **Cache reads:** 88% of tokens. **Against the envelope:** $26.95 of $300/mo, sixth
> release this month, $212 spent. **$ is an estimate** from list prices (tokens ×
> per-million), not an invoice; on a subscription it's value consumed, not cash out.
> **Compared to the last two releases:** the design share doubled — this one had three
> new states rather than one, which is expected, not a signal.

The numbers are itemized because that's what makes an expensive role *visible* rather than
suspected; and the estimate is labelled as one.

## 5. Reporting status

**Weak:**

> Everything's going well! The team is making great progress on search. 🎉

**Strong:**

> **Moving:** ranking (stage 2, backend, day 2 of ~3).
> **Waiting on you:** the disambiguation design decision — 4 days old, blocking stage 3.
> Keeping it open costs roughly a day of designer idle time per week.
> **Stopped:** localization, session limit hit 02:10, resets 07:00 — not a failure, it
> resumes on rerun.
> **Money:** $212 of $300 this month; at this rate the envelope holds until the 28th.
> **What I'd do:** settle disambiguation today, or drop it from this release explicitly
> rather than by drift.

No praise, an age on the approval, a cost for waiting, and a recommendation. "Great
progress" would have been the same words whether or not anything moved.

## 6. Recording a rejected decision

**Weak:** *(nothing recorded — the option was discussed in a thread and dismissed)*

Six weeks later somebody proposes it again, and the argument is re-run from memory.

**Strong — appended to `docs/DECISIONS.md`:**

> ## 2026-06-14 — Search stays in Postgres, no dedicated engine
>
> **Considered:** Postgres full-text · Meilisearch (self-hosted) · Algolia
> **Chose:** Postgres full-text · **Rejected:** Meilisearch, Algolia
> **Because:** the acceptance set passes at 19/20 on Postgres, so the quality gap we
> assumed isn't there at our size. Algolia is $50/mo above our envelope at current record
> counts (checked 2026-06-14, algolia.com/pricing). Meilisearch is free but adds a service
> to run, back up and upgrade, which nobody here owns.
> **Would revisit if:** the library passes ~50k recordings per account, or non-Latin
> search becomes a requirement.
> **Decided by:** conductor, with the backend engineer · **Where:** issue #211

Every field earns its place: **what was considered**, so the alternatives aren't re-argued; **the evidence**, priced and dated, not "it felt cleaner"; and **the revisit trigger**, so the decision is provisional on the thing that would change it — not a permanent verdict nobody remembers the reason for. That is the difference between a decision log and a graveyard of opinions.
