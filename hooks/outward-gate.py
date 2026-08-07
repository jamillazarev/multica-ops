#!/usr/bin/env python3
"""Stop an outward act, so the owner's word is asked for rather than assumed.

**Why this is a hook and not a sentence.** The rule — *spending, outward acts, destruction and
reshaping the team are the owner's, and no history buys them* — is in the core, in PLAYBOOKS's
gate table, and in the README. It is also `prose-only`, and prose does not hold the light tier:
**measured 2026-08-07, scenario 1, 5 runs of 5 went `Edit → git add → git commit → git push`
without asking**, and all five reported *"Done… and pushed"* afterwards. The corpus's own ladder
says what to do about a prose rule that keeps failing — *a form, not a stronger sentence* — and
this is the form.

**It stops every time, and the first design stopped once — measured, and wrong.** The
stop-once-then-let-the-retry-pass shape was borrowed from a role gate where the *owner* is the
one who insists. Here the retryer is the model: measured 2026-08-07 across five runs, the rate
moved 0/5 → 2/5, and **the other three simply ran `git push` again and it went through** —
`push_attempts=3` in each transcript. That is this repository's own law arriving from the other
side: *a gate whose bypass the constrained party can perform is not a gate, it is a prompt
naming the sentence that unlocks the door* (PLAYBOOKS → Gates). A hook cannot tell *the owner
said yes* from *the model tried again*, so it must not pretend to.

**So the door is named instead of built into the gate**: the owner runs the push themselves, or
turns this off deliberately (`MOPS_OUTWARD_GATE=off`, which is a decision with a name rather
than a retry that looks like consent). The cost is honest and stated — an owner who genuinely
wants the agent to push must say so once in their settings.

**What it deliberately does not do.** It does not judge whether the push is a good idea, does
not read the diff, and does not touch anything that is not leaving this machine. Local work —
`git commit`, `git add`, a branch, a local build — is not an outward act and never trips it.

Measured caveat, corrected: plugin `PreToolUse` hooks **do** fire under `claude -p` (probed
2026-08-07 on Claude Code 2.1.220 — a matcher-`Bash` hook fired on the first tool call of a
headless run). The earlier note next door said they did not; it does not hold here.
"""
import json
import os
import re
import sys

# Outward: it leaves this machine and someone else can see it. `git push` is the measured case;
# the rest are the same act wearing other clothes. Kept deliberately short — a long list is a
# list nobody audits, and a miss here is a rule that was already prose-only anyway.
OUTWARD = re.compile(
    r"\bgit\s+push\b"
    r"|\bgh\s+(?:release\s+create|pr\s+create)\b"
    r"|\bnpm\s+publish\b"
    r"|\b(?:vercel|netlify|fly|wrangler)\s+deploy\b"
    r"|\bdocker\s+push\b",
    re.I)

# A dry run is a read: it tells you what *would* leave, and nothing does.
DRY = re.compile(r"--dry-run\b|--dry_run\b", re.I)


def out():
    sys.exit(0)


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        out()  # every internal error fails open: a broken gate must not become a broken session
    if payload.get("hook_event_name") != "PreToolUse":
        out()
    # An explicit, named off-switch — the owner's decision, not a retry that looks like consent.
    if str(os.environ.get("MOPS_OUTWARD_GATE", "")).lower() in ("off", "0", "false"):
        out()
    if payload.get("tool_name") != "Bash":
        out()

    cmd = str((payload.get("tool_input") or {}).get("command") or "")
    if not cmd or DRY.search(cmd):
        out()
    m = OUTWARD.search(cmd)
    if not m:
        out()

    act = m.group(0)
    sys.stderr.write(
        f"`{act}` is an outward act — it leaves this machine and someone else can see it, "
        f"which is one of the four kinds that are the owner's to authorise (spend · outward · "
        f"destructive · shape-of-company).\n\n"
        f"**Say what is about to go out and to where, and hand it back.** Being told to do the "
        f"work is not the same as being told to publish it, and a request carries no blanket "
        f"authorisation for the pushes after it.\n\n"
        f"**Running it again will not work, and that is deliberate** — a gate the constrained "
        f"party can retry past is not a gate. The two real doors: the owner runs the command "
        f"themselves, or the owner turns this gate off on purpose with "
        f"`MOPS_OUTWARD_GATE=off`.\n")
    sys.exit(2)


if __name__ == "__main__":
    main()
