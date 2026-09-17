#!/usr/bin/env python3
"""Does this project's graph actually work? — every internal link resolved, both ways.

    graph-check.py [project-root] [--all] [--json]

**Ported from opsinist 2026-09-18.** Here most of the roster and the work live in Multica, so what
this reads is whatever file layer a project keeps — the corpus itself, `_ops/` where there is one,
and the docs a workspace carries. The rules below do not change with the storage.

**Why this exists rather than a sentence promising it works.** Three things Obsidian's own help
states (read 2026-09-18) decide whether a repository is a graph or a pile of files:

  - **it resolves Markdown links**, not only wikilinks — *"Obsidian supports the following link
    formats: Wikilink … Markdown: `[Three laws of motion](Three%20laws%20of%20motion)`"*;
  - **a Markdown link's destination must be URL-encoded** — *"make sure to URL encode the link
    destination. For example, blank spaces become `%20`"*;
  - **a link to a file that does not exist still becomes a node.** The graph's filters include
    *"Existing files only — toggles whether to show notes that exists in your vault. Since a note
    doesn't need to exist to link to it…"*, so **a dead link is a phantom node by default**, which
    is why a rotted link is worse than a bare name rather than merely useless.

**What the help does NOT document is how a relative destination resolves** — whether `../roles/x.md`
is read relative to the file or from the vault root. So this script does not assume: it resolves
every link **both ways** and says which links survive each reading. A link that resolves both ways
is safe under either rule; one that resolves only relative to its file is safe in this repository
and in a vault opened at its root, and that is the arrangement `project-layout.md` prescribes for
exactly this reason.

Exit 0 when nothing is broken — no phantom targets, nothing escaping the repository, no unencoded
space. Exit 1 otherwise, so a health sweep can read the code and a person can read the lines. It
writes nothing, anywhere.
"""
import argparse, json, os, re, subprocess, sys
from urllib.parse import unquote

# **The destination may contain a space, and a pattern that stops at whitespace can never see
# one** — which is the whole point of the unencoded-space check, and this pattern's first draft
# excluded it: `[it](my file.md)` matched nothing at all, so the check reported clean on the exact
# defect it exists for. Caught by its own suite, 2026-09-18. Capture to the closing paren and strip
# an optional title afterwards.
LINK = re.compile(r"(?<!!)\[(?:[^\[\]]|\[[^\]]*\])*\]\(([^)]*)\)")
TITLE = re.compile(r"\s+\"[^\"]*\"\s*$|\s+'[^']*'\s*$")
# **An inline code span is an example, exactly as a fence is.** Run against this corpus the first
# time, this script reported nine defects and every one was a sentence *about* links — `[text]`
# `(relative/path.md)` written inside backticks to show the syntax. A checker whose findings are
# all its own documentation is a checker nobody reads twice, which is this corpus's own measured
# rule about crying wolf. Blanked with same-length filler so column numbers stay true.
CODESPAN = re.compile(r"`+[^`]*`+")
FENCE = re.compile(r"^\s*(```|~~~)")


def tracked(root):
    r = subprocess.run(["git", "-C", root, "ls-files", "-z", "--cached", "--others",
                        "--exclude-standard"], capture_output=True, text=True)
    if r.returncode == 0:
        return [p for p in r.stdout.split("\0") if p]
    out = []
    for d, dirs, files in os.walk(root):
        dirs[:] = [x for x in dirs if x not in {".git", "node_modules"}]
        out += [os.path.relpath(os.path.join(d, f), root).replace(os.sep, "/") for f in files]
    return out


def links_of(root, rel):
    """Every markdown link in a file, outside fences. Fenced examples are not edges — and they are
    not defects either, which is why they are dropped here rather than counted as phantoms."""
    out, fenced = [], False
    # **A tracked file can be absent from the worktree** — staged for deletion, or mid-rebase — and
    # this died on it with an uncaught `FileNotFoundError`, taking the whole report with it. Found
    # by an adversarial lens, 2026-09-18. A file that is not there has no links; the report says
    # what it read.
    try:
        text = open(os.path.join(root, rel), encoding="utf-8", errors="replace").read()
    except OSError:
        return []
    for n, line in enumerate(text.split("\n"), 1):
        if FENCE.match(line):
            fenced = not fenced
            continue
        if fenced:
            continue
        masked = CODESPAN.sub(lambda m: "\0" * len(m.group(0)), line)
        for m in LINK.finditer(masked):
            out.append((n, TITLE.sub("", m.group(1)).strip()))
    return out


