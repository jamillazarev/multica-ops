#!/usr/bin/env python3
"""In a project, an id or a path named in passing becomes a link — so Obsidian's graph, GitHub and
any reader see the edge the mention implied.

    link-ids.py [project-root]            report each mention that could be a link — exit 1 if any
    link-ids.py [project-root] --write    rewrite: T-04SMFZ → [T-04SMFZ](tasks/T-04SMFZ-latency-measure.md)

Run as the skill's `scripts/link-ids.py`. **It never runs by itself, and `--write` is the owner's
word** — it changes the project's own files, so it is offered at an upgrade, with the report first
(`/multica-ops:upgrade`). Here the tasks live in Multica, so what it mostly finds is a file of
`_ops/` named in another; an id becomes a link only where a file carries it.

Ported from opsinist, where it was measured on a live project on 2026-09-11: 298 links in its
`_ops/`, and 273 mentions in 171 files that could have been.

What becomes a link:
  - an id — `T-04SMFZ`, `R-…` — whose entity file exists: exactly one `<ID>-<slug>.md` or `<ID>.md`
    anywhere in the tree, bare or in backticks;
  - a backticked path of a markdown file in the project — `_ops/DECISIONS.md` — linked relative to
    the file it is written in. The link text keeps what was written, backticks and all.

What never does — the DECLARATIONS readers parse, and the records kept as written:
  - a heading: a task's `# T-… — title` is where the id is declared, not a mention of it;
  - a `**Task**` row or a `task:` line: a declaration — in opsinist the guard reads it by taking
    the last id in the cell, and a link there hands it the slug instead (measured 2026-09-11);
  - `_ops/runs/` (evidence), `_ops/research/raw/` (material), a `## History` section (a log, kept
    as logged), fences, frontmatter, HTML comments, existing links, and a file's own id.
"""
import os, re, subprocess, sys

ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"          # new-id.py's: no I, L, O or U
ID = r"[A-Z]{1,2}-[%s]{6}" % ALPHABET
MENTION = re.compile(r"`(%s)`|(?<![A-Za-z0-9/\[_-])(%s)(?![A-Za-z0-9_-])|`([A-Za-z0-9_][A-Za-z0-9_./-]*\.md)`"
                     % (ID, ID))
MASK = re.compile(r"!?\[(?:[^\[\]]|\[[^\]]*\])*\]\([^)]*\)|<https?://[^>]+>|<!--.*?-->")
DECLARATION = re.compile(r"\*\*task\*\*|^\s*task\s*:", re.I)
SKIP = ("_ops/runs/", "_ops/research/raw/", "_ops/scripts/")


def tree(root):
    r = subprocess.run(["git", "-C", root, "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
                       capture_output=True, text=True)
    if r.returncode == 0:
        return sorted(p for p in r.stdout.split("\0") if p and os.path.exists(os.path.join(root, p)))
    out = []
    for d, dirs, files in os.walk(root):
        dirs[:] = [x for x in dirs if x not in {".git", "node_modules"}]
        out += [os.path.relpath(os.path.join(d, f), root).replace(os.sep, "/") for f in files]
    return sorted(out)


def entity_files(paths):
    """id → its file, for ids that name exactly one file; an id naming two names neither."""
    seen = {}
    for p in paths:
        m = re.match(r"^(%s)(?:-[^/]*)?\.md$" % ID, os.path.basename(p))
        if m:
            seen.setdefault(m.group(1), []).append(p)
    return {i: ps[0] for i, ps in seen.items() if len(ps) == 1}


def rewrite_line(line, here, ents, mds, own):
    masked = MASK.sub(lambda m: "\0" * len(m.group(0)), line)
    out, last, found = [], 0, []
    for m in MENTION.finditer(masked):
        ident = m.group(1) or m.group(2)
        path = m.group(3)
        if ident:
            if ident == own or ident not in ents:
                continue
            target, text = ents[ident], line[m.start():m.end()]
        else:
            clean = path[2:] if path.startswith("./") else path
            if clean not in mds:
                continue
            target, text = clean, "`%s`" % path
        rel = os.path.relpath(target, os.path.dirname(here) or ".").replace(os.sep, "/")
        out += [line[last:m.start()], "[%s](%s)" % (text, rel)]
        last = m.end()
        found.append(ident or path)
    out.append(line[last:])
    return "".join(out), found


def process(root, path, ents, mds, write):
    lines = open(os.path.join(root, path), encoding="utf-8").read().split("\n")
    own = re.match(r"^(%s)" % ID, os.path.basename(path))
    own = own.group(1) if own else None
    fenced = comment = history = False
    front = lines[:1] == ["---"]
    hits = []
    for i, line in enumerate(lines):
        s = line.strip()
        if front:
            front = not (i > 0 and s == "---")
            continue
        if s.startswith("```") or s.startswith("~~~"):
            fenced = not fenced
            continue
        if "<!--" in s and "-->" not in s:
            comment = True
        if comment:
            comment = "-->" not in s
            continue
        if s.startswith("#"):
            history = re.match(r"^##\s+History\s*$", s) is not None
            continue
        if fenced or history or DECLARATION.search(line):
            continue
        new, found = rewrite_line(line, path, ents, mds, own)
        if found:
            hits += ["%s:%d: %s" % (path, i + 1, f) for f in found]
            lines[i] = new
    if write and hits:
        open(os.path.join(root, path), "w", encoding="utf-8").write("\n".join(lines))
    return hits


def main(argv):
    write = "--write" in argv
    args = [a for a in argv if not a.startswith("--")]
    root = args[0] if args else "."
    paths = tree(root)
    ents = entity_files(paths)
    mds = set(p for p in paths if p.endswith(".md"))
    hits = []
    for p in paths:
        if p.endswith(".md") and p.startswith("_ops/") and not p.startswith(SKIP):
            hits += process(root, p, ents, mds, write)
    files = len({h.split(":")[0] for h in hits})
    if write:
        print("linked %d mention%s in %d file%s" % (len(hits), "" if len(hits) == 1 else "s",
                                                    files, "" if files == 1 else "s"))
        return 0
    for h in hits:
        print(h)
    print("%d mention%s in %d file%s could be links%s" % (
        len(hits), "" if len(hits) == 1 else "s", files, "" if files == 1 else "s",
        " — the skill's `scripts/link-ids.py --write`, with the owner's word" if hits else ""))
    return 1 if hits else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
