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
printf '# Tooling\n\n| Thing | Why | Owner |\n|---|---|---|\n\n~~~\n| Foo | bar | me |\n~~~\n' > "$R/_ops/TOOLING.md"
git -C "$R" add -A
[ "$(g | grep -c 'what it replaces')" = 0 ] \
  && ok || bad "a ~~~ fenced example row was treated as a register row"
printf '# Tooling\n\n| Thing | Why | Owner |\n|---|---|---|\n\n<!--\n| Draft | not yet | me |\n-->\n' > "$R/_ops/TOOLING.md"
git -C "$R" add -A
[ "$(g | grep -c 'what it replaces')" = 0 ] \
  && ok || bad "a row parked in an HTML comment was treated as live"

# ── a comment hides a LINE, and only when it is one ─────────────────────────────────────────
# **This repo shipped the §4f comment fix with none of its tests** — the code comment claimed a
# measured regression and nothing here verified it, against clause 2 of the capability bar. Three
# ways the register went silent, all measured 2026-08-27: a line that was entirely an inline
# comment read as the end of the table and silenced every live row below it · the same with a `>`
# inside, which the strip could not cross · the same with a CR at the end.
_reg2(){ printf '%b' "$1" > "$R/_ops/TOOLING.md"; git -C "$R" add -A
         local n; n=$(g | grep -c 'what it replaces'); reset; echo "$n"; }
_H='# T\n\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n'
[ "$(_reg2 "$_H<!-- | draft | parked |  | d | -->\n| live | notes |  | d |\n")" -ge 1 ] \
  && ok || bad "a parked draft row silenced the gate for the live row below it"
[ "$(_reg2 "$_H<!-- | draft | a -> b |  | d | -->\n| live | notes |  | d |\n")" -ge 1 ] \
  && ok || bad "a parked row containing > silenced the gate"
[ "$(_reg2 "$_H<!-- sorted by date -->\n| live | notes |  | d |\n")" -ge 1 ] \
  && ok || bad "a comment-only note between rows ended the table early"
[ "$(_reg2 "$_H| live | notes | the intern | d |\n")" = 0 ] \
  && ok || bad "an honest answer was refused"
# The register is read from the INDEX. Reading it from the worktree while the added lines came
# from the index made the rung fall silent the moment the two disagreed — a regression measured
# 2026-08-23, and whitespace alignment was enough to trigger it.
printf '# Tooling\n\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n' > "$R/_ops/TOOLING.md"
git -C "$R" add -A && git -C "$R" -c user.email=t@t -c user.name=t commit -qm reg >/dev/null 2>&1
printf '| Figma | design files |  | 2026-08-23 |\n' >> "$R/_ops/TOOLING.md"
git -C "$R" add -A
python3 - "$R" <<'MUT'
import pathlib, sys
p = pathlib.Path(sys.argv[1]) / "_ops/TOOLING.md"; t = p.read_text()
p.write_text(t.replace("| Figma | design files |  |", "| Figma  | design files  |  |"))
MUT
[ "$(g | grep -c 'what it replaces')" -ge 1 ] \
  && ok || bad "the rung fell open when the worktree and the index disagreed"
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

# ── §4f: every way the register was made invisible ──────────────────────────────────────────
# **This suite had no assertion for any of them**, while this repo's own changelog listed three
# as closed — found by a contradiction lens 2026-08-28. The reason it went unnoticed is worth
# keeping: the fixture register above has no `Replaces` column, so §4f never fired on it at all,
# and a rung that never fires cannot fail. The helper below builds a register that does have one.
# The guard file is byte-identical to the sibling's, so these mirror its fixtures deliberately —
# a shared file with coverage in only one repository is covered in neither, next time it is edited
# from the other side.
_reg(){ python3 - "$1" > "$R/_ops/TOOLING.md" <<'RPY'
import sys
sys.stdout.write(sys.argv[1])
RPY
  git -C "$R" add -A >/dev/null 2>&1
  local n; n=$( ( cd "$R" && bash _ops/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )
  git -C "$R" reset -q; git -C "$R" checkout -q -- . 2>/dev/null; printf '%s' "$n"; }

# the control: a live row with a blank Replaces cell must be refused, or nothing below means much
[ "$(_reg '# Tooling

| Tool | Replaces |
|---|---|
| ripgrep |  |
')" -ge 1 ] && ok || bad "§4f did not refuse a live row with a blank Replaces cell — every assertion below is vacuous"

# an inline comment in a live row hid that row while the page still rendered it
[ "$(_reg '# Tooling

| Tool | Replaces |
|---|---|
| ripgrep |  | <!-- todo -->
')" -ge 1 ] && ok || bad "an inline comment in a live row made that row invisible to the gate"

# an opener with no closer hid every row after it, permanently. **It sits INSIDE a cell**: a
# `<!--` alone on its line has no pipes, and a line with no pipes is where a markdown table
# genuinely ends — refusing there would be the gate inventing a table the page does not render.
[ "$(_reg '# Tooling

| Tool | Replaces |
|---|---|
| beta | write <!-- here |
| ripgrep |  |
')" -ge 1 ] && ok || bad "an unterminated comment inside a cell swallowed every row after it"

# a stray fence opener at the top did the same
[ "$(_reg '# Tooling

```
| Tool | Replaces |
|---|---|
| ripgrep |  |
')" -ge 1 ] && ok || bad "an unclosed fence marker voided the whole register"

# a line that is ENTIRELY a comment read as the end of the table — the parked-draft idiom
[ "$(_reg '# Tooling

| Tool | Replaces |
|---|---|
<!-- | draft | parked | -->
| ripgrep |  |
')" -ge 1 ] && ok || bad "a parked draft row read as the end of the table and hid the live rows below"

# the strip has to cross a > and survive a CR
[ "$(_reg '# Tooling

| Tool | Replaces |
|---|---|
<!-- | draft | a -> b <span> | -->
| ripgrep |  |
')" -ge 1 ] && ok || bad "a parked row containing > was neither stripped nor hidden"
printf '# Tooling\r\n\r\n| Tool | Replaces |\r\n|---|---|\r\n<!-- | draft | x | -->\r\n| ripgrep |  |\r\n' > "$R/_ops/TOOLING.md"
git -C "$R" add -A >/dev/null 2>&1
[ "$( ( cd "$R" && bash _ops/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )" -ge 1 ] \
  && ok || bad "a CRLF register read a parked row as the end of the table"
git -C "$R" reset -q; git -C "$R" checkout -q -- . 2>/dev/null

# a live row quoting the opener in backticks — the register that documents its own idiom
[ "$(_reg '# Tooling

| Tool | Replaces |
|---|---|
| parkdoc | park a draft by wrapping it in `<!--` |
| ripgrep |  |
<!-- | someday | x | -->
')" -ge 1 ] && ok || bad "a live row quoting a comment opener in backticks silenced every live row below it"

# a stray closer left standing is not a row boundary
[ "$(_reg '# Tooling

| Tool | Replaces |
|---|---|
| other | x |
  -->
| ripgrep |  |
')" -ge 1 ] && ok || bad "a stray --> line was read as the end of the table, hiding every row after it"

echo "company-guard: $pass passed, $fail failed"
exit "$fail"
