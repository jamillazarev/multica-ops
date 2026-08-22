#!/usr/bin/env bash
# guard-version: 0.4.9   <!-- stamped from the skill at ship time; read by the check below -->
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

SENTINEL="# managed by multica-ops company-preflight"

if [ "${1:-}" = "--install" ]; then
  # Must be a real repo with a real hooks dir. In a worktree .git is a FILE, and with
  # core.hooksPath (husky, lefthook) the hooks live elsewhere — writing blind there
  # reports success while installing nothing.
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "  x not inside a git repository — nothing installed"; exit 1; }
  hookdir=$(git config --get core.hooksPath 2>/dev/null || true)
  if [ -n "$hookdir" ]; then
    echo "  x this repo uses core.hooksPath=$hookdir (husky, lefthook or similar)."
    echo "    Add to your existing pre-commit instead:  bash scripts/preflight.sh || exit 1"
    exit 1
  fi
  hookdir=$(git rev-parse --git-path hooks 2>/dev/null) || hookdir="$root/.git/hooks"
  hook="$hookdir/pre-commit"

  # Only ever replace a hook this script wrote. A substring test on the script name is
  # not enough: the chaining line we print below contains that same name, so a chained
  # gitleaks hook would look like ours and get overwritten — deleting a real control.
  if [ -e "$hook" ] || [ -L "$hook" ]; then
    if ! grep -qF "$SENTINEL" "$hook" 2>/dev/null; then
      echo "  x $hook already exists and was not written by this script."
      echo "    Not touching it - it may be your secret scan or test gate."
      echo "    Chain it by adding this line to it:  bash scripts/preflight.sh || exit 1"
      exit 1
    fi
  fi

  mkdir -p "$hookdir" || { echo "  x cannot create $hookdir"; exit 1; }
  tmp="$hook.multica-tmp.$$"
  printf '#!/bin/sh\n%s\nexec bash scripts/preflight.sh\n' "$SENTINEL" > "$tmp" || {
    echo "  x cannot write $tmp"; exit 1; }
  chmod +x "$tmp" && mv -f "$tmp" "$hook" || {
    rm -f "$tmp"; echo "  x cannot install $hook"; exit 1; }
  echo "pre-commit hook installed at $hook"; exit 0
fi

