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

# ── §15 · a skill that runs commands records what it refused ───────────────────────────────
# Ported from the sibling 2026-09-10, where the rule measured 0 of 5 as prose. The twins come
# first: a gate that refuses everything and a gate that reads nothing look identical from here.
mkdir -p "$R/_ops/skills/assemble"
sk="$R/_ops/skills/assemble/SKILL.md"

cat > "$sk" <<'SK'
# Assemble

    python3 _ops/scripts/assemble.py --check

## Tested against

- **Input:** `_ops/drafts/empty.md` — a draft whose body is only a heading
- **Refused with:** `assemble.py: refusing _ops/drafts/empty.md — body is a heading and nothing else`
- **Run on:** 2026-09-10
SK
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" = "0" ] && ok || bad "§15 refused an honest skill"

cat > "$sk" <<'SK'
# A door

Load the advisor skill and follow the flow.

## Tested against

- none: this skill routes and runs nothing
SK
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" = "0" ] && ok || bad "§15 refused a door that runs nothing"

printf '# Assemble\n\n    python3 _ops/scripts/assemble.py --check\n' > "$sk"
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" != "0" ] && ok || bad "a skill running commands with no Tested-against passed"

cat > "$sk" <<'SK'
# Assemble

    python3 _ops/scripts/assemble.py --check

## Tested against

- **Input:** {{the defective input}}
- **Refused with:** {{what it printed}}
SK
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" != "0" ] && ok || bad "an unfilled Tested-against template passed"

cat > "$sk" <<'SK'
# Assemble

    python3 _ops/scripts/assemble.py --check

## Tested against

- **Input:** read the documentation and the flags look right
- **Run on:** 2026-09-10
SK
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" != "0" ] && ok || bad "a test claimed with nothing under Refused with passed"
rm -rf "$R/_ops/skills"
( cd "$R" && git add -A >/dev/null 2>&1 )

# ── §17 · a finding carries what orders it and what expires it ─────────────────────────────
mkdir -p "$R/_ops/research/raw" "$R/_ops/tasks"
# **The task this finding decides must exist**, or §20 refuses the commit for a dead link and every
# assertion below measures that instead of §17 — a fixture whose links point nowhere is a fixture in
# a state no project should be in.
printf '# T-AB12CD — panels\n\nThe task a finding decides.\n' > "$R/_ops/tasks/T-AB12CD-panels.md"
git -C "$R" add -A >/dev/null 2>&1
git -C "$R" -c user.email=t@t -c user.name=t commit -qm "the task a finding decides" >/dev/null 2>&1
fd="$R/_ops/research/panels.md"
honest_fd() { cat > "$fd" <<'FD'
# Should we pay for synthetic panels

**Decides**: [T-AB12CD](../tasks/T-AB12CD-panels.md) · **Status**: settled · **Depth**: deciding
**Answered**: 2026-09-10 · **Recheck when**: a replacement for the grounding study ships

## What we now believe

No, for percentages; yes, for surfacing an angle nobody asked about.
FD
}
honest_fd; ( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" = "0" ] && ok || bad "§17 refused an honest finding"

honest_fd; printf '# transcript\n\nraw\n' > "$R/_ops/research/raw/notes.md"
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" = "0" ] && ok || bad "§17 judged a raw artifact as a finding"

honest_fd; sed -i '' 's/^\*\*Decides\*\*.*· \*\*Status\*\*/**Status**/' "$fd"
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" != "0" ] && ok || bad "a finding with no Decides passed"

honest_fd; sed -i '' 's/a replacement for the grounding study ships/{{a named event}}/' "$fd"
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" != "0" ] && ok || bad "an unanswered Recheck passed"

# Depth was a required field with a guard for one day and was demoted to guidance the same day:
# no measured defect stood behind it, and its standing cross-check read a path no client workspace
# has. Its assertions came out with the gate.

honest_fd; sed -i '' '/^No, for percentages/d' "$fd"
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" != "0" ] && ok || bad "'"'"'settled'"'"' with no conclusion passed"

honest_fd; sed -i '' 's/\*\*Status\*\*: settled/**Status**: open/; /^No, for percentages/d' "$fd"
( cd "$R" && git add -A >/dev/null 2>&1 )
[ "$(grc)" = "0" ] && ok || bad "an OPEN finding with no conclusion was refused"
rm -rf "$R/_ops/research"
( cd "$R" && git add -A >/dev/null 2>&1 )


# ── §20 · a mention of something inside this project is a link ─────────────────────────────
# **Ported from opsinist's §27, 2026-09-18**, with its measurement: one link in a live project's
# whole `_ops/` against twenty-two bare ids, and a graph of identical strings on separate islands.
# Here the tasks live in Multica, so this reads whatever file layer a project keeps — an id is a
# link only where a file carries it, and the rule does not change with the storage.
reset
printf '# A note\n\nSee `_ops/ROADMAP.md`.\n' > "$R/_ops/NOTE.md"
git -C "$R" add -A
case "$(g)" in *"where a link would be an edge"*) ok;; *) bad "§20 said nothing about a backticked internal path";; esac
[ "$(grc)" = 0 ] && ok || bad "§20 refused a backticked path where it should warn — a shipped template's prose names project files on purpose"

reset
printf '# A note\n\nSee [the gone one](GONE.md).\n' > "$R/_ops/NOTE.md"
git -C "$R" add -A
case "$(g)" in *"is not there"*) ok;; *) bad "§20 accepted a link that resolves to nothing";; esac
[ "$(grc)" = 1 ] && ok || bad "a dead link did not refuse the commit"

reset
printf '# A note\n\nSee [it](/Users/somebody/_ops/ROADMAP.md).\n' > "$R/_ops/NOTE.md"
git -C "$R" add -A
case "$(g)" in *"no vault can follow"*) ok;; *) bad "§20 accepted an absolute path as a link";; esac

reset
printf '# A note\n\nSee [it](my file.md).\n' > "$R/_ops/NOTE.md"
git -C "$R" add -A
case "$(g)" in *"unencoded space"*) ok;; *) bad "§20 accepted an unencoded space in a destination";; esac

reset
printf '# A note\n\nSee [the roadmap](ROADMAP.md) and https://example.com/a%%20b.md which is not ours.\n' > "$R/_ops/NOTE.md"
git -C "$R" add -A
[ "$(grc)" = 0 ] && ok || bad "§20 refused a resolving link, or judged an outside URL"

# its mutant: the dead-link half switched off, which is what a phantom node looks like from here
_m="$T/mut-20.sh"
python3 - "$HERE/templates/company-preflight.sh" > "$_m" <<'MUT'
import sys
s = open(sys.argv[1]).read()
a = "                dead.append(target)"
assert s.count(a) == 1, "MUTATION ANCHOR: found %d" % s.count(a)
sys.stdout.write(s.replace(a, "                pass"))
MUT
[ -s "$_m" ] || bad "MUTATION DID NOT APPLY: the dead-link half switched off"
reset
cp "$_m" "$R/_ops/preflight.sh"
printf '# A note\n\nSee [the gone one](GONE.md).\n' > "$R/_ops/NOTE.md"
git -C "$R" add -A
[ "$(grc)" = 0 ] && ok || bad "the suite did not catch the mutant: dead links accepted"
cp "$HERE/templates/company-preflight.sh" "$R/_ops/preflight.sh"
reset; rm -f "$R/_ops/NOTE.md"; git -C "$R" add -A >/dev/null 2>&1

echo "company-guard: $pass passed, $fail failed"
exit "$fail"
