#!/usr/bin/env python3
"""The Trio line of a release entry says what the release added — this measures whether it did.

    python3 scripts/check-trio.py            # the newest entry, against the last tag before it
    python3 scripts/check-trio.py 0.2.19     # a released entry, against the tag before its own

Every entry ends with a `**Trio:**` paragraph naming the diagrams, situations and facts the
release added. 0.2.19's Trio line said diagrams 8 · situations 21 · facts 262–277, over a range that
added 10 · 24 · 262–282: the lens rounds read each repair's diff
and nothing read the entry against the release as a whole (found by the owner, 2026-09-25).

What is measured, between the tag before the entry and the entry's own tag (or the working
tree for the unreleased one):
- **diagrams** — mermaid blocks, net, across every tracked `.md` but the changelog;
- **situations** — data rows, net, in the use-case file (`use-cases.md` · `USE-CASES.md`);
- **facts** — numbers new in `facts.md`, or entries new in `sources/SOURCES.md` (`### id · …`).

The claim is read from the Trio paragraph: a number word or digits before *diagram(s)* and
*situation(s)*, `no diagram` / `no situation` as zero, and for facts every bold number or range
after `facts.md` — or a number word before *register entr(y|ies)*. **A kind the paragraph does not
mention is not compared** — a Trio line is prose, and a phrasing this cannot read is reported as
unread rather than guessed. Exit 1 on a mismatch, 2 when there is nothing to compare.

**Named limits**: the counts are NET, so a diagram or a situation removed elsewhere in the same
release lowers them — the line then states the net, or names the removal; and a number word is
read as the house writes it, `twenty-four` with its hyphen (`twenty four` reads as four).
"""
import re
import subprocess
import sys
from pathlib import Path

WORDS = {w: i for i, w in enumerate(
    "zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen "
    "fifteen sixteen seventeen eighteen nineteen".split())}
WORDS.update({"twenty": 20, "thirty": 30, "forty": 40, "fifty": 50, "sixty": 60, "no": 0})


def number(word):
    word = word.lower()
    if word.isdigit():
        return int(word)
    if "-" in word:
        tens, _, ones = word.partition("-")
        if tens in WORDS and ones in WORDS:
            return WORDS[tens] + WORDS[ones]
    return WORDS.get(word)


