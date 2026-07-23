#!/usr/bin/env python3
"""Structural integrity of the docs. Every check here exists because the defect it
looks for actually shipped once — see CHANGELOG 2.1.1/2.1.2. Prints FAIL:/WARN: lines
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

# g · every docs file the stand-up creates needs a template, or an explicit exemption.
EXEMPT = {"LATER", "ECONOMICS", "analytics"}
try:
    boot = open("BOOTSTRAP.md", encoding="utf-8").read()
    step = re.search(r"^7\. \*\*Labels\*\*.*?(?=\n\n|\n## )", boot, re.S | re.M)
    if step:
        for name in set(re.findall(r"`docs/([A-Z][A-Za-z]*)\.md`", step.group(0))):
            if name in EXEMPT:
                continue
            if not os.path.exists(f"templates/{name}-template.md"):
                warn(f"docs/{name}.md is in the stand-up skeleton with no templates/{name}-template.md")
except OSError:
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
