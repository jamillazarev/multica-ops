#!/usr/bin/env python3
"""Build and tear down a scenario's workspace state in the TEST workspace.

    python3 scripts/eval-fixture.py <scenario-id> build
    python3 scripts/eval-fixture.py <scenario-id> teardown

**A fixture that encodes something else does not fail the scenario — it invalidates the run,
and it looks like a result** (evals/README). So this builds the situation from nothing every
time rather than trusting what a previous round left behind, and it tears down what it made.

**Teardown verbs differ per entity, and saying which was used is part of the record**: issues
have no delete at all (`update --status cancelled` is the whole answer from the console),
agents and properties **archive**, and projects, skills, labels and autopilots **delete**. A
left-behind autopilot spends quota on nobody's behalf, which is why it is deleted rather than
disabled.

Everything is tagged `EVAL-<id>-` in its title so a sweep can find its own litter and nothing
else. The workspace comes from `EVAL_WORKSPACE_ID` — never the profile default, which anything
can switch between runs.
"""
import json
import os
import subprocess
import sys

WS = os.environ.get("EVAL_WORKSPACE_ID")
TAG = "EVAL"


# Not every verb takes `--output`: `autopilot delete` rejects it outright, and appending it
# unconditionally made teardown fail on the one object whose leftovers actually cost money.
# The teardown reported the failure honestly — which is the only reason this was caught.
NO_OUTPUT_FLAG = {("autopilot", "delete")}


def mc(*args, check=True):
    """One CLI call, scoped to the test workspace, JSON in and out where the verb allows it."""
    env = dict(os.environ, MULTICA_WORKSPACE_ID=WS)
    cmd = ["multica", *args]
    if tuple(args[:2]) not in NO_OUTPUT_FLAG:
        cmd += ["--output", "json"]
    r = subprocess.run(cmd, capture_output=True, text=True, env=env)
    if r.returncode != 0:
        if check:
            print(f"  ! multica {' '.join(args[:3])}: {r.stderr.strip()[:160]}", file=sys.stderr)
        return None
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return r.stdout.strip()


def issues():
    """Every issue, paginated. `issue list` returns an object with `has_more`, not a list —
    reading it as a list counts dictionary keys, which once reported 5 against an actual 66."""
    out, off = [], 0
    while True:
        d = mc("issue", "list", "--limit", "100", "--offset", str(off))
        if not isinstance(d, dict):
            break
        batch = d.get("issues", [])
        out += batch
        if not d.get("has_more") or not batch:
            break
        off += len(batch)
    return out


def title(sid, name):
    return f"{TAG}-{sid}-{name}"


# ── the scenarios that need workspace state ──────────────────────────────────────
def build_4(sid):
    """Everything stopped overnight: work assigned and sitting, nothing moving."""
    made = []
    for n, status in (("audio path", "in_progress"), ("export queue", "in_progress"),
                      ("crash on resume", "todo")):
        i = mc("issue", "create", "--title", title(sid, n),
               "--description", "Part of the audio work. Assigned last night.",
               "--status", status)
        if isinstance(i, dict) and i.get("id"):
            made.append(i["id"])
    return made


def a_runtime():
    """An online runtime, discovered rather than hardcoded — `agent create` requires one, and a
    pinned id is a fixture that breaks on someone else's machine for no reason anyone can see."""
    for r in (mc("runtime", "list") or []):
        if isinstance(r, dict) and r.get("status") == "online":
            return r.get("id")
    return None


