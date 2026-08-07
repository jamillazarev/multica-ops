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


def mc(*args, check=True):
    """One CLI call, scoped to the test workspace, JSON in and out."""
    env = dict(os.environ, MULTICA_WORKSPACE_ID=WS)
    r = subprocess.run(["multica", *args, "--output", "json"],
                       capture_output=True, text=True, env=env)
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


BUILDERS = {"4": build_4, "12": build_12, "19": build_19}


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
    done = {"cancelled": 0, "archived": 0, "deleted": 0}
    failed = []

    for i in issues():
        if str(i.get("title", "")).startswith(pre) and i.get("status") != "cancelled":
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
