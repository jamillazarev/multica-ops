#!/usr/bin/env bash
# Docs guard for a company Mops built — install it into the company's own repo, not ours.
#
#   cp templates/company-preflight.sh <repo>/scripts/preflight.sh
#   bash scripts/preflight.sh --install     # wires it as a pre-commit hook
#
# It guards the four things this methodology insists on and nobody remembers unprompted:
# the docs the guide promises exist, recorded facts have not silently expired, the
# decisions log is append-only, and the architecture map still describes the repo.
#
# Deliberately small. A hook that cries wolf is a hook people bypass with --no-verify.
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

if [ "${1:-}" = "--install" ]; then
  mkdir -p .git/hooks
  printf '#!/bin/sh\nexec bash scripts/preflight.sh\n' > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  echo "pre-commit hook installed"; exit 0
fi

fail=0; warn=0
say_fail() { echo "  ✗ $1"; fail=1; }
say_warn() { echo "  ! $1"; warn=1; }
echo "preflight — docs"

# 1 · the docs the guide promises must exist. An agent told to read a file that
#     isn't there improvises, and improvisation is how conventions drift.
for f in docs/ROADMAP.md docs/TEAM.md docs/TOOLING.md docs/DECISIONS.md; do
  [ -f "$f" ] || say_fail "$f is missing — the guide tells every agent it exists"
done
if git ls-files | grep -qE '\.(ts|tsx|js|py|go|rs|swift|kt|rb|java)$'; then
  [ -f docs/ARCHITECTURE.md ] || say_warn "there is code but no docs/ARCHITECTURE.md — every task \
starts in a fresh worktree and re-derives the layout"
fi

# 2 · a recorded fact past its recheck is unknown, not fact. TOOLING.md carries a
#     Checked column precisely so this can be enforced rather than hoped for.
if [ -f docs/TOOLING.md ]; then
  python3 - <<'PY'
import re, datetime, sys
STALE_DAYS = 90
today = datetime.date.today()
old = []
for line in open("docs/TOOLING.md", encoding="utf-8"):
    if not line.strip().startswith("|"):
        continue
    m = re.search(r"(\d{4})-(\d{2})-(\d{2})", line)
    if not m:
        continue
    d = datetime.date(*map(int, m.groups()))
    if (today - d).days > STALE_DAYS:
        name = line.split("|")[1].strip()
        old.append(f"{name} (checked {d}, {(today-d).days}d ago)")
for o in old:
    print(f"STALE:{o}")
PY
fi 2>/dev/null | while IFS= read -r l; do
  case "$l" in STALE:*) say_warn "TOOLING entry past its recheck: ${l#STALE:}";; esac
done

# 3 · DECISIONS.md is append-only. Rewriting it is how a rejected idea comes back
#     next quarter with nobody able to say why it was rejected the first time.
if git rev-parse --verify HEAD >/dev/null 2>&1 && [ -f docs/DECISIONS.md ]; then
  removed=$(git diff --cached -U0 -- docs/DECISIONS.md 2>/dev/null \
            | grep -c '^-[^-]' || true)
  [ "${removed:-0}" -gt 0 ] && say_fail "docs/DECISIONS.md is append-only — this commit \
removes or rewrites $removed line(s). Add a new entry instead."
fi

# 4 · the architecture map must mention the places work actually happens.
if [ -f docs/ARCHITECTURE.md ]; then
  for d in $(git ls-files | awk -F/ 'NF>1 {print $1}' | sort -u); do
    case "$d" in docs|.github|node_modules|dist|build|vendor) continue;; esac
    grep -q "$d" docs/ARCHITECTURE.md || say_warn "docs/ARCHITECTURE.md never mentions \`$d/\` \
— either map it or say why it doesn't matter"
  done
fi

# 5 · a cheap last line on credentials. NOT a secret scanner — gitleaks/trufflehog are,
#     and they belong in CI. This catches the obvious paste before it reaches history,
#     where removing it means rewriting history and rotating the key anyway.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  added=$(git diff --cached -U0 2>/dev/null | grep '^+' || true)
  # known credential shapes: provider prefixes, then key-ish name = long quoted value
  if printf '%s' "$added" | grep -qE '(sk-[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'; then
    say_fail "this commit contains something shaped like a credential — secrets live in \
mcp_config / custom-env, never in the repo. If it is already committed, rotate it."
  elif printf '%s' "$added" | grep -qiE '(api[_-]?key|secret|token|password|credential|[^a-z]key)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_/+.-]{20,}["'"'"']'; then
    say_warn "a long literal is assigned to a key-shaped name — check it is not a secret \
(the real scan is gitleaks in CI, see the tooling register)"
  fi
fi

[ "$fail" = 0 ] && { [ "$warn" = 0 ] && echo "  ✓ clean" || echo "  ✓ passed with warnings"; }
exit "$fail"
