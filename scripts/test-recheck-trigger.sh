#!/usr/bin/env bash
# §18 of the company guard, ported from opsinist's §22 — a new tension in the source register reaches the findings resting on
# either end of it — shown refusing each mutant and passing its honest twin, in a throwaway project.
#
# The register sits outside `_ops/research/` on purpose: the guard finds it by its shape, and a
# fixture that put it where a path-based reader would look first could not show that.
#
# **Two code mutants** against the assertions they should break: the whole-id match loosened to a
# substring (so `x-2024` drags in the finding that cites `x-2024-b`), and any edit counted as a
# re-read (so a finding touched but not re-stamped passes). A mutant that does not apply is said.
set -u
cd "$(dirname "$0")/.." || exit 1
HERE=$(pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cd "$T"
git init -q . && git config user.email t@f.t && git config user.name T
mkdir -p _ops/research sources
cp "$HERE/templates/company-preflight.sh" _ops/preflight.sh
for f in ROADMAP TEAM DECISIONS LATER TOOLING; do printf '# %s\n' "$f" > "_ops/$f.md"; done
_gv=$(sed -n 's/^# guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$HERE/templates/company-preflight.sh" | head -1)
printf '# Co\n\n**Operated by** multica-ops **%s**\n' "$_gv" > CLAUDE.md

entry() {   # $1 id · $2 what its Reads against says
  printf '### %s · a source\n- **Citation:** Someone (2024).\n- **Live:** https://example.org/%s\n' "$1" "$1"
  printf -- '- **Archive:** not pinned yet\n- **Licence:** copyrighted — cite + our distillate\n'
  printf -- '- **Distillate:** what it shows.\n- **Check-date:** 2026-09-01\n- **Reads against:** %s\n' "$2"
  printf -- '- **Cited-by:** _ops/research/one.md\n\n'
}
finding() {  # $1 file · $2 the ids under it · $3 Answered · $4 Status
  cat > "_ops/research/$1" <<EOF
# Should we trust the $1 question?

**Decides**: nothing yet · **Status**: ${4:-settled} · **Depth**: deciding
**Answered**: ${3:-2026-09-01} · **Recheck when**: a source contesting what this rests on arrives

## What we now believe

We believe the thing, for the reason the sources give.

**Confidence**: cited

## What would change it

A source that measures the opposite.

## Under it

**Sources**: $2

**Earlier findings this rests on**: none
EOF
}
{ printf '# Sources\n\n'; entry x-2024 '`none found`'; entry x-2024-b '`none found`'; entry other-2020 '`not checked`'; } > sources/SOURCES.md
finding one.md '`x-2024` — the measurement this rests on'
finding two.md 'x-2024-b, cited bare'
finding three.md '`other-2020`'
git add -A && git commit -qm fixture

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
run() { git add -A; OUT=$(bash _ops/preflight.sh 2>&1); RC=$?; }
said() { [ "$(printf '%s' "$OUT" | grep -c -- "$1")" -gt 0 ]; }   # grep -c: no pipe can eat it
reset() { git reset -q --hard HEAD 2>/dev/null; git clean -qfd; }   # inside the throwaway fixture only

# the new tension: `y-2026` arrives reading against `x-2024`, and `x-2024` says so back
tension() {
  python3 - <<'PY'
p = "sources/SOURCES.md"; s = open(p).read()
s = s.replace("### x-2024 · a source", "### x-2024 · a source", 1)
a = "- **Reads against:** `none found`\n- **Cited-by:** _ops/research/one.md\n\n### x-2024-b"
assert s.count(a) == 1, "fixture drifted"
s = s.replace(a, "- **Reads against:** `y-2026` — it measures the opposite\n- **Cited-by:** _ops/research/one.md\n\n### x-2024-b")
open(p, "w").write(s)
PY
  [ $? = 0 ] || { bad "the fixture drifted — the tension was not applied, so what follows proves nothing"; return 1; }
  entry y-2026 '`x-2024` — the opposite result, on a larger sample' >> sources/SOURCES.md
}

suite() {   # $1 = label; runs against whatever guard is in _ops/preflight.sh
  local L="[$1]"
  # the mutant the section exists for: the tension recorded, the finding on it untouched
  reset; tension; run
  [ "$RC" = 1 ] && said '_ops/research/one.md rests on `x-2024`' && ok \
    || bad "$L a new tension against a source a finding rests on passed with the finding untouched"
  said 'research/two.md rests on' && bad "$L \`x-2024\` dragged in the finding citing \`x-2024-b\`" || ok
  said 'research/three.md rests on' && bad "$L a finding on an uncontested source was named" || ok

  # touching it is not re-reading it
  reset; tension; printf '\nA note added later.\n' >> _ops/research/one.md; run
  [ "$RC" = 1 ] && said 'one.md rests on' && ok || bad "$L an edit that did not re-stamp Answered counted as a re-read"

  # the twins: re-stamped, or marked stale
  reset; tension; finding one.md '`x-2024` — the measurement this rests on' 2026-09-11; run
  [ "$RC" = 0 ] && ok || bad "$L a finding re-stamped in the same commit was refused: $OUT"
  reset; tension; finding one.md '`x-2024` — the measurement this rests on' 2026-09-01 stale; run
  [ "$RC" = 0 ] && ok || bad "$L a finding marked stale in the same commit was refused: $OUT"

  # a finding written in the same commit was written with the tension in view
  reset; tension; finding one.md '`x-2024` — the measurement this rests on' 2026-09-11
  finding four.md '`x-2024`, `y-2026` — both, read together'; run
  [ "$RC" = 0 ] && ok || bad "$L a finding new in the tension's own commit was refused: $OUT"

  # a finding renamed in the tension's own commit is the same finding: moving it is not re-reading it
  reset; tension && { git mv _ops/research/one.md _ops/research/one-renamed.md; run
    [ "$RC" = 1 ] && said 'one-renamed.md rests on' && ok || bad "$L renaming the finding dodged the re-read: $OUT"; }
  # the register renamed in the tension's own commit still records the tension
  reset; tension && { git mv sources/SOURCES.md sources/REGISTER.md; run
    [ "$RC" = 1 ] && said 'one.md rests on' && ok || bad "$L renaming the register hid the new tension: $OUT"; }
  # and a rename that records nothing new demands nothing
  reset; git mv sources/SOURCES.md sources/REGISTER.md; run
  [ "$RC" = 0 ] && ok || bad "$L renaming the register alone demanded a re-read: $OUT"
  # a byte that is not UTF-8 is read around, not crashed on
  reset; tension && { printf 'a stray byte \377 in a distillate\n' >> sources/SOURCES.md; run
    [ "$RC" = 1 ] && said 'one.md rests on' && ! said 'stopped before its end' && ok \
      || bad "$L a byte that is not UTF-8 stopped the check: $OUT"; }

  # no tension, no demand: an entry arriving with `not checked`, and a tension taken away
  reset; entry z-2026 '`not checked`' >> sources/SOURCES.md; run
  [ "$RC" = 0 ] && ok || bad "$L an entry naming no tension demanded a re-read: $OUT"
  reset; tension; finding one.md '`x-2024` — the measurement this rests on' 2026-09-11; git add -A
  git commit -qm tension >/dev/null 2>&1
  python3 - <<'PY'
p = "sources/SOURCES.md"; s = open(p).read()
s = s.replace("- **Reads against:** `y-2026` — it measures the opposite", "- **Reads against:** `none found`")
s = s.replace("- **Reads against:** `x-2024` — the opposite result, on a larger sample", "- **Reads against:** `none found`")
open(p, "w").write(s)
PY
  run
  [ "$RC" = 0 ] && ok || bad "$L a tension removed demanded a re-read: $OUT"
  git reset -q --hard HEAD~1 2>/dev/null || true
}

suite "the guard as shipped"

mutant() {   # $1 what it breaks · $2 text · $3 its mutant — the guard alone is committed, on a clean tree
  reset
  cp "$HERE/templates/company-preflight.sh" _ops/preflight.sh
  M_FROM="$2" M_TO="$3" python3 - _ops/preflight.sh <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  git add _ops/preflight.sh && git commit -qm "mutant: $1" >/dev/null 2>&1
}
mutant "the whole-id match loosened to a substring" \
  're.search(r"(?<![A-Za-z0-9-])%s(?![A-Za-z0-9-])" % re.escape(i), m.group(1))' 're.search(re.escape(i), m.group(1))' \
  && { reset; tension && { run; said 'research/two.md rests on' && ok || bad "the suite did not catch the mutant: a substring match"; }; }
mutant "any edit counted as a re-read" \
  'if field(text, "Status") == "stale" or field(text, "Answered") != field(head, "Answered"):' 'if True:' \
  && { reset; tension && { printf '\nA note added later.\n' >> _ops/research/one.md; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: any edit as a re-read"; }; }

mutant "a renamed finding compared with a path it never had" 'head = git("show", "HEAD:" + ren.get(f, f))' 'head = git("show", "HEAD:" + f)' \
  && { reset; tension && { git mv _ops/research/one.md _ops/research/one-renamed.md; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: a renamed finding passing as new"; }; }
mutant "the recheck made to crash" 'import re, subprocess' 'import re, subprocess; raise SystemExit(3)' \
  && { reset; tension && { run; [ "$RC" = 1 ] && said 'stopped before its end' && ok \
         || bad "a recheck that crashed let the commit through — it failed open: $OUT"; }; }

echo "recheck-trigger: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
