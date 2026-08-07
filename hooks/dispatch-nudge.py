#!/usr/bin/env python3
"""Name the moment a run is performing the work it said it would dispatch.

**The third reproduction of one failure.** Asked to audit a workspace, five runs of five next
door and **three of three here** ran the sweep inline — 26, 35 and 7 tool calls inside the turn
— instead of dispatching it to an agent. The rule is in the corpus (*the audit is dispatched,
not performed*), it is `prose-only`, and prose does not hold the light tier. Two rules in this
release took the same shape and the same repair: **a form, not a stronger sentence.**

**What this can and cannot see.** A hook cannot tell an audit from ordinary work, and must not
try — a gate that guesses intent is one that fires on the wrong thing and gets switched off. It
can see something narrower and sufficient: **a long unbroken run of read-only calls with
nothing dispatched, written or transitioned.** That shape is the same whether it comes from an
audit performed inline or from a session digging through a tree it should have asked about, and
the note is useful in both.

**It reports and never refuses.** Unlike the outward-act and rule-home gates, there is nothing
here to forbid: reading is legitimate, and the twentieth read is only *probably* the wrong move.
So this is a `PostToolUse` note, delivered once and then retired for the session — **a
suggestion's value is inverse to how often it appears**, and a nag is how a real signal gets
tuned out.

**And the delivery channel is the whole difference between a note and nothing.** Measured
2026-08-07: the first version wrote to **stderr and exited 0** — the hook fired on every call
(proved with a marker file) and **the model never saw a word of it**, so the rate did not move
and the repair looked like a failed idea rather than a mis-wired one. `PostToolUse` reaches the
model only through **`hookSpecificOutput.additionalContext`** on stdout, which is what this
emits. A refusal at `PreToolUse` gets its message across by exiting 2; a note has to be handed
over deliberately.

Any write, dispatch or status change resets the count, because each is evidence that the run is
doing something with what it has read.
"""
import json
import os
import re
import sys
import tempfile

THRESHOLD = int(os.environ.get("MOPS_DISPATCH_THRESHOLD", "14"))

READ_ONLY = {"Read", "Glob", "Grep", "NotebookRead", "WebFetch", "WebSearch", "ToolSearch"}
# A Bash call that only looks. Anything else — a create, an assign, a commit — is action.
LOOKING = re.compile(r"^\s*(?:multica\s+\w+\s+(?:list|get|status|runs|usage|search|children)"
                     r"|git\s+(?:log|show|status|diff|branch)"
                     r"|ls|cat|find|grep|rg|head|tail|wc|tree|awk|sed\s+-n)\b")


def out():
    sys.exit(0)


def state_path(sid):
    safe = re.sub(r"[^A-Za-z0-9_-]", "", str(sid))[:64] or "nosession"
    home = os.environ.get("MOPS_GATE_DIR") or tempfile.gettempdir()
    return os.path.join(home, f"mops-dispatch-{safe}")


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        out()
    if payload.get("hook_event_name") != "PostToolUse":
        out()
    if str(os.environ.get("MOPS_DISPATCH_NUDGE", "")).lower() in ("off", "0", "false"):
        out()

    tool = payload.get("tool_name") or ""
    cmd = str((payload.get("tool_input") or {}).get("command") or "")
    looking = tool in READ_ONLY or (tool == "Bash" and bool(LOOKING.match(cmd)))

    p = state_path(payload.get("session_id"))
    try:
        n = int(open(p).read().strip() or 0)
    except Exception:
        n = 0
    if n < 0:
        out()  # already spoken this session; retired

    if not looking:
        try:
            open(p, "w").write("0")   # a write, a dispatch, a transition — the run is acting
        except OSError:
            pass
        out()

    n += 1
    if n < THRESHOLD:
        try:
            open(p, "w").write(str(n))
        except OSError:
            pass
        out()

    try:
        open(p, "w").write("-1")      # said once, then never again this session
    except OSError:
        pass
    note = (
        f"{n} read-only calls in a row, with nothing written, dispatched or moved. "
        "**If this is a sweep — an audit, a health check, a status read across the whole "
        "workspace — it is supposed to be *dispatched*, not performed here.** Assign it to an "
        "agent and say concretely what was sent, roughly how long, and which issue or run to "
        "watch; then carry on with the conversation while it runs. A report produced by doing "
        "the work inline costs the owner a turn they could have spent talking to you. "
        "If it is not a sweep, say what you now know and take the next real step. "
        "This note arrives once.")
    json.dump({"hookSpecificOutput": {"hookEventName": "PostToolUse",
                                      "additionalContext": note}}, sys.stdout)
    sys.exit(0)   # a note, not a refusal


if __name__ == "__main__":
    main()
