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

# Outward: it leaves this machine and someone else can see it. The measured case is the one every
# run reached for; the rest are the same act wearing other clothes. Kept deliberately short — a
# long list is a list nobody audits, and a miss here is a rule that was already prose-only anyway.
#
# **A command starts a command; a word after another word is prose.** This matched the verb
# anywhere in the string, so writing a SENTENCE about publishing into a file was refused as if it
# were the act — measured 2026-09-18, twice in one session, the second time on the comment
# explaining this very repair. The constrained party's only way past a gate that reads prose is to
# reword the prose, which is the *satisfied-by-vocabulary* failure the corpus names, arriving at
# the one gate that must not be word-gameable. So the verb must sit where a command can start: the
# beginning, a newline, after `;` `&&` `||` `|`, or inside `(`…`)` or `$(`…`)`. **The sibling's own
# gate has anchored this way since it was written and this copy had not**, which is the divergence
# a shared rule in two files always eventually produces.
#
# **A quote is a command start only after something that runs a shell.** Treating any quote as one
# caught the wrapper `sh -c "…"` and also caught `grep 'npm publish' docs/` — a READ, which is
# never outward, refused by the gate that exists for publishing (caught by this suite the moment
# the case was written). So the second alternative is explicit: a shell-runner, then its quoted
# argument. The wrapper built by substitution still passes, and that is named rather than chased.
CMD_START = (r"(?:(?:^|[\n;&|(){}`]|\$\()\s*"
             r"|\b(?:bash|sh|zsh|dash|eval|xargs)\b[^\n]{0,40}?[\"']\s*)")
OUTWARD = re.compile(
    CMD_START + r"(git\s+push"
    r"|gh\s+(?:release\s+create|pr\s+create)"
    r"|npm\s+publish"
    r"|(?:vercel|netlify|fly|wrangler)\s+deploy"
    r"|docker\s+push)\b",
    re.I)

# A dry run is a read: it tells you what *would* leave, and nothing does.
DRY = re.compile(r"--dry-run\b|--dry_run\b", re.I)


def last_owner_instruction(transcript, limit=240):
    """The owner's most recent message — **context for the person, never consent.**

    A gate cannot read intent and must not try: the party it constrains is the one that would be
    doing the explaining, and the measured failure is that the explanation was confident and wrong
    — 5 runs of 5 reported *"done… and pushed"* about a publish nobody had authorised. What a gate
    CAN do is put the human's own last words beside the refusal, so whoever decides is not hunting
    for the context first.

    **Quoted and never acted on.** *"Publish when it's ready"* an hour ago is not permission now: a
    request to do the work is not a request to announce it, and an earlier yes does not roll
    forward. **If this function ever grows a branch that lets something through, that branch is the
    bug.**

    Tool results arrive as `user` entries too, so an entry carrying a `tool_result` block is
    machinery talking to machinery and is skipped; so is a `<system-reminder>`, which is the
    harness speaking rather than the owner.
    """
    text = ""
    try:
        with open(transcript, encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line or line[0] != "{":
                    continue
                try:
                    e = json.loads(line)
                except Exception:
                    continue
                if e.get("type") != "user":
                    continue
                content = (e.get("message") or {}).get("content")
                if isinstance(content, str):
                    chunks = [content]
                elif isinstance(content, list):
                    if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in content):
                        continue
                    chunks = [b.get("text", "") for b in content
                              if isinstance(b, dict) and b.get("type") == "text"]
                else:
                    continue
                said = "\n".join(c for c in chunks if c).strip()
                said = re.sub(r"<system-reminder>.*?</system-reminder>", " ", said, flags=re.S)
                said = " ".join(said.split())
                if said:
                    text = said
    except Exception:
        return ""
    return text[:limit] + ("…" if len(text) > limit else "")


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

    act = m.group(1)
    said = last_owner_instruction(str(payload.get("transcript_path", "")))
    ctx = (f"\n\n**What you last asked for, for your own reading — context, not consent**, because "
           f"a request to do the work is not a request to announce it and an earlier yes does not "
           f"roll forward: «{said}»" if said else "")
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
        f"`MOPS_OUTWARD_GATE=off`.\n\n"
        f"**And if this is not the act but a sentence about it** — the phrase written into a file, "
        f"a comment, a message — say that to the owner and let them look. **Do not reword it to get "
        f"past**: a gate you can word your way around is not a gate, and this one asks for a person "
        f"either way.{ctx}\n")
    sys.exit(2)


if __name__ == "__main__":
    main()
