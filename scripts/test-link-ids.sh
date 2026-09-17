#!/usr/bin/env bash
# link-ids.py — ported from opsinist with its suite — an id or a path named in passing becomes a link — shown on a throwaway project that
# holds every declaration a reader parses (a heading, a run's `**Task**` row, a `task:` line) and
# every record kept as written (runs, raw research, a History section), beside the mentions that
# should change. **Then the project's own guard is run over the rewritten tree**: a rewrite that
# made the guard misread a file would pass every assertion about text and still break the project.
#
# **Three code mutants** against the assertions they should break: the History section rewritten,
# the run record's declaration rewritten, and a file's own id linked to itself.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
has() { [ "$(grep -cF -- "$2" "$T/p/$1")" -gt 0 ]; }     # grep -c: no pipe can eat it

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/runs" "$T/p/_ops/requests" "$T/p/_ops/research/raw"
  cd "$T/p"
  git init -q . && git config user.email t@f.t && git config user.name T
  cp "$HERE/../templates/company-preflight.sh" _ops/preflight.sh
  printf '# Co\n\n**Operated by** multica-ops **%s**\n' \
    "$(sed -n 's/^# guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$HERE/../templates/company-preflight.sh" | head -1)" > CLAUDE.md
  printf '# Later\n' > _ops/LATER.md
  printf '# Roadmap\n\nFirst the alpha, T-AAAAAA.\n' > _ops/ROADMAP.md
  printf '# Team\n' > _ops/TEAM.md; printf '# Tooling\n' > _ops/TOOLING.md
  cat > _ops/tasks/T-AAAAAA-alpha.md <<'EOF'
# T-AAAAAA — alpha

**Type**: feature · **Status**: started
**Assignee**: worker-a

This depends on T-BBBBBB and on `T-BBBBBB` in backticks; T-AAAAAA is this file's own id.

```
T-BBBBBB inside a fence
```

## History

- 2026-09-01 — blocked by T-BBBBBB
EOF
  cat > _ops/tasks/T-BBBBBB-beta.md <<'EOF'
# T-BBBBBB — beta

**Type**: feature · **Status**: started
**Assignee**: worker-a

## History
EOF
  cat > _ops/DECISIONS.md <<'EOF'
# Decisions

- 2026-09-01 — T-AAAAAA over T-CCCCCC, which has no file; `_ops/ROADMAP.md` says why.
- [alpha](tasks/T-AAAAAA-alpha.md) is already a link, and T-AAAAAA-alpha is a filename, not an id.
task: T-AAAAAA
EOF
  printf '# Q-AAAAAA\n\n**blocks**: T-AAAAAA\n' > _ops/requests/Q-AAAAAA-ask.md
  printf '# Run\n\n| **Task** | T-AAAAAA · alpha |\n\nIt also touched T-BBBBBB.\n' > _ops/runs/2026-09-01-T-AAAAAA.md
  printf 'transcript naming T-AAAAAA\n' > _ops/research/raw/call.md
  # a **Task** row outside the run records: the guard's record_task takes the LAST id in the cell,
  # and measured 2026-09-11 it reads `[T-ABC123](…/T-ABC123-alpha-slug.md)` as `T-ABC123-alpha-slug`
  mkdir -p _ops/threads; printf '# Thread\n\n| **Task** | T-AAAAAA · alpha |\n' > _ops/threads/one.md
  # only the scripts are committed: the project's files stay NEW, so the guard reads every one of
  # them — once as written, once as rewritten — and the two verdicts can be compared
  git add _ops/preflight.sh CLAUDE.md && git commit -qm scripts
  git add -A; G0=$(bash _ops/preflight.sh 2>&1); git reset -q
  BEFORE=$(printf '%s\n' "$G0" | grep '✗' | sort)
}

