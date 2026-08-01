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

# The guide's own version line — the failure this hook was extended to catch. Measured
# 2026-08-01 at N=3: no run bumped it, and two wrote a log line, which is what silences the
# log check. Each rule must refuse the stale guide AND stay quiet on the honest twin.
G="$T/g"; mkdir -p "$G"; git -C "$G" init -q
printf '# Upgrades\n\n- 2026-08-01 · %s · SHA c3d4 · applied\n' "$V" > "$G/UPGRADES.md"
printf 'Operated by multica-ops **0.0.1**.\n' > "$G/CLAUDE.md"
say "log current, guide stale → speaks"          "the guide is the one every session reads" "$G"
printf 'Operated by multica-ops **%s**.\n' "$V" > "$G/CLAUDE.md"
say "log current, guide agrees → silent"         "EMPTY" "$G"
printf 'Operated by multica-ops.\n' > "$G/CLAUDE.md"
say "guide states no version → silent, not guessed" "EMPTY" "$G"
printf 'Operated by multica-ops **%s**.\nWe once ran 0.0.1 and it broke.\n' "$V" > "$G/CLAUDE.md"
say "prose naming an old version is not a claim" "EMPTY" "$G"
printf '# Upgrades\n\n- 2026-07-24 · 0.2.0 · SHA a1b2 · applied\n' > "$G/UPGRADES.md"
printf 'Operated by multica-ops **0.0.1**.\n' > "$G/CLAUDE.md"
say "both stale → one message naming both"       "bump the version line" "$G"
printf 'Operated by multica-ops **0.0.1**.\n' > "$G/AGENTS.md"; rm "$G/CLAUDE.md"
say "the guide may be AGENTS.md"                 "AGENTS.md" "$G"


# A record's grammar is a paragraph. Measured 2026-08-02: a correct entry wrapped over four
# lines was read as absent, which would have nagged forever about a migration that happened.
W2="$T/wrap"; mkdir -p "$W2"; git -C "$W2" init -q
printf 'Operated by multica-ops **%s**.\n' "$V" > "$W2/CLAUDE.md"
printf '# Upgrades\n\n- 2026-08-02 · multica-ops %s · pre-upgrade SHA abc\n  impact: guide version line only.\n  Outcome: applied.\n' "$V" > "$W2/UPGRADES.md"
say "a wrapped entry counts as a line"           "EMPTY" "$W2"
printf '# Upgrades\n\n- 2026-08-02 · multica-ops %s · pre-upgrade SHA abc\n  impact: none yet.\n\n- 2026-07-01 · 0.1.0 · applied\n' "$V" > "$W2/UPGRADES.md"
say "an entry with no outcome word still speaks" "no line for version" "$W2"

say "outside a git repo → silent"                "EMPTY" "$T"
printf 'not json' | python3 "$H" >/dev/null 2>&1 && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: broken stdin must fail open"; }
printf '{"hook_event_name":"Stop","cwd":"%s"}' "$W" | python3 "$H" >/dev/null 2>&1 && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: a non-SessionStart event must pass through"; }

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