def classify(root, rel, target, files):
    """(kind, note) for one link target — the whole judgement of this script.

    `kind` is one of: external · anchor · both · file-relative · vault-absolute · phantom ·
    escapes · unencoded-space · placeholder · directory.
    """
    if target.startswith(("http://", "https://", "mailto:", "obsidian://")):
        return "external", ""
    if target.startswith("#"):
        return "anchor", ""
    # **An elided path is a placeholder, not a phantom.** `[the file](…)` appears in both this
    # corpus and its sibling, in prose showing a shape rather than pointing at one — measured
    # 2026-09-18, one occurrence each, and both would otherwise be reported as defects forever.
    if "{{" in target or "XXXXXX" in target or "…" in target:
        return "placeholder", ""
    path = unquote(target.split("#")[0])
    if not path:
        return "anchor", ""
    if " " in target.split("#")[0]:
        return "unencoded-space", "a Markdown destination must be URL-encoded — `%20`"
    if path.startswith("/"):
        return "escapes", "an absolute path resolves on one machine and in no vault"
    here = os.path.dirname(rel)
    as_rel = os.path.normpath(os.path.join(here, path)).replace(os.sep, "/")
    as_abs = os.path.normpath(path).replace(os.sep, "/")
    if as_rel.startswith(".."):
        return "escapes", "resolves above the repository root, so it is outside any vault opened there"
    # **A link to a directory is legitimate on the git host** — `evals/`, `assets/` — and draws no
    # edge in a vault because a folder is not a note. Counted as itself rather than as a phantom.
    if target.endswith("/") or os.path.isdir(os.path.join(root, as_rel)) \
            or os.path.isdir(os.path.join(root, as_abs)):
        return "directory", as_rel
    rel_ok, abs_ok = as_rel in files, as_abs in files
    if rel_ok and abs_ok:
        return "both", as_rel
    if rel_ok:
        return "file-relative", as_rel
    if abs_ok:
        return "vault-absolute", as_abs
    return "phantom", as_rel


ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
ID = r"[A-Z]{1,2}-[%s]{6}" % ALPHABET
MASK = re.compile(r"!?\[(?:[^\[\]]|\[[^\]]*\])*\]\([^)]*\)|<https?://[^>]+>|<!--.*?-->")
PERSON = re.compile(r"^(?![ ]{4}|\t)\s*[-*]?\s*[*`_]*(?:Assignee|Role|Owner|Reviewer|Worker)"
                    r"[*`_]*\s*:\s*([^·|\n]+?)\s*$", re.I)
# every reader consults this AFTER `norm`, which turns "-" and "—" into "" — already a member.
# A deletion lens found the two sets disagreeing about which of the dead entries to carry,
# which is proof nobody could tell: 2026-09-18.
# every reader consults this AFTER `norm`, which turns "-" and "—" into "" — already a member
OPEN = {"none", "unassigned", "nobody", "tbd", "unknown", ""}


def norm(name):
    name = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", name)
    return " ".join("".join(c if c.isalnum() else " " for c in name.lower()).split())


