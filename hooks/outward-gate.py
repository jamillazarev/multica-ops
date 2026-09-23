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
# **The two copies had three different verb lists and nobody had written down why** — this one
# missed `flyctl`, `kamal`, `cap`, `make deploy` and `npm run deploy`; the other missed
# `gh pr create`. Aligned 2026-09-18 after a contradiction lens ran them side by side: **a
# divergence that is not deliberate and written down is just a divergence.**
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
#
# **Then an adversarial lens walked in with eleven ways past it, all reproduced** (2026-09-18), and
# each is handled here rather than argued with: **a wrapper word** before the verb (`env X=1`,
# `sudo`, `nohup`, `time`, `nice -n 10`, `command`, `exec`, and a bare `eval` with no quote at all)
# is neither a delimiter nor a runner, so nothing anchored · **a line continuation** is one command
# to the shell and two lines to a regex · **a redirect** needs no space before it, and the lookahead
# did not count `>` as a terminator · **the runner's quote** can sit further than forty characters
# away, so the cap is gone. A **heredoc body** is blanked before matching: it is data being fed to
# another program, and a document that carries the verb at the start of a line is not a publish —
# the same *prose is not an act* defect, arriving back through the newline anchor that repaired it.
CMD_START = (r"(?:(?:^|[\n;&|(){}`]|\$\()\s*"
             r"|\b(?:bash|sh|zsh|dash|eval|xargs)\b[^\n]*?[\"']\s*)")
# **A wrapper word takes flags, a flag takes its own argument, and there can be any number of
# them.** Eight shapes carried the verb past the anchor on 2026-09-18 — `env` with no assignment,
# `env -i`, `env --`, `sudo -u root`, `command -p`, `time -p`, `nice --adjustment=10`,
# `exec -a name` — and listing the option SHAPES was not enough, because a flag with its own
# argument leaves a bare word before the verb. The run that replaced it was capped at four tokens,
# and on 2026-09-23 `env A=1 B=2 C=3 D=4 E=5 F=6 git push` walked past the cap: a bound on the
# UNSAFE side of an anchor is a hole with a number on it. **Any run of tokens, on the same line.**
# The cost is named: a wrapper followed later on its line by a quoted mention of the verb is
# refused, which is the loud side, and the refusal's third door is there for exactly that.
WRAP = r"(?:(?:env|sudo|nohup|time|command|exec|eval|nice)[ \t]+(?:\S+[ \t]+)*)?"
OUTWARD = re.compile(
    CMD_START + WRAP + r"(git\s+push"
    r"|gh\s+(?:release\s+create|pr\s+create)"
    r"|npm\s+publish"
    r"|(?:flyctl|fly|vercel|netlify|wrangler|kamal|cap)\s+deploy"
    r"|(?:npm|yarn|pnpm)\s+run\s+deploy|(?:make|just)\s+deploy"
    r"|docker\s+push)(?=[\s;&|)<>\"'`]|$)",
    re.I)


def _opener_is_code(c, at):
    """Whether a `<<` at `at` sits outside quotes and comments on its own line.

    A line-local scanner, not a parser: single quotes, double quotes with their backslash escape,
    a backslash outside quotes, and a `#` that starts a word. **What it does not read is named,
    not chased** — a quote opened on an EARLIER line, `$'…'`, an arithmetic `$((a<<b))`. Each takes
    a command written to deceive the gate; this gate stops the ordinary spelling of an outward act
    and every variation a working agent produces, and it does not claim to parse bash.
    """
    q, i = None, c.rfind("\n", 0, at) + 1
    while i < at:
        ch = c[i]
        if q is None:
            if ch == "\\":
                i += 2
                continue
            if ch in "'\"":
                q = ch
            elif ch == "#" and (i == 0 or c[i - 1] in " \t\n;&|("):
                return False                    # a comment runs to the end of the line
        elif q == '"' and ch == "\\":
            i += 2
            continue
        elif ch == q:
            q = None
        i += 1
    return q is None