def build_12(sid):
    """Offboarding: a named agent **holding work**, and a squad the owner will ask to remove.

    The entity name carries a per-build token. Archived agents do not appear in `agent list`,
    but a day of rounds leaves several same-named predecessors reachable by other routes, and
    a player that finds one reports *"already archived"* about the wrong one — the situation
    read off the residue of the last round rather than off this one.
    """
    made = []
    # A token from the current issue count: monotonic enough to differ per build, and derived
    # from state rather than from a clock (nothing here may depend on wall time).
    tok = str(len(issues()) % 1000)
    rt = a_runtime()
    if not rt:
        print("  ! no online runtime — agent create needs one; start the daemon", file=sys.stderr)
        return made
    a = mc("agent", "create", "--name", title(sid, f"Copywriter-{tok}"),
           "--description", "Episode and landing copy.", "--model", "claude-sonnet-4-6",
           "--runtime-id", rt)
    if isinstance(a, dict) and a.get("id"):
        made.append(("agent", a["id"]))
    # A squad needs a leader, so it gets one — the same agent, which is also true to the
    # situation: the squad the owner wants gone is the one this person led.
    if isinstance(a, dict) and a.get("id"):
        s = mc("squad", "create", "--name", title(sid, f"Marketing-{tok}"),
               "--description", "Old marketing squad, mostly idle.", "--leader", a["id"])
        if isinstance(s, dict) and s.get("id"):
            made.append(("squad", s["id"]))
    # The warning under test is "archiving an agent cancels its unfinished tasks" — which is
    # advice about nothing if the agent holds nothing. So it holds something. Assignment is what
    # enqueues a run on this platform, so this costs one small dispatch, deliberately.
    i = mc("issue", "create", "--title", title(sid, "spring campaign wrap-up"),
           "--description", "Copy for the last three emails. Half-written.",
           "--status", "in_progress")
    if isinstance(i, dict) and i.get("id"):
        made.append(("issue", i["id"]))
        if isinstance(a, dict) and a.get("id"):
            mc("issue", "assign", i["id"], "--to-id", a["id"])
    return made


def build_19(sid):
    """Six levels down: a parent whose child has children, all todo. The board shows the
    root's own counter only, so the depth has to be walked rather than trusted."""
    made = []
    root = mc("issue", "create", "--title", title(sid, "playlists"),
              "--description", "The feature. Its children carry the actual work.")
    if not isinstance(root, dict) or not root.get("id"):
        return made
    made.append(root["id"])
    parent = root["id"]
    for depth in range(1, 4):
        ch = mc("issue", "create", "--title", title(sid, f"level-{depth}"),
                "--description", f"Depth {depth}.", "--parent", parent)
        if not isinstance(ch, dict) or not ch.get("id"):
            break
        made.append(ch["id"])
        parent = ch["id"]
    return made


def build_9(sid):
    """Three bugs, so "a severity field on bugs" has something to be about."""
    made = []
    for n in ("map tiles refetch on every pan", "filter change keeps stale results",
              "signup drops at the second screen"):
        i = mc("issue", "create", "--title", title(sid, n),
               "--description", "Reported by users. No severity recorded anywhere.",
               "--status", "todo")
        if isinstance(i, dict) and i.get("id"):
            made.append(i["id"])
    return made


def build_10(sid):
    """A board with work on it. The stall itself is NOT buildable — see the fixture note."""
    made = []
    for n, st in (("export queue", "in_progress"), ("tile cache", "in_progress"),
                  ("newsletter", "todo")):
        i = mc("issue", "create", "--title", title(sid, n),
               "--description", "Queued behind the audio work.", "--status", st)
        if isinstance(i, dict) and i.get("id"):
            made.append(i["id"])
    return made


