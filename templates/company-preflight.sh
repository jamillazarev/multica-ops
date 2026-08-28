#!/usr/bin/env bash
# guard-version: 0.4.14   <!-- stamped from the skill at ship time; read by the check below -->
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
  # **Seven manifest kinds are named in the pathspec, so seven shapes are read.** The first
  # version matched two — JSON `"n": "^1.0"` and `n==1.0` — and was blind to `"latest"`, `"*"`,
  # `npm:`/`git+`/`file:` specifiers, bare `requirements.txt` names, `go.mod`'s `require`, TOML
  # tables, and Gemfile `gem "x"`. Nine of sixteen realistic ways to add a dependency, in a gate
  # whose pathspec promises all seven files. Measured 2026-08-23 by two lenses.
  # The VALUE decides, not the key. Dropping the version-prefix requirement to catch `"latest"`
  # and `"*"` made `"name": "renamed"` a dependency — caught by this gate's own suite within the
  # minute. So the value must look like a version or a known specifier: a digit, `^ ~ > < =`,
  # `latest`, `*`, or a `npm: git+ file: workspace: link:` prefix. A key blocklist was the other
  # option and it rots; this reads what a dependency actually looks like.
  _pick() { grep -oE '"[A-Za-z0-9@/._-]+"[[:space:]]*:[[:space:]]*"([~^>=<*0-9]|latest|npm:|git\+|file:|workspace:|link:)[^"]*"|^[[:space:]]*(require[[:space:]]+)?[A-Za-z0-9_.@/-]+[[:space:]]*([=~<>!]{1,2}[[:space:]]*[0-9v]|[[:space:]]+v?[0-9])|^[[:space:]]*gem[[:space:]]+"[^"]+"|^[[:space:]]*[A-Za-z0-9_.-]+[[:space:]]*=[[:space:]]*[{"][~^>=<*0-9]' \
             | grep -oE '"[A-Za-z0-9@/._-]+"|^[[:space:]]*(gem[[:space:]]+"[^"]+"|require[[:space:]]+[A-Za-z0-9_.@/-]+|[A-Za-z0-9_.@/-]+)' \
             | sed 's/^[[:space:]]*gem[[:space:]]*//; s/^[[:space:]]*require[[:space:]]*//' | tr -d '" \t' \
             | grep -vE '^([0-9~^v]|require$|dependencies$|dev-dependencies$|tool$|project$|package$)' || true; }
  _old_names=$(printf '%s\n' "$_gone" | _pick)
  _names=$(printf '%s\n' "$_new" | _pick | while IFS= read -r _n; do
             [ -n "$_n" ] && { printf '%s\n' "$_old_names" | hits -xF -- "$_n" || printf '%s\n' "$_n"; }
           done)
  [ -n "$_names" ] && _dep_added="$_dep_added $mf" && _dep_names="$_dep_names $_names"
# **Rooted AND at depth.** A bare `package.json` is a git pathspec anchored at the top
# level, so a monorepo — `frontend/package.json`, `services/api/go.mod` — was invisible to
# both this gate and the reach gate. That is exactly the case the reach gate was widened
# for. Measured 2026-08-23. Lockfiles are skipped in the loop above, so `*/…` is safe.
done < <(changed --diff-filter=AMR -- 'package.json' '*/package.json' 'requirements*.txt' \
         '*/requirements*.txt' 'pyproject.toml' '*/pyproject.toml' 'go.mod' '*/go.mod' \
         'Cargo.toml' '*/Cargo.toml' 'Gemfile' '*/Gemfile' 'composer.json' '*/composer.json')
