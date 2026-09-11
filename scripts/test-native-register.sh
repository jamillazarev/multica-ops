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

  # an MCP row wired by an agent's mcp_config is not this section's business
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')" \
      "$(row sentry '`mcp_config` on the web agent')"
  run; [ "$RC" = 0 ] && ok || bad "[$1] a row wired by an agent's mcp_config was refused: $OUT"
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

echo "native-register: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
