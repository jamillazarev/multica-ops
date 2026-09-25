#!/usr/bin/env bash
# check-trio.py — an entry's Trio line against what the release added — shown on a throwaway
# repository with two tags, in both layouts (`facts.md` here, `sources/SOURCES.md` next door):
# the honest line passes, and a wrong count, a missing kind, a missing line and a missing tag
# each get their own answer. A released entry is reported and not failed for what it cannot read.
#
# **Six code mutants** against the assertions they should break, each asserting it changed the
# file first — a mutation that never applied reads exactly like a toothless test.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
S="$HERE/check-trio.py"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(grep -cF -- "$1" "$T/report")" -gt 0 ]; }    # grep -c: no pipe can eat it
G() { git -c user.name=t -c user.email=t@t.invalid "$@"; }

UC=use-cases.md
mk() {   # $1 ops | sib — the first release, tagged
  rm -rf "$T/r"; mkdir -p "$T/r"; cd "$T/r"; git init -q .
  if [ "$1" = ops ]; then
    UC=use-cases.md; printf '# Facts\n\n1. **One** fact.\n\n2. **Two** fact.\n' > facts.md
  else
    UC=USE-CASES.md; mkdir -p sources; printf '# Sources\n\n### one-id · First\n\nbody\n' > sources/SOURCES.md
  fi
  printf '# A\n' > a.md
  printf '# Situations\n\n| Situation | Say | Runs |\n|---|---|---|\n| one | x | y |\n' > "$UC"
  printf '# Changelog\n\n## 0.1.0 — 2026-01-01\n\n**Trio:** none — the first release.\n' > CHANGELOG.md
  G add -A; G commit -qm one; G tag v0.1.0
}
grow() {   # the release: one diagram, two situations in a NEW table (a header to skip), one fact
  printf '\n```mermaid\nflowchart LR\n  A --> B\n```\n' >> a.md
  printf '\n## More\n\n| Situation | Say | Runs |\n|---|---|---|\n| two | x | y |\n| three | x | y |\n' >> "$UC"
  if [ -f facts.md ]; then printf '\n3. **Three** fact.\n' >> facts.md
  else printf '\n### two-id · Second\n\nbody\n' >> sources/SOURCES.md; fi
}
entry() {   # $1 the Trio paragraph — the entry also quotes a diagram, which is not one the release added
  python3 - "$1" <<'PY'
import sys
t = open("CHANGELOG.md", encoding="utf-8").read()
head = "# Changelog\n\n"
new = ("## 0.2.0 — 2026-01-02\n\nA release.\n\n```mermaid\nflowchart LR\n  X --> Y\n```\n\n"
       + sys.argv[1] + "\n\n")
open("CHANGELOG.md", "w", encoding="utf-8").write(t.replace(head, head + new, 1))
PY
}
release() { G add -A; G commit -qm two; G tag v0.2.0; }
run() { python3 "$1" ${2:+"$2"} > "$T/report" 2>&1; RC=$?; }   # no second word: the newest entry

HONEST='**Trio:** one diagram · two situations · `facts.md` **3**.
Suites: a-suite **9** · b-suite **12**, all zero-fail.'

# — the honest line passes, with suite sizes in bold on the line after it
mk ops; grow; entry "$HONEST"; run "$S"
[ "$RC" = 0 ] && said "matches v0.1.0..the working tree" && ok || bad "the honest line was refused (rc=$RC): $(head -3 "$T/report")"

# — a wrong count, each kind
mk ops; grow; entry '**Trio:** two diagrams · two situations · `facts.md` **3**.'; run "$S"
[ "$RC" = 1 ] && said "says diagrams 2" && said "added 1" && ok || bad "a wrong diagram count passed (rc=$RC)"
mk ops; grow; entry '**Trio:** one diagram · three situations · `facts.md` **3**.'; run "$S"
[ "$RC" = 1 ] && said "says situations 3" && ok || bad "a wrong situation count passed (rc=$RC)"
mk ops; grow; entry '**Trio:** one diagram · two situations · `facts.md` **3–4**.'; run "$S"
[ "$RC" = 1 ] && said "says facts 3–4" && ok || bad "a wrong fact range passed (rc=$RC)"

# — a kind the release added and the line does not name: the entry being written fails…
mk ops; grow; entry '**Trio:** one diagram · `facts.md` **3**.'; run "$S"
[ "$RC" = 1 ] && said "says nothing this can read" && ok || bad "an unread kind on the unreleased entry passed (rc=$RC)"
# …a released one is reported, not failed — its entry is frozen and cannot be fixed but by a correction
release; run "$S" 0.2.0
[ "$RC" = 0 ] && said "unread: situations" && ok || bad "an unread kind on a released entry was failed or not reported (rc=$RC)"

