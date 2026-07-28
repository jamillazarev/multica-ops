#!/usr/bin/env python3
"""Structural integrity of the docs. Every check here exists because the defect it
looks for actually shipped once — see the 2.1.0 entry. Prints FAIL:/WARN: lines
for preflight to render; deterministic classes fail, heuristic ones warn."""
import glob, os, re, shutil, subprocess, sys

DOCS = sorted(set(glob.glob("*.md")) | set(glob.glob("templates/*.md")) | set(glob.glob("evals/*.md")))
out = []
def fail(m): out.append("FAIL:" + m)
def warn(m): out.append("WARN:" + m)

def strip_code(t):
    return re.sub(r"```.*?```", "", t, flags=re.S)

def cells(line):
    """Pipe count that ignores escaped pipes and pipes inside inline code —
    `/upgrade [skill\\|all]` is one cell, not two."""
    l = re.sub(r"`[^`]*`", "`", line).replace(r"\|", "")
    return l.count("|")

for f in DOCS:
    t = open(f, encoding="utf-8").read()
    lines = t.split("\n")
    body = strip_code(t)

    # a · a markdown table row must have the column count its header declares.
    # Fifteen STACKS rows silently lost their free-tier column this way.
    cols, in_tbl = None, False
    for i, l in enumerate(lines, 1):
        s = l.strip()
        if not s.startswith("|"):
            cols, in_tbl = None, False
            continue
        if re.match(r"^\|[\s\-:|]+\|$", s):
            cols = cells(lines[i - 2]) if i >= 2 else None
            in_tbl = True
            continue
        if in_tbl and cols and cells(l) != cols:
            fail(f"{f}:{i} table row has {cells(l)-1} cells, header declares {cols-1}")

    # b · a list item's continuation must stay indented, or it falls out of the list.
    in_list = False
    for i, l in enumerate(lines, 1):
        if re.match(r"^\s*([-*]|\d+\.) ", l):
            in_list = True
            continue
        if in_list:
            if not l.strip() or l.lstrip().startswith(("|", ">", "```", "#")):
                in_list = False
            elif not l.startswith("  "):
                fail(f"{f}:{i} list continuation lost its indent — renders as a stray paragraph")
                in_list = False

    # b2 · a heading swallowed by the sentence above it. An insert that replaces part of a
    # block and leaves the rest is the signature defect of repeated rewriting, and it hides
    # from the Contents check because the heading no longer exists on either side.
    for i, l in enumerate(lines, 1):
        if re.search(r"[a-z,)]\d+\.\s+[A-Z]", l) and not l.lstrip().startswith(("|", ">", "-", "#")):
            fail(f"{f}:{i} looks like a heading absorbed into prose — '{l.strip()[:60]}'")

    # b3 · section numbers must be contiguous: a missing §N means one was eaten or dropped.
    nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\.", t, re.M)]
    if nums and nums != list(range(nums[0], nums[0] + len(nums))):
        missing = sorted(set(range(nums[0], nums[-1] + 1)) - set(nums))
        if missing:
            fail(f"{f}: section numbering skips {missing} — a heading was lost")

    # c · a line ending in a hyphen is a word a reflow tool broke in half.
    for i, l in enumerate(lines, 1):
        if re.search(r"[a-z]-$", l):
            fail(f"{f}:{i} line ends mid-word on a hyphen")

    # d · "Three loops:" must be followed by three of them.
    words = dict(one=1, two=2, three=3, four=4, five=5, six=6, seven=7, eight=8)
    for i, l in enumerate(lines, 1):
        m = re.search(r"\b(one|two|three|four|five|six|seven|eight|\d+)\s+(?:\w+\s+){0,2}"
                      r"(loops?|kinds?|rules?|blocks?|passes|things?|levers?|guardrails?|"
                      r"options?|origins?|shapes?|questions?|steps?)\b[^.]*:\s*$", l, re.I)
        if not m:
            continue
        want = words.get(m.group(1).lower(), None) or (int(m.group(1)) if m.group(1).isdigit() else None)
        if not want:
            continue
        got, j = 0, i
        while j < len(lines):
            nl = lines[j]
            # a list belonging to a different section is not this sentence's count —
            # stop at the next heading (any level) or horizontal rule, whichever comes first.
            if re.match(r"^#{1,6}\s", nl) or re.match(r"^ {0,3}(-{3,}|\*{3,}|_{3,})\s*$", nl):
                break
            if re.match(r"^\s*([-*]|\d+\.) ", nl):
                got += 1
            elif nl.strip() and not nl.startswith("  ") and got:
                break
            j += 1
        if got and got != want:
            warn(f"{f}:{i} says {m.group(1)} {m.group(2)} but {got} follow")

    # e · the same long sentence twice in one file is a copy-paste that will drift apart.
    seen = {}
    for s in re.split(r"(?<=[.!?])\s+", body):
        n = " ".join(s.split())
        if len(n) > 110:
            if n in seen:
                warn(f"{f} repeats a sentence verbatim: “{n[:60]}…”")
            seen[n] = 1

# f · mermaid blocks must at least be structurally closed.
for f in DOCS:
    for n, blk in enumerate(re.findall(r"```mermaid\n(.*?)```", open(f, encoding="utf-8").read(), re.S), 1):
        for open_c, close_c in "[]", "{}", "()":
            if blk.count(open_c) != blk.count(close_c):
                fail(f"{f}: mermaid diagram {n} has unbalanced {open_c}{close_c}")
        if blk.count("subgraph") != len(re.findall(r"^\s*end\s*$", blk, re.M)):
            fail(f"{f}: mermaid diagram {n} has a subgraph without its end")

