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
  # The pin is read BY NAME, not by position. `head -1` took the first vX.Y.Z in the file,
  # which became a citation of someone else's release the moment one was written above §10 —
  # a ticket's version and this repository's pin look identical to a regex, and the check
  # confused them the same day a note was added warning about exactly that.
  pinned=$(grep -oE 'of `multica` \*\*v[0-9]+\.[0-9]+\.[0-9]+' REFERENCE.md \
           | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
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
  # The READER above is anchored by name and the WRITER was not, which is half a repair: a global
  # `s/v0.4.23/v0.4.26/g` rewrites a citation of someone else's release as readily as our own pin,
  # and that is the incident AGENTS.md dates to 2026-08-15 — performed by hand once, and then
  # available to be performed mechanically by this script. Measured: with the pin at 0.4.23 the
  # entire resulting diff was one line, the `MUL-5958` citation, under the message "review and
  # commit". Worse with an empty pin — a plain copy-edit to §10's wording makes `pinned` empty,
  # `s/v/v0.4.26/g` follows, and 446 lines across both files are corrupted with exit 0.
  [ -n "$pinned" ] || { echo "→ could not read the pin from §10 by name — the anchor 'of \`multica\` **vX.Y.Z' is not in REFERENCE.md. Re-pin by hand; refusing to sweep"; exit 1; }
  # One anchored substitution, on the pin itself. README carries dated measurements ("measured,
  # CLI v0.4.12") whose date IS the claim — re-dating those without re-measuring is the thing the
  # evidence rungs exist to stop, so they are reported here and never rewritten.
  perl -0pi -e "s/(of \`multica\` \*\*v)${pinned}/\${1}${local_v}/" REFERENCE.md
  echo "  ✓ surface unchanged — re-pinned v${pinned} → v${local_v} in §10 (review and commit)"
  stale=$(grep -n 'CLI v[0-9]\+\.[0-9]\+\.[0-9]\+' README.md | grep -v "v${local_v}" || true)
  [ -n "$stale" ] && { echo "  ! README still cites an older CLI — these are dated measurements, not pins; re-check each against v${local_v} and re-date it, or mark it unverified:"; echo "$stale" | sed 's/^/      README.md:/'; }
  exit 0
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

# 1 · every manifest carries the version in skills/mops/SKILL.md — a sweep, not a pair.
# We ship four manifests across four runtimes and a hand-maintained checklist only bumps the
# ones somebody remembers: opsinist lost a release to three stragglers this way. The list is
# DISCOVERED (any tracked .json declaring a "version"), because a hardcoded list is the same
# rot surface wearing a script's clothes — a fifth runtime's manifest is checked the day it
# lands, without anyone editing this.
sv=$(grep -m1 '^version:' skills/mops/SKILL.md | awk '{print $2}')
[ -n "$sv" ] || say_fail "skills/mops/SKILL.md has no version: frontmatter line"
swept=0
while IFS= read -r m; do
  mv_=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("version",""))' "$m" 2>/dev/null)
  [ -n "$mv_" ] || continue
  swept=$((swept+1))
  [ "$mv_" = "$sv" ] || say_fail "version straggler: $m=$mv_ but skills/mops/SKILL.md=$sv"
done <<< "$(git ls-files '*.json' | grep -v '^company/')"
[ "$swept" -ge 3 ] || say_warn "manifest sweep saw only $swept versioned manifest(s) — expected at least 3 (Claude Code, Codex, Gemini); has one stopped declaring a version?"

# 1b · the documented skill-import URL pins THIS version, not a moving ref.
#      An import becomes agent instructions, so `tree/main` means the content behind someone's
#      agents can change without them moving — the substance of the auditors' W012 finding,
#      2026-07-30. A pin only works if it is maintained, so the maintenance is a check.
#      **SECURITY.md is exempt, on purpose.** It records a URL that was *run once, on a date*, as
#      the control for a measurement. Dragging that forward each release would make the control
#      unreproducible — the exact defect the record exists to avoid — so this check covers
#      instructions, which rot, and not history, which must not move. Verify the exemption is not
#      hiding a real instruction: SECURITY.md gives none, and this asserts it.
#      The exemption is kept honest by a POSITIVE assertion rather than by trying to tell a
#      record from an instruction by its shape — they are the same shape, which is why the first
#      attempt at this guard fired on the record it was written to protect. Instead: INSTALL.md
#      must still carry the pinned line. Move the instruction into the exempt file to dodge the
#      pin and this fires, because the place it belongs went empty.
grep -q "multica-ops/tree/v${sv}/skills/mops" INSTALL.md 2>/dev/null || \
  say_fail "INSTALL.md no longer carries the import line pinned to v$sv — §1b exempts SECURITY.md \
because it records past runs, and that exemption only holds while the real instruction lives here."
#      **And the exemption asserts a negative, because a guard that only catches a MOVE is
#      cheaper to walk around than to obey**: adding a second URL to the exempt page leaves
#      INSTALL.md untouched and passes. So every `tree/` URL inside SECURITY.md must be either
#      the one recorded control or the current pin — anything else is refused, on the page a
#      reader trusts most.
sec_bad=$(grep -hoE 'multica-ops/tree/[A-Za-z0-9._-]+/skills/mops' SECURITY.md 2>/dev/null | sort -u \
          | grep -vE "multica-ops/tree/(v${sv}|v0\.4\.4)/skills/mops" || true)
