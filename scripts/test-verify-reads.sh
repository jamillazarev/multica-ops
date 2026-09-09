#!/usr/bin/env bash
# `--verify-reads` shown refusing each mutant and passing its honest twin.
#
# **A "must not fire" assertion is paired with a "must fire" twin on the same fixture**, because
# a checker that reads nothing and a checker that finds nothing wrong return the identical
# silence (`facts.md` 254). Every mutant below asserts that the mutation applied before it runs:
# a patch that silently missed its anchor looks exactly like a surviving mutant.
set -u

PY=${PY:-python3}
SCRIPT=$(cd "$(dirname "$0")" && pwd)/fetch-source.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# The honest twin: a two-entry register whose pair points both ways.
twin() {
  cat > "$1" <<'EOF'
# Sources register

### alpha · A study
- **Citation:** A.
- **Check-date:** 2026-09-10
- **Reads against:** `beta` — measures a different population
- **Cited-by:** x.md

### beta · Another study
- **Citation:** B.
- **Check-date:** 2026-09-10
- **Reads against:** `alpha` — the same tension from the other side
- **Cited-by:** x.md
EOF
}

run() { ( cd "$T" && "$PY" "$SCRIPT" --verify-reads >out.txt 2>&1; echo $? ); }

# ── the twin must pass, or every refusal below is meaningless ────────────────────────────────
twin "$T/sources.md"; mv "$T/sources.md" "$T/SOURCES.md"
mkdir -p "$T/sources" && mv "$T/SOURCES.md" "$T/sources/SOURCES.md"
[ "$(run)" = "0" ] && ok || bad "the honest twin was refused — the checker refuses everything"
grep -q "symmetric" "$T/out.txt" && ok || bad "a clean run did not say what it checked"

# ── mutant 1 · a one-way pair ────────────────────────────────────────────────────────────────
twin "$T/sources/SOURCES.md"
before=$(grep -c 'Reads against' "$T/sources/SOURCES.md")
sed -i '' 's/^- \*\*Reads against:\*\* `alpha`.*$/- **Reads against:** `none found`/' "$T/sources/SOURCES.md"
grep -q 'none found' "$T/sources/SOURCES.md" || bad "MUTATION DID NOT APPLY (one-way) — the assertion below proves nothing"
[ "$(run)" = "1" ] && ok || bad "a one-way pair was accepted"
grep -q "one-way pair" "$T/out.txt" && ok || bad "the refusal did not name the one-way pair"

# ── mutant 2 · a dangling id ─────────────────────────────────────────────────────────────────
twin "$T/sources/SOURCES.md"
sed -i '' 's/`beta` — measures/`gamma` — measures/' "$T/sources/SOURCES.md"
grep -q '`gamma`' "$T/sources/SOURCES.md" || bad "MUTATION DID NOT APPLY (dangling)"
[ "$(run)" = "1" ] && ok || bad "a pointer at an entry that is not here was accepted"
grep -q "not an entry here" "$T/out.txt" && ok || bad "the refusal did not name the dangling id"

# ── mutant 3 · the field missing entirely — silence must not read as "none found" ─────────────
twin "$T/sources/SOURCES.md"
sed -i '' '/^- \*\*Reads against:\*\* `alpha`/d' "$T/sources/SOURCES.md"
[ "$(grep -c 'Reads against' "$T/sources/SOURCES.md")" -lt "$before" ] || bad "MUTATION DID NOT APPLY (missing field)"
[ "$(run)" = "1" ] && ok || bad "an entry with no Reads-against line was accepted"
grep -q "silence is not" "$T/out.txt" && ok || bad "the refusal did not say why silence is not an answer"

# ── the twin's OTHER legal values must still pass — a checker that refuses `not checked`
#    would push everyone to write `none found`, which is the lie the field exists to prevent ──
twin "$T/sources/SOURCES.md"
sed -i '' 's/^- \*\*Reads against:\*\* `alpha`.*$/- **Reads against:** `not checked`/' "$T/sources/SOURCES.md"
sed -i '' 's/^- \*\*Reads against:\*\* `beta`.*$/- **Reads against:** `none found`/' "$T/sources/SOURCES.md"
[ "$(run)" = "0" ] && ok || bad "'not checked' or 'none found' was refused — the field would become a lie"

echo "verify-reads: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
