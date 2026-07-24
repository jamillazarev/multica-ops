#!/usr/bin/env bash
# Pre-commit preflight for the multica-ops repo.
# Keeps the skill coherent: versions in sync, CHANGELOG written, README complete,
# no broken links, commands consistent, and the always-loaded core from bloating.
# Run: bash scripts/preflight.sh   ·   install: bash scripts/preflight.sh --install
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

# --regen-cli : verify REFERENCE §10 against the installed CLI, re-pin when the surface
# matches, and list what changed when it doesn't. Explicit action — never silent.
if [ "${1:-}" = "--regen-cli" ]; then
  command -v multica >/dev/null || { echo "multica CLI not installed"; exit 1; }
  local_v=$(multica --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  pinned=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' REFERENCE.md | head -1 | sed 's/^v//')
  echo "installed=$local_v pinned=$pinned"
  sec=$(awk '/## 10\./{f=1} f{print}' REFERENCE.md); diff=0
  for g in $(multica --help 2>&1 | sed -n '/COMMANDS/,/FLAGS/p' | grep -E '^\s+[a-z]' | awk '{print $1}' | tr -d ':'); do
    echo "$sec" | grep -qE "\`$g\`" || { echo "  + group missing from §10: $g"; diff=1; }
    for s in $(multica "$g" --help 2>&1 | sed -n '/COMMANDS/,/FLAGS/p' | grep -E '^\s+[a-z]' | awk '{print $1}' | tr -d ':'); do
      echo "$sec" | grep -q "\b$s\b" || { echo "  + subcommand missing from §10: $g $s"; diff=1; }
    done
  done
  if [ $diff -eq 1 ]; then
    echo "→ surface changed: edit REFERENCE §10 by hand, then re-run"; exit 1
  fi
  [ "$local_v" = "$pinned" ] && { echo "  ✓ §10 matches, pin already current"; exit 0; }
  newest=$(printf '%s\n%s\n' "$local_v" "$pinned" | sort -V | tail -1)
  if [ "$newest" = "$pinned" ]; then
    echo "  ✓ §10 matches; your CLI (v$local_v) is behind the pin (v$pinned) — nothing to re-pin, update your CLI"; exit 0
  fi
  sed -i.bak "s/v${pinned}/v${local_v}/g" REFERENCE.md README.md && rm -f REFERENCE.md.bak README.md.bak
  echo "  ✓ surface unchanged — re-pinned v${pinned} → v${local_v} (review and commit)"; exit 0
fi

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

# 5a · official guidance: SKILL.md body under 500 lines
lines=$(wc -l < SKILL.md | tr -d ' ')
[ "$lines" -gt 500 ] && say_fail "SKILL.md $lines lines — over Anthropic's 500-line guidance"

# 5b · reference files >100 lines need a table of contents (partial reads otherwise miss scope)
# Exempt: SKILL (its load-routing table is the TOC), and the read-top-to-bottom entry docs
# README/CHANGELOG/AGENTS — those are narrative, not navigable companion references.
for f in $(ls *.md | grep -vE '^(README|CHANGELOG|SKILL|AGENTS)\.md$'); do
  n=$(wc -l < "$f" | tr -d ' ')
  [ "$n" -gt 100 ] && ! grep -qE '^## Contents' "$f" && say_warn "$f is $n lines with no '## Contents'"
done

# 5d · cross-references to interview items must name the item they point at.
# Inserting a checklist item silently shifts every "#N" elsewhere; requiring the title
# makes the drift detectable instead of invisible.
ref_bad=$(python3 - <<'PYEOF'
import re,glob,sys
sec=re.search(r"## 16\. Interview checklist.*?\n(.*?)(?=\n## |\Z)", open("BOOTSTRAP.md").read(), re.S)
items={}
if sec:
    for m in re.finditer(r"^(\d+)\.\s+\*\*(.+?)\*\*", sec.group(1), re.M):
        items[int(m.group(1))]=m.group(2)
bad=[]
for f in glob.glob("*.md")+glob.glob("templates/*.md"):
    for m in re.finditer(r"checklist #(\d+)(?:\s*·\s*([^)\n]+?))?\s*\)", open(f).read()):
        n=int(m.group(1)); title=(m.group(2) or "").strip()
        if n not in items: bad.append(f"{f}: #{n} has no such interview item"); continue
        if not title: bad.append(f"{f}: #{n} must name the item (checklist #{n} · {items[n]})"); continue
        a=re.sub(r"[^a-z]","",title.lower()); b=re.sub(r"[^a-z]","",items[n].lower())
        if a not in b and b not in a:
            bad.append(f"{f}: #{n} says '{title}' but item {n} is '{items[n]}'")
print("\n".join(bad))
PYEOF
)
[ -n "$ref_bad" ] && while IFS= read -r l; do say_fail "$l"; done <<< "$ref_bad"

# 5e · prose cross-references ("STACKS → skill screening") must hit something real.
# A silently no-op edit leaves the pointer dangling; links are checked, prose was not.
xref_bad=$(python3 - <<'PYEOF'
import re,glob
bad=[]
for f in glob.glob("*.md")+glob.glob("templates/*.md"):
    for m in re.finditer(r"\b(SKILL|ROLES|STACKS|PLAYBOOKS|FLOWS|REFERENCE|BOOTSTRAP|COMMANDS|MODULES|EXAMPLES|USE-CASES) → ([A-Za-z][A-Za-z0-9 &'/-]*)", open(f).read()):
        tgt, sect = m.group(1)+".md", m.group(2).strip().rstrip(".,;)")
        try: body=open(tgt).read()
        except OSError: bad.append(f"{f}: points at {tgt}, which does not exist"); continue
        hay=re.sub(r"[^a-z]","",body.lower())
        if re.sub(r"[^a-z]","",sect.lower()) not in hay:
            bad.append(f"{f}: '{m.group(1)} → {sect}' matches nothing in {tgt}")
print("\n".join(bad))
PYEOF
)
[ -n "$xref_bad" ] && while IFS= read -r l; do say_fail "$l"; done <<< "$xref_bad"

# 5f · a Contents block must list exactly the file's own ## headings, as working anchors.
# Hand-maintained tables of contents go stale the moment a section is added or renamed.
toc_bad=$(python3 - <<'PYEOF'
import re, glob
def anchor(h):
    a = re.sub(r"`|\*\*|\*|\[|\]|\(|\)", "", h)
    a = re.sub(r"[^\w\s-]", "", a, flags=re.U).strip().lower()
    return re.sub(r"\s+", "-", a)
def clean(h): return re.sub(r"`|\*\*|\*", "", h).strip()
bad=[]
for f in sorted(glob.glob("*.md")):
    t=open(f).read()
    m=re.search(r"^## Contents\n(.*?)(?=^## )", t, re.S|re.M)
    if not m: continue
    want=[f"- [{clean(h)}](#{anchor(h)})" for h in re.findall(r"^## (.+)$", t, re.M) if h.strip()!="Contents"]
    have=[l.strip() for l in m.group(1).strip().split("\n") if l.strip()]
    if have!=want:
        miss=[w for w in want if w not in have]; extra=[h for h in have if h not in want]
        d=(f" missing {len(miss)}" if miss else "")+(f" stale {len(extra)}" if extra else "")
        bad.append(f"{f}: Contents does not match its headings —{d or ' order differs'}")
print("\n".join(bad))
PYEOF
)
[ -n "$toc_bad" ] && while IFS= read -r l; do say_fail "$l"; done <<< "$toc_bad"

# 5g · a script nobody documents is a script nobody runs.
for f in scripts/*; do
  b=$(basename "$f")
  [ "$b" = "preflight.sh" ] && continue
  grep -rql -- "$b" ./*.md 2>/dev/null || say_warn "scripts/$b is not mentioned in any doc"
done

# 5h · the guide-template weight quoted in ROLES must match the file it describes.
# The skill tells everyone that recorded facts expire; this is that rule turned inward.
gt_bad=$(python3 - <<'PYEOF'
import re
try:
    actual = len(open("templates/GUIDE-template.md").read()) / 4 / 1000
except OSError:
    raise SystemExit
m = re.search(r"GUIDE-template[^~]*~([\d.]+)k tokens", open("ROLES.md").read())
if m and abs(float(m.group(1)) - actual) > 0.25:
    print("ROLES quotes the guide template at ~%sk tokens; it is ~%.1fk" % (m.group(1), actual))
PYEOF
)
[ -n "$gt_bad" ] && say_warn "$gt_bad"

# 5i · structural integrity — eight classes of defect that each shipped once.
# Deterministic ones fail, heuristic ones warn. See scripts/check-structure.py.
if [ -f scripts/check-structure.py ]; then
  while IFS= read -r line; do
    case "$line" in
      FAIL:*) say_fail "${line#FAIL:}" ;;
      WARN:*) say_warn "${line#WARN:}" ;;
    esac
  done <<< "$(python3 scripts/check-structure.py 2>/dev/null)"
fi

# 5j · a version bump must bring the tests with it. Evals and the lens review go stale
# silently — 2.3 shipped with evals a release behind until caught by hand.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  head_ver=$(git show HEAD:SKILL.md 2>/dev/null | grep -m1 "^version:" | tr -dc "0-9.")
  work_ver=$(grep -m1 "^version:" SKILL.md | tr -dc "0-9.")
  if [ -n "$head_ver" ] && [ "$head_ver" != "$work_ver" ]; then
    git diff --quiet HEAD -- evals/README.md 2>/dev/null &&       say_warn "version bumped ${head_ver} → ${work_ver} but evals/README.md is unchanged — refresh the eval scenarios for any new behaviour"
    say_warn "releasing ${work_ver}: run the four review lenses before tagging (AGENTS.md → Cutting a release)"
  fi
fi

# 5c · references must stay one level deep from SKILL.md
for f in $(ls *.md | grep -vE '^(SKILL|README|CHANGELOG|AGENTS)\.md$'); do
  nested=$(grep -ohE '\]\([A-Z][A-Za-z-]*\.md' "$f" 2>/dev/null | head -1)
  [ -n "$nested" ] && say_warn "$f links to another companion — keep references one level deep from SKILL.md"
done

# 5 · always-loaded core stays lean (it is paid on every run, by every agent)
chars=$(wc -c < SKILL.md | tr -d ' '); tok=$((chars/4))
[ "$tok" -gt 10000 ] && say_fail "SKILL.md ~${tok} tokens — over the 10k budget; move detail to a companion file"
[ "$tok" -gt 9000 ] && [ "$tok" -le 10000 ] && say_warn "SKILL.md ~${tok} tokens — approaching the 10k budget"

# 6 · every command in the table has a plugin file
for c in $(grep -oE '^\| `/mops [a-z-]+' COMMANDS.md | sed -E 's/^.*mops //'); do
  [ -f "commands/$c.md" ] || say_fail "command /mops $c has no commands/$c.md"
done

# 6b · official checklist: at least three evaluations
n=$(grep -c '^## [0-9]' evals/README.md 2>/dev/null || echo 0)
[ "$n" -lt 3 ] && say_warn "evals/README.md has $n scenarios — the official checklist asks for 3+"

# 7 · docs coverage — a new command with no use case is a doc gap, not a bug
missing=""
for c in $(grep -oE '^\| `/mops [a-z-]+' COMMANDS.md | sed -E 's/^.*mops //'); do
  grep -q "/mops $c" USE-CASES.md || missing="$missing /mops $c"
done
[ -n "$missing" ] && say_warn "USE-CASES.md covers no situation for:$missing — add one or decide it's internal"

# 8 · CLI drift — warn, never rewrite silently (a bumped pin with a stale §10 would be
#     a false claim of currency, worse than visibly stale)
if command -v multica >/dev/null 2>&1; then
  lv=$(multica --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  pv=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' REFERENCE.md | head -1 | sed 's/^v//')
  [ -n "$lv" ] && [ "$lv" != "$pv" ] && say_warn "installed CLI v$lv ≠ pinned v$pv — run: bash scripts/preflight.sh --regen-cli"
fi

# 9 · coherence — a new capability must be reachable from every entry point, or it is
#     invisible in practice. Warn per missing surface rather than guessing intent.
for c in $(grep -oE '^\| `/mops [a-z-]+' COMMANDS.md | sed -E 's/^.*mops //'); do
  gaps=""
  grep -q "/mops $c" SKILL.md || gaps="$gaps SKILL"
  grep -qE "(^|[^a-z-])$c([^a-z-]|$)" commands/mops.md || gaps="$gaps /mops-dispatcher"
  [ -n "$gaps" ] && say_warn "/mops $c not reachable from:$gaps"
done
# the /join delta must cover every interview topic, or a joined workspace is asked less
# than a new one — checked against BOOTSTRAP §16 rather than a hardcoded phrase.
delta_bad=$(python3 - <<'PYEOF'
import re
boot = open("BOOTSTRAP.md").read()
sec = re.search(r"## 16\. Interview checklist.*?\Z", boot, re.S)
if not sec: raise SystemExit
titles = re.findall(r"^\d+\. \*\*(.+?)\*\*", sec.group(0), re.M)
flows = open("FLOWS.md").read().lower()
missing = []
for t in titles:
    words = [w for w in re.sub(r"[^a-z ]", " ", t.lower()).split() if len(w) > 4]
    if words and not any(w in flows for w in words):
        missing.append(t[:38])
if missing:
    print("the /join delta in FLOWS.md never mentions: " + ", ".join(missing[:4]))
PYEOF
)
[ -n "$delta_bad" ] && say_warn "$delta_bad"

# 10 · reminders that cannot be verified from this repo
git diff --cached --name-only 2>/dev/null | grep -qE '\.md$' && \
  echo "  → docs site: regenerate + deploy (python3 scripts/generate.py <repo> in the ai repo)"

[ $fail -eq 0 ] && [ $warn -eq 0 ] && echo "  ✓ all checks passed"
[ $fail -eq 0 ] && [ $warn -eq 1 ] && echo "  ✓ passed with warnings"
exit $fail