[ -n "$sec_bad" ] && while IFS= read -r r; do
  say_fail "SECURITY.md carries an import URL that is neither the recorded control (v0.4.4) nor \
the current pin (v$sv): $r — the page is exempt from the pin check, not from scrutiny."
done <<< "$sec_bad"
pinfiles=$(ls -1 *.md 2>/dev/null | grep -v '^SECURITY\.md$')
bad_ref=$(grep -hoE 'multica-ops/tree/[A-Za-z0-9._-]+/skills/mops' $pinfiles 2>/dev/null | sort -u \
          | grep -v "multica-ops/tree/v${sv}/skills/mops" || true)
[ -n "$bad_ref" ] && while IFS= read -r r; do
  say_fail "import URL is not pinned to v$sv: $r"
done <<< "$bad_ref"

# 2 · CHANGELOG documents this version (it is the migration map for /upgrade)
grep -q "^## ${sv}\b" CHANGELOG.md || say_fail "CHANGELOG.md has no '## $sv' section"

# 3 · README lists every companion file
for f in $(ls *.md | grep -vE '^(README|CHANGELOG)\.md$'); do
  grep -q "$f" README.md || say_fail "README.md does not mention $f"
done

# 4 · internal .md links resolve — from every doc we ship, not only the root ones, and
# including links that carry a path (`](templates/X.md)`): the filename-only pattern skipped
# those silently, so a whole class of link could rot inside the check's own blind spot.
link_bad=$(python3 - <<'PYEOF'
import glob, os, re
bad = []
for f in (glob.glob("*.md") + glob.glob("templates/*.md") + glob.glob("commands/*.md")
          + glob.glob("evals/*.md") + glob.glob("evals/runs/*.md") + glob.glob("sources/*.md")):
    for l in re.findall(r"\]\(([A-Za-z0-9_./-]+\.md)(?:#[^)]*)?\)", open(f, encoding="utf-8").read()):
        if not (os.path.exists(l) or os.path.exists(os.path.join(os.path.dirname(f), l))):
            bad.append(f"broken link in {f}: {l}")
print("\n".join(sorted(set(bad))))
PYEOF
)
[ -n "$link_bad" ] && while IFS= read -r l; do say_fail "$l"; done <<< "$link_bad"

