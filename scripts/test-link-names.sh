#!/usr/bin/env bash
# link-names.py — ported from opsinist, with this repository's one-level rule — a backticked name of a file in this tree becomes a link — shown on a throwaway
# tree holding every place it must NOT write: a fence, a heading, frontmatter, an HTML comment, an
# existing link, a name that leads a double life, a file that does not exist, CHANGELOG.md, and the
# directories copied into projects or kept as evidence.
#
# **Four code mutants** against the assertions they should break: the fence ignored, the
# double-life list emptied, the one-level rule dropped, and existing links left unmasked (a link
# written inside a link).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
has() { [ "$(grep -cF -- "$2" "$T/w/$1")" -gt 0 ]; }     # grep -c: no pipe can eat it

fixture() {
  rm -rf "$T/w"; mkdir -p "$T/w/templates" "$T/w/skills/x" "$T/w/evals" "$T/w/sub"
  cd "$T/w"
  printf '# B\n' > b.md; printf '# T\n' > templates/T.md; printf '# Runs\n' > evals/RUNS.md
  printf '# C\n' > CLAUDE.md; printf '# Deep\n' > sub/deep.md
  cat > AGENTS.md <<'EOF'
# A — and a heading naming `b.md` stays a heading

See `b.md` for more, and `b.md` again on the same line.
A project carries its own `CLAUDE.md`, and this names that one.
[see `b.md`](b.md) is already a link.
`missing.md` is not a file here, and `_ops/b.md` is a project's.
The template is `templates/T.md`; the deep one is `sub/deep.md`.

```
`b.md` inside a fence
```

<!--
`b.md` inside a comment
-->
| a table | `b.md` |
<!-- `b.md` in a comment on one line -->
EOF
  cat > skills/x/SKILL.md <<'EOF'
---
description: routes to `b.md`
---
Read `b.md` first.
EOF
  printf '## 0.1 — 2026-01-01\n\n- `b.md` changed\n' > CHANGELOG.md
  printf 'Read `b.md`.\n' >> templates/T.md
  printf 'Measured against `b.md`.\n' >> evals/RUNS.md
  printf 'Up to `b.md` and across to `sub/deep.md`.\n' >> sub/deep.md
  mkdir -p skills/mops && printf 'Read `b.md`.\n' > skills/mops/SKILL.md   # the always-loaded core
  printf '# C\n\nSee `b.md`, and the template `templates/T.md`.\n' > c.md
}

