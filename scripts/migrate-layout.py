#!/usr/bin/env python3
"""Move a pre-0.4.0 workspace's `docs/` machinery into the `_ops/` layout — as history, not as loss.

    python3 scripts/migrate-layout.py <project-root> [--dry-run]

Before 0.4.0 everything the methodology owned lived under `docs/`, mixed into whatever
documentation the project already had. `_ops/` sorts first, collides with nothing, and gives
the root back to the craft.

Three properties this script exists to have:

**It moves only what it recognises.** The claimed list below is the canonical layout table
(BOOTSTRAP §7) and nothing else. **A `docs/` entry it does not know is left exactly where it
is and named in the output** — that directory is very often the project's own, and a migration
that swallows a craft's documentation is worse than no migration.

**Every move is a `git mv`**, so blame and history survive; an untracked file is moved plainly.

**It is its own diff.** A dirty tree is refused, because a migration mixed into unrelated work
is a diff nobody can review. It is idempotent — a second run finds nothing and says so — and a
destination that already exists is a `CONFLICT` line and a nonzero exit, never a silent
overwrite.
"""
import subprocess
import sys
from pathlib import Path

# The canonical layout table, and only it.
DOCS_FILES = ["ROADMAP.md", "TEAM.md", "TOOLING.md", "DECISIONS.md", "LATER.md",
              "FIELD-NOTES.md", "ARCHITECTURE.md", "MAP.md", "BUDGET.md", "ECONOMICS.md",
              "assets.md", ".workspace-state.json"]
DOCS_DIRS = ["analytics", "research", "audience", "design-system", "brand", "skill-backups"]
# The one rename: a runbook is what the directory holds, and `docs/tooling/` sitting beside
# `docs/TOOLING.md` was one word doing two jobs.
RENAMES = {"tooling": "runbooks"}


def sh(root, *args):
    return subprocess.run(args, cwd=root, capture_output=True, text=True)


def tracked(root, rel):
    return sh(root, "git", "ls-files", "--error-unmatch", rel).returncode == 0


def main():
    argv = [a for a in sys.argv[1:] if a != "--dry-run"]
    dry = "--dry-run" in sys.argv
    if not argv:
        print(__doc__.strip().splitlines()[0])
        print(f"\n    usage: {Path(sys.argv[0]).name} <project-root> [--dry-run]")
        return 2
    root = Path(argv[0]).resolve()
    if not (root / ".git").exists():
        print(f"not a git repository: {root}")
        return 2
    if not dry and sh(root, "git", "status", "--porcelain").stdout.strip():
        print("the tree is dirty — commit or stash first, so the migration is its own diff")
        return 2

    # `_ops/` is a door shared with the sibling project `opsinist`, which uses the same
    # directory and names nine of its twelve documents identically. That sharing is deliberate
    # — a successor finds the predecessor's record where it would have put its own — but it
    # means the ownership must be read before anything moves. `_ops/config.md` is theirs; an
    # `Operated by multica-ops` line in the guide is ours.
    if (root / "_ops" / "config.md").is_file():
        ours = any(
            "operated by multica-ops" in (root / g).read_text(encoding="utf-8", errors="replace").lower()
            for g in ("CLAUDE.md", "AGENTS.md", "GEMINI.md") if (root / g).is_file())
        if not ours:
            print("this tree is operated by another system — `_ops/config.md` is present and no\n"
                  "guide here says `Operated by multica-ops`. Nothing was moved. Their records are\n"
                  "evidence, not our workspace: stay a guest, or let the owner decide to succeed them.")
            return 2

    moves = []

    def claim(src_rel, dst_rel):
        if (root / src_rel).exists():
            moves.append((src_rel, dst_rel))

    for f in DOCS_FILES:
        claim(f"docs/{f}", f"_ops/{f}")
    for d in DOCS_DIRS:
        claim(f"docs/{d}", f"_ops/{d}")
    for old, new in RENAMES.items():
        claim(f"docs/{old}", f"_ops/{new}")

    conflicts = [(s, d) for s, d in moves if (root / d).exists()]
    moves = [(s, d) for s, d in moves if not (root / d).exists()]

    if not moves and not conflicts:
        print("nothing to migrate — the layout is already `_ops/`, or was never ours")
        return 0

    for s, d in moves:
        print(f"  {s}  →  {d}")
        if dry:
            continue
        (root / d).parent.mkdir(parents=True, exist_ok=True)
        if tracked(root, s) or sh(root, "git", "ls-files", s).stdout.strip():
            r = sh(root, "git", "mv", s, d)
            if r.returncode != 0:
                print(f"  git mv failed: {r.stderr.strip()}")
                return 1
        else:
            (root / s).rename(root / d)

    # What stayed behind is the point, not an afterthought: say it by name so nobody has to
    # guess whether the migration finished or gave up halfway.
    # **What this run is about to move is not left behind, and a dry run must not say it is.**
    # This read the directory from disk, which is right after a real move and wrong before a
    # previewed one: under `--dry-run` nothing has moved yet, so every file the preview had just
    # promised to move was printed a second time as staying put. The behaviour was correct and
    # only the preview lied — in the one place a preview exists for. Reported 2026-09-05 against
    # the sibling and reproduced here unchanged.
    _claimed = {s for s, _ in moves}
    leftovers = sorted(p.name for p in (root / "docs").iterdir()
                       if f"docs/{p.name}" not in _claimed) if (root / "docs").is_dir() else []
    if leftovers:
        print(f"  left in docs/, as the project's own: {', '.join(leftovers)}")

    # The pre-commit guard is a *copy* of our template, so it still checks `docs/…` paths that
    # no longer exist and would fail every commit. It is the project's file, so it is named
    # rather than rewritten — re-copying is the honest fix, and it brings the newer checks too.
    hook = root / ".git" / "hooks" / "pre-commit"
    try:
        if hook.is_file() and "docs/" in hook.read_text(encoding="utf-8", errors="replace"):
            print("  ! .git/hooks/pre-commit still checks docs/… — re-copy "
                  "templates/company-preflight.sh over it")
    except OSError:
        pass

    for s, d in conflicts:
        print(f"  CONFLICT: {s} not moved — {d} already exists; merge by hand")

    if not dry:
        print("moved — review the staged renames, then commit them as one migration commit")
    return 1 if conflicts else 0


if __name__ == "__main__":
    sys.exit(main())