def git(*args):
    r = subprocess.run(["git", *args], capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else None


def read_at(ref, path):
    if ref is None:
        p = Path(path)
        return p.read_text(encoding="utf-8") if p.exists() else ""
    return git("show", f"{ref}:{path}") or ""


def md_files(ref):
    out = git("ls-tree", "-r", "--name-only", ref) if ref else git("ls-files")
    return [f for f in (out or "").splitlines() if f.endswith(".md") and f != "CHANGELOG.md"]


def diagrams(ref):
    return sum(read_at(ref, f).count("```mermaid") for f in md_files(ref))


def situation_rows(text):
    lines = text.splitlines()
    n = 0
    for i, l in enumerate(lines):
        if not l.startswith("|") or re.match(r"^\|\s*:?-", l):
            continue
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        if re.match(r"^\|\s*:?-", nxt):          # a header row
            continue
        n += 1
    return n


def facts(text, kind):
    if kind == "facts.md":
        return set(re.findall(r"^(\d+)\. ", text, re.M))
    return set(re.findall(r"^### ([^\s·]+) ·", text, re.M))


def spans(nums):
    """{262, 263, 264, 270} → '262–264, 270'."""
    out, run = [], []
    for n in sorted(int(x) for x in nums):
        if run and n == run[-1] + 1:
            run.append(n)
            continue
        if run:
            out.append(f"{run[0]}–{run[-1]}" if len(run) > 1 else str(run[0]))
        run = [n]
    if run:
        out.append(f"{run[0]}–{run[-1]}" if len(run) > 1 else str(run[0]))
    return ", ".join(out) or "none"


def layout():
    if Path("facts.md").exists():
        return "use-cases.md", "facts.md"
    return "USE-CASES.md", "sources/SOURCES.md"


def entry(version=None):
    text = Path("CHANGELOG.md").read_text(encoding="utf-8")
    heads = list(re.finditer(r"^## (\d+\.\d+\.\d+)\b.*$", text, re.M))
    for k, h in enumerate(heads):
        if version is None or h.group(1) == version:
            end = heads[k + 1].start() if k + 1 < len(heads) else len(text)
            prev = heads[k + 1].group(1) if k + 1 < len(heads) else None
            return h.group(1), prev, text[h.start():end]
    return None, None, None


def claimed(body):
    """What the entry says it added: its Trio paragraph, and then — overriding it kind by kind — a
    marked correction of that line (`> **Correction, <date> — the Trio line …**`), because a released
    entry is frozen and a correction is the only way it can say the true number."""
    m = re.search(r"^\*\*Trio:\*\*(.*?)(?=\n\n|\Z)", body, re.S | re.M)
    if not m:
        return None
    c = counts(" ".join(m.group(1).split()))
    for q in re.findall(r"^> \*\*Correction[^\n]*Trio line.*?(?=\n(?!>)|\Z)", body, re.S | re.M):
        c.update(counts(" ".join(re.sub(r"^> ?", "", q, flags=re.M).split())))
    return c


def counts(t):
    c = {}
    d = re.search(r"\b([\w-]+) diagrams?\b", t)
    if d and number(d.group(1)) is not None:
        c["diagrams"] = number(d.group(1))
    s = re.search(r"\b([\w-]+) situations?\b", t)
    if s and number(s.group(1)) is not None:
        c["situations"] = number(s.group(1))
    f = re.search(r"facts\.md`?\s*(.*)", t)
    if f:
        # the facts are the RUN of bold numbers right after it, joined by commas or *and*, and
        # nothing after: 0.2.17's Trio line is followed by suite sizes in bold, and a trailing
        # *held by suite **9*** in the same sentence was read as a fact (a lens, 2026-09-25)
        run = re.match(r"(?:\s*(?:,|and)?\s*\*\*\d+(?:\s*[–-]\s*\d+)?\*\*)+", f.group(1))
        nums = set()
        for a, b in re.findall(r"\*\*(\d+)(?:\s*[–-]\s*(\d+))?\*\*", run.group(0) if run else ""):
            nums.update(str(i) for i in range(int(a), int(b or a) + 1))
        if nums:
            c["facts"] = nums
    r = re.search(r"\b([\w-]+) register entr(?:y|ies)\b", t)
    if r and number(r.group(1)) is not None:
        c["entries"] = number(r.group(1))
    return c


def main():
    want = sys.argv[1] if len(sys.argv) > 1 else None
    version, prev, body = entry(want)
    if not body:
        print(f"no changelog entry {want or ''}".strip())
        return 2
    tags = set((git("tag") or "").split())
    here = f"v{version}" if f"v{version}" in tags else None      # None: the working tree
    base = f"v{prev}" if prev and f"v{prev}" in tags else None
    if base is None:
        print(f"{version}: no tag for the entry before it — nothing to measure against")
        return 2
    c = claimed(body)
    if c is None:
        print(f"{version}: the entry has no **Trio:** line — every release names what it added, "
              f"or says it owes none")
        return 1
    uc, fk = layout()
    got = {
        "diagrams": diagrams(here) - diagrams(base),
        "situations": situation_rows(read_at(here, uc)) - situation_rows(read_at(base, uc)),
    }
    new = facts(read_at(here, fk), fk) - facts(read_at(base, fk), fk)
    if fk == "facts.md":
        got["facts"] = new
    else:
        got["entries"] = len(new)
    where = here or "the working tree"
    bad, unread = [], []
    for k in got:
        if k not in c:
            if got[k]:
                unread.append(k)
            continue
        if c[k] != got[k]:
            say = spans if k == "facts" else str
            bad.append(f"{version}: the Trio line says {k} {say(c[k])}; {base}..{where} added {say(got[k])}")
    for b in bad:
        print(b)
    for u in unread:
        print(f"{version}: the release added {u} and the Trio line says nothing this can read about them — "
              f"write a number word or digits before *diagrams* · *situations* · *register entries*, "
              f"or bold numbers after `facts.md`")
    # the entry being written must say it in words this reads; a released one is only reported
    if bad or (unread and here is None):
        return 1
    print(f"{version}: the Trio line matches {base}..{where}" + (f" (unread: {', '.join(unread)})" if unread else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
