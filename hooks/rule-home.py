#!/usr/bin/env python3
"""Refuse to file the owner's rule in the harness's memory, and name the homes that exist.

**Why this is a hook and not a sentence.** *"Remember this" lands in a file the workers read,
never the chat's memory* shipped as law in 0.4.0 — in the always-loaded core, in PLAYBOOKS, and
in the README. Scenario 26, **five runs of five, wrote the owner's rule into the runtime's
private cross-session memory instead** (`…/projects/<box>/memory/feedback_no_friday_ships.md`)
and nothing into the repository. Not one named a home back. The sibling project measured 2 of 2
on the same trap. That is prose failing at the same rate as the outward-act rule did, and it
gets the same answer: a form.

**Why the memory is the wrong home here specifically.** It is not merely unconventional — it is
**invisible to the people the rule is for**. The workers on this platform are agents that read
the workspace and the repository; they never read your laptop's memory store. A rule filed there
is unreachable by every single one of them while looking, to the person who spoke it, exactly
like it landed.

**It is scoped to workspaces this skill operates**, by the same ownership test the session-start
check uses — a guide naming `Operated by multica-ops`. In an ordinary repository the runtime's
memory is nobody's business but its own, and this stays silent.
"""
import json
import os
import re
import sys

GUIDES = ("CLAUDE.md", "AGENTS.md", "GEMINI.md")
# A memory store, not a project's own `memory/` directory: the path sits outside the tree the
# session is working in, under a config home.
MEMORY = re.compile(r"(?:^|/)(?:memory|memories)/[^/]*$")


def out():
    sys.exit(0)


def operated(root):
    """Does a guide here say this workspace is operated by us? Same test as the session-start
    check, and for the same reason: a tree that merely mentions the name is not ours."""
    for g in GUIDES:
        p = os.path.join(root, g)
        try:
            if os.path.isfile(p):
                t = open(p, encoding="utf-8", errors="replace").read().lower()
                if "operated by" in t and "multica-ops" in t:
                    return True
        except OSError:
            return False
    return False


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        out()  # fails open: a broken gate must not become a broken session
    if payload.get("hook_event_name") != "PreToolUse":
        out()
    if str(os.environ.get("MOPS_RULE_HOME_GATE", "")).lower() in ("off", "0", "false"):
        out()
    if payload.get("tool_name") not in ("Write", "Edit", "NotebookEdit"):
        out()

    path = str((payload.get("tool_input") or {}).get("file_path") or "")
    if not path or not MEMORY.search(path):
        out()

    cwd = str(payload.get("cwd") or os.getcwd())
    # A `memory/` directory inside the tree being worked on is the project's own and none of our
    # business. Only a store outside it is the trap.
    try:
        if os.path.abspath(path).startswith(os.path.abspath(cwd) + os.sep):
            out()
    except Exception:
        out()
    if not operated(cwd):
        out()

    sys.stderr.write(
        "That path is the runtime's own cross-session memory — **outside this repository, and "
        "unread by every agent in this workspace.** A rule filed there is invisible to the "
        "people it is for while looking, to whoever spoke it, exactly like it landed.\n\n"
        "**Put it in a home that the workers actually read, and say which one you chose:**\n"
        "  · a behaviour every agent must follow → a line in the guide (`CLAUDE.md`), in effect "
        "at the next boundary\n"
        "  · a word this company uses in its own way → the guide's glossary section\n"
        "  · a choice, with its reason → `_ops/DECISIONS.md`, append-only\n"
        "  · a place to look or a thing to use → `_ops/TOOLING.md`, with its why\n"
        "  · not now → `_ops/LATER.md`, with a revisit trigger\n")
    sys.exit(2)


if __name__ == "__main__":
    main()