# 4b · an external URL carrying a literal `(` is stored percent-encoded, or the link checker
# reads it truncated and reports a live page as rot. Measured next door as issue #1: four
# "dead" links that all answered 200, one of them a URL cut at its own parenthesis. The
# checker's extraction cannot be made paren-aware without a markdown parser, so the corpus
# holds the invariant instead and this is what holds the corpus to it.
paren_url=$(grep -rnoE '\]\(https?://[^)[:space:]]*\(' -- *.md templates/*.md 2>/dev/null || true)
[ -n "$paren_url" ] && while IFS= read -r l; do
  say_fail "URL contains a literal '(' — percent-encode it as %28/%29: $l"
done <<< "$paren_url"

# 4c · the machinery's own paths live under `_ops/`, never `docs/`. A project's `docs/` is the
# craft's, and before 0.4.0 ours was mixed into it. The old habit is one keystroke away, so the
# invariant is held rather than remembered. Two things are deliberately NOT matched: a leading
# slash (`/docs/squads` is a multica.ai documentation URL, not a file — the blind-sed trap that
# cost the sibling project a line reading "200 _ops/requests/hour"), and `docs/cache/`, which
# appears only inside a prompt-injection example describing a file the project already owns.
# **And it reads `skills/*/SKILL.md` too — the omission that made it blind where it mattered
# most.** The layout sweep globbed the root and `templates/`, so the always-loaded core kept
# sixteen `docs/` paths through the whole release, and this guard looked in exactly the same two
# places and confirmed the silence. A guard that shares the sweep's blind spot is not a check,
# it is the same mistake wearing a second name. Found by the contradiction lens, 2026-08-07.
stray=$(grep -rnoE '(^|[^/[:alnum:]_-])docs/(ROADMAP|TEAM|TOOLING|DECISIONS|LATER|FIELD-NOTES|ARCHITECTURE|MAP|BUDGET|ECONOMICS|assets|analytics|research|audience|design-system|brand|skill-backups|tooling|\.workspace-state)' \
        -- *.md templates/*.md skills/*/SKILL.md 2>/dev/null | grep -v '^CHANGELOG.md:' || true)
[ -n "$stray" ] && while IFS= read -r l; do
  say_fail "machinery path still under docs/ — it lives in _ops/ since 0.4.0: $l"
done <<< "$stray"

# 5a · official guidance: skills/mops/SKILL.md body under 500 lines
lines=$(wc -l < skills/mops/SKILL.md | tr -d ' ')
[ "$lines" -gt 500 ] && say_fail "skills/mops/SKILL.md $lines lines — over Anthropic's 500-line guidance"

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
        name = m.group(1)
        # the corpus core moved into the plugin's skills/ layout; its companions did not
        tgt = "skills/mops/SKILL.md" if name == "SKILL" else name + ".md"
        sect = m.group(2).strip().rstrip(".,;)")
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
  git check-ignore -q "$f" && continue   # build artifacts (__pycache__) are not documentation
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

# 5i · structural integrity — nine classes of defect that each shipped once.
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
# silently — 2.3 shipped with evals a release behind until caught by hand. Compared against
# the LAST RELEASE TAG, not HEAD: a working-tree-vs-HEAD check stops firing the moment the
# bump is committed (FIELD-NOTES 2026-07-27), so the guard went blind after every commit.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  last_tag=$(git describe --tags --abbrev=0 2>/dev/null)
  if [ -z "$last_tag" ]; then
    say_warn "no release tag yet — skipping the version-bump / evals guard (fresh clone)"
  else
    tag_ver=$(git show "${last_tag}:skills/mops/SKILL.md" 2>/dev/null | grep -m1 "^version:" | tr -dc "0-9.")
    work_ver=$(grep -m1 "^version:" skills/mops/SKILL.md | tr -dc "0-9.")
    if [ -n "$tag_ver" ] && [ "$tag_ver" != "$work_ver" ]; then
      git diff --quiet "$last_tag" -- evals/README.md 2>/dev/null &&         say_warn "version bumped ${tag_ver} → ${work_ver} since ${last_tag} but evals/README.md is unchanged — refresh the eval scenarios for any new behaviour"
      say_warn "releasing ${work_ver}: run the four review lenses before tagging (AGENTS.md → Cutting a release)"
      case "$work_ver" in
        *.0) [ -f "evals/runs/${work_ver}.md" ] || say_warn "no evals/runs/${work_ver}.md — a minor/major is not tagged without a run record (evals/runs/TEMPLATE.md)";;
      esac
    fi
  fi
fi

# 5c · references must stay one level deep from skills/mops/SKILL.md.
# AGENTS.md and CLAUDE.md are exempt because they are not companions: they are the repo's own
# dev furniture, read by whoever is changing the skill, and pointing at the contract and the
# prose rules is the whole job of both.
for f in $(ls *.md | grep -vE '^(SKILL|README|CHANGELOG|AGENTS|CLAUDE)\.md$'); do
  nested=$(grep -ohE '\]\([A-Z][A-Za-z-]*\.md' "$f" 2>/dev/null | head -1)
  [ -n "$nested" ] && say_warn "$f links to another companion — keep references one level deep from skills/mops/SKILL.md"
done

# 5 · always-loaded core stays lean (it is paid on every run, by every agent)
# Characters, not bytes. `wc -c` counts bytes, and the chars/4 heuristic is about characters —
# so every em-dash and every Cyrillic word in this corpus inflated the estimate. Measured
# 2026-08-15: 37829 bytes against 37315 characters, ~129 phantom tokens, all of it in one
# direction. A budget that reads its own file wrong is strict for a reason nobody chose.
chars=$(python3 -c "import sys; print(len(open(sys.argv[1], encoding='utf-8').read()))" skills/mops/SKILL.md 2>/dev/null \
        || wc -c < skills/mops/SKILL.md | tr -d ' ')
tok=$((chars/4))
[ "$tok" -gt 10000 ] && say_fail "skills/mops/SKILL.md ~${tok} tokens — over the 10k budget; move detail to a companion file"
# The second warning fires on GROWTH, not on size. "Approaching the budget" was true at 9.0k and
# will be true at every commit until someone cuts the core, and a warning that is always on names
# nothing — it is read past, which is how the one that matters gets read past too. Measured
# 2026-08-15: at ~9.3k every section of the core is an invariant, detail is already delegated by
# pointer, and exactly one sentence of 142 appears in any companion — so there is nothing cheap
# left to move, and the honest signal is not "it is large" but "it just got larger".
if [ "$tok" -le 10000 ] && [ "$tok" -gt 8000 ]; then
  last_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
  if [ -n "$last_tag" ]; then
    prev=$(git show "${last_tag}:skills/mops/SKILL.md" 2>/dev/null \
           | python3 -c "import sys; print(len(sys.stdin.read()))" 2>/dev/null || echo 0)
    prev_tok=$(( ${prev:-0} / 4 ))
    if [ "${prev_tok:-0}" -gt 0 ] && [ "$tok" -gt "$prev_tok" ]; then
      say_warn "skills/mops/SKILL.md grew ~${prev_tok} → ~${tok} tokens since ${last_tag} (budget 10000). \
Every agent pays this on every run: either the new lines are invariants that belong in the always-loaded \
core, or they are detail and belong in a companion"
    fi
  fi
fi

# 6 · every command in the table has a plugin file
for c in $(grep -oE '^\| `/multica-ops:[a-z-]+' COMMANDS.md | sed -E 's/^.*multica-ops://'); do
  [ -f "skills/$c/SKILL.md" ] || say_fail "command /multica-ops:$c has no skills/$c/SKILL.md"
done

# 6b · official checklist: at least three evaluations
n=$(grep -cE '^## [0-9]+\. ' evals/README.md 2>/dev/null || true); n=${n:-0}
[ "$n" -lt 3 ] && say_warn "evals/README.md has $n scenarios — the official checklist asks for 3+"

# 6c · and the hand-kept copy of that number must agree with it. This is a REPEAT: the changelog
#      already records "advertised 22 eval scenarios against a rubric that now holds 26", and it
#      drifted again to 26-against-27 — published on the site, where one page said 26 and another
#      said 27. Twice is the threshold everywhere here, and past it the repair is a form, not a
#      third correction of the same number by hand. The rubric is the home; README and the
#      runsheet are copies, and a copy that disagrees is the defect.
rs=$(grep -cE '^[0-9]+[[:space:]]' evals/runsheet.tsv 2>/dev/null || true)
[ "${rs:-0}" = "$n" ] || say_fail "evals/runsheet.tsv has ${rs:-0} rows against $n scenarios in \
the rubric (evals/README.md) — the sheet has gone one behind twice before."
# **Inverted on purpose.** Iterating over whatever a grep happened to find is a silent pass the
# moment somebody rephrases: `**26** stratified…`, `26 scenarios, stratified`, `26 scenarios in
# the rubric` — six realistic phrasings were all blind, and bolding a digit is ordinary drift.
# So the canonical phrase is REQUIRED to be present with the right number, and its absence is
# the failure. The same for COVERAGE.md, which is a third hand-kept copy and is published: it
# was the page that disagreed with README on the site.
for doc in README.md evals/COVERAGE.md; do
  [ -f "$doc" ] || continue
  grep -qE "(^|[^0-9])${n}( stratified)? (eval )?scenarios" "$doc" || say_fail "$doc does not \
state the scenario count as \"$n … scenarios\" — the rubric (evals/README.md) holds $n, this is \
a hand-kept copy, and it has drifted twice before. Write the number in that phrase."
  wrong=$(grep -oE '(^|[^0-9])[0-9]+( stratified)? (eval )?scenarios' "$doc" \
          | grep -oE '[0-9]+' | sort -u | grep -v "^${n}$" || true)
  [ -n "$wrong" ] && while IFS= read -r w; do
    say_fail "$doc also advertises $w scenarios; the rubric holds $n."
  done <<< "$wrong"
done

# 7 · docs coverage — a new command with no use case is a doc gap, not a bug
missing=""
for c in $(grep -oE '^\| `/multica-ops:[a-z-]+' COMMANDS.md | sed -E 's/^.*multica-ops://'); do
  grep -q "/multica-ops:$c" USE-CASES.md || missing="$missing /multica-ops:$c"
done
[ -n "$missing" ] && say_warn "USE-CASES.md covers no situation for:$missing — add one or decide it's internal"

# 8 · CLI drift — warn, never rewrite silently (a bumped pin with a stale §10 would be
#     a false claim of currency, worse than visibly stale)
if command -v multica >/dev/null 2>&1; then
  lv=$(multica --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  # Same anchor as --regen-cli above, and for the same reason: `head -1` reads whichever
  # version happens to appear first, which is a citation of someone else's release.
  pv=$(grep -oE 'of `multica` \*\*v[0-9]+\.[0-9]+\.[0-9]+' REFERENCE.md \
       | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  [ -n "$lv" ] && [ "$lv" != "$pv" ] && say_warn "installed CLI v$lv ≠ pinned v$pv — run: bash scripts/preflight.sh --regen-cli"
fi

# 9 · coherence — a new capability must be reachable from every entry point, or it is
#     invisible in practice. Warn per missing surface rather than guessing intent.
for c in $(grep -oE '^\| `/multica-ops:[a-z-]+' COMMANDS.md | sed -E 's/^.*multica-ops://'); do
  gaps=""
  grep -q "/multica-ops:$c" skills/mops/SKILL.md || gaps="$gaps SKILL"
  grep -qE "(^|[^a-z-])$c([^a-z-]|$)" skills/mops/SKILL.md || gaps="$gaps the-dispatcher"
  [ -n "$gaps" ] && say_warn "/multica-ops:$c not reachable from:$gaps"
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

# 9b · recorded facts past their recheck are unknown, not fine — the skill's own freshness
#      law turned on itself. Dates written as "checked/verified/re-verified YYYY-MM-DD"
#      older than the window get a warning; warn-only, because staleness is a claim to
#      re-verify, not proof of falsehood.
fresh_bad=$(python3 - <<'PYEOF'
import re, datetime, glob
STALE_DAYS = 180
today = datetime.date.today()
old = []
for f in glob.glob("*.md") + glob.glob("templates/*.md") + glob.glob("sources/*.md"):
    for i, line in enumerate(open(f, encoding="utf-8"), 1):
        # IGNORECASE, the word "measured", and an optional backtick — each was a hole a lens
        # measured. Case was the worst: house style capitalises at a sentence start, so 33 of
        # STACKS' 61 stamps were exempt and the exemption was the DEFAULT. The strongest claims
        # in this corpus are the ones that say "measured <date>", and they aged unseen. The gate
        # had never fired, because nothing is 180 days old yet, so green meant nothing about half
        # the file and would first have admitted it in 2027.
        # NOTE: the backtick is written \x60 on purpose. A literal one here makes an odd number
        # of backticks inside $( <<HEREDOC ), which bash tokenises for nesting even in a quoted
        # heredoc — the file then dies with "unexpected end of file" 30 lines further down.
        # Up to three words may sit between the verb and the date: this corpus writes
        # "re-verified behaviourally 2026-08-01", "Measured end to end 2026-08-01" and
        # "measured on this machine 2026-08-01" — 41 stamps escaped the first repair for
        # exactly that reason, which is the same hole as the case-sensitivity one, in the
        # house's dominant style. (?<!un) keeps "unverified"/"unchecked" from reading as
        # verification, which would invert the meaning of the stamp.
        for m in re.finditer(r"(?<!un)\b(?:checked|verified|re-verified|measured|re-measured)"
                             r"(?:\W+\w+){0,3}?\W+(\d{4})-(\d{2})-(\d{2})", line, re.I):
            try:
                d = datetime.date(*map(int, m.groups()))
            except ValueError:
                # A single typo'd date used to raise here, and because every print happened
                # after the loop, stdout came back empty and the whole gate went silent with
                # genuinely stale facts in the file. Report it and keep going.
                print(f"BAD:{f}:{i} ({m.group(0)!r} is not a date)")
                continue
            age = (today - d).days
            if age > STALE_DAYS:
                print(f"OLD:{f}:{i} ({d}, {age}d ago)")
for o in old[:6]:
    print(o)  # retained for older callers; the loop above prints directly
if len(old) > 6:
    print(f"…and {len(old)-6} more")
PYEOF
)
[ -n "$fresh_bad" ] && while IFS= read -r l; do
  say_warn "recorded fact past its recheck window: $l"
done <<< "$fresh_bad"

# 10 · reminders that cannot be verified from this repo
git diff --cached --name-only 2>/dev/null | grep -qE '\.md$' && \
  echo "  → docs site: regenerate + deploy (python3 scripts/generate.py <repo> in the ai repo)"

[ $fail -eq 0 ] && [ $warn -eq 0 ] && echo "  ✓ all checks passed"
[ $fail -eq 0 ] && [ $warn -eq 1 ] && echo "  ✓ passed with warnings"
exit $fail
