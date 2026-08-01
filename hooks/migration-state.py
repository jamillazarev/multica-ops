#!/usr/bin/env python3
"""Report, at session start, whether this workspace was migrated to the version now running it.

**Swapping the skill files is not migrating the company**, and the two are indistinguishable from
outside: a workspace whose `UPGRADES.md` has no line for the installed version looks exactly like
one that migrated cleanly. `UPGRADES.md` is the only thing that tells them apart.

Measured 2026-08-01, scenario 24: given an ordinary *"what's next?"* against exactly that state,
the run never asked the migration question — it opened `/multica-ops:next` and answered what it
was asked, reading **no companion at all**. The rules live in `FLOWS.md`; a `next` run does not
open `FLOWS.md`. **A rule in a file nothing routes to is a rule nothing executes.**

So the state is delivered as a fact before the first message rather than left as a rule to
remember. This hook **reports and never refuses**: it makes no claim the session could forge,
because it only reads a file and says what is in it. Silent whenever there is nothing to say — a
hook that speaks every session is noise. Every internal error fails open.
"""
import json
import os
import re
import subprocess
import sys

PLUGIN_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTCOMES = ("applied", "nothing-required", "declined", "deferred", "failed")


def out():
    sys.exit(0)


def repo_root(path):
    try:
        r = subprocess.run(["git", "-C", path, "rev-parse", "--show-toplevel"],
                           capture_output=True, text=True, timeout=5)
        return r.stdout.strip() if r.returncode == 0 else None
    except Exception:
        return None


def skill_version():
    try:
        txt = open(os.path.join(PLUGIN_ROOT, "skills", "mops", "SKILL.md"),
                   encoding="utf-8", errors="replace").read(2000)
        m = re.search(r"^version:\s*(\S+)", txt, flags=re.M)
        return m.group(1) if m else None
    except Exception:
        return None


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        out()
    if payload.get("hook_event_name") != "SessionStart":
        out()

    root = repo_root(payload.get("cwd") or ".")
    if not root:
        out()

    # A workspace we operate: a guide that names this skill, or the upgrade log itself.
    ours = os.path.isfile(os.path.join(root, "UPGRADES.md"))
    for guide in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        p = os.path.join(root, guide)
        try:
            if os.path.isfile(p) and "multica-ops" in open(p, encoding="utf-8", errors="replace").read().lower():
                ours = True
        except Exception:
            out()
    if not ours:
        out()

    v = skill_version()
    if not v:
        out()

    log = os.path.join(root, "UPGRADES.md")
    try:
        if not os.path.isfile(log):
            sys.stdout.write(
                f"multica-ops {v}: this workspace has no `UPGRADES.md`, so nothing records whether "
                f"it was ever migrated — and swapping the skill's files is not migrating the "
                f"company. Before acting on it, say so, run the migration delta (FLOWS.md → "
                f"*Getting current*), and open the log with its outcome.\n")
            sys.exit(0)
        txt = open(log, encoding="utf-8", errors="replace").read()
    except Exception:
        out()

    for line in txt.split("\n"):
        if v in line and any(o in line for o in OUTCOMES):
            out()  # recorded — say nothing

    sys.stdout.write(
        f"multica-ops {v}: `UPGRADES.md` has no line for version {v}, so this workspace is not "
        f"recorded as migrated to the version now running it — and swapping the skill's files is "
        f"not migrating the company. Before acting on it, say so, run the migration delta "
        f"(FLOWS.md → *Getting current*) — one list split by whether it needs the owner — and "
        f"append a line with its outcome, `nothing-required` included.\n")
    sys.exit(0)


if __name__ == "__main__":
    main()