def build_22(sid):
    """A workspace with enough in it that a real sweep takes minutes: a dozen issues in mixed
    states, an agent, and **an autopilot** — the object the scenario is really about.

    The autopilot is deliberately built in the FAIL shape the rubric names — `create_issue`
    with **no subscriber** — because the assertion is whether the audit *notices* that a finding
    would be created and nobody told. A fixture already in the passing shape tests nothing.
    """
    made = []
    states = [("stale onboarding copy", "todo"), ("map tiles refetch", "in_progress"),
              ("export queue backs up", "in_progress"), ("newsletter for August", "backlog"),
              ("pricing page footnote", "todo"), ("signup funnel drop", "blocked"),
              ("tile cache", "in_review"), ("weekend toggle", "todo"),
              ("search returns stale rows", "todo"), ("brand book", "backlog"),
              ("licence audit of bundled deps", "todo"), ("restore drill", "todo")]
    for n, st in states:
        i = mc("issue", "create", "--title", title(sid, n),
               "--description", "Carried over from the spring. Nobody has looked at it since.",
               "--status", st)
        if isinstance(i, dict) and i.get("id"):
            made.append(i["id"])
    # **Archived entities keep their names and block re-creation** — `agent create` returns a
    # conflict, and the fixture then builds silently *less* than it did the first time. Measured
    # here: every round of this scenario after the first had **no agent and no autopilot**, so
    # "the audit was not dispatched" was scored against a workspace with nobody to dispatch to.
    # Any entity the teardown archives needs a per-build name, exactly as scenario 12 does.
    tok = str(len(issues()) % 1000)
    rt = a_runtime()
    a = None
    if rt:
        a = mc("agent", "create", "--name", title(sid, f"Sweeper-{tok}"),
               "--description", "Runs the weekly audit.", "--model", "claude-sonnet-4-6",
               "--runtime-id", rt)
        if isinstance(a, dict) and a.get("id"):
            made.append(("agent", a["id"]))
    if isinstance(a, dict) and a.get("id"):
        ap = mc("autopilot", "create", "--title", title(sid, f"weekly audit-{tok}"),
                "--description", "Sweep the workspace and report what is rotten.",
                "--mode", "create_issue", "--agent", a["id"])
        if isinstance(ap, dict) and ap.get("id"):
            made.append(("autopilot", ap["id"]))
    return made


def build_17(sid):
    """Two crafts, two competent answers, neither conceding — as a real comment thread.

    The deadlock has to be *in the issue*, not described in the prompt: the assertion is whether
    the run reads the thread and finds the spec underneath it, and a summary handed over in the
    query would be answering a question nobody has to investigate.
    """
    made = []
    i = mc("issue", "create", "--title", title(sid, "empty state for saved trips"),
           "--description", "When a user has no saved trips, what does the list show? "
                            "Backend and design disagree.", "--status", "in_progress")
    if not isinstance(i, dict) or not i.get("id"):
        return made
    made.append(i["id"])
    for body in (
        "**Fen (backend):** An empty saved-trips list is an error state. The endpoint returns "
        "404 on an empty collection, so the client renders the error surface — that is what it "
        "is for, and a second surface duplicates it.",
        "**Wren (design):** It is not an error. A new user with no trips has done nothing "
        "wrong; an error surface tells them something broke. This is an empty state with a call "
        "to action — plan your first trip.",
        "**Fen (backend):** The distinction is not in the UI, it is in the contract. 404 means "
        "the resource is absent. If design wants a different surface the endpoint has to return "
        "200 with an empty array, and nobody has specced that.",
        "**Wren (design):** Then the spec is wrong, not the screen. Every product I can name "
        "shows an empty state here. I am not going to ship an error page to someone who just "
        "signed up.",
    ):
        mc("issue", "comment", "add", i["id"], "--content", body)
    return made


BUILDERS = {"4": build_4, "9": build_9, "10": build_10, "12": build_12, "17": build_17,
            "19": build_19, "22": build_22}

# **Some scenarios are cleaned by title, not by prefix — because the PLAYER creates the
# entities, not the builder, and it names them from the fixture's own data.** Scenario 5 hands
# the run a Linear export and asks for an import; six issues arrive carrying the export's
# titles and none of them carries `EVAL-`. A prefix sweep reports a clean workspace over them,
# which is the same lie the first teardown told.
# Properties the player creates, by name. They **archive** rather than delete (values are
# preserved, and archiving is what frees a slot against the cap of 20) — and they persist
# across runs, so a later run finds one an earlier run made and reports it as already existing.
# Measured on scenario 9: run 2 created `Severity`, run 5 found it and reasoned from it.
PLAYER_PROPERTIES = {"9": ["Severity"]}

