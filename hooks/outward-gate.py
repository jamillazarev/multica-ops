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
import shlex
import sys

# Outward: it leaves this machine and someone else can see it. The measured case is the one every
# run reached for; the rest are the same act wearing other clothes. Kept deliberately short — a
# long list is a list nobody audits, and a miss here is a rule that was already prose-only anyway.
# **The two copies had three different verb lists and nobody had written down why** — this one
# missed `flyctl`, `kamal`, `cap`, `make deploy` and `npm run deploy`; the other missed
# `gh pr create`. Aligned 2026-09-18 after a contradiction lens ran them side by side: **a
# divergence that is not deliberate and written down is just a divergence.** The alignment missed
# one: the other copy has always ended its list with a catch-all for a project's own deploy
# script — `./scripts/deploy`, `terraform-deploy` — and this one never had it. Found by a
# contradiction lens on 2026-09-23 and crossed the loud way; the next day an adversarial lens found
# it refusing `predeploy` and `./scripts/predeploy`, local checks that publish nothing, so `deploy`
# must now be the whole name or follow a `/` `-` `_` `.`, and never `pre-`.
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
# refused, which is the loud side, and the refusal's closing line — *if this is a sentence
# about the act, say so to the owner* — is there for exactly that.
WRAP = r"(?:(?:env|sudo|nohup|time|command|exec|eval|nice)[ \t]+(?:\S+[ \t]+)*)?"
# **A tool takes global options before its subcommand, and can be named by its path.**
# `git -C . push`, `git -c k=v push`, `gh -R o/r release create`, `npm --prefix x publish`,
# `docker --context x push` and `/usr/bin/git push` all went through both gates from the day
# they were written, because the pattern wanted the subcommand straight after the name — found on
# 2026-09-24, the absolute path by an adversarial lens and the options by checking what else that
# shape covered. They are read as the same act now, and refused: any run of option tokens
# between the two, and any path before the name.
# **A word is read the way a shell reads one** — quoted parts may hold spaces — **and an argument
# that merely STARTS with a subcommand word is still an argument.** `npm --prefix publish-tools
# publish`, `gh -R pr-team/r release create`, `git -c "user.name=x y" push` and a quoted path with
# a space in it all passed while this read `\S` and `\b` (an adversarial lens, 2026-09-24). A
# path, or a bare name, may open a quote the name closes — `"git" push`, 2026-09-24 — which is
# what the optional quote after each name is for — and every word of the act may be quoted whole,
# `git "push"`, since quoting each word is an ordinary habit (2026-09-24). **What is not read, by
# design**: a verb the shell assembles from parts — `pu'sh'`, `$v` — is a decision to hide the
# act, and this gate does not claim to parse bash against the one it constrains. **And an
# option whose argument IS one of the act's words** — `npm --workspace publish install` — is
# read as the act and refused: a pattern cannot know which options take an argument, so of the
# two readings it takes the one that stops (2026-09-24, declined as a defect, kept as a limit).
WORD = r"""(?:[^\s"'\\]|\\.|"(?:[^"\\]|\\.)*"|'[^']*')"""
OPTS = (r"(?:\s+-" + WORD + r"*(?:\s+(?![\"']?(?:push|publish|release|pr|run|deploy)[\"']?(?:\s|$))(?!-)"
      + WORD + r"+)?)*")
QUOTE = r"""["']?"""


def say(*words):
    """The act's words, each one of which may be quoted whole."""
    return "".join(r"\s+" + QUOTE + w + QUOTE for w in words)


# the same alternatives, in the same order, as the other copy of this gate
OUTWARD = re.compile(
    CMD_START + WRAP + r"((?:[\"'][^\"'\n]*/|[\"']|[\w.~/-]*/)?(?:"
    r"git" + QUOTE + OPTS + say("push") +
    r"|gh" + QUOTE + OPTS + r"(?:" + say("release", "create") + r"|" + say("pr", "create") + r")"
    r"|npm" + QUOTE + OPTS + say("publish") +
    r"|docker" + QUOTE + OPTS + say("push") +
    r"|(?:npm|yarn|pnpm)" + QUOTE + OPTS + say("run", "deploy") +
    r"|(?:make|just)" + QUOTE + OPTS + say("deploy") +
    r"|(?:flyctl|fly|vercel|netlify|wrangler|kamal|cap)" + QUOTE + OPTS + say("deploy") + r")"
    r"|(?:[\w./-]*[/_.-])?(?<!pre[-_])deploy)(?=[\s;&|)<>\"'`]|$)",
    re.I)


_SPECIAL = re.compile(r"[\n\\#$()'\"<`{}]")
_QUOTED = {"'": re.compile(r"'"), '"': re.compile(r'[\\"$`]'), "$'": re.compile(r"[\\']")}
_OPENER = re.compile(r"<<(-?)[ \t]*\\?(['\"]?)(\w+)\2")


