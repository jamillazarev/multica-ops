#!/usr/bin/env python3
"""Fill the `touched by:` blocks in a product map from the board — and flag contended nodes.

    python3 scripts/map-blocks.py [_ops/MAP.md] [--from issues.json] [--check]

The map says how the product is walked; **who is standing on a node right now** is board state,
and board state typed by hand is stale the same afternoon. So each node carries a marker pair

    <!-- touched-by: Library -->
    <!-- /touched-by -->

and this script rewrites **only what sits between them**. Everything else in the file — the
prose, the flows, the ordering — is never touched, because a generator that reformats a document
it does not own is one nobody dares run.

An issue declares its nodes in native metadata:

    multica issue metadata set <issue-id> touches "Library,Player"

**Two live issues on one node is stated inside the block**, which is the whole point: it is a
merge conflict arriving a week early, while sequencing them is still cheap.

`--check` writes nothing and exits 1 if any block is out of date — for a preflight, where the
question is *did anyone run this* rather than *fix it for me*.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

LIVE = {"todo", "in_progress", "in_review", "blocked"}
BLOCK = re.compile(r"(<!-- touched-by: (?P<node>[^>]+?) -->)(?P<body>.*?)(<!-- /touched-by -->)",
                   re.S)


def from_cli():
    """Every issue with its status and its `touches` metadata, read from the CLI."""
    r = subprocess.run(["multica", "issue", "list", "--output", "json"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print(f"! multica issue list failed: {r.stderr.strip()[:200]}", file=sys.stderr)
        return None
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        print("! could not parse `issue list --output json`", file=sys.stderr)
        return None


def touchers(issues):
    """node → [(key, status)], live issues only, in board order."""
    by_node = {}
    for i in issues or []:
        status = (i.get("status") or "").lower()
        if status not in LIVE:
            continue
        meta = i.get("metadata") or {}
        raw = meta.get("touches") if isinstance(meta, dict) else None
        if not raw:
            continue
        key = i.get("key") or i.get("identifier") or i.get("id") or "?"
        for node in [n.strip() for n in str(raw).split(",") if n.strip()]:
            by_node.setdefault(node, []).append((key, status))
    return by_node


def render(node, by_node):
    rows = by_node.get(node, [])
    if not rows:
        return "\n  <!-- none live -->\n  "
    listed = " · ".join(f"{k} ({s})" for k, s in rows)
    out = f"\n  - touched by: {listed}\n"
    if len(rows) > 1:
        out += ("  - ⚠️ **contended — two live issues on one node.** Sequence them by stage, or "
                "say out loud why they are independent; discovering it at review costs a "
                "rewrite.\n")
    return out + "  "


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    check = "--check" in sys.argv
    src = next((a for a in sys.argv[1:] if a.startswith("--from=")), None)
    path = Path(args[0]) if args else Path("_ops/MAP.md")
    if not path.is_file():
        print(f"no map at {path} — nothing to do")
        return 0

    if src:
        issues = json.loads(Path(src.split("=", 1)[1]).read_text(encoding="utf-8"))
    elif "--from" in sys.argv:
        i = sys.argv.index("--from")
        issues = json.loads(Path(sys.argv[i + 1]).read_text(encoding="utf-8"))
    else:
        issues = from_cli()
        if issues is None:
            return 2

    by_node = touchers(issues)
    text = path.read_text(encoding="utf-8")
    seen, contended = [], []

    def sub(m):
        node = m.group("node").strip()
        seen.append(node)
        if len(by_node.get(node, [])) > 1:
            contended.append(node)
        return m.group(1) + render(node, by_node) + m.group(4)

    new = BLOCK.sub(sub, text)
    if not seen:
        print(f"{path} has no `touched-by` markers — add a pair under each node "
              "(templates/MAP-template.md)")
        return 0

    stale = new != text
    if check:
        print(f"{path}: {len(seen)} node(s)" + (" — blocks are out of date" if stale else " — current"))
        return 1 if stale else 0
    if stale:
        path.write_text(new, encoding="utf-8")
    unknown = sorted(set(by_node) - set(seen))
    print(f"{path}: {len(seen)} node(s) filled" + (", unchanged" if not stale else ""))
    if contended:
        print(f"  ⚠️ contended: {' · '.join(sorted(set(contended)))}")
    if unknown:
        print(f"  ! issues name nodes the map does not have: {' · '.join(unknown)}"
              " — either the map is behind, or the issue named it wrong")
    return 0


if __name__ == "__main__":
    sys.exit(main())
