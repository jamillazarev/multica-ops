# Workflow diagrams

Mermaid renders on GitHub, in Obsidian, and on the docs site.

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
```

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