# **The guard checks its OWN age against the guide.** This file is a COPY: written into the
# company's repo at stand-up and never moving again by itself, so every release that adds a check
# leaves existing companies on the old one — silently, green, running fewer gates than the version
# their guide claims. The upgrade's layers named the skill's bytes, the format, attached skills and
# tooling versions; the installed machinery was in none of them. Named 2026-08-22, when one release
# added two checks here and nothing would have carried them into a single existing company.
# A WARNING, not a refusal: sitting a version behind between upgrades is legitimate, and a guard
# that blocks every commit is a guard people delete.
fail=0; warn=0
# Two helpers the sibling's guard already carries, brought over with the dependency gate that
# needs them. `changed` takes a git PATHSPEC rather than filtering names in shell — a path with a
# newline survives that and does not survive `grep -z` under BSD. `hits` counts rather than
# short-circuits: under `set -o pipefail` a `grep -q` SIGPIPEs its producer and the pipeline
# returns that failure even when the phrase MATCHED, which reads as absent.
changed() { git -c core.quotePath=false diff --cached --name-only -z "$@" 2>/dev/null || true; }
hits() { [ "$( grep -c "$@" 2>/dev/null | head -1 || true )" -gt 0 ] 2>/dev/null; }
say_fail() { echo "  ✗ $1"; fail=1; }
say_warn() { echo "  ! $1"; warn=1; }
_gv=$(sed -n 's/^# guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$0" | head -1)
_pv=$(grep -m1 -oE '[Oo]perated by[^0-9]*([0-9]+\.[0-9]+\.[0-9]+)' CLAUDE.md 2>/dev/null \
      | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
if [ -n "$_gv" ] && [ -n "$_pv" ] && [ "$_gv" != "$_pv" ]; then
  say_warn "this guard is version $_gv and the guide says the company runs $_pv — the guard is a \
COPY and does not move with an upgrade, so any check added since $_gv is not running here and \
nothing else will say so. Re-copy it: \`cp <skill>/templates/company-preflight.sh \
_ops/preflight.sh\`. A stale guard does not complain; it does less"
fi

echo "preflight — _ops"

# 1 · the docs the guide promises must exist. An agent told to read a file that
#     isn't there improvises, and improvisation is how conventions drift.
for f in _ops/ROADMAP.md _ops/TEAM.md _ops/TOOLING.md _ops/DECISIONS.md _ops/LATER.md; do
  [ -f "$f" ] || say_fail "$f is missing — the guide tells every agent it exists"
done
if git ls-files | grep -qE '\.(ts|tsx|js|py|go|rs|swift|kt|rb|java)$'; then
  [ -f _ops/ARCHITECTURE.md ] || say_warn "there is code but no _ops/ARCHITECTURE.md — every task \
starts in a fresh worktree and re-derives the layout"
fi

# 2 · a recorded fact past its recheck is unknown, not fact. TOOLING.md carries a
#     Checked column precisely so this can be enforced rather than hoped for.
if [ -f _ops/TOOLING.md ]; then
  python3 - <<'PY'
import re, datetime, sys
STALE_DAYS = 90
today = datetime.date.today()
old = []
for line in open("_ops/TOOLING.md", encoding="utf-8"):
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

# 3 · DECISIONS.md and FIELD-NOTES.md are append-only. Rewriting the first is how a
#     rejected idea comes back next quarter with nobody able to say why it lost; editing
#     the second is how a stumble gets polished into never having happened — a correction
#     is a new entry, never an edit to an old one.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  for ao in _ops/DECISIONS.md _ops/FIELD-NOTES.md; do
    [ -f "$ao" ] || continue
    removed=$(git diff --cached -U0 -- "$ao" 2>/dev/null \
              | grep -c '^-[^-]' || true)
    [ "${removed:-0}" -gt 0 ] && say_fail "$ao is append-only — this commit \
removes or rewrites $removed line(s). Add a new entry instead."
  done
fi

# 4 · the architecture map must mention the places work actually happens.
if [ -f _ops/ARCHITECTURE.md ]; then
  for d in $(git ls-files | awk -F/ 'NF>1 {print $1}' | sort -u); do
    case "$d" in _ops|docs|.github|node_modules|dist|build|vendor) continue;; esac
    grep -q "$d" _ops/ARCHITECTURE.md || say_warn "_ops/ARCHITECTURE.md never mentions \`$d/\` \
— either map it or say why it doesn't matter"
  done
fi

# 4b · a document nobody links is a document nobody reads. The skeleton files are
#      referenced by the guide itself; anything else under _ops/ has to be reachable
#      from at least one other document, or it was written into a drawer.
for f in $(git ls-files '_ops/*.md' '_ops/**/*.md' 2>/dev/null); do
  case "$f" in
    _ops/ROADMAP.md|_ops/TEAM.md|_ops/TOOLING.md|_ops/DECISIONS.md|_ops/LATER.md|\
_ops/ARCHITECTURE.md|_ops/BUDGET.md|_ops/ECONOMICS.md|_ops/README.md) continue;;
  esac
  base=$(basename "$f")
  git grep -qF "$base" -- '*.md' ":!$f" 2>/dev/null \
    || say_warn "nothing links \`$f\` — link it from the doc it belongs under, or delete it"
done