def shell_only(cmd):
    """The command as a shell would run it: continuations folded, heredoc BODIES blanked.

    A heredoc body is data fed to another program, so a document carrying the verb at the start of
    a line is not a publish. **Every regex over the raw string was out-guessed within a round**: a
    missing terminator blanked to the end of the string (2026-09-18); a body blanked from right
    after the delimiter hid `cat > f <<EOF && git push`, because bash starts the body on the NEXT
    line (2026-09-23); a `<<X` inside `$'…'` or `$((…))` was taken for an opener and hid the push
    on the line after it (2026-09-23); and a double quote inside `$(…)` within a double-quoted
    string closed the outer string early, so a `<<X` still inside it was read as code (2026-09-24).
    Each of the last three was confirmed in real bash against a stub `git`.

    So this is one pass, left to right, **keeping the state bash keeps**: outside quotes or inside
    `'…'`, `"…"` or `$'…'`; inside arithmetic `((…))`; in a `#` comment; and, inside a double-quoted
    string, inside a `$(…)`, a backtick pair or a `${…}`, each with its own quoting, on a stack. A
    `<<` opens a heredoc only where bash would read one — never in a quote, a comment, arithmetic or
    a `${…}`, and `<<<` is a here-STRING, not an opener. Bodies are read the way bash reads them:
    after the newline that ends the command, every heredoc of that line in order, each to a line
    that IS its word (after leading tabs, for `<<-`). **No terminator, or an unclosed quote, and
    nothing more is blanked**: bash would run none of the rest, so leaving it visible costs a false
    refusal at worst. **A comment is blanked too**, since bash never reads it: a trailing
    `# --dry-run tested this yesterday` was excusing the real act it trailed (2026-09-24). One pass
    keeps it linear — a scan per opener took 13 s on a 358 KB command of unterminated openers, and
    this takes 0.05–0.08 s as a whole hook call (both measured 2026-09-23).

    **What it does not track can hide a publish, and is named for that reason**: a `case` pattern's
    unmatched `)` inside a command substitution within a double-quoted string closes the
    substitution early, and so would any other construct whose bracket bash balances by grammar
    rather than by count. Nothing an agent writes by accident has been found in that shape; the
    ones that were found are closed above.
    """
    c = re.sub(r"\\\n", " ", cmd)                    # a continuation is one command
    out, n, i = list(c), len(c), 0
    q, arith, depth, ctx, pending, stack = None, 0, 0, "code", [], []
    while i < n:
        if q is not None:                            # inside a quote: its end, an escape, or a
            s = _QUOTED[q].search(c, i)              # substitution opening inside "…"
            if not s:
                break                                # never closed: bash runs none of it
            i, ch = s.start(), s.group()
            if ch == "\\":
                i += 2
                continue
            if ch == "`":
                opened = ("code", "`", 1)
            elif ch == "$" and c.startswith("$(", i) and not c.startswith("$((", i):
                opened = ("code", ")", 2)
            elif ch == "$" and c.startswith("${", i):
                opened = ("param", "}", 2)
            elif ch == "$":
                i += 1
                continue
            else:
                q, i = None, i + 1
                continue
            stack.append((q, arith, depth, ctx, opened[1]))
            q, arith, depth, ctx, i = None, 0, 0, opened[0], i + opened[2]
            continue
        s = _SPECIAL.search(c, i)
        if not s:
            break
        i, ch = s.start(), s.group()
        if ch == ")" and arith and c.startswith("))", i):
            arith, i = arith - 1, i + 2
        elif stack and ch == stack[-1][4] and depth == 0:
            q, arith, depth, ctx, _ = stack.pop()    # back inside the string it opened in
            i += 1
        elif ch == "\n":
            i += 1
            for dash, word in pending:               # each body, in the order its opener came
                j = i
                while True:
                    e = c.find("\n", j)
                    line = c[j:] if e < 0 else c[j:e]
                    if (line.lstrip("\t") if dash else line) == word:
                        break
                    if e < 0:
                        return "".join(out)          # no terminator: the rest stays visible
                    j = e + 1
                for k in range(i, j):
                    if out[k] != "\n":
                        out[k] = " "
                i = n if e < 0 else e + 1
            pending = []
        elif ch == "\\":
            i += 2
        elif ch == "#" and ctx == "code" and (i == 0 or c[i - 1] in " \t\n;&|("):
            e = c.find("\n", i)                      # a comment runs to its newline, and is
            e = n if e < 0 else e                    # blanked: bash never reads a word of it
            for k in range(i, e):
                out[k] = " "
            i = e
        elif ch == "$" and c.startswith("$'", i):
            q, i = "$'", i + 2
        elif ch == "$" and c.startswith("$((", i):
            arith, i = arith + 1, i + 3
        elif ch == "(" and ctx == "code" and c.startswith("((", i):
            arith, i = arith + 1, i + 2
        elif ch == "(" and ctx == "code":
            depth, i = depth + 1, i + 1
        elif ch == ")" and ctx == "code" and depth:
            depth, i = depth - 1, i + 1
        elif ch == "{" and ctx == "param":
            depth, i = depth + 1, i + 1
        elif ch == "}" and ctx == "param" and depth:
            depth, i = depth - 1, i + 1
        elif ch in "'\"":
            q, i = ch, i + 1                         # bash 3.2 reads `'` in "${…}" as a quote too
        elif ch == "<" and c.startswith("<<<", i):
            i += 3                                   # a here-STRING, not a heredoc
        elif ch == "<" and ctx == "code" and not arith:
            m = _OPENER.match(c, i)
            if m:
                pending.append((m.group(1), m.group(3)))
                i = m.end()
            else:
                i += 1
        else:
            i += 1
    return "".join(out)


