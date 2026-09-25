#!/usr/bin/env python3
"""Every project on the shelf carries a link — the owner's rule, 2026-09-25.

    python3 scripts/check-shelf-links.py [shelf.md]     # exit 1 and one line per finding

The shelf is `catalogue.md` here and `STACKS.md` in the sibling; with no argument, whichever
exists. A table is a shelf table when its header names a column in SHELF_COLUMNS, and only
those columns are read — they are where a project is put on the shelf; the others explain it.

In each such cell the entries are split on the house separators, links become a placeholder,
parenthetical notes are dropped, and each entry's HEAD is taken: the text before its first
dash with a space each side (` — `, ` – `, ` - `) or colon (`: `, or at a bold boundary —
`**Label**: text` and `**Label:** text` both), split again on `/`. A head that reads as a name — capitalised, at most four
words, no function word, not a licence id, not a code span — must be a link in that entry, or
the text of a link elsewhere on the shelf (a cross-reference to an entry that carries one).

**Known limits, named rather than hidden** (the lens stopping rule of 2026-09-24):
- a name inside a sentence is not an entry head, and is not seen;
- a name spelt in lowercase (`pytest`, `i18next`) does not read as a name, and is not seen;
- a name of five words or more does not read as a name;
- an entry holding one link is read as linked, whatever else it names — skipping it is what keeps
  a heading like *Reusable — licence-clean:* before a link from reading as an unlinked project;
- `NOT_PROJECTS` is a list a person keeps: a project added to it is silenced, which is why every
  entry carries its reason and the list is read in review like any other rule.
"""
import re
import sys
from pathlib import Path

SHELF_COLUMNS = {"Default", "Default stack", "Anchor", "Read",
                 "Unit / component", "E2E", "Visual / a11y / perf"}

# Heads that are methods, measures, standards or kinds of thing — not something one installs,
# forks or signs up to. Each group says why; a project never belongs here, however well known.
NOT_PROJECTS = {
    # growth, research and strategy frameworks — methods with no single home to link
    "See-Think-Do-Care", "PLG flywheel", "AARRR", "JTBD timeline", "Morningstar's five moats",
    "Porter's five forces", "Hunt's awareness ladder",
    # UX and satisfaction measures — questionnaires, not products
    "CES", "SEQ", "CSAT", "CSI", "UMUX-Lite", "SUS", "NASA-TLX", "UEQ-S", "NPS",
    "Sean Ellis test",
    # words that head an entry and name a category, a rung or a caveat, not a project
    "EU-hosted", "API", "VC content", "OG images", "SaaS navigation", "Default stack",
    "Unit", "More free", "Other agent runtimes", "B2B",
}

LICENCE = re.compile(r"^(MIT|Apache|AGPL|LGPL|GPL|BSD|MPL|CC0|CC BY|BUSL|FSL|ELv2|Elastic|SSPL|"
                     r"Unlicense|ISC|EPL|OSS|Zlib|0BSD)\b", re.I)
FUNCTION_WORDS = set("the a an and or of for to in on at by is are not no with when what which from "
                     "as it its this that be was were every any all only never than then per via "
                     "own".split())
LINK = re.compile(r"\[([^\]]*)\]\([^)]*\)")


def strip_parens(s):
    prev = None
    while prev != s:
        prev, s = s, re.sub(r"\([^()]*\)", "", s)
    return s


def norm(s):
    return re.sub(r"[*`]", "", s).strip(" .,;:").lower()


def reads_as_name(h):
    if not h or h in NOT_PROJECTS or len(h) > 40:
        return False
    words = h.split()
    if len(words) > 4 or any(w.lower() in FUNCTION_WORDS for w in words):
        return False
    if LICENCE.match(h) or re.search(r"\d[\d.,]*\s*(k|★|stars)", h):
        return False
    return h[0].isupper() or h[0].isdigit()


def heads(cell):
    c = LINK.sub("\x00", cell)
    c = strip_parens(c)
    for entry in re.split(r" · | / |; | \+ ", c):
        entry = entry.strip()
        if not entry or "\x00" in entry:
            continue
        head = re.split(r" — | – | - |: |\*\*:|:\*\* ", entry)[0]
        if re.fullmatch(r"\s*`[^`]*`\s*", head):      # a code span is a command, not a name
            continue
        head = re.sub(r"`[^`]*`", "", head)
        for part in head.split("/"):
            part = part.replace("*", "").strip(" .,;:")
            if reads_as_name(part):
                yield part


def findings(path):
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    linked = {norm(m.group(1)) for l in lines for m in LINK.finditer(l)}
    out, cols, section = [], None, ""
    for i, line in enumerate(lines):
        if line.startswith("## "):
            section = line[3:].strip()
        if not line.startswith("|"):
            cols = None
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        if cols is None:                      # the header row names the columns
            cols = [k for k, c in enumerate(cells) if c in SHELF_COLUMNS] \
                if re.match(r"^\|\s*:?-", nxt) else []
            continue
        if re.match(r"^\|\s*:?-", line):
            continue
        for k in cols:
            if k >= len(cells):
                continue
            for h in heads(cells[k]):
                if norm(h) not in linked:
                    out.append(f"{path}:{i + 1}: '{h}' is on the shelf without a link "
                               f"({section[:40]}) — link it where it is named")
    return out


def main():
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = next((p for p in ("catalogue.md", "STACKS.md") if Path(p).exists()), None)
        if path is None:
            print("no shelf here — neither catalogue.md nor STACKS.md exists")
            return 2
    bad = findings(path)
    for b in bad:
        print(b)
    if bad:
        print(f"{len(bad)} project(s) on {path} without a link")
        return 1
    print(f"every project named at the head of a shelf entry in {path} carries a link")
    return 0


if __name__ == "__main__":
    sys.exit(main())
