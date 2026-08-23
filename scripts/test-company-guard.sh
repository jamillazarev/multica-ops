#!/usr/bin/env bash
# The company docs guard — `templates/company-preflight.sh` — exercised on its mutants and twins.
#
# **It shipped with none.** 0.4.9 added 101 lines of gate to a file that `grep -rl` found named
# only in prose, the template itself, and a migration script: nothing ran it, ever. A lens found
# that on 2026-08-23 and filed it CRITICAL, which is the right severity — this file is copied into
# other people's repositories and refuses their commits.
#
# The guard runs inside a throwaway repo, never this one.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
HERE=$(pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ pass=$((pass+1)); }; bad(){ fail=$((fail+1)); echo "  ✗ $1"; }

R="$T/co"; mkdir -p "$R/_ops"
cp "$HERE/templates/company-preflight.sh" "$R/_ops/preflight.sh"
for f in ROADMAP TEAM TOOLING DECISIONS LATER; do printf '# %s\n' "$f" > "$R/_ops/$f.md"; done
printf '| Tool | Purpose | Owner | Kind | Checked |\n|---|---|---|---|---|\n' >> "$R/_ops/TOOLING.md"
_gv=$(sed -n 's/^# guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$HERE/templates/company-preflight.sh" | head -1)
printf '# Co\n\n**Operated by** multica-ops **%s**\n' "$_gv" > "$R/CLAUDE.md"
printf '{\n  "name": "app",\n  "dependencies": {}\n}\n' > "$R/package.json"
git -C "$R" init -q && git -C "$R" add -A && \
  git -C "$R" -c user.email=t@t -c user.name=t commit -qm init >/dev/null 2>&1

g(){ ( cd "$R" && bash _ops/preflight.sh 2>&1 || true ); }
grc(){ ( cd "$R" && bash _ops/preflight.sh >/dev/null 2>&1; echo $? ); }
# RESET first, THEN checkout. `git checkout -- .` restores from the INDEX, so with a broken file
# staged it restores the broken file — which left package.json as invalid JSON and killed the two
# cases after it. Caught on this suite's first run.
reset(){ git -C "$R" reset -q; git -C "$R" checkout -q -- . 2>/dev/null
         rm -f "$R/requirements.txt" "$R/go.mod" "$R/Gemfile"; }

# the twin: an untouched company passes
[ "$(grc)" = 0 ] && ok || bad "the untouched company failed the guard"

# ── §4e · a dependency names itself in the decision log ────────────────────────────────────
dep(){ # <file> <line> → 1 when the guard refuses
  printf '%s\n' "$2" >> "$R/$1"; git -C "$R" add -A
  local n; n=$(g | grep -c 'says nothing about why'); reset; echo "$n"; }

[ "$(dep package.json '{"dependencies":{"lodash":"^4.17.21"}}')" -ge 1 ] \
  && ok || bad "§4e let a dependency in with nothing said about why"
[ "$(dep package.json '{"dependencies":{"leftpad":"latest"}}')" -ge 1 ] \
  && ok || bad "§4e is blind to a dependency pinned to \`latest\`"
[ "$(dep requirements.txt 'requests>=2.31')" -ge 1 ] \
  && ok || bad "§4e is blind to a requirements.txt line"
[ "$(dep go.mod 'require github.com/pkg/errors v0.9.1')" -ge 1 ] \
  && ok || bad "§4e is blind to a go.mod require line"
[ "$(dep Gemfile 'gem "rails"')" -ge 1 ] \
  && ok || bad "§4e is blind to a Gemfile gem"

# the twin: the same dependency, named in the decision log
python3 - "$R" <<'PY'
import json, pathlib, sys
r = pathlib.Path(sys.argv[1])
p = r / "package.json"; d = json.loads(p.read_text())
d["dependencies"]["lodash"] = "^4.17.21"; p.write_text(json.dumps(d, indent=2) + "\n")
(r / "_ops/DECISIONS.md").write_text(
    (r / "_ops/DECISIONS.md").read_text()
    + "- 2026-08-23 lodash replaces our own deep-clone helper; structuredClone rejected\n")
PY
git -C "$R" add -A
[ "$(grc)" = 0 ] && ok || bad "a dependency arriving with its reason was refused"
# and a version BUMP is not a new dependency
git -C "$R" -c user.email=t@t -c user.name=t commit -qm dep >/dev/null 2>&1
python3 - "$R" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1]) / "package.json"; d = json.loads(p.read_text())
d["dependencies"]["lodash"] = "^4.17.22"; p.write_text(json.dumps(d, indent=2) + "\n")
PY
git -C "$R" add -A
[ "$(grc)" = 0 ] && ok || bad "a version bump was treated as a new dependency"
reset

