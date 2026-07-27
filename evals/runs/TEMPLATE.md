# Eval run — {{x.y.z}}

**Ran** {{YYYY-MM-DD}} · **skill version** {{x.y.z}} · **player** {{stronger|medium|light}} ·
**judge** {{stronger|medium|light}} · **run by** {{who}}

**Why this run:** {{what changed since the last one — which scenarios that made load-bearing,
and why the rest were or weren't re-run}}

| # | Scenario | Verdict | Evidence |
|---|---|---|---|
| 1 | {{title}} | pass | {{commit · issue · transcript excerpt}} |
| 2 | {{title}} | **fail** | {{what it produced, below}} |
| 3 | {{title}} | partial | {{what held, what didn't}} |
| … | {{title}} | not run | {{why — "untouched by this release" is a reason}} |

## Fails, and what each produced

- **{{n}} · {{scenario}}** — {{the fix commit, or the recorded decision to accept it}}

## Noticed, not asked

{{Anything the rubric didn't ask that the run revealed — these are the candidates for the
next scenario. The 2.4.4 regression gate was born exactly here.}}

---

**How to fill this in**

- **`not run` is listed, never omitted.** A record that hides its gaps reads as a full pass
  and is worse than no record at all.
- **A fail must produce something** — a fix, or a written decision to accept it. A fail with
  no consequence is a fail that repeats next release.
- **Tiers in outcome terms** — stronger · medium · light, never a vendor name (evals/README).
- **Never rewritten.** A later run is a new file; this one is what was true on its date, the
  same forward-only rule the changelog runs on.
- **Evidence, not assertion.** A verdict with nothing to point at is an opinion.