if [ -n "$_dep_added" ]; then
  _dec=$( ( git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null || true ) | grep '^+' | grep -v '^+++ ' || true )
  _unnamed=""
  for _d in $_dep_names; do
    # WORD-BOUNDED. `hits -iF` was an unbounded substring test, so a decision about anything
    # containing the package name as a fragment — `date` inside `update`, `fs` inside `refs` —
    # satisfied it. Measured 2026-08-23.
    # **A full stop after the name must not break the match.** `.` is a NAME character here so
    # `lodash.merge` and `github.com/x/y` hold together — and that made `left-pad.` fail the
    # trailing boundary, so a maintainer who wrote exactly what the refusal asked was refused
    # again, and told "says nothing about why" about a commit that said it. Measured 2026-08-23 in
    # a lens's four-variant probe: name followed by a space passed, name followed by a full stop
    # did not. This file is copied into other people's repositories; the only escapes were
    # guessing the punctuation rule or `--no-verify`.
    #
    # So a `.` counts as part of the name only when a name character follows it.
    _esc=$(printf '%s' "$_d" | sed 's/[].[^$\\*\/]/\\&/g')
    printf '%s\n' "$_dec" | hits -iE "(^|[^A-Za-z0-9_.@/-])${_esc}([^A-Za-z0-9_.@/-]|\.([^A-Za-z0-9_@/-]|$)|$)" \
      || _unnamed="$_unnamed $_d"
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
#      It REFUSES, and the accepted answer is what makes that fair: outside software the honest
#      answer is very often *we had none* — the work was not being done at all — and that is an
#      answer, not an evasion, so writing it passes. It warned for its first hours and measured
#      0 of 5; as a refusal, 2 of 5 (2026-08-22). The register's own template already asks *what for*; what this asks
#      is the rung above choosing: **what was done before this, and why that stopped being enough.**
# **It refuses rather than warns, and that was measured rather than argued.** It warned for its
# first hours and scored 0 of 5 — three runs added the row, committed, and none said what came
# before. The same day, in the same corpus, a rule that REFUSES scored 5 of 5. A warning is a
# demand, and this system's own rounds put demands in the same band as prose. Accepting
# `we had none` is what makes refusing fair: the gate refuses SILENCE, never the answer.
#
# The six lines above lived INSIDE the refusal string for a day — the closing quote sat after
# them, so every reader of this gate's message got the author's commentary as part of it. Three
# lenses found it, 2026-08-23. A comment inside a quoted argument is not a comment.
_tool_rows=""
if ( changed --diff-filter=AMR -- '_ops/TOOLING.md' ) | hits . ; then
  # **Everything is read from the INDEX, because that is what a pre-commit hook judges.** The
  # first version of this took the register from the WORKTREE and the added lines from the index,
  # then intersected them — so the moment the two disagreed the intersection was empty and the
  # rung went silent. Staging a row and then aligning the table's pipes, which is what a person
  # does next, made the gate pass a row it had just refused. Measured 2026-08-23 by an adversarial
  # lens; a regression against the version before it, whose single source could not disagree with
  # itself. One source, and the question it answers is the right one: what is about to be committed.
  _staged=$(git show :_ops/TOOLING.md 2>/dev/null || true)
  # A separator is one-or-more dashes: `|-|-|` is valid GFM and `-{2,}` read the separator itself
  # as a data row, so a register standing up in that dialect was still refused. The header is the
  # line above it — structure, never the words in it — and fences are skipped because this file's
  # own templates ship example tables.
  # Fences come in dialects, and all of them hide an example the same way: ``` and ~~~ both open
  # and close one, and an HTML comment is how a register parks a draft row it does not mean yet.
  # Only ``` was skipped, so a ~~~ example and a commented-out row were both read as live rows
  # and refused — four documentation-only edits, measured 2026-08-23 by an adversarial lens.
  # **A comment hides a LINE, never the rest of the file, and never a live row it sits inside.**
  # The first version set a flag on any line containing `<!--` and skipped until one carried
  # `-->`. **Six ways silenced the gate, all measured 2026-08-27, and they need three cures.**
  # An opener is believed only when a closer exists — that answers the first three: an inline
  # `<!-- todo -->` in a live row made that row invisible while GFM still rendered it; a bare
  # `<!--` with no closer anywhere made every row after it invisible **permanently**; a stray
  # fence opener with no closer at the top did the same. A line left empty by the strip is HIDDEN
  # rather than read as a boundary — that answers the fourth, the parked draft row. And the strip
  # itself has to survive the text it walks — that answers the last two, a `>` inside a parked row
  # and a CR at the end of it. **This sentence has said "three ways · one cure" through three of
  # those discoveries**; when the next one lands, the count moves with it.
  #
  # Lines are buffered RAW — the diff is matched against the file's own bytes, so a line rewritten
  # for analysis would never match what was staged. Comments are resolved afterwards, where the
  # whole file is visible and an opener can be told from an opener that never closes.
  _rowsrc='
    { n++; L[n] = $0 }
    function resolve(   i, j, k, s) {
      for (i = 1; i <= n; i++) hide[i] = 0
      i = 1
      while (i <= n) {
        # **The inline strip must survive a `>` and a CR.** `<!--[^>]*-->` cannot cross a `>`, so a
        # parked row containing `->`, `>=` or any HTML tag was neither stripped nor hidden — it
        # stayed as non-pipe text and the row scan read it as the end of the table, silencing every
        # live row below. `[ \t]` excluded `\r`, so a CRLF register did the same. Both measured
        # 2026-08-27, both surviving instances of the defect the strip was written to close: the
        # repair had generalised the finding and not the rule.
        # **Three more things this loop has to survive, all measured 2026-08-28.**
        # (a) It rebuilt the WHOLE line each pass — prefix included — so the next match rescanned
        #     everything already walked: 27.8s on a 390 KB row against 0.06s for the single gsub
        #     it replaced. A guard that slow is one people run with --no-verify, which this
        #     file names as its own failure mode. The prefix is consumed into _acc and never
        #     scanned again; same output, 0.7s.
        # (b) An opener inside a CODE SPAN is text. A register documenting its own parking idiom
        #     — a row whose cell reads `<!--` in backticks — had no closer on that line, so the
        #     multi-line path fired and swallowed every live row down to the next `-->`. The gate
        #     went silent on the very file that explained it. Backtick parity is carried across
        #     the line in _par, counted chunk by chunk so it stays linear.
        # (c) A bare `-->` left standing is not a row, and the walk read it as the end of one.
        _open = 0
        s = L[i]; _acc = ""; _par = 0
        while (match(s, /<!--/)) {
          _st = RSTART
          _pre = substr(s, 1, _st - 1)
          _t = _pre; _par += gsub(/`/, "&", _t)
          if (_par % 2 == 1) { _acc = _acc _pre "<!--"; s = substr(s, _st + 4); continue }
          _rest = substr(s, _st + 4)
          if (!match(_rest, /-->/)) { _open = 1; break }
          _t = substr(_rest, 1, RSTART + 2); _par += gsub(/`/, "&", _t)
          _acc = _acc _pre
          s = substr(_rest, RSTART + 3)
        }
        s = _acc s
        S[i] = s
        if (s ~ /^[ \t\r]*-->[ \t\r]*$/) { hide[i] = 1; i++; continue }
        # **A line that was ENTIRELY an inline comment is a hidden line, not an empty one.** Left
        # visible-but-empty it read as the end of the table, so one parked draft row —
        # `<!-- | draft | parked | | -->`, the idiom the comment above recommends — silenced
        # the gate for every live row below it. Measured 2026-08-27; a regression against the
        # version before this rewrite, which refused that file.
        if (L[i] ~ /<!--/ && s ~ /^[ \t\r]*$/) { hide[i] = 1; i++; continue }
        if (_open) {
          # an opener with no closer later in the file is ordinary text, not a comment
          k = 0
          for (j = i + 1; j <= n; j++) if (L[j] ~ /-->/) { k = j; break }
          if (k) { for (j = i; j <= k; j++) hide[j] = 1; i = k + 1; continue }
        }
        i++
      }
      # A fence opener with no closer after it is not a fence — it is a stray line. Toggling on it
      # left every row below hidden and the gate silent for the rest of the file, which one
      # accidental ``` at the top of a register achieved. Measured 2026-08-27, same shape as the
      # unterminated comment above and cured the same way: look for the closer before believing
      # the opener.
      i = 1
      while (i <= n) {
        if (hide[i] || S[i] !~ /^[ \t]*(```|~~~)/) { i++; continue }
        k = 0
        for (j = i + 1; j <= n; j++) if (!hide[j] && S[j] ~ /^[ \t]*(```|~~~)/) { k = j; break }
        if (!k) { i++; continue }
        for (j = i; j <= k; j++) hide[j] = 1
        i = k + 1
      }
    }
  '  # **One awk pass, and the header never makes a round trip through the shell.** Passing it back
  # as `HDR="$_hdr"` was an evasion anyone could trigger with a single character: awk
  # escape-processes a command-line assignment, so a header containing `c:\temp` arrived with a
  # TAB in it and `\|` — markdown's own pipe escape — arrived as a bare pipe. The equality test
  # then matched nothing and **§4f went silent for that file, permanently**. Measured 2026-08-23
  # by an adversarial lens; a regression introduced the same day the table-scoping was.
  #
  # **Which table is the register**: the first one, plus any table whose header carries a
  # `Replaces` column. The first, because a file's opening table is its subject; the others,
  # because a decoy table above the register would otherwise capture the gate and a `Replaces`
  # column on the wrong table would otherwise steal it. Both were measured as evasions. The cost
  # is that a `## Retired` table which itself carries a `Replaces` column gets asked — coherent,
  # since its author put the column there.
  #
  # Each row is emitted with ITS OWN table's column index, so two tables with the column in
  # different positions are both read correctly. Index 0 means "this table has no such column" and
  # sends the row to the keyword fallback below.
  # **Cells are split by an unescaped pipe outside a code span**, not by `-F"|"`. Markdown's own
  # escape `\|` and a pipe inside backticks both shift every field after them, so a header
  # carrying either put the column index one place out and the gate read the wrong cell —
  # `| Otter | x |  | d |` answered with the date. Both measured 2026-08-23.
  #
  # The whole judgement happens here, in one pass, and the shell is handed a verdict rather than
  # an index: Y the cell is filled · N the cell is blank · K this table has no such column.
  _cand=$(printf '%s\n' "$_staged" | awk "$_rowsrc"'
    function cells(s, A,   i, ch, cur, k, tick) {
      k = 0; cur = ""; tick = 0
      for (i = 1; i <= length(s); i++) {
        ch = substr(s, i, 1)
        if (ch == "\\" && i < length(s)) { cur = cur substr(s, i+1, 1); i++; continue }
        if (ch == "`") { tick = !tick; cur = cur ch; continue }
        if (ch == "|" && !tick) { A[++k] = cur; cur = ""; continue }
        cur = cur ch
      }
      A[++k] = cur
      return k
    }
    # `\r` is in the class because a CRLF register whose last column is `Replaces` and whose rows
    # omit the optional trailing pipe left `" \r"` in the final cell — non-empty, so a blank answer
    # read as filled. One character, measured 2026-08-27.
    function trim(s) { gsub(/^[ \t\r*]+|[ \t\r*]+$/, "", s); return s }
    # No apostrophe in this comment: the whole program is single-quoted, and one would end it.
    function colof(h,   i, m, cc) {
      m = cells(h, F)
      for (i = 1; i <= m; i++) { cc = tolower(F[i]); gsub(/[^a-z]/, "", cc); if (cc == "replaces") return i }
      return 0
    }
    END {
      resolve()
      tbl = 0
      for (i = 1; i <= n; i++) {
        if (hide[i]) continue
        if (i + 1 > n || hide[i+1] || S[i+1] !~ /^[ \t]*\|[ \t]*:?-+/) continue
        tbl++
        ci = colof(S[i])
        if (tbl != 1 && ci == 0) continue
        for (j = i + 2; j <= n; j++) {
          if (hide[j]) continue
          if (S[j] !~ /^[ \t]*\|/) break
          if (S[j] ~ /^[ \t]*\|[ \t]*:?-+/) continue
          m = cells(S[j], R)
          state = (ci == 0) ? "K" : ((ci <= m && trim(R[ci]) != "") ? "Y" : "N")
          # The tool name is emitted with its own tabs squeezed out: the three fields travel to the
          # shell tab-delimited, so one interior tab in a cell shifted `cut -f2`/`-f3-` and the row
          # was dropped from the intersection entirely — the gate silent on a row v0.2.11 refused.
          # A regression of the round trip itself, measured 2026-08-27. The raw line still goes out
          # whole as the third field, because that is what must match the diff.
          _tool = trim(R[2]); gsub(/\t/, " ", _tool)
          printf "%s\t%s\t%s\n", state, _tool, L[j]
        }
      }
    }')
  _real=$(printf '%s\n' "$_cand" | cut -f3- | grep . || true)
  _added=$( ( git diff --cached -U0 -- _ops/TOOLING.md 2>/dev/null || true ) \
    | grep '^+' | grep -v '^+++ ' | sed 's/^+//' | grep -E '^[[:space:]]*\|' || true )
  if [ -n "$_cand" ] && [ -n "$_added" ]; then
    # keep each candidate WITH its own table's column index; the diff only says which are new
    _tool_rows=$(printf '%s\n' "$_cand" \
      | while IFS= read -r _l; do
          _r=$(printf '%s' "$_l" | cut -f3-)
          printf '%s\n' "$_added" | grep -Fxq -- "$_r" && printf '%s\n' "$_l"
        done || true)
  fi
fi
if [ -n "$_tool_rows" ]; then
  _dec2=$( ( git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null || true ) \
    | grep '^+' | grep -v '^+++ ' || true )
  # **A FIELD, not a vocabulary.** This began as a keyword list — `instead of|replaces|already|…`
  # — which is precisely the defect §4e was repaired away from in this same file on the same day:
  # a gate satisfied by words teaches people to sprinkle them, and refuses an honest answer that
  # uses different ones. The register carries a **Replaces** column
  # (`templates/TOOLING-template.md`) and this reads the cell.
  #
  # **Two homes count and either is enough** — the cell, or a line in `_ops/DECISIONS.md` that
  # NAMES the row's tool. With only the cell read, a maintainer doing exactly what the refusal
  # prescribed was refused again by the same message, with no hint a column existed. A register
  # that predates the column keeps the keyword fallback, and that fallback is named here rather
  # than presented as a test: an old register is not a project's fault, and refusing every commit
  # until it is reshaped is how a guard gets deleted.
  _unanswered=0
  while IFS= read -r _entry; do
    [ -n "$_entry" ] || continue
    _state=$(printf '%s' "$_entry" | cut -f1)
    _tool=$(printf '%s' "$_entry" | cut -f2)
    _row=$(printf '%s' "$_entry" | cut -f3-)
    [ "$_state" = "Y" ] && continue
    if [ "$_state" = "K" ]; then
      # this row's table has no Replaces column — the older shape, judged by the keyword list
      printf '%s\n' "$_row" \
        | hits -iE 'instead of|replaces|rather than|already|by hand|nothing else|we had none|had no ' \
        && continue
    fi
    # the cell is blank (or the row said nothing) — a decision naming this tool is the other answer
    if [ -n "$_tool" ]; then
      _esc2=$(printf '%s' "$_tool" | sed 's/[].[^$\\*\/]/\\&/g')
      printf '%s\n' "$_dec2" | hits -iE "(^|[^A-Za-z0-9_-])${_esc2}([^A-Za-z0-9_-]|$)" && continue
    fi
    _unanswered=$((_unanswered+1))
  done <<TOOLROWS
$_tool_rows
TOOLROWS
  [ "$_unanswered" -eq 0 ] \
    || say_fail "this commit adds a row to _ops/TOOLING.md and nothing says what it replaces. Two \
places count, and either one is enough: the row's own **Replaces** cell, or a line in \
_ops/DECISIONS.md that NAMES this tool and says what was done before it. \`we had none\` is a \
complete answer and often the true one outside software — write it in the cell and this passes. \
A tool arrives in a minute and is maintained for a year, which is why the rung is asked at all"
fi


[ "$fail" = 0 ] && { [ "$warn" = 0 ] && echo "  ✓ clean" || echo "  ✓ passed with warnings"; }
exit "$fail"