suite() {   # $1 label · $2 the script
  local L="[$1]" S="$2"
  fixture
  python3 "$S" . > "$T/report" 2>&1; RC=$?
  [ "$RC" = 1 ] && [ "$(grep -c '^AGENTS.md:3: b.md$' "$T/report")" = 2 ] && ok || bad "$L the report did not list both names on AGENTS.md:3 and exit 1"
  python3 "$S" . --write > "$T/wrote" 2>&1
  has AGENTS.md 'See [`b.md`](b.md) for more, and [`b.md`](b.md) again on the same line.' && ok || bad "$L two names on one line were not both linked"
  has AGENTS.md '# A — and a heading naming `b.md` stays a heading' && ok || bad "$L a heading was rewritten"
  has AGENTS.md 'A project carries its own `CLAUDE.md`, and this names that one.' && ok || bad "$L a name with a double life was linked"
  has AGENTS.md '[see `b.md`](b.md) is already a link.' && ok || bad "$L an existing link was rewritten"
  has AGENTS.md '`missing.md` is not a file here, and `_ops/b.md` is a project'"'"'s.' && ok || bad "$L a name that is not a file here was linked"
  has AGENTS.md 'The template is [`templates/T.md`](templates/T.md); the deep one is [`sub/deep.md`](sub/deep.md).' && ok \
    || bad "$L a path under a directory was not linked"
  has AGENTS.md '`b.md` inside a fence' && ! has AGENTS.md '[`b.md`](b.md) inside a fence' && ok || bad "$L a name inside a fence was linked"
  has AGENTS.md '`b.md` inside a comment' && ! has AGENTS.md '[`b.md`](b.md) inside a comment' && ok || bad "$L a name inside an HTML comment was linked"
  has AGENTS.md '| a table | [`b.md`](b.md) |' && ok || bad "$L a name in a table cell was not linked"
  has AGENTS.md '<!-- `b.md` in a comment on one line -->' && ok || bad "$L a name in a one-line HTML comment was linked"
  has skills/x/SKILL.md 'description: routes to `b.md`' && ok || bad "$L frontmatter was rewritten"
  has skills/x/SKILL.md 'Read [`b.md`](../../b.md) first.' && ok || bad "$L a nested file's link is not relative to it"
  has sub/deep.md 'Up to [`b.md`](../b.md) and across to [`sub/deep.md`](deep.md).' && ok || bad "$L the paths from one level down are wrong"
  has CHANGELOG.md '- `b.md` changed' && ok || bad "$L CHANGELOG.md was rewritten — its released entries are published notes"
  has templates/T.md 'Read `b.md`.' && ok || bad "$L a template was rewritten — it is copied into projects, where the path does not exist"
  has evals/RUNS.md 'Measured against `b.md`.' && ok || bad "$L evidence under evals/ was rewritten"
  has skills/mops/SKILL.md 'Read `b.md`.' && ok || bad "$L the always-loaded core was rewritten — every link in it is paid on every run"
  has c.md 'See `b.md`, and the template [`templates/T.md`](templates/T.md).' && ok \
    || bad "$L a companion's name of a companion was linked, or its template path was not — §5c keeps references one level deep"
  python3 "$S" . > "$T/report2" 2>&1; RC=$?
  [ "$RC" = 0 ] && ok || bad "$L after --write the report still found names: $(head -2 "$T/report2")"
  python3 "$S" . --write > "$T/wrote2" 2>&1
  [ "$(grep -c '^linked 0 names' "$T/wrote2")" = 1 ] && ok || bad "$L a second --write changed something: $(cat "$T/wrote2")"
}

suite "as shipped" "$HERE/link-names.py"

# in a repository, what git ignores is not the corpus — an eval workspace holds a project of its own
fixture; git init -q . && printf '/scratch/\n' > .gitignore && mkdir -p scratch/_ops
printf 'See `b.md`.\n' > scratch/_ops/DECISIONS.md
python3 "$HERE/link-names.py" . --write > /dev/null 2>&1
has scratch/_ops/DECISIONS.md 'See `b.md`.' && ok || bad "a file git ignores was rewritten"
has AGENTS.md 'See [`b.md`](b.md) for more' && ok || bad "inside a repository, the tracked-or-new files were not rewritten"

mutant() {   # $1 what it breaks · $2 text · $3 its mutant · $4 the file · $5 the line that must go wrong
  cp "$HERE/link-names.py" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  fixture; python3 "$T/mut.py" . --write > /dev/null 2>&1
  has "$4" "$5" && ok || bad "the suite did not catch the mutant: $1"
}
mutant "the fence ignored" 'if fenced or s.startswith("#"):' 'if s.startswith("#"):' AGENTS.md '[`b.md`](b.md) inside a fence'
mutant "the double-life list emptied" '("/" not in path and path in DOUBLE_LIVES)' 'False' AGENTS.md '[`CLAUDE.md`](CLAUDE.md)'
mutant "the one-level rule dropped" 'if "/" not in here and "/" not in path and here not in ONE_LEVEL_EXEMPT:' 'if False:' \
  c.md 'See [`b.md`](b.md)'
mutant "the core rewritten" 'if p not in ("CHANGELOG.md", CORE)' 'if p not in ("CHANGELOG.md",)' \
  skills/mops/SKILL.md 'Read [`b.md`](../../b.md).'
mutant "existing links left unmasked" 'masked = LINK.sub(lambda m: "\0" * len(m.group(0)), line)' 'masked = line' \
  AGENTS.md '[see [`b.md`](b.md)](b.md)'

echo "link-names: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