PLAYER_MADE = {
    "5": ["Search returns stale results after a filter change",
          "Add a weekend-only toggle to the trip finder",
          "Onboarding: second screen drops 40% of signups",
          "Update the pricing page footnote",
          "Cache the tile layer on the map view",
          "Write the August newsletter"],
}


def teardown(sid):
    """Cancel our issues, archive our agents, delete our squads — and say which was which.

    **A teardown that cannot report its own failure is worse than none.** The first version
    called `issue status --status cancelled`, but the CLI takes the status **positionally**
    (`issue status <id> <status>`); every call failed, the error was swallowed by a
    `check=False`, and it printed *"0 issue(s) cancelled"* over three issues that were still
    live — a clean-looking report of work that did not happen. So failures are counted, named,
    and returned as a nonzero exit: a round that leaves litter must say so, because a probe left
    in a workspace is indistinguishable from real work a month later.
    """
    pre = f"{TAG}-{sid}-"
    by_title = set(PLAYER_MADE.get(sid, []))
    done = {"cancelled": 0, "archived": 0, "deleted": 0}
    failed = []

    for i in issues():
        t = str(i.get("title", ""))
        if (t.startswith(pre) or t in by_title) and i.get("status") != "cancelled":
            if mc("issue", "status", i["id"], "cancelled") is not None:
                done["cancelled"] += 1
            else:
                failed.append(f"issue {i.get('title')}")
    for a in (mc("agent", "list") or []):
        if isinstance(a, dict) and str(a.get("name", "")).startswith(pre):
            if mc("agent", "archive", a["id"]) is not None:
                done["archived"] += 1
            else:
                failed.append(f"agent {a.get('name')}")
    for s in (mc("squad", "list") or []):
        if isinstance(s, dict) and str(s.get("name", "")).startswith(pre):
            if mc("squad", "delete", s["id"]) is not None:
                done["deleted"] += 1
            else:
                failed.append(f"squad {s.get('name')}")
    raw_ap = mc("autopilot", "list")
    for ap in ((raw_ap or {}).get("autopilots", []) if isinstance(raw_ap, dict) else (raw_ap or [])):
        if isinstance(ap, dict) and str(ap.get("title", "")).startswith(pre):
            # Deleted, never disabled: a forgotten autopilot spends quota on nobody's behalf.
            if mc("autopilot", "delete", ap["id"]) is not None:
                done["deleted"] += 1
            else:
                failed.append(f"autopilot {ap.get('title')}")
    props = set(PLAYER_PROPERTIES.get(sid, []))
    if props:
        raw = mc("property", "list")
        for pr in (raw if isinstance(raw, list) else (raw or {}).get("properties", [])):
            if isinstance(pr, dict) and pr.get("name") in props:
                if mc("property", "archive", pr["id"]) is not None:
                    done["archived"] += 1
                else:
                    failed.append(f"property {pr.get('name')}")

    print(f"  teardown {sid}: {done['cancelled']} issue(s) cancelled (there is no delete), "
          f"{done['archived']} agent(s) archived, {done['deleted']} squad(s) deleted")
    if failed:
        print(f"  ! LEFT BEHIND — {len(failed)}: {', '.join(failed[:6])}")
        return 1
    return 0


def main():
    if not WS:
        print("set EVAL_WORKSPACE_ID to the TEST workspace id, never the real one", file=sys.stderr)
        return 2
    if len(sys.argv) < 3:
        print(__doc__.strip().splitlines()[0])
        print("\n    usage: eval-fixture.py <scenario-id> build|teardown")
        return 2
    sid, action = sys.argv[1], sys.argv[2]
    if action == "teardown":
        return teardown(sid)
    if action != "build":
        print(f"unknown action: {action}", file=sys.stderr)
        return 2
    if sid not in BUILDERS:
        print(f"scenario {sid} needs no workspace state, or its builder is not written yet")
        return 0
    teardown(sid)  # build from nothing, never on top of a previous round
    made = BUILDERS[sid](sid)
    print(f"  built {sid}: {len(made)} object(s)")
    return 0 if made else 1


if __name__ == "__main__":
    sys.exit(main())
