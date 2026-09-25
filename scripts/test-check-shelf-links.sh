#!/usr/bin/env bash
# check-shelf-links.py — every project on the shelf carries a link — shown on a throwaway shelf
# holding every shape it must PASS (a linked entry, a cross-reference to one, a method on the
# not-a-project list, a licence in bold, a command in backticks, a name in an explaining column,
# a table that is not a shelf) and every shape it must REFUSE (a bold name, a plain name, a name
# after a `/`, a name in a four-column shelf row).
#
# **Five code mutants** against the assertions they should break, each asserting it changed the
# file first — a mutation that never applied reads exactly like a toothless test.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
S="$HERE/check-shelf-links.py"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(grep -cF -- "$1" "$T/report")" -gt 0 ]; }    # grep -c: no pipe can eat it

honest() {
  rm -rf "$T/w"; mkdir -p "$T/w"; cd "$T/w"
  cat > shelf.md <<'EOF'
# A shelf

## Services by need

| Need | Default | What you'd use it for |
|---|---|---|
| **Linked** | **[Foo](https://foo.example)** (MIT) · [Qux](https://qux.example) | an Unlinked Explainer in the third column is not an entry |
| **Cross-reference** | Foo (above) · **[Bar](https://bar.example)** | the entry was linked where it stands |
| **Method** | **AARRR** — funnel metrics · **[Baz](https://baz.example)** | a method, not a project |
| **Licence** | **[Quux](https://quux.example)** (**AGPL-3.0**) · **MIT** for the SDK | bold licence text |
| **Command** | `npm audit` · [osv](https://osv.example) | a command in backticks |

## Picking a tool

| Tier | What it means |
|---|---|
| **one** | Plain Name in a table that is not a shelf |

## Evidence

| Need | Anchor | Why this one | Free tier |
|---|---|---|---|
| **Four columns** | **[Corge](https://corge.example)** | the sibling's shape | ✅ |
EOF
}

run() { python3 "${1:-$S}" shelf.md > "$T/report" 2>&1; RC=$?; }

# — the honest shelf passes, and says so
honest; run
[ "$RC" = 0 ] && ok || bad "the honest shelf was refused (rc=$RC): $(head -2 "$T/report")"
said "carries a link" && ok || bad "a clean run did not say what it checked"

# — each shape it must refuse, with its twin that must pass
refuse() {   # $1 label · $2 the row · $3 the name the report must carry · $4 the linked twin
  honest; printf '%s\n' "$2" >> shelf.md; run
  [ "$RC" = 1 ] && said "'$3' is on the shelf without a link" && ok \
    || bad "[$1] not refused (rc=$RC): $(head -2 "$T/report")"
  honest; printf '%s\n' "$4" >> shelf.md; run
  [ "$RC" = 0 ] && ok || bad "[$1] its linked twin was refused (rc=$RC): $(head -2 "$T/report")"
}
# appended rows land in the Evidence table — the four-column shelf, the sibling's shape
refuse "a bold name" '| **New** | **Widget** (MIT, read 2026-09-25) | a tool | ✅ |' Widget \
  '| **New** | **[Widget](https://widget.example)** (MIT, read 2026-09-25) | a tool | ✅ |'
refuse "a plain name" '| **New** | Gadget Pro (free tier) | a tool | ✅ |' "Gadget Pro" \
  '| **New** | [Gadget Pro](https://gadget.example) (free tier) | a tool | ✅ |'
refuse "a name after a slash" '| **New** | Foo/Gizmo (the pair) | a tool | ✅ |' Gizmo \
  '| **New** | Foo/Gizmo (the pair) · [Gizmo](https://gizmo.example) | a tool | ✅ |'
refuse "a name before a colon" '| **New** | **Thingy**: its built-ins | a tool | ✅ |' Thingy \
  '| **New** | **[Thingy](https://thingy.example)**: its built-ins | a tool | ✅ |'

# — the line number points at the row
honest; printf '%s\n' '| **New** | **Widget** (MIT) | a tool | ✅ |' >> shelf.md; run
n=$(grep -c '' shelf.md)
said "shelf.md:$n:" && ok || bad "the finding did not name line $n: $(head -1 "$T/report")"

# — no shelf at all is its own answer, not a pass
rm -rf "$T/e"; mkdir -p "$T/e"; cd "$T/e"; python3 "$S" > "$T/report" 2>&1; RC=$?
[ "$RC" = 2 ] && ok || bad "a directory with no shelf exited $RC, not 2"

mutant() {   # $1 what it breaks · $2 text · $3 its mutant · $4 the row appended (or '') · $5 the rc it must now give
  cp "$S" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  honest; [ -n "$4" ] && printf '%s\n' "$4" >> shelf.md; run "$T/mut.py"
  [ "$RC" = "$5" ] && ok || bad "the suite did not catch the mutant: $1 (rc=$RC)"
}
mutant "cross-references forgotten" \
  'linked = {norm(m.group(1)) for l in lines for m in LINK.finditer(l)}' 'linked = set()' '' 1
mutant "the not-a-project list ignored" \
  'if not h or h in NOT_PROJECTS or len(h) > 40:' 'if not h or len(h) > 40:' '' 1
mutant "every column read as a shelf column" \
  'cols = [k for k, c in enumerate(cells) if c in SHELF_COLUMNS] \' \
  'cols = [k for k, c in enumerate(cells)] \' '' 1
mutant "notes read as part of the name" 'c = strip_parens(c)' 'c = c' '' 1
mutant "a finding that exits clean" '        return 1
    print(f"every project' '        return 0
    print(f"every project' '| **New** | **Widget** (MIT) | a tool | ✅ |' 0

echo "check-shelf-links: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