def command_end(c, i):
    """Where the simple command holding the act at `i` ends — read from index 0 of the whole text
    the hook received, NOT from the previous separator, because a window that starts where a pair
    may already be open cannot tell an opening backtick from a closing one.

    Bash's own state is kept on the way: quotes, a backslash escaping the next character outside
    single quotes, and every `$(…)`, `$((…))`, `<(…)`, `>(…)`, backtick pair or grouping `(…)` on
    a stack with its own quoting — a grouping pair because `$((1 + (2*3)))` closed the arithmetic
    one parenthesis early and refused a real dry run (2026-09-24). The act's *depth* is how many of those are open where it starts; the command holding
    it ends at the first `\n ; & | )` outside quotes at that depth, or where the pair holding the act
    closes. Arithmetic and process substitution were read as ordinary parentheses until 2026-09-24, so
    `branch$((1+1)) --dry-run` was refused as a publish. A bare character split stopped at a `)` inside a quoted
    release note; a flat quote flag was fooled by `"… $(date "+%Y (UTC)") …"`; and a window started
    at the act read the backtick that closed `` `git push` --dry-run `` as opening another pair —
    three misreadings on 2026-09-24, two loud and one a hole."""
    stack, q, k, depth = [], None, 0, None
    while k < len(c):
        if depth is None and k >= i:
            depth = len(stack)                       # the depth of the command holding the act
        ch = c[k]
        if q == "'":
            q = None if ch == "'" else q
            k += 1
            continue
        if ch == "\\":
            k += 2
            continue
        if c.startswith("$((", k):
            opener = ("))", 3)                       # arithmetic, closed by its own doubled paren
        elif c.startswith("$(", k) or (q is None and c.startswith(("<(", ">("), k)):
            opener = (")", 2)                        # a command or process substitution
        elif ch == "`":
            opener = ("`", 1)
        elif q is None and ch == "(":
            opener = (")", 1)                        # a subshell, or grouping inside arithmetic
        else:
            opener = None
        if q == '"':
            if ch == '"':
                q = None
            elif opener:
                stack.append((q, opener[0]))
                q = None
                k += opener[1]
                continue
            k += 1
            continue
        if stack and c.startswith(stack[-1][1], k):
            if depth is not None and len(stack) == depth:
                return k                             # the pair holding the act closes
            k += len(stack[-1][1])
            q = stack.pop()[0]
            continue
        if ch in "'\"":
            q = ch
        elif opener:
            stack.append((None, opener[0]))
            k += opener[1]
            continue
        elif depth is not None and len(stack) == depth and ch in "\n;&|)":
            return k
        k += 1
    return len(c)

# **A dry run is a read — of its OWN act, and of nothing else on the line.** Both spellings,
# case-blind. It used to exempt the whole command: `echo testing --dry-run`, then a real
# `git push` on the next line, went through both gates — and so did a comment that merely
# mentioned the flag (an adversarial lens, 2026-09-24). So every outward act is found, and each is
# excused only by a `--dry-run` in its own simple command — which ends where `command_end` says,
# so `$(git push) --dry-run`, whose push runs inside the substitution before the flag is ever
# read, is not excused. **And the flag has to mean dry**: `npm publish --dry-run=false` publishes, so only
# the bare flag or `=true` · `=1` · `=yes` excuses anything (both 2026-09-24). A comment is gone
# before this reads the line: `shell_only` blanks it.
# **And the flag has to be a word of that command.** `git push origin mainX--dry-run` was
# excused because the pattern found the flag glued to another word (2026-09-24), so the command is
# split the way a shell splits it and only a whole word counts — the act's own options included,
# since `npm --dry-run publish` is a dry run too. A command that will not split is not excused.
DRY = re.compile(r"--dry[-_]run(?:=(?:true|1|yes))?", re.I)


def is_dry(words):
    """Whether a whole shell word of `words` is a dry-run flag that means dry."""
    try:
        return any(DRY.fullmatch(w) for w in shlex.split(words))
    except ValueError:
        return False


def first_act(c):
    """The first outward act in `c` that is not a dry run of itself, or None."""
    for m in OUTWARD.finditer(c):
        if not is_dry(c[m.start(1):command_end(c, m.start(1))]):
            return m
    return None


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
    if not cmd:
        out()
    m = first_act(shell_only(cmd))
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
