#!/usr/bin/env bash
# Tests for scripts/map-blocks.py. The load-bearing assertion is that a generator rewrites ONLY
# between its markers — a script that reformats a document it does not own is one nobody runs.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
M="$PWD/scripts/map-blocks.py"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { if [ "$2" = "$3" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 (want rc=$2, got rc=$3)"; fi; }
has() { if grep -q -- "$2" "$3"; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 — '$2' missing"; fi; }
no()  { if grep -q -- "$2" "$3"; then fail=$((fail+1)); echo "FAIL: $1 — '$2' should be absent"; else pass=$((pass+1)); fi; }

cat > "$T/issues.json" <<'JSON'
[
 {"key":"TES-1","status":"in_progress","metadata":{"touches":"Library,Player"}},
 {"key":"TES-2","status":"todo","metadata":{"touches":"Player"}},
 {"key":"TES-3","status":"done","metadata":{"touches":"Library"}},
 {"key":"TES-4","status":"todo","metadata":{"touches":"Ghost"}},
 {"key":"TES-5","status":"todo","metadata":{}}
]
JSON

cat > "$T/MAP.md" <<'MD'
# Product map

## The things

- **Library** — everything the user owns
  <!-- touched-by: Library -->
  <!-- /touched-by -->
- **Player** — one recording
  <!-- touched-by: Player -->
  <!-- /touched-by -->
- **Search** — nobody is on this one
  <!-- touched-by: Search -->
  <!-- /touched-by -->

## Not mapped yet

The sharing flow. THIS PROSE MUST SURVIVE VERBATIM.
MD

python3 "$M" "$T/MAP.md" --from "$T/issues.json" > "$T/o1" 2>&1; ok "fills the blocks" 0 $?
has "a live issue is listed"            "TES-1 (in_progress)" "$T/MAP.md"
has "a second live issue on one node"   "TES-2 (todo)"        "$T/MAP.md"
has "contention is stated in the block" "contended"           "$T/MAP.md"
has "and reported on stdout"            "contended: Player"   "$T/o1"
no  "a done issue is not live"          "TES-3"               "$T/MAP.md"
no  "an issue with no touches is absent" "TES-5"              "$T/MAP.md"
has "an empty node says so"             "none live"           "$T/MAP.md"
has "a node the map lacks is reported"  "Ghost"               "$T/o1"
# The whole point: nothing outside the markers moved.
has "prose outside the markers survives" "THIS PROSE MUST SURVIVE VERBATIM" "$T/MAP.md"
has "the node's own line survives"       "everything the user owns"         "$T/MAP.md"

# Idempotent, and --check agrees once it is current.
cp "$T/MAP.md" "$T/MAP.once"
python3 "$M" "$T/MAP.md" --from "$T/issues.json" > /dev/null 2>&1
diff -q "$T/MAP.once" "$T/MAP.md" > /dev/null; ok "a second run changes nothing" 0 $?
python3 "$M" "$T/MAP.md" --from "$T/issues.json" --check > "$T/o2" 2>&1; ok "--check passes when current" 0 $?

# --check must FAIL when the board moved under a stale map.
cat > "$T/issues2.json" <<'JSON'
[{"key":"TES-9","status":"todo","metadata":{"touches":"Search"}}]
JSON
python3 "$M" "$T/MAP.md" --from "$T/issues2.json" --check > "$T/o3" 2>&1; ok "--check fails when stale" 1 $?
has "and says so" "out of date" "$T/o3"
grep -q "TES-9" "$T/MAP.md" && { fail=$((fail+1)); echo "FAIL: --check wrote to the file"; } || pass=$((pass+1))

# A map with no markers is a no-op, not an error.
printf '# Map\n\nNo markers here.\n' > "$T/bare.md"
python3 "$M" "$T/bare.md" --from "$T/issues.json" > "$T/o4" 2>&1; ok "a map with no markers is fine" 0 $?
has "and says what to do" "no \`touched-by\` markers" "$T/o4"

python3 "$M" "$T/nope.md" --from "$T/issues.json" > "$T/o5" 2>&1; ok "a missing map is not an error" 0 $?

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
