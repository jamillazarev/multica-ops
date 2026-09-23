#!/usr/bin/env bash
# §19 of the company guard — `mise.toml` and the register held to each other — shown refusing each
# mutant and passing its honest twin, in a throwaway company repo. Ported from opsinist's suite of
# the same name, without its `.mcp.json` half: here an MCP server is carried by an agent's
# `mcp_config`, which no commit can see.
#
# **The guard runs on whatever `python3` the machine has, so this suite runs it twice**: once on the
# one on PATH, and once with PATH pointed at the system interpreter (`/usr/bin/python3`, 3.9 on a Mac
# with no Homebrew). §19 parses `mise.toml` by hand precisely so it never imports `tomllib`, which is
# 3.11+; the second pass is the only thing that can show that claim holds.
set -u
cd "$(dirname "$0")/.." || exit 1
HERE=$(pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
R="$T/co"; mkdir -p "$R/_ops"
cp "$HERE/templates/company-preflight.sh" "$R/_ops/preflight.sh"
for f in ROADMAP TEAM DECISIONS LATER; do printf '# %s\n' "$f" > "$R/_ops/$f.md"; done
printf '# Tooling\n' > "$R/_ops/TOOLING.md"
_gv=$(sed -n 's/^# guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$HERE/templates/company-preflight.sh" | head -1)
printf '# Co\n\n**Operated by** multica-ops **%s**\n' "$_gv" > "$R/CLAUDE.md"
cd "$R" && git init -q . && git config user.email t@f.t && git config user.name T
git add -A && git commit -qm fixture

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# The register: one table whose *Wired how* column is found by its header, as the guard finds it.
reg() {
  { printf '# Tooling\n\n| Tool | What it'"'"'s for | Replaces | Licence | Access | Wired how | Checked |\n'
    printf '|---|---|---|---|---|---|---|\n'
    for r in "$@"; do printf '%s\n' "$r"; done; } > _ops/TOOLING.md
}
row() { printf '| %s | a reason | we had none | MIT · read 2026-09-11 | none | %s | 2026-09-11 |' "$1" "$2"; }

# **And the register as this repository's own template ships it.** The column was widened to
# *Wired how · what it ships* while the check still matched its header by equality, so a project
# that copied the template and registered correctly was told it had no row. The sibling's copy of
# the same rule was repaired and this one was not — which is what a shared rule living in two files
# does when only one is touched (an adversarial lens, 2026-09-18). The fixture below is the
# template's own header, so the two cannot drift apart again unnoticed.
reg_shipped() {
  { printf '# Tooling\n\n%s\n' \
      "| Tool | What it's for | **Replaces** | Access & where the secret lives | Wired how · **what it ships** | **Gone when** | Checked |"
    printf '|---|---|---|---|---|---|---|\n'
    for r in "$@"; do printf '%s\n' "$r"; done; } > _ops/TOOLING.md
}
row_shipped() {
  printf '| %s | a reason | we had none | none | %s · CLI only — checked 2026-09-18 | we stop shipping it | 2026-09-18 |' "$1" "$2"
}

run() { git add -A; OUT=$(bash _ops/preflight.sh 2>&1); RC=$?; }
said() { [ "$(printf '%s' "$OUT" | grep -c -- "$1")" -gt 0 ]; }   # grep -c: no pipe can eat it

suite() {
  # the twin: a runtime, and one system package spelled per OS — all three lines meet ONE row
  printf '[tools]\npython = "3.12"\n"github:BeaconBay/ck" = "latest"\n\n[tools.node]\nversion = "22"\n\n'  > mise.toml
  printf '[bootstrap.packages]\n"brew:ffmpeg" = "latest"\n"apt:ffmpeg" = { os = "linux" }\n' >> mise.toml
  printf '"winget:Gyan.FFmpeg" = { os = "windows" }  # the Windows id is not the name\n' >> mise.toml
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')"
  run; [ "$RC" = 0 ] && ok || bad "[$1] the honest mise twin was refused: $OUT"

  # a tool with no row
  printf '"npm:@anthropic-ai/claude-code" = "latest"\n' >> mise.toml
  run; [ "$RC" = 1 ] && said 'claude-code' && ok || bad "[$1] a mise tool with no register row passed"

  # a row naming nothing mise installs
  sed -i '' '/claude-code/d' mise.toml
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" \
      "$(row ffmpeg '`mise.toml`')" "$(row imagemagick '`mise.toml`')"
  run; [ "$RC" = 1 ] && said 'row `imagemagick`' && ok || bad "[$1] a register row naming nothing in mise.toml passed"

  # names match EXACTLY, never as a substring: `ck` must not vouch for `brew:package-stack`
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')"
  printf '"brew:package-stack" = "latest"\n' >> mise.toml
  run; [ "$RC" = 1 ] && said 'package-stack' && ok || bad "[$1] a row \`ck\` vouched for \`package-stack\` by substring"
  sed -i '' '/package-stack/d' mise.toml

  # a `#` comment and a subtable are not entries — the twin must still be clean after the edits
  run; [ "$RC" = 0 ] && ok || bad "[$1] the restored mise twin was refused: $OUT"

  # a key is a path: the same entries in dotted keys, and a quoted word in a comment is not an entry
  reg "$(row python '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')"
  printf 'tools.python = "3.12"\ntools."github:BeaconBay/ck" = "latest"   # "quoted" words in a comment\n' > mise.toml
  printf 'bootstrap.packages."brew:ffmpeg" = "latest"\n' >> mise.toml
  run; [ "$RC" = 0 ] && ok || bad "[$1] a mise.toml in dotted keys, each entry with its row, was refused: $OUT"
  printf 'tools.jq = "1.7"\n' >> mise.toml
  run; [ "$RC" = 1 ] && said '`jq`' && ok || bad "[$1] a tool declared as a dotted key, with no row, passed"

  # an MCP row wired by an agent's mcp_config is not this section's business
  printf 'tools.python = "3.12"\ntools.node = "22"\ntools."github:BeaconBay/ck" = "latest"\nbootstrap.packages."brew:ffmpeg" = "latest"\n' > mise.toml
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')" \
      "$(row sentry '`mcp_config` on the web agent')"
  run; [ "$RC" = 0 ] && ok || bad "[$1] a row wired by an agent's mcp_config was refused: $OUT"

  # the shipped header finds the same column — and the column still does its work under it
  printf 'tools.python = "3.12"\n' > mise.toml
  reg_shipped "$(row_shipped python '`mise.toml`')"
  run; [ "$RC" = 0 ] && ok || bad "[$1] the header this repository's own template ships was not found: $OUT"
  printf 'tools.jq = "1.7"\n' >> mise.toml
  run; [ "$RC" = 1 ] && said '`jq`' && ok || bad "[$1] under the shipped header, a tool with no row passed: $OUT"

  # a column a project adds before the real one must not win it (2026-09-18, 2026-09-23)
  printf 'tools.python = "3.12"\n' > mise.toml
  for decoy in "Wired how much budget" "Wired How-To"; do
    { printf '# Tooling\n\n| Tool | %s | What it'"'"'s for | **Replaces** | Access & where the secret lives | Wired how · **what it ships** | **Gone when** | Checked |\n' "$decoy"
      printf '|---|---|---|---|---|---|---|---|\n'
      printf '| python | n/a | a reason | we had none | none | `mise.toml` · CLI only | we stop shipping it | 2026-09-18 |\n'
    } > _ops/TOOLING.md
    run; [ "$RC" = 0 ] && ok || bad "[$1] the decoy column \`$decoy\` won the lookup: $OUT"
  done
  # …and a header that only starts like the column is not the column, even alone (2026-09-23)
  { printf '# Tooling\n\n| Tool | What it'"'"'s for | Replaces | Access | Wired How-To | Gone when | Checked |\n'
    printf '|---|---|---|---|---|---|---|\n'
    printf '| python | a reason | we had none | none | see the wiki: mise.toml setup | never | 2026-09-23 |\n'
  } > _ops/TOOLING.md
  run; [ "$RC" = 1 ] && said 'Wired How-To' && ok || bad "[$1] a lone near-miss column was read as the wiring, or refused unnamed: $OUT"

  git rm -q --cached mise.toml; rm -f mise.toml; printf '# Tooling\n' > _ops/TOOLING.md; git add -A
  git commit -qm clean-mise >/dev/null 2>&1 || true
}

suite "python3 on PATH"

# the same suite on the system interpreter, if this machine has one that is not the PATH one
SYS=/usr/bin/python3
if [ -x "$SYS" ] && [ "$("$SYS" -c 'import sys; print(sys.version_info >= (3, 11))')" = "False" ]; then
  mkdir -p "$T/.shim" && ln -sf "$SYS" "$T/.shim/python3"
  PATH="$T/.shim:$PATH" python3 -c 'import sys; assert sys.version_info < (3, 11)' \
    || bad "the shim did not put the system python first — the second pass would prove nothing"
  PATH="$T/.shim:$PATH" suite "system $("$SYS" --version 2>&1)"
fi

# a check that stops before its end refuses — it does not pass the part it never read
python3 - "_ops/preflight.sh" <<'PY' || bad "MUTATION DID NOT APPLY: the native check made to crash"
import sys
p = sys.argv[1]; s = open(p).read(); a = "import json, re, subprocess\n"
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, a + "raise SystemExit(3)\n"))
PY
printf '[tools]\npython = "3.12"\n' > mise.toml; reg "$(row python '`mise.toml`')"
run; [ "$RC" = 1 ] && said 'stopped before its end' && ok || bad "a check that crashed let the commit through — it failed open: $OUT"
cp "$HERE/templates/company-preflight.sh" _ops/preflight.sh

echo "native-register: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