suite() {   # $1 label · $2 the script
  local L="[$1]" S="$2"
  fixture
  python3 "$S" . > "$T/report" 2>&1; RC=$?
  [ "$RC" = 1 ] && ok || bad "$L the report exited $RC with mentions to link"
  python3 "$S" . --write > "$T/wrote" 2>&1
  has _ops/tasks/T-AAAAAA-alpha.md 'This depends on [T-BBBBBB](T-BBBBBB-beta.md) and on [`T-BBBBBB`](T-BBBBBB-beta.md) in backticks; T-AAAAAA is this file'"'"'s own id.' \
    && ok || bad "$L a bare and a backticked id were not both linked, or the file's own id was"
  has _ops/tasks/T-AAAAAA-alpha.md '# T-AAAAAA — alpha' && ok || bad "$L the task's declaration — its heading — was rewritten"
  has _ops/tasks/T-AAAAAA-alpha.md 'T-BBBBBB inside a fence' && ! has _ops/tasks/T-AAAAAA-alpha.md '[T-BBBBBB](T-BBBBBB-beta.md) inside a fence' \
    && ok || bad "$L an id inside a fence was linked"
  has _ops/tasks/T-AAAAAA-alpha.md '- 2026-09-01 — blocked by T-BBBBBB' && ok || bad "$L the History log was rewritten"
  has _ops/DECISIONS.md '- 2026-09-01 — [T-AAAAAA](tasks/T-AAAAAA-alpha.md) over T-CCCCCC, which has no file; [`_ops/ROADMAP.md`](ROADMAP.md) says why.' \
    && ok || bad "$L a decision's mentions were not linked right, or an id with no file was"
  has _ops/DECISIONS.md '- [alpha](tasks/T-AAAAAA-alpha.md) is already a link, and T-AAAAAA-alpha is a filename, not an id.' \
    && ok || bad "$L an existing link or a filename was rewritten"
  has _ops/DECISIONS.md 'task: T-AAAAAA' && ok || bad "$L a \`task:\` declaration was rewritten"
  has _ops/threads/one.md '| **Task** | T-AAAAAA · alpha |' && ok || bad "$L a **Task** row was rewritten — the guard would read the slug as the id"
  has _ops/requests/Q-AAAAAA-ask.md '**blocks**: [T-AAAAAA](../tasks/T-AAAAAA-alpha.md)' && ok || bad "$L a request's blocks was not linked relative to it"
  has _ops/runs/2026-09-01-T-AAAAAA.md '| **Task** | T-AAAAAA · alpha |' && has _ops/runs/2026-09-01-T-AAAAAA.md 'It also touched T-BBBBBB.' \
    && ok || bad "$L a run record — evidence, with its declaration — was rewritten"
  has _ops/research/raw/call.md 'transcript naming T-AAAAAA' && ok || bad "$L raw research material was rewritten"
  has _ops/ROADMAP.md 'First the alpha, [T-AAAAAA](tasks/T-AAAAAA-alpha.md).' && ok || bad "$L a roadmap mention was not linked"
  python3 "$S" . > "$T/report2" 2>&1; RC=$?
  [ "$RC" = 0 ] && ok || bad "$L after --write the report still found mentions: $(head -2 "$T/report2")"
  python3 "$S" . --write > "$T/wrote2" 2>&1
  [ "$(grep -c '^linked 0 mentions' "$T/wrote2")" = 1 ] && ok || bad "$L a second --write changed something: $(cat "$T/wrote2")"
  # the project's own guard over the rewritten tree: no refusal it did not already make of the original
  git add -A; G1=$(bash _ops/preflight.sh 2>&1); AFTER=$(printf '%s\n' "$G1" | grep '✗' | sort)
  # a guard that never ran compares equal to itself — so each run must end the way the guard ends
  for _g in "$G0" "$G1"; do
    [ "$(printf '%s\n' "$_g" | grep -cE '✓ clean|✓ passed with warnings|✗')" -gt 0 ] && ok \
      || bad "$L the guard did not run to its verdict, so the comparison proves nothing: $(printf '%s' "$_g" | tail -1)"
  done
  [ -n "${DEBUG:-}" ] && { echo "before:"; printf '%s\n' "$G0" | tail -5; echo "after:"; printf '%s\n' "$G1" | tail -5; }
  NEW=$(comm -13 <(printf '%s\n' "$BEFORE") <(printf '%s\n' "$AFTER") | grep -c .)
  [ "$NEW" = 0 ] && ok || bad "$L the guard refused the rewritten tree for something new: $(comm -13 <(printf '%s\n' "$BEFORE") <(printf '%s\n' "$AFTER") | head -2)"
}