# f2 · every commands/*.md must have a row in COMMANDS.md. The coherence checks in
# preflight all iterate table → file, so a command missing from the table is invisible
# to every one of them at once. Commands are written in full — `/mops <name>` — so the
# `mops ` prefix is optional here only to still match the bare `/mops` dispatcher itself.
try:
    table = open("COMMANDS.md", encoding="utf-8").read()
    for path in sorted(glob.glob("commands/*.md")):
        name = os.path.basename(path)[:-3]
        if not re.search(rf"/(?:mops )?{re.escape(name)}[`\s(\\|:]", table):
            warn(f"commands/{name}.md has no row in COMMANDS.md — /help will never list it")
except OSError:
    pass

# f3 · /help must derive its command list from COMMANDS.md, not carry a frozen copy that
# drifts. A help file that names commands without pointing at the table is the stale-list
# failure the reverse-command check can't see.
try:
    h = open("commands/help.md", encoding="utf-8").read()
    if "COMMANDS.md" not in h:
        warn("commands/help.md should read the command surface from COMMANDS.md, "
             "not list commands itself — a frozen list is a stale list")
except OSError:
    pass

# g · every template the stand-up skeleton declares must exist. Read from the table's own
# Template column, not from the prose around it: the previous regex stopped at the first blank
# line and so saw one path out of nineteen, passing green on almost nothing checked. Hence the
# empty-table guard below — a check that silently reads nothing is worse than no check.
DECLARED = set()
try:
    boot = open("BOOTSTRAP.md", encoding="utf-8").read()
    rows = re.findall(r"^\s*\|\s*`(docs/[^`]+)`\s*\|[^|]*\|[^|]*\|\s*([^|]*?)\s*\|", boot, re.M)
    if not rows:
        fail("BOOTSTRAP: the repo-layout table has no `docs/…` rows — the template guard is blind")
    for path, tmpl in rows:
        name = tmpl.split()[0] if tmpl.strip() else ""
        if not name or name.startswith("—"):
            continue  # the row declares no template, deliberately
        DECLARED.add(name)
        if not os.path.exists(f"templates/{name}-template.md"):
            fail(f"BOOTSTRAP: {path} declares template '{name}' — templates/{name}-template.md is missing")
except OSError:
    pass

# i · a file nothing points at is a file nobody opens. Links were checked forwards only, so a
# store could sit in the repo with every link inside it valid and no door into it — worse than
# a dangling link, because the chain reads as intact from both ends while nothing traverses it.
# Reachable = named (by path or filename) in some other tracked file, or declared in the
# skeleton table above. The exemptions are the paths something *outside* this repo reaches by
# convention; each says who reaches it, so an obsolete exemption is legible rather than silent.
CONVENTION = {
    "commands/": "the plugin loads the directory; check f2 owns the COMMANDS.md row",
    "evals/runs/": "release records, reached by version in preflight 5j",
    ".github/workflows/": "run by GitHub, by path",
    ".claude-plugin/": "read by the plugin loader, by name",
    "scripts/tests/": "collected by the test runner",
    "assets/": "used by the docs site, the social preview and the plugin listing — none in this repo",
    ".gitignore": "read by git",
}
try:
    tracked = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True)
    paths = [p for p in tracked.stdout.split("\n") if p]
    # CHANGELOG is history, not a pointer: a file whose only mention is its own release note is
    # orphaned in the live documentation, which is exactly the state we are looking for.
    corpus = {}
    for p in paths:
        if p == "CHANGELOG.md" or p.endswith((".png", ".jpg", ".ico")):
            continue
        try:
            corpus[p] = open(p, encoding="utf-8", errors="ignore").read()
        except OSError:
            pass
    for p in paths:
        if any(p == k or p.startswith(k) for k in CONVENTION):
            continue
        base = os.path.basename(p)
        if base.endswith("-template.md") and base[:-len("-template.md")] in DECLARED:
            continue  # declared in the skeleton table, which check g holds to its word
        # Match on a name boundary, or a guard reports reachability it never established:
        # `SKILL-SCAFFOLD.md` ends with the name `OLD.md`. A leading path segment is fine —
        # `${CLAUDE_PLUGIN_ROOT}/templates/mops-alias.md` is a reference like any other.
        named = re.compile(r"(?<![\w-])(?:%s|%s)" % (re.escape(p), re.escape(base)))
        if not any(named.search(t) for q, t in corpus.items() if q != p):
            warn(f"{p} is reachable from nothing — no other file names it, and it is not "
                 f"one of the convention-reached paths")
except (OSError, subprocess.CalledProcessError):
    pass

# h · every `multica <group> <sub>` the docs promise must exist in the installed CLI.
if shutil.which("multica"):
    claimed = set()
    for f in DOCS + sorted(glob.glob("scripts/*")):
        try:
            txt = open(f, encoding="utf-8", errors="ignore").read()
        except OSError:
            continue
        for g, sub in re.findall(r"multica\s+([a-z][a-z-]+)\s+([a-z][a-z-]+)", txt):
            claimed.add((g, sub))
    groups = {}
    for g, sub in sorted(claimed):
        if g not in groups:
            r = subprocess.run(["multica", g, "--help"], capture_output=True, text=True)
            groups[g] = r.stdout if r.returncode == 0 else None
        h = groups[g]
        if h is None:
            fail(f"docs reference `multica {g}` — no such command group")
        elif not re.search(rf"^\s+{re.escape(sub)}:", h, re.M) and not sub.startswith("-"):
            if not re.search(rf"--{re.escape(sub)}\b", h):
                warn(f"docs reference `multica {g} {sub}` — not in that group's help")

print("\n".join(out))
