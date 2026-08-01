#!/usr/bin/env bash
# Mutation tests for hooks/migration-state.py — each rule shown speaking on the mutant and
# silent on its honest twin, or the hook is a sentence.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
H=hooks/migration-state.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
V=$(grep -m1 '^version:' skills/mops/SKILL.md | awk '{print $2}')
pass=0; fail=0
ss() { printf '{"hook_event_name":"SessionStart","cwd":"%s"}' "$1"; }
say() { # name want-substring-or-EMPTY dir
  local name=$1 want=$2 dir=$3 got
  got=$(printf '%s' "$(ss "$dir")" | python3 "$H" 2>/dev/null)
  if { [ "$want" = "EMPTY" ] && [ -z "$got" ]; } || { [ "$want" != "EMPTY" ] && printf '%s' "$got" | grep -q "$want"; }; then
    pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $name (got: ${got:-<empty>})"; fi
}

W="$T/ws"; mkdir -p "$W"; git -C "$W" init -q
say "not a workspace we operate → silent"        "EMPTY" "$W"
printf 'Operated by multica-ops.\n' > "$W/CLAUDE.md"
say "our guide, no UPGRADES.md → speaks"         "no \`UPGRADES.md\`" "$W"
printf '# Upgrades\n\n- 2026-07-24 · 0.2.0 · SHA a1b2 · applied\n' > "$W/UPGRADES.md"
say "log misses this version → speaks"           "no line for version" "$W"
printf -- "- 2026-08-01 · %s · SHA c3d4 · nothing-required\n" "$V" >> "$W/UPGRADES.md"
say "log names this version → silent"            "EMPTY" "$W"
printf '# Upgrades\n\n- 2026-08-01 · %s · SHA c3d4 · noted\n' "$V" > "$W/UPGRADES.md"
say "version present but no outcome word → speaks" "no line for version" "$W"
say "outside a git repo → silent"                "EMPTY" "$T"
printf 'not json' | python3 "$H" >/dev/null 2>&1 && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: broken stdin must fail open"; }
printf '{"hook_event_name":"Stop","cwd":"%s"}' "$W" | python3 "$H" >/dev/null 2>&1 && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: a non-SessionStart event must pass through"; }

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
