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

**What this hook must never sound like.** Measured 2026-08-02, scenario 25: a wording that said
recording *"is not gated on approval"* was read by a run as **an injection attempt** — a system
message pushing file edits through without the owner's say-so — and it refused the entire flow,
correctly by its own lights. **A message that disclaims the owner's approval has the exact shape
of an attack, and the more carefully a model reads, the more reliably it will refuse.** So this
text names *what to record* and never *whose permission is unnecessary*. One run in two tripped
on it, which is a coin flip, which is broken.
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


def operator_line(root):
    """The line by which a workspace declares *this* skill operates it, and the version it names.

    Returns `(guide, version-or-None)`, or `None` where no such line exists.

    **Ownership is an operator line, never a mention.** The first version of this hook called a
    tree ours when any guide merely contained the string `multica-ops`, and the cost landed on
    2026-08-07 in the most visible place available: **the skill's own repository**, whose
    `AGENTS.md` names the skill because it *is* the skill. Every development session opened
    with a migration notice about a company that does not exist. Anything that answers *is this
    ours* by substring match will say yes to the source tree, to a fixture, and to a repository
    whose README merely recommends us.

    The mutation suite had assumed this rule from the start — every fixture declares itself with
    `Operated by multica-ops` — and asserted it nowhere, so the implementation drifted below its
    own tests in silence. **A guard whose fixtures are stricter than its code is a guard nobody
    is testing.**
    """
    for guide in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        p = os.path.join(root, guide)
        try:
            if not os.path.isfile(p):
                continue
            for line in open(p, encoding="utf-8", errors="replace"):
                if "operated" in line.lower() and "multica-ops" in line.lower():
                    m = re.search(r"(\d+\.\d+\.\d+)", line)
                    return guide, (m.group(1) if m else None)
        except Exception:
            return None
    return None


def guide_version(root):
    """The version the workspace's own guide claims to be operated by, if it states one.

    Measured 2026-08-01, scenario 24 at N=3: **no run bumped this line**, and two then wrote a
    migration-log line, which silences the log check for good — leaving a workspace asserting one
    version in `UPGRADES.md` and another in the guide, with nothing left to notice. **A check
    that can be satisfied without fixing what it was built to catch turns a visible problem into
    an invisible one.**

    Only a line that says *operated* counts. Prose mentioning a version — a changelog quote, a
    note about what some release corrected — is not a claim about what runs this workspace, and
    matching it would produce a hook that cries wolf and gets switched off.

    **A limit, named rather than papered over: silencing this is one edit away.** A session that
    bumps the line without migrating anything makes the hook quiet, exactly as writing a log line
    does. That is tolerable *here* only because this is not a gate — it refuses nothing and
    asserts nothing about whether work happened. It reports that two files disagree, which is
    true or false independently of who wrote them. **Anything built on top of it that starts
    treating the line as proof would be the forgeable-evidence trap this project has already paid
    for twice.**
    """
    g = operator_line(root)
    return g if g and g[1] else None


def log_entries(txt):
    """`UPGRADES.md` as entries, not as physical lines.

    Measured 2026-08-02, scenario 25: a run wrote a correct four-line entry — version on the
    first line, `Outcome: applied.` on the fourth — and a per-line check called it **absent**,
    so the hook would have nagged forever about a migration that had happened. **A record's
    grammar is a paragraph, and anything reading it a line at a time is reading a different
    file.** An entry starts at a `-` bullet and runs until the next one.
    """
    entries, cur = [], []
    for line in txt.split("\n"):
        if line.lstrip().startswith(("- ", "* ")):
            if cur:
                entries.append(" ".join(cur))
            cur = [line.strip()]
        elif cur and line.strip():
            cur.append(line.strip())
        elif cur:
            entries.append(" ".join(cur))
            cur = []
    if cur:
        entries.append(" ".join(cur))
    return entries


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

    # A workspace we operate: a guide carrying an operator line, or the upgrade log itself.
    # A mention of the name is not a claim to be operated — see `operator_line`.
    if not (os.path.isfile(os.path.join(root, "UPGRADES.md")) or operator_line(root)):
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

    logged = any(v in e and any(o in e for o in OUTCOMES) for e in log_entries(txt))

    # The guide is checked whether or not the log is current, because the failure this exists to
    # catch is precisely the two disagreeing: a log that names the running version while the file
    # every session reads still names an older one.
    g = guide_version(root)
    if g and g[1] != v:
        name, claimed = g
        if logged:
            sys.stdout.write(
                f"multica-ops {v}: `UPGRADES.md` records the migration to {v}, but `{name}` still "
                f"says this workspace is operated by **{claimed}**. **The two disagree, and the "
                f"guide is the one every session reads.** The log being current is why nothing "
                f"else will raise this. Reconcile the version line before acting on the "
                f"workspace, and say which one was right.\n")
        else:
            sys.stdout.write(
                f"multica-ops {v}: `UPGRADES.md` has no line for version {v} and `{name}` says "
                f"this workspace is operated by **{claimed}** — so it is not recorded as migrated "
                f"to the version now running it, and swapping the skill's files is not migrating "
                f"the company. Before acting on it, say so, run the migration delta (FLOWS.md → "
                f"*Getting current*) — one list split by whether it needs the owner — **bump the "
                f"version line in `{name}`**, and append a line with its outcome. If the check "
                f"ends with a question for the owner, the outcome word for that is "
                f"`deferred`.\n")
        sys.exit(0)

    if logged:
        out()  # recorded, and the guide agrees — say nothing

    sys.stdout.write(
        f"multica-ops {v}: `UPGRADES.md` has no line for version {v}, so this workspace is not "
        f"recorded as migrated to the version now running it — and swapping the skill's files is "
        f"not migrating the company. Before acting on it, say so, run the migration delta "
        f"(FLOWS.md → *Getting current*) — one list split by whether it needs the owner — and "
        f"append a line with its outcome. If the check ends with a question for the owner, "
        f"the outcome word for that is `deferred`.\n")
    sys.exit(0)


if __name__ == "__main__":
    main()