def shell_only(cmd):
    """The command as a shell would run it: continuations folded, heredoc BODIES blanked.

    A heredoc body is data fed to another program, so a document carrying the verb at the start of
    a line is not a publish. **The body starts on the line AFTER the opener** — the rest of the
    opener's own line is still shell, and `cat > f <<EOF && git push` publishes. Blanking from just
    after the delimiter hid exactly that (found 2026-09-23, reproduced end to end). **Both ends must
    be visible or nothing is blanked**: a missing terminator blanked to the end of the string and
    became three ways to publish unseen (2026-09-18). **An opener must be code** — not inside a
    quote, not in a comment, not inside a body already blanked — or a `<<X` in a commit message,
    with a lone `X` two lines down, hides whatever sits between. `(?<!<)<<(?!<)` keeps `<<<`, a
    here-STRING, out; no separator is required before it, because `cat<<EOF` is a heredoc too.
    Every failure of this function is meant to fall on the loud side: a body left visible.
    """
    c = re.sub(r"\\\n", " ", cmd)                    # a continuation is one command
    for m in re.finditer(r"(?<!<)<<-?(?!<)[ \t]*\\?(['\"]?)(\w+)\1", c):
        if c[m.start():m.end()] != m.group(0) or not _opener_is_code(c, m.start()):
            continue                     # inside a body already blanked, a quote, or a comment
        nl = c.find("\n", m.end())
        if nl < 0:
            continue                     # no body at all
        end = re.search(r"^[ \t]*%s[ \t]*$" % re.escape(m.group(2)), c[nl + 1:], re.M)
        if not end:
            continue                     # no terminator in sight: blank nothing
        stop = nl + 1 + end.start()
        c = c[:nl + 1] + re.sub(r"[^\n]", " ", c[nl + 1:stop]) + c[stop:]
    return c

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

    **Most of what arrives as a `user` entry is not the owner**, and an adversarial lens proved
    the first version of this wrong on a real transcript (2026-09-18). Four shapes, each handled:
    a **tool result**, which arrives as a `user` entry; a `<system-reminder>`, **possibly
    unterminated or nested**; a `<task-notification>`, *a background agent's return value routed
    back as a user turn*; and the harness's **conversation-continuation summary**, tens of
    thousands of characters that are not a turn at all. An entry carrying BOTH text and a tool
    result keeps its text — discarding it made the gate quote an older message as *what you last
    asked for*, and a stale instruction reads exactly like a current one.

    **Whatever survives is still untrusted text**, shown between guillemets under a line saying it
    is not consent. An instruction inside it is a thing the human reads, and the human was going to
    decide anyway.
    """
    def _strip(t):
        """Drop the harness's own blocks with a stack of tag NAMES, never by matching pairs — a
        regex leaks what sits between a nested inner close and the outer one, and a plain depth
        counter let a `</task-notification>` close a `<system-reminder>`, handing anything that can
        inject tag-shaped text control over what the refusal shows and hides (reproduced
        2026-09-18). A closing tag closes only the innermost block, and only by its name — a crossed
        close (`<a> <b> </a> … </b>`) popped through `<b>` and put what sat inside it on show,
        reproduced 2026-09-23. An unterminated block leaves the stack non-empty and its tail
        goes; an orphan, mismatched or crossed closing tag is ignored."""
        out, stack, last = [], [], 0
        for m in re.finditer(r"</?(system-reminder|task-notification)>", t):
            closing, name = m.group(0).startswith("</"), m.group(1)
            if not stack:
                out.append(t[last:m.start()])
            if closing:
                if stack and stack[-1] == name:
                    stack.pop()                 # only the innermost block, and only by its name
            else:
                stack.append(name)
            last = m.end()
        if not stack:
            out.append(t[last:])
        return " ".join(out)

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
                bare = isinstance(content, str)
                if bare:
                    chunks = [content]
                elif isinstance(content, list):
                    chunks = [b.get("text", "") for b in content
                              if isinstance(b, dict) and b.get("type") == "text"]
                    if not chunks:
                        continue        # a tool result alone is not the owner speaking
                else:
                    continue
                said = _strip("\n".join(c for c in chunks if c).strip())
                said = " ".join(said.split())
                # **Two signals, because one was spoofable**: a real instruction merely opening
                # with the harness's own words was dropped whole, and the refusal then quoted a
                # SUPERSEDED message as what you last asked for. The summaries arrive as a bare
                # string and are long; a person's turn arrives as text blocks.
                if (bare and len(said) > 2000
                        and said.startswith(("This session is being continued",
                                             "Caveat: The messages below", "[harness:"))):
                    continue
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
    m = OUTWARD.search(shell_only(cmd))
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