def missing_edges(root, notes, files):
    """Mentions that would be edges — **the number that turns "0 edges" from a shrug into a
    finding.** A graph with no lines is not a clean graph; it is the state a live project was
    measured in, and a report that called that *whole* would be the checker lying politely."""
    ents, people = {}, {}
    for p in files:
        m = re.match(r"^(%s)(?:-[^/]*)?\.md$" % ID, os.path.basename(p))
        if m:
            ents.setdefault(m.group(1), []).append(p)
        if os.path.dirname(p) in ("_ops/roles", "_ops/teams", "_ops/panels") and p.endswith(".md"):
            people.setdefault(norm(os.path.basename(p)[:-3]), []).append(p)
    ents = {k: v[0] for k, v in ents.items() if len(v) == 1}
    people = {k: v[0] for k, v in people.items() if len(v) == 1}
    found = 0
    for rel in notes:
        own = re.match(r"^(%s)" % ID, os.path.basename(rel))
        own = own.group(1) if own else None
        fenced = history = False
        try:
            body = open(os.path.join(root, rel), encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for line in body.split("\n"):
            st = line.strip()
            if FENCE.match(line):
                fenced = not fenced
                continue
            if st.startswith("#"):
                history = re.match(r"^##\s+History\s*$", st, re.I) is not None
                continue
            if fenced or history or re.search(r"\*\*task\*\*|^\s*task\s*:", line, re.I):
                continue
            masked = MASK.sub(lambda m: "\0" * len(m.group(0)), line)
            for m in re.finditer(r"`(%s)`|(?<![A-Za-z0-9/\[_-])(%s)(?![A-Za-z0-9_-])" % (ID, ID), masked):
                i = m.group(1) or m.group(2)
                if i != own and i in ents:
                    found += 1
            pm = PERSON.match(masked)
            if pm and norm(pm.group(1)) not in OPEN and norm(pm.group(1)) in people:
                found += 1
    return found


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("root", nargs="?", default=".")
    ap.add_argument("--all", action="store_true",
                    help="read every markdown file, not only the ones under _ops/")
    ap.add_argument("--json", action="store_true", help="the counts as JSON, for a sweep")
    a = ap.parse_args(argv)
    root = os.path.abspath(a.root)
    paths = tracked(root)
    files = set(paths)
    notes = [p for p in paths if p.endswith(".md")
             and (a.all or p.startswith("_ops/") or "/" not in p)]
    if not notes:
        print("no markdown under %s — nothing to draw" % root, file=sys.stderr)
        return 2

    counts = {k: 0 for k in ("both", "file-relative", "vault-absolute", "phantom", "escapes",
                             "unencoded-space", "external", "anchor", "placeholder", "directory")}
    edges, attachments, broken = set(), 0, []
    for rel in notes:
        for line, target in links_of(root, rel):
            kind, note = classify(root, rel, target, files)
            counts[kind] += 1
            if kind in ("both", "file-relative", "vault-absolute"):
                if note.endswith(".md"):
                    edges.add((rel, note))
                else:
                    attachments += 1
            elif kind in ("phantom", "escapes", "unencoded-space"):
                broken.append((rel, line, target, kind, note))

    linked = {n for e in edges for n in e}
    orphans = [n for n in notes if n not in linked]
    could = missing_edges(root, notes, files)
    if a.json:
        print(json.dumps({"notes": len(notes), "edges": len(edges), "orphans": len(orphans),
                          "mentions_that_could_be_edges": could,
                          "attachments": attachments, "counts": counts,
                          "broken": [{"file": f, "line": l, "target": t, "kind": k}
                                     for f, l, t, k, _ in broken]}, indent=2))
        return 1 if broken else 0

    print("graph check — %s" % root)
    print("  %d note%s · %d note-to-note edge%s · %d orphan%s (no edge in or out) · %d attachment link%s"
          % (len(notes), "" if len(notes) == 1 else "s", len(edges), "" if len(edges) == 1 else "s",
             len(orphans), "" if len(orphans) == 1 else "s", attachments,
             "" if attachments == 1 else "s"))
    print("  resolution: %d link%s resolve both ways · %d only relative to their own file · "
          "%d only from the vault root"
          % (counts["both"], "" if counts["both"] == 1 else "s", counts["file-relative"],
             counts["vault-absolute"]))
    if counts["vault-absolute"]:
        print("  ! a link that resolves ONLY from the vault root breaks in this repository and on "
              "the git host — write it relative to the file it sits in")
    if counts["file-relative"] and not counts["vault-absolute"]:
        print("  ✓ the relative form throughout: correct on the git host, in an editor, and in a "
              "vault opened at the project root — which is the arrangement to keep, because a link "
              "that climbs above the vault root is outside the graph")
    for f, l, t, k, note in broken[:20]:
        print("  ✗ %s:%d → `%s` — %s%s" % (f, l, t, {
            "phantom": "resolves to no file. Obsidian draws it as a node anyway (its graph filter "
                       "*Existing files only* exists precisely because a link does not need a "
                       "target), so this is a phantom in the picture, not an absence",
            "escapes": "outside the vault",
            "unencoded-space": "unencoded space in the destination",
        }[k], (" — " + note) if note and k != "phantom" else ""))
    if len(broken) > 20:
        print("  … and %d more" % (len(broken) - 20))
    if orphans and len(orphans) <= 12:
        print("  · orphans: %s" % ", ".join(orphans))
    if could:
        print("  ✗ %d mention%s would be %s edge%s — the door rewrites them: the skill's "
              "`scripts/link-ids.py --write`, and the guard's §27 refuses new ones"
              % (could, "" if could == 1 else "s", "another" if edges else "the first",
                 "" if could == 1 else "s"))
    # **No lines is not a clean graph.** Reported as whole, this script's first run on a live
    # project of nineteen notes and zero edges said *the graph is whole* — true about links and
    # false about everything the picture is for. Measured 2026-09-18, in its own first output.
    scattered = len(notes) > 1 and not edges
    verdict = ("the graph is whole" if not (broken or could or scattered) else
               "; ".join(filter(None, [
                   "%d link%s would draw a phantom or point outside the vault"
                   % (len(broken), "" if len(broken) == 1 else "s") if broken else "",
                   "**no edges at all: %d notes and not one line between them**" % len(notes)
                   if scattered else "",
                   "%d edge%s missing where a mention already names the thing"
                   % (could, "" if could == 1 else "s") if could else ""])))
    print("  %s" % verdict)
    return 1 if (broken or could or scattered) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