# 5b · skills born in this repo stay modular (templates/SKILL-SCAFFOLD.md): a budgeted
#      router core + companions. Catches the monolith while it is still one commit old.
for sk in $(git ls-files | grep -E '(^|/)SKILL\.md$' || true); do
  dir=$(dirname "$sk")
  budget=$(sed -n 's/^core_budget:[[:space:]]*//p' "$sk" | head -1)
  lines=$(grep -c '' "$sk")
  if [ -n "$budget" ] && [ "$lines" -gt "$budget" ]; then
    say_warn "$sk is $lines lines against its own core_budget: $budget — move a block to a companion, don't squeeze"
  fi
  companions=$(ls "$dir"/*.md 2>/dev/null | grep -v 'SKILL\.md$' | wc -l | tr -d ' ')
  if [ "$companions" -gt 0 ] && ! grep -q '| Load' "$sk"; then
    say_warn "$sk has $companions companion file(s) but no '| Load … | …when |' routing table — companions nobody routes to are dead weight"
  fi
done

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


# 4e · **a new dependency says what it replaces.** The sharpest rung of *should this exist at all*
#      is the one a commit can be asked about: adding a dependency. Everything above it in the
#      ladder — is it already here · does the standard library do it · does the platform do it
#      natively · can it be one line — is a judgement no script can make. **Whether the answer was
#      written down is not.**
#
#      So this refuses a commit that ADDS a dependency line with nothing in the same commit saying
#      what was considered. `unknown` is not the escape here that it is for a market figure: the
#      answer is cheap and the asker is the person who just chose. One line in `_ops/DECISIONS.md`
#      naming the dependency does it.
#
#      Enforced on what the commit CREATES, like every gate here — existing dependencies are the
#      project's history and are not retro-justified.
_dep_added=""
_dep_names=""   # under `set -u` an unset name is not empty, it is the end of the script —
                # and it ends BEFORE printing anything, so the failure arrives as a green
                # tick with no refusal. Caught by this gate's own suite, 2026-08-22.
while IFS= read -r -d '' mf; do
  # the added lines of this manifest, fences and lockfiles aside
  case "$mf" in *.lock|*lock.json|*.sum) continue;; esac
  _new=$( ( git diff --cached -U0 -- "$mf" 2>/dev/null || true ) | grep '^+' | grep -v '^+++ ' | sed 's/^+//' )
  # The NAME, not just the shape. A keyword list was the first version and the suite caught it
  # inside the hour: it accepted a justification that happened to say `stdlib` and refused an
  # honest one that did not — the substring-instead-of-value class, in a gate written the same day
  # two others were repaired for it. Requiring the dependency's own NAME cannot be satisfied by
  # vocabulary, and the person who just chose it is the one person who can write it.
  # ADDED MINUS REMOVED. Writing a manifest reformats its neighbours — adding one dependency
  # re-indents the line above it and puts a comma on it, so a naive read of the `+` side asked
  # about a package nobody touched. It also, for free, stops a VERSION BUMP being treated as a
  # new dependency: the name is on both sides, so it cancels. Both measured 2026-08-22, the first
  # by this gate's own suite within the hour.
  _gone=$( ( git diff --cached -U0 -- "$mf" 2>/dev/null || true ) | grep '^-' | grep -v '^--- ' | sed 's/^-//' )
  # ANYWHERE in the line, not anchored to its start. Third iteration of this extractor, and
  # reformatting was the adversary every time: writing a manifest re-indents neighbours (caught
  # first), and it also COLLAPSES or EXPANDS them — `{"react": "^18.0.0"}` on one line becomes
  # three, so the removed side carries the name inside a brace and a line-anchored read missed it,
  # reporting a package nobody touched. Measured 2026-08-22, all three by this gate's own tests.
  _pick() { grep -oE '"[A-Za-z0-9@/._-]+"[[:space:]]*:[[:space:]]*"[~^>=<0-9][^"]*"|^[[:space:]]*[A-Za-z0-9_.-]+[[:space:]]*([=~<>]{1,2}[[:space:]]*[0-9]|=[[:space:]]*"[0-9~^])' \
             | grep -oE '^[[:space:]]*"[A-Za-z0-9@/._-]+"|^[[:space:]]*[A-Za-z0-9_.-]+' | tr -d '" \t' | grep -vE '^[0-9~^]' || true; }
  _old_names=$(printf '%s\n' "$_gone" | _pick)
  _names=$(printf '%s\n' "$_new" | _pick | while IFS= read -r _n; do
             [ -n "$_n" ] && { printf '%s\n' "$_old_names" | hits -xF -- "$_n" || printf '%s\n' "$_n"; }
           done)
  [ -n "$_names" ] && _dep_added="$_dep_added $mf" && _dep_names="$_dep_names $_names"
done < <(changed --diff-filter=AMR -- 'package.json' 'requirements*.txt' 'pyproject.toml' 'go.mod' 'Cargo.toml' 'Gemfile' 'composer.json')
if [ -n "$_dep_added" ]; then
  _dec=$( ( git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null || true ) | grep '^+' | grep -v '^+++ ' || true )
  _unnamed=""
  for _d in $_dep_names; do
    printf '%s\n' "$_dec" | hits -iF -- "$_d" || _unnamed="$_unnamed $_d"
  done
  [ -z "$_unnamed" ] \
    || say_fail "this commit adds$(printf '%s' "$_unnamed" | tr -s ' ') to$(printf '%s' "$_dep_added" | tr -s ' ') and says \
nothing about why. The cheapest code is the code nobody writes, and the ladder above a new \
dependency — is it already here · does the standard library do it · does the platform do it \
natively · can it be one line — is a judgement only the person choosing can make. Write the one \
line they already know, in _ops/DECISIONS.md in this same commit, NAMING IT: what it replaces, \
and what was rejected. The name is asked for rather than a keyword, because a gate satisfied by \
vocabulary teaches people to sprinkle words. A dependency arrives in a minute and leaves over a \
year"
fi

# 4f · **the same rung outside software.** A package manifest is one project's spelling of *a new
#      standing commitment*. A bakery's is a supplier, a channel's is a subscription, a studio's
#      is a stock licence — and this system is used in all of them (*a chip maker has no data
#      flows and a bakery has no deploys*). **The universal register is `_ops/TOOLING.md`**: a row
#      added there is the same act as a dependency line, arriving in a minute and maintained for a
#      year. So a project with no package manifest at all is not exempt from the rung, which it
#      was for the first hour of this gate's life.
#
#      A WARNING rather than a refusal, and the reason is the domain: outside software the honest
#      answer is very often *we had none* — the work was not being done at all — and that is an
#      answer, not an evasion. The register's own template already asks *what for*; what this asks
#      is the rung above choosing: **what was done before this, and why that stopped being enough.**
_tool_rows=""
if ( changed --diff-filter=AMR -- '_ops/TOOLING.md' ) | hits . ; then
  _tool_rows=$( ( git diff --cached -U0 -- _ops/TOOLING.md 2>/dev/null || true ) \
    | grep '^+' | grep -v '^+++ ' | sed 's/^+//' \
    | grep -E '^[[:space:]]*\|' \
    | grep -vE '^[[:space:]]*\|[[:space:]]*-{2,}' \
    | grep -viE '\|[[:space:]]*(tool|name|what)[[:space:]]*\|' || true )
fi
if [ -n "$_tool_rows" ]; then
  _dec2=$( ( git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null || true ) \
    | grep '^+' | grep -v '^+++ ' || true )
  printf '%s\n%s\n' "$_tool_rows" "$_dec2" \
    | hits -iE 'instead of|replaces|rather than|already|by hand|nothing else|we had none|had no ' \
    || say_fail "this commit adds a row to _ops/TOOLING.md and nothing says what it replaces. A \
tool arrives in a minute and is maintained for a year, and the rung above choosing one is asking \
whether the work already had a way — a clause in the row's own why, or a line in \
_ops/DECISIONS.md: what was done before this, and why that stopped being enough. \`we had none\` \
is a complete answer and often the true one outside software — write it and this passes.
#
#      **It refuses rather than warns, and that was measured rather than argued.** It warned for
#      its first hours and scored 0 of 5: three runs added the row, committed, and none said what
#      came before. The same day, in the same corpus, a rule that REFUSES scored 5 of 5. A warning
#      is a demand, and this system's own rounds put demands in the same band as prose. Accepting
#      \`we had none\` is what makes refusing fair: the gate refuses SILENCE, never the answer."
fi


[ "$fail" = 0 ] && { [ "$warn" = 0 ] && echo "  ✓ clean" || echo "  ✓ passed with warnings"; }
exit "$fail"