suite "as shipped" "$HERE/link-ids.py"

# ── a person named in a field that names one becomes a link ────────────────────────────────────
# **The edge a project misses most.** Measured 2026-09-16: nine tasks naming an assignee and one
# link in the whole of `_ops/`, so *who is this and where do I read about them* was a search every
# time and the graph drew a roster with no edges to the work. Every reader of that field un-links
# before it reads — the door, the board and the guard's self-review check — so making the edge is
# free; the assertion below is the guard running over the rewritten tree, not the text alone.
fixture
mkdir -p _ops/roles
printf '# Web Engineer\n\n**Type**: worker · **Grade**: mid\n' > _ops/roles/web_engineer.md
printf '# Architect\n\n**Type**: expert · **Grade**: senior\n' > _ops/roles/architect.md
printf '# T-PPPPPP — a thing\n\n**Type**: feature · **Status**: review\n**Assignee**: Web Engineer\n\n## History\n\n- 2026-09-17 — reviewed by architect\n' > _ops/tasks/T-PPPPPP-thing.md
printf '# T-QQQQQQ — another\n\n**Type**: feature · **Status**: review\n**Assignee**: Nobody Here\n\n## History\n' > _ops/tasks/T-QQQQQQ-other.md
python3 "$HERE/link-ids.py" . --write > /dev/null 2>&1
has _ops/tasks/T-PPPPPP-thing.md '**Assignee**: [Web Engineer](../roles/web_engineer.md)' \
  && ok || bad "an assignee that names a role file did not become a link"
has _ops/tasks/T-QQQQQQ-other.md '**Assignee**: Nobody Here' \
  && ok || bad "a name that resolves to nothing was linked anyway, or rewritten"
python3 "$HERE/link-ids.py" . --write > /dev/null 2>&1
[ "$(grep -cF '](../roles/web_engineer.md)' _ops/tasks/T-PPPPPP-thing.md)" = 1 ] \
  && ok || bad "a second run linked the link again"

# **No door case here**: stage changes are Multica's own primitive, so there is no local reader of
# this field to break. What the sibling measured — a linked declaration handing back its slug — is
# why the rule still says every reader un-links first, and why `link-ids.py` stops at declarations.

mutant() {   # $1 what it breaks · $2 text · $3 its mutant · $4 file · $5 the text that must appear
  cp "$HERE/link-ids.py" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  fixture; python3 "$T/mut.py" . --write > /dev/null 2>&1
  has "$4" "$5" && ok || bad "the suite did not catch the mutant: $1"
}
mutant "the History section rewritten" 'if fenced or history or DECLARATION.search(line):' 'if fenced or DECLARATION.search(line):' \
  _ops/tasks/T-AAAAAA-alpha.md 'blocked by [T-BBBBBB](T-BBBBBB-beta.md)'
mutant "a declaration rewritten" 'if fenced or history or DECLARATION.search(line):' 'if fenced or history:' \
  _ops/DECISIONS.md 'task: [T-AAAAAA](tasks/T-AAAAAA-alpha.md)'
mutant "a file's own id linked to itself" 'if ident == own or ident not in ents:' 'if ident not in ents:' \
  _ops/tasks/T-AAAAAA-alpha.md '[T-AAAAAA](T-AAAAAA-alpha.md) is this file'

echo "link-ids: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
