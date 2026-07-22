#!/usr/bin/env bash
# Pre-commit preflight for the multica-ops repo.
# Keeps the skill coherent: versions in sync, CHANGELOG written, README complete,
# no broken links, commands consistent, and the always-loaded core from bloating.
# Run: bash scripts/preflight.sh   ·   install: bash scripts/preflight.sh --install
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

if [ "${1:-}" = "--install" ]; then
  printf '#!/usr/bin/env bash\nexec bash scripts/preflight.sh\n' > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  echo "✓ installed as .git/hooks/pre-commit"; exit 0
fi

fail=0; warn=0
say_fail() { echo "  ✗ $1"; fail=1; }
say_warn() { echo "  ! $1"; warn=1; }

echo "preflight — multica-ops"

# 1 · version in SKILL.md == plugin.json
sv=$(grep -m1 '^version:' SKILL.md | awk '{print $2}')
pv=$(grep -m1 '"version"' .claude-plugin/plugin.json | sed 's/.*"version": *"\([^"]*\)".*/\1/')
[ "$sv" = "$pv" ] || say_fail "version mismatch: SKILL.md=$sv plugin.json=$pv"

# 2 · CHANGELOG documents this version (it is the migration map for /upgrade)
grep -q "^## ${sv}\b" CHANGELOG.md || say_fail "CHANGELOG.md has no '## $sv' section"

# 3 · README lists every companion file
for f in $(ls *.md | grep -vE '^(README|CHANGELOG)\.md$'); do
  grep -q "$f" README.md || say_fail "README.md does not mention $f"
done

# 4 · internal .md links resolve
for l in $(grep -rohE '\]\([A-Za-z0-9_.-]+\.md\)' ./*.md templates/*.md 2>/dev/null | sed 's/](//;s/)//' | sort -u); do
  [ -f "$l" ] || say_fail "broken link: $l"
done

# 5 · always-loaded core stays lean (it is paid on every run, by every agent)
chars=$(wc -c < SKILL.md | tr -d ' '); tok=$((chars/4))
[ "$tok" -gt 10000 ] && say_fail "SKILL.md ~${tok} tokens — over the 10k budget; move detail to a companion file"
[ "$tok" -gt 9000 ] && [ "$tok" -le 10000 ] && say_warn "SKILL.md ~${tok} tokens — approaching the 10k budget"

# 6 · every command in the table has a plugin file
for c in $(grep -oE '^\| `/[a-z-]+' COMMANDS.md | tr -d '| `/'); do
  [ -f "commands/$c.md" ] || say_fail "command /$c has no commands/$c.md"
done

# 7 · reminders that cannot be verified from this repo
git diff --cached --name-only 2>/dev/null | grep -qE '\.md$' && \
  echo "  → docs site: regenerate + deploy (python3 scripts/generate.py <repo> in the ai repo)"

[ $fail -eq 0 ] && [ $warn -eq 0 ] && echo "  ✓ all checks passed"
[ $fail -eq 0 ] && [ $warn -eq 1 ] && echo "  ✓ passed with warnings"
exit $fail