# — a released entry that is wrong still fails, which is how 0.2.19 was found
mk ops; grow; entry '**Trio:** two diagrams · two situations · `facts.md` **3**.'; release; run "$S" 0.2.0
[ "$RC" = 1 ] && said "v0.1.0..v0.2.0 added 1" && ok || bad "a released wrong count passed (rc=$RC)"

# — a released entry is frozen, and a marked correction of its Trio line is what it says instead
mk ops; grow; entry '**Trio:** two diagrams · two situations · `facts.md` **3**.

> **Correction, 2026-01-03 — the Trio line overcounts.** The release added one diagram, not two.'
release; run "$S" 0.2.0
[ "$RC" = 0 ] && ok || bad "a marked correction of the Trio line was not read (rc=$RC): $(head -2 "$T/report")"

# — no Trio line at all
mk ops; grow; entry 'A release that forgot.'; run "$S"
[ "$RC" = 1 ] && said "has no **Trio:** line" && ok || bad "a missing Trio line passed (rc=$RC)"

# — nothing to measure against is its own answer
rm -rf "$T/r"; mkdir -p "$T/r"; cd "$T/r"; git init -q .
printf '# Changelog\n\n## 0.1.0 — 2026-01-01\n\n**Trio:** one diagram.\n' > CHANGELOG.md
run "$S"
[ "$RC" = 2 ] && ok || bad "an entry with no earlier tag exited $RC, not 2"

# — a number word with a hyphen
mk ops; for i in $(seq 1 21); do printf '| row %s | x | y |\n' "$i" >> use-cases.md; done
printf '\n3. **Three** fact.\n' >> facts.md
entry '**Trio:** no diagram · twenty-one situations · `facts.md` **3**.'; run "$S"
[ "$RC" = 0 ] && ok || bad "twenty-one situations were not read as 21 (rc=$RC): $(head -2 "$T/report")"

# — the sibling's layout: register entries in sources/SOURCES.md
mk sib; grow; entry '**Trio:** one diagram, two situations in USE-CASES, and one register entry.'; run "$S"
[ "$RC" = 0 ] && ok || bad "the sibling layout's honest line was refused (rc=$RC): $(head -2 "$T/report")"
mk sib; grow; entry '**Trio:** one diagram, two situations in USE-CASES, and two register entries.'; run "$S"
[ "$RC" = 1 ] && said "says entries 2" && ok || bad "a wrong register count passed (rc=$RC)"

mutant() {   # $1 what it breaks · $2 text · $3 its mutant · $4 the fixture, as a function · $5 the rc it must now give
  cp "$S" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  "$4"; run "$T/mut.py"
  [ "$RC" = "$5" ] && ok || bad "the suite did not catch the mutant: $1 (rc=$RC)"
}
honest_ops()   { mk ops; grow; entry "$HONEST"; }
corrected_ops() { mk ops; grow; entry '**Trio:** two diagrams · two situations · `facts.md` **3**.

> **Correction, 2026-01-03 — the Trio line overcounts.** The release added one diagram, not two.'; }
unread_ops()   { mk ops; grow; entry '**Trio:** one diagram · `facts.md` **3**.'; }
hyphen_ops()   { mk ops; for i in $(seq 1 21); do printf '| row %s | x | y |\n' "$i" >> use-cases.md; done
                 printf '\n3. **Three** fact.\n' >> facts.md
                 entry '**Trio:** no diagram · twenty-one situations · `facts.md` **3**.'; }
mutant "the facts clause read to the paragraph's end" \
  'clause = re.split(r"\.\s| · |\.$", f.group(1))[0]' 'clause = f.group(1)' honest_ops 1
mutant "a table's header counted as a situation" \
  'if re.match(r"^\|\s*:?-", nxt):          # a header row' 'if False:' honest_ops 1
mutant "the changelog's own diagrams counted" \
  'and f != "CHANGELOG.md"]' ']' honest_ops 1
mutant "a hyphenated number word not read" \
  'if "-" in word:' 'if False:' hyphen_ops 1
mutant "a marked correction of the Trio line ignored" \
  'c.update(counts(' '(counts(' corrected_ops 1
mutant "an unread kind passed on the entry being written" \
  'if bad or (unread and here is None):' 'if bad:' unread_ops 0

echo "check-trio: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
