# Workflow diagrams

Mermaid renders on GitHub, in Obsidian, and on the docs site.

## Contents

Bootstrap · Two seats of Mops · One feature through the conveyor · Escalation & control ·
Session limits · The skill lifecycle

## Bootstrap — from a sentence to a working company

```mermaid
flowchart TD
    U["User: one sentence"] --> Q{"Quick job or company?"}
    Q -->|quick| QJ["3 questions:<br/>deliverable · repo · language"] --> MINI["Conductor + 1-2 executors"]
    Q -->|company| INT["Progressive interview<br/>defaults everywhere"]
    INT --> WS["Workspace = company<br/>details + logo"]
    WS --> CON["Conductor = project lead"]
    CON --> GUIDE["Guide skill + find-skills<br/>on every agent"]
    GUIDE --> ROLES["Roles from interview<br/>squads where 2+"]
    ROLES --> OPT["Opt-in modules:<br/>design system · brand<br/>experts · personas · Design QA<br/>autopilots · Slack · Lark"]
    OPT --> RES["Mops in Multica<br/>(resident · optional)"]
    RES --> GO["User starts first feature<br/>conveyor takes over"]
    MINI --> GO
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
