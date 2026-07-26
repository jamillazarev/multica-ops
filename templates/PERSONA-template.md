# {{Persona name}} — persona profile

One shape for every persona in the theatre (MODULES → Persona theatre). Lives in
`docs/audience/` and is the persona's **primary artifact** — the agent's instructions are
generated from it, never the other way round.

**A twin** is a validated persona grounded in **one specific real person's** interview — it must
fill the provenance, usage-log, accuracy and revocation blocks below. A validated persona built
from **pooled segment data is not a twin**, and a **proto-persona** is a hypothesis, not a real
person — both skip the twin-only blocks (mark them `n/a`).

## Stage

{{**proto** (pre-interview hypothesis — a guess, treat decisions on it as `unknown`) **or**
**validated** (carries the interview transcript / QDA distillation below).}}

## Who, and in what situation

- **Who:** {{goals · habits · vocabulary · what they already use · what frustrates them}}
- **Context of use:** {{the situation the reaction is grounded in — *one-handed before work* ·
  *comparing two tabs at a desk* · *back after three weeks* · *first five minutes*. The same
  persona in two contexts gives two verdicts; name the context every session.}}

## Grounding artifact (validated only)

{{Link to the grounding distillation — the primary grounding, not a bio. For a **twin**: this one
person's **interview transcript / QDA**. For a **validated non-twin**: the **pooled segment
transcripts / QDA**. Chain: Whisper → transcript → QDA distillation → this persona. A validated
persona with no artifact linked here is still a proto-persona.}}

For a real person the link is a **pointer, not the file** — raw audio and full transcript live in
the external store (see Provenance); audio is transcribed **locally by default (Whisper)**, a
hosted STT only with consent recorded there.

## Bias profile — 2–4 named biases, each with its source

| Bias | Source | How it shows in a decision |
|---|---|---|
| {{loss aversion}} | {{twin: own interview transcript §…}} | {{the choice where it fires — not "performs it in every reply"}} |
| {{anchoring}} | {{non-twin: pooled segment QDA §…}} | {{fixates on the first price shown}} |
| {{social proof}} | {{proto: cited literature}} | {{follows the option marked "most popular"}} |

**Rules:** a twin's biases come from **its own transcript**; a **validated non-twin's** from the
**pooled segment transcripts / QDA** (its grounding artifact); a proto-persona's from **named
cognitive-science literature**; **never assigned from demographics** (interview-grounding narrowed
demographic-parity gaps; demographic personas amplify stereotype bias — Stanford, checked
2026-07-26).

## Accuracy score (twins only)

- **Score:** {{agreement between the real person and the twin on a short shared question set}}
- **Check-date:** {{YYYY-MM-DD}} — **re-verify before a decision leans on it; a stale score is
  `unknown`.**

## Provenance (twins only)

{{Whose data — a **pseudonym reference** (never the real name — identity lives only in the
external store's pseudonym → person map) · gathered how · when · under what permission ·
**hosted-STT consent** (yes/no — default is local Whisper). This is the record that makes the
twin legitimate.}}

**External-store pointers** — raw audio, full transcript and QDA source live **outside git**; the
repo holds only pointer + checksum + capture date, and the in-repo file is pseudonymized:

| Object | Pointer | Checksum | Captured |
|---|---|---|---|
| audio | {{…}} | {{…}} | {{YYYY-MM-DD}} |
| transcript | {{…}} | {{…}} | {{YYYY-MM-DD}} |
| QDA source | {{…}} | {{…}} | {{YYYY-MM-DD}} |

## Usage log (twins only)

Append-only. One line per use.

| Date | Round / artifact | Used by |
|---|---|---|
| {{YYYY-MM-DD}} | {{what it reacted to}} | {{who convened it}} |

## Revocation (twins only)

{{Permission granted now can be **withdrawn later**; withdrawal is not negotiable. On withdrawal,
three legs:
1. **retire the twin** — archive the agent, mark this persona file `revoked`;
2. **purge the external store** — delete the audio, transcript and QDA-source objects above;
3. **log it** — add the date to the usage log.}}

**Honest limit:** pseudonymized derivatives already in git history persist — which is why raw
identifiable material never entered git. Identifiable data committed by mistake is an owner-level
history-rewrite decision — flagged, never silent.

## Marking (squad mode)

When this persona runs as an agent: **🎭 prefix** in the name; description first line
`theatre: personas · axis: <segment|cohort|situational>`. It is **not staff** — excluded from
`/mops team` headcount, attributed to the theatre line in the ledger (MODULES → Persona theatre).
