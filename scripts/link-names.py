#!/usr/bin/env python3
"""A backticked name of a file in this tree becomes a link, so GitHub, Obsidian's graph and
check-links.py see the edge the name only implied.

    link-names.py [root]            report each unlinked name as file:line — exit 1 if any
    link-names.py [root] --write    rewrite them: `tooling.md` → [`tooling.md`](tooling.md)

**Measured 2026-09-11**: this corpus held 53 markdown links and 419 backticked `.md` names — but
only 42 of the names are files in this tree: the rest name a project's own files (`_ops/…`) or
another repository's, and linking those would be a lie. The 42 were edges nothing could see or
check; opsinist, where the same count was 640, is where this script was written.

**Which files are rewritten**: the tracked chapters at the root and the doors under skills/ —
the files the corpus is read through. **Not CHANGELOG.md** (a released entry is
published release notes, compared against GitHub by check-releases.sh), **not templates/** (copied
into projects, where these paths do not exist), **not rules/** (loaded by a runtime from a copy, where
a relative path would lie), **not evals/ or sources/** (evidence and the register, as written), and
nothing git ignores — the eval workspaces beside the corpus hold whole projects of their own.

**Which names**: a backticked span that is exactly the path of a markdown file in this tree. Never
these bare names, which lead double lives — a project carries its own, and a prose mention usually
means that one: CLAUDE.md, LATER.md, README.md, AGENTS.md, CHANGELOG.md, SKILL.md — the
list opsinist's site generator reached the hard way. **And never a companion's name inside another
companion**: references stay one level deep from `skills/mops/SKILL.md`, which is this repository's
own rule (preflight §5c, which warns on exactly that link) — so here a root chapter naming a root
chapter keeps the name, and the hub and the dev files are the ones that link. Never inside a fence, a heading,
frontmatter, an HTML comment or an existing link — and the link text keeps the name as it was
written, so a reader sees exactly what they saw before.
"""
import os, re, subprocess, sys

DOUBLE_LIVES = {"CLAUDE.md", "LATER.md", "README.md", "AGENTS.md", "CHANGELOG.md",
                "SKILL.md"}
# preflight §5c's exemptions: the files that may link a companion, because they are not companions
ONE_LEVEL_EXEMPT = {"SKILL.md", "README.md", "CHANGELOG.md", "AGENTS.md", "CLAUDE.md"}
SKIP_DIRS = {".git", "node_modules", "templates", "evals", "sources", "assets", ".claude", "hooks", "rules"}
NAME = re.compile(r"`([A-Za-z0-9_][A-Za-z0-9_./-]*\.md)`")
LINK = re.compile(r"!?\[(?:[^\[\]]|\[[^\]]*\])*\]\([^)]*\)|<https?://[^>]+>|<!--.*?-->")


def tree(root):
    """Every markdown file, relative to the root: what git tracks where there is a repository —
    so nothing it ignores — and every file on disk where there is not."""
    r = subprocess.run(["git", "-C", root, "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
                       capture_output=True, text=True)
    if r.returncode == 0:
        return sorted(p for p in r.stdout.split("\0") if p.endswith(".md") and os.path.exists(os.path.join(root, p)))
    out = []
    for d, dirs, files in os.walk(root):
        dirs[:] = [x for x in dirs if x not in {".git", "node_modules"}]
        out += [os.path.relpath(os.path.join(d, f), root).replace(os.sep, "/") for f in files if f.endswith(".md")]
    return sorted(out)


# The always-loaded core is not rewritten: every link in it is paid by every session. Measured
# 2026-09-11 on opsinist's core, 81 links added 1,785 bytes — about 7% of the file, on every run —
# for edges its routing table's own check already reads. The doors, loaded only when called, are.
CORE = "skills/mops/SKILL.md"


def sources(paths):
    """The files rewritten: outside the skipped directories, CHANGELOG.md and the core aside."""
    return [p for p in paths if p not in ("CHANGELOG.md", CORE) and not set(p.split("/")[:-1]) & SKIP_DIRS
            and not p.split("/")[0].startswith(".")]


def rewrite_line(line, here, known):
    """(new line, names linked) — spans inside existing links are masked first."""
    masked = LINK.sub(lambda m: "\0" * len(m.group(0)), line)
    out, last, found = [], 0, []
    for m in NAME.finditer(masked):
        name = m.group(1)
        path = name[2:] if name.startswith("./") else name
        if path not in known or ("/" not in path and path in DOUBLE_LIVES) or path.startswith("_ops/"):
            continue
        if "/" not in here and "/" not in path and here not in ONE_LEVEL_EXEMPT:
            continue          # a companion naming a companion: one level deep from the hub (§5c)
        rel = os.path.relpath(path, os.path.dirname(here) or ".").replace(os.sep, "/")
        out.append(line[last:m.start()])
        out.append("[`%s`](%s)" % (name, rel))
        last = m.end()
        found.append(name)
    out.append(line[last:])
    return "".join(out), found


def process(root, path, known, write):
    text = open(os.path.join(root, path), encoding="utf-8").read()
    lines = text.split("\n")
    fenced = comment = False
    front = lines[:1] == ["---"]
    hits = []
    for i, line in enumerate(lines):
        s = line.strip()
        if front:
            if i > 0 and s == "---":
                front = False
            continue
        if s.startswith("```") or s.startswith("~~~"):
            fenced = not fenced
            continue
        if "<!--" in s and "-->" not in s:
            comment = True
        if comment:
            comment = "-->" not in s
            continue
        if fenced or s.startswith("#"):
            continue
        new, found = rewrite_line(line, path, known)
        if found:
            hits += ["%s:%d: %s" % (path, i + 1, n) for n in found]
            lines[i] = new
    if write and hits:
        open(os.path.join(root, path), "w", encoding="utf-8").write("\n".join(lines))
    return hits


def main(argv):
    write = "--write" in argv
    args = [a for a in argv if not a.startswith("--")]
    root = args[0] if args else "."
    paths = tree(root)
    known = set(paths)
    hits = []
    for p in sources(paths):
        hits += process(root, p, known, write)
    if write:
        print("linked %d name%s in %d file%s" % (len(hits), "" if len(hits) == 1 else "s",
              len({h.split(":")[0] for h in hits}), "" if len({h.split(":")[0] for h in hits}) == 1 else "s"))
        return 0
    for h in hits:
        print(h)
    if hits:
        print("%d backticked name%s of a file in this tree, not linked — `python3 scripts/link-names.py --write`"
              % (len(hits), "" if len(hits) == 1 else "s"))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