# the boundary: a decision naming `update` must not satisfy a dependency called `date`
python3 - "$R" <<'PY'
import json, pathlib, sys
r = pathlib.Path(sys.argv[1])
p = r / "package.json"; d = json.loads(p.read_text())
d["dependencies"]["date"] = "^1.0.0"; p.write_text(json.dumps(d, indent=2) + "\n")
(r / "_ops/DECISIONS.md").write_text(
    (r / "_ops/DECISIONS.md").read_text() + "- 2026-08-23 we now update the invoice page weekly\n")
PY
git -C "$R" add -A
[ "$(g | grep -c 'says nothing about why')" -ge 1 ] \
  && ok || bad "a decision saying \`update\` satisfied a dependency named \`date\`"
reset

# ── §4f · the same rung where there is no code ─────────────────────────────────────────────
row(){ printf '%s\n' "$1" >> "$R/_ops/TOOLING.md"; git -C "$R" add -A
       local n; n=$(g | grep -c 'what it replaces'); reset; echo "$n"; }

[ "$(row '| Otter | interview transcripts | me | service | 2026-08-23 |')" -ge 1 ] \
  && ok || bad "§4f let a register row in with nothing about what came before"
[ "$(row '| Otter | transcripts, instead of the intern typing them | me | service | 2026-08-23 |')" = 0 ] \
  && ok || bad "a row saying what it replaces was still asked"
[ "$(row '| Otter | transcripts; we had none, this is new | me | service | 2026-08-23 |')" = 0 ] \
  && ok || bad "\`we had none\` was not accepted — outside software it is usually the true answer"
# it REFUSES, measured: as a warning it scored 0 of 5 and as a refusal 2 of 5 (2026-08-22)
printf '| Otter | interview transcripts | me | service | 2026-08-23 |\n' >> "$R/_ops/TOOLING.md"
git -C "$R" add -A
[ "$(grc)" != 0 ] && ok || bad "§4f warned instead of refusing"
reset

# The header is found by STRUCTURE — the line above the `|---|` — never by the words in it, and a
# fenced example is not the register. The filter used to drop any row matching `tool|name|what`,
# a vocabulary one level below the one §4e was cured of in the same file. A register naming its
# columns anything else had its own header read as a data row, so standing one up from a template
# was refused for saying nothing about what it replaced.
printf '# Tooling\n\n| Thing | Why we have it | Owner |\n|---|---|---|\n' > "$R/_ops/TOOLING.md"
git -C "$R" add -A
[ "$(g | grep -c 'what it replaces')" = 0 ] \
  && ok || bad "a register standing up with headers and no rows was refused — the header read as a row"
printf '| Otter | interview transcripts | me |\n' >> "$R/_ops/TOOLING.md"; git -C "$R" add -A
[ "$(g | grep -c 'what it replaces')" -ge 1 ] \
  && ok || bad "a real row in an unfamiliarly-headed register was not seen at all"
printf '# Tooling\n\n| Thing | Why | Owner |\n|---|---|---|\n\nExample:\n\n```\n| Foo | bar | me |\n```\n' > "$R/_ops/TOOLING.md"
git -C "$R" add -A
[ "$(g | grep -c 'what it replaces')" = 0 ] \
  && ok || bad "a fenced example row was treated as a register row"
reset

# ── the guard notices its own age ──────────────────────────────────────────────────────────
printf '# Co\n\n**Operated by** multica-ops **0.0.1**\n' > "$R/CLAUDE.md"; git -C "$R" add -A
g | grep -q 'guard is version' \
  && ok || bad "a guard older than the guide said nothing — the copy nobody moves"
[ "$(grc)" = 0 ] && ok || bad "the age check refused instead of warning"
printf '# Co\n\n**Operated by** multica-ops **%s**\n' "$_gv" > "$R/CLAUDE.md"; git -C "$R" add -A
g | grep -q 'guard is version' \
  && bad "the guard complained about its age while matching the guide" || ok
reset

echo "company-guard: $pass passed, $fail failed"
exit "$fail"
