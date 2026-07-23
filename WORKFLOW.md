# Workflow diagrams

Mermaid renders on GitHub, in Obsidian, and on the docs site.

## Contents

- [From first message to a working company](#from-first-message-to-a-working-company)
- [The four routes, side by side](#the-four-routes-side-by-side)
- [Two seats of Mops](#two-seats-of-mops)
- [One feature through the conveyor](#one-feature-through-the-conveyor)
- [Escalation & control](#escalation-control)
- [Session limits — detect and recover](#session-limits-detect-and-recover)
- [Getting current — what /upgrade actually walks](#getting-current-what-upgrade-actually-walks)
- [The skill lifecycle — gates, not ceremony](#the-skill-lifecycle-gates-not-ceremony)

## From first message to a working company

```mermaid
flowchart TD
    U["Any first message —<br/>even a bare /mops or 'hi'"] --> DZ["Day zero: installed · current ·<br/>signed in · workspace · daemon · runtimes<br/><i>one ladder with its fixes, not six prompts</i>"]
    DZ --> Q{"Three questions:<br/>what exists · what you want ·<br/>who runs the work"}
    Q -->|"nothing, want a team"| SHAPE
    Q -->|"a workspace already"| JOIN["/join — audit, then fix<br/>in approved batches"]
    Q -->|"a backlog elsewhere"| IMP["/import — mapping shown first,<br/>issues created unassigned"]
    Q -->|"one job, no team"| QJ["Quick job: 3 questions,<br/>1–2 agents, build → review"]
    SHAPE["Shape the work:<br/>what's hard · what it's made of ·<br/>rough size → <b>team proposed with reasons</b>"] --> INT["Interview in waves —<br/>control question second"]
    INT --> STAND["Stand up: conductor → guide +<br/>find-skills → roles → docs skeleton<br/>+ branch protection + docs guard"]
    IMP --> CREW
    Q -->|"a list of tasks, you decide order"| CREW["Crew mode: executors + gates,<br/><b>no conductor</b> — owner is the PM"]
    CREW --> RUN["Work"]
    STAND --> RUN
    QJ --> RUN
    JOIN --> RUN
```

> Nobody is asked to choose a command. Crew mode is the **default offer after `/import`** —
> someone who just moved their backlog has already decided what the work is. Adding a
> conductor later is an upgrade, not a redo.

## The four routes, side by side

```mermaid
flowchart LR
    subgraph INIT["/init — a company"]
        I1["shaping → interview"] --> I2["conductor + squads"] --> I3["roadmap · ICE · discovery"]
    end
    subgraph CREW["/crew — a crew"]
        C1["executors + gates"] --> C2["owner assigns"] --> C3["owner also holds:<br/>accept · skill screening ·<br/>dates · 3rd-round"]
    end
    subgraph QJ["quick job"]
        J1["1–2 agents"] --> J2["build → review"] --> J3["no docs skeleton,<br/>no ledger, no modules"]
    end
    subgraph JOIN["/join — inherit"]
        N1["audit first"] --> N2["interview delta"] --> N3["fix in approved batches"]
    end
```

## Two seats of Mops

```mermaid
flowchart TD
    OWNER["Owner"]
    OWNER -->|"build · heavy ops<br/>instant · own quota"| CLI["Mops in CLI<br/>shell · git · deploy · full CLI"]
    OWNER -->|"@Mops: status · advice<br/>escalation · async"| MUL["Mops in Multica<br/>resident agent · shared limit<br/>(optional)"]
    CLI -->|writes decisions| STATE["Written state<br/>repo + issue comments<br/>= source of truth"]
    MUL -->|reads + writes| STATE
    STATE -.->|kickoff handoff| MUL
```

## One feature through the conveyor

```mermaid
flowchart TD
    IDEA["Idea"] --> DISC["Discovery:<br/>AS IS to TO BE · audience<br/>competitors · risks · metrics"]
    DISC --> SPEC["Spec in repo<br/>approved by owner"]
    SPEC --> DECOMP["Conductor: staged sub-issues"]
    DECOMP --> S1["Stage 1 · Design<br/>(when UI)"]
    S1 --> S2["Stage 2 · Build<br/>squad leader routes,<br/>executors commit"]
    S2 --> S3{"Stage 3 · Review<br/>parallel gates"}
    S3 --> QA["QA gate"]
    S3 --> DQA["Design QA gate"]
    S3 --> SEC["Security gate"]
    QA & DQA & SEC --> ACC["Stage 4 · Accept<br/>merge · archive"]
    ACC --> SHIP["Ship<br/>deploy · release notes · tag"]
    SHIP --> MEAS["Measure<br/>vs success metrics"]
    MEAS --> LEARN["Learn<br/>→ ROADMAP.md"]
    LEARN -->|non-stop mode| NEXT["Next feature<br/>from ROADMAP.md"]
    S3 -->|request changes| S2
    S3 -->|same point, 3rd round| CND["Conductor settles<br/>what 'done' means"]
    CND --> S2
```

> A stage is a **barrier, not a queue**: everything genuinely independent goes on the *same*
> stage and runs concurrently — the numbers order dependencies, not tasks. And width is only
> real on a `github_repo` project; a `local_directory` serializes everything regardless.

## Escalation & control

```mermaid
flowchart BT
    EXEC["Executor agent"] --> LEAD["Squad leader"]
    LEAD --> PM["Conductor (PM)"]
    PM --> MOPS["Mops"]
    MOPS --> OWNER["Owner"]
    EXEC -.->|"destructive only:<br/>delete · publish · spend"| OWNER
```

## Session limits — detect and recover

```mermaid
flowchart TD
    RUN["Run fails:<br/>agent_error"] --> CHK{"Comment says<br/>resets HH:MM?"}
    CHK -->|yes| WAIT["Wait for reset<br/>(retry before it fails again)"]
    WAIT --> RERUN["issue rerun<br/>= Retry task"]
    CHK -->|no| DIAG["Read run error<br/>+ daemon logs"]
    RERUN --> OK["Work resumes<br/>from repo state"]
```

## Getting current — what `/upgrade` actually walks

```mermaid
flowchart TD
    GO["/upgrade"] --> L1{"Is this skill's copy<br/>on your machine current?"}
    L1 -->|"behind"| YOU["<b>You run one line</b> —<br/>claude plugin update, or npx skills add.<br/><i>A skill cannot replace its own plugin</i>"]
    YOU --> L2
    L1 -->|"current"| L2["Read the NEW version's CHANGELOG<br/>— it is the migration map"]
    L2 --> BK["Back up both halves:<br/>skill files + agent config snapshot<br/>+ pre-upgrade SHA in UPGRADES.md"]
    BK --> WS["Migrate the workspace:<br/>missing docs files · guide rules ·<br/>agent instructions · renamed commands"]
    WS --> SK{"Imported skills:<br/>newer upstream?"}
    SK -->|"yes"| SCR["<b>Re-screen</b> against the version<br/>you screened — diff the prose,<br/>not only the scripts"]
    SCR --> SK
    SK -->|"all current"| CLI{"CLI behind,<br/>locally or on a runtime?"}
    CLI -->|"yes"| IDLE{"active_task_count = 0<br/>and nothing in_progress?"}
    IDLE -->|"no"| WAIT["Say what's in flight.<br/>Wait for idle, or /stop<br/>if the owner accepts it"]
    WAIT --> IDLE
    IDLE -->|"idle"| UPD["multica update ·<br/>runtime update &lt;id&gt; ·<br/>daemon restart"]
    UPD --> FP
    CLI -->|"current"| FP["Recompute the fingerprint —<br/><i>after</i> reconciling, never before"]
    FP --> VER{"Behaviour still right?"}
    VER -->|"no"| RB["Restore from the SHA —<br/>rollback is a normal outcome"]
    VER -->|"yes"| DONE["Report what was adapted"]
```

> Two things this picture exists to prevent: **new bytes without a migration** (half the
> company on one version, half on another), and **a CLI replaced under a running agent**,
> which produces failures that look like the agent's fault.

## The skill lifecycle — gates, not ceremony

```mermaid
flowchart TD
    subgraph CREATE["Create"]
        R1["Routine seen twice"] --> DRAFT["skill-creator draft"]
        DRAFT --> TEST["Tested on a fresh agent<br/>that never saw the routine"]
    end
    subgraph IMPORT["Import"]
        FIND["find-skills / search"] --> SCAN{"Screen:<br/>commands · exfiltration ·<br/>endpoints · grants · injection"}
        SCAN -->|critical| REJ["Rejected<br/>→ DECISIONS.md"]
        SCAN -->|broad access| HUM["Conductor + security reviewer<br/>never auto-approved"]
        SCAN -->|clean| READ["Someone still reads<br/>what it instructs"]
        HUM --> READ
        READ --> TRIM["Trim to what this company needs"]
    end
    TEST --> OPT
    TRIM --> OPT{"Optimize<br/>fail-closed"}
    OPT -->|"commands · paths · numbers<br/>survive verbatim"| REV["Independent reviewer<br/>confirms meaning held"]
    OPT -->|NOT_COMPRESSIBLE| ATT
    REV --> ATT["Attach with provenance<br/>source · version · date · approver"]
    ATT --> USE["In use"]
    USE -->|"upgrade available"| SCAN
    USE -->|"proved across 2 projects"| REL["Release:<br/>de-identify → owner's own repo<br/>owner-confirmed → re-import as external"]
```

> The loop back to **Screen** on upgrade is the point most setups miss: a version you vetted
> is not the version you are about to install.
