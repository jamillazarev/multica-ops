#!/usr/bin/env bash
# Every published release's notes, against the changelog entry it was cut from.
#
# **A released entry is frozen, and the one permitted change is a marked correction** — that is
# `preflight.sh` §1a-bis, and it is a form. What had no form is the other half: a correction lands
# in `CHANGELOG.md`, reaches the site at the next regeneration, and **never reaches the GitHub
# Release**, whose notes were written once at publish time. So the file admits an error and the
# page most people actually read goes on repeating it.
#
# The measurement, the count and the date live in one home — the sibling methodology's release
# ritual, and this repository's own count is in its changelog: **four of its releases had drifted**.
# This header carried "three across the two repositories" for a week: an early count by
# correction-block, superseded once whole entries were compared. The sibling's copy of this file
# names that divergence as the argument against restating, and **the fix reached one of two
# byte-identical copies** — which is the same argument, made twice.
#
# This is a REPORT, not a gate: it needs the network and `gh`, so it cannot live in preflight,
# which must run offline. It prints the command that closes each gap; publishing is outward and
# stays the owner's hand.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# `--emit <dir>` writes each drifted entry to a file and prints the one command that closes the
# gap. It writes nothing outward: publishing a release is the owner's hand, every time.
# `--emit <dir>` is accepted in ANY position: it shipped recognised only as `$1`, so the natural
# `check-releases.sh owner/name --emit <dir>` silently did nothing, which is the shape of failure
# this whole release is about.
EMIT=""; ARGS=""
while [ "$#" -gt 0 ]; do
  if [ "$1" = "--emit" ]; then
    EMIT=${2:-}
    [ -n "$EMIT" ] || { echo "--emit needs a directory"; exit 2; }
    mkdir -p "$EMIT" || exit 2
    shift 2
  else
    ARGS="$1"; shift
  fi
done
set -- ${ARGS:+"$ARGS"}

REPO=${1:-}
if [ -z "$REPO" ]; then
  REPO=$(git remote get-url origin 2>/dev/null \
    | sed -E 's#^git@github\.com:##; s#^https://github\.com/##; s#\.git$##')
fi
[ -n "$REPO" ] || { echo "cannot tell which GitHub repository this is; pass owner/name"; exit 2; }
command -v gh >/dev/null 2>&1 || { echo "gh is not on PATH — this check needs it"; exit 2; }

CH=CHANGELOG.md
[ -f "$CH" ] || { echo "no $CH here"; exit 2; }

# One entry, with its `## X.Y.Z — DATE` heading collapsed to the bare italic date — which is the
# exact shape the release ritual publishes, so the comparison is like against like.
entry() {
  awk -v v="$1" '
    $0 ~ "^## " v " " { f = 1
      sub(/^## [0-9.]+ — /, ""); print "*" $0 "*"; next }
    /^## [0-9]/ { f = 0 }
    f { print }' "$CH"
}

# **A listing that failed is not a listing of nothing.** `gh release list`'s exit status was
# discarded, so no auth, the wrong repository or no network read as *"0 releases checked, every one
# matches its entry"* — a green report on a check that did not happen, which is `facts.md` 254
# shipped in the same three commits that quote it. Measured 2026-09-05 with a stub `gh`.
TAGS=$(gh release list --repo "$REPO" --limit 40 --json tagName -q '.[].tagName' 2>/dev/null); _rc=$?
if [ "$_rc" -ne 0 ]; then
  echo "  gh could not list releases for $REPO (exit $_rc) — not authenticated, wrong repository,"
  echo "  or offline. This is not a clean result; nothing was compared."
  exit 2
fi
if [ -z "$TAGS" ]; then
  echo "  $REPO has no published releases. Nothing to compare — say that, do not call it clean."
  exit 0
fi

drift=0; checked=0
while IFS= read -r tag; do
  [ -n "$tag" ] || continue
  v=${tag#v}
  e=$(entry "$v")
  # counted BEFORE the entry lookup, or a release the changelog does not describe bumps `drift`
  # alone and the summary reads "3 of 0" — measured 2026-09-05.
  checked=$((checked+1))
  [ -n "$e" ] || { printf '  %-10s no entry named %s in %s — the release exists and the changelog does not describe it\n' "$tag" "$v" "$CH"; drift=$((drift+1)); continue; }
  b=$(gh release view "$tag" --repo "$REPO" --json body -q .body 2>/dev/null | tr -d '\r')
  # **Blank-line and trailing-space differences are not drift**, and saying they are is how a
  # check gets ignored: the first version of this flagged 23 of 35 releases, of which 3 were real
  # — every other one differed by a single empty line after the date. Both sides are squeezed to
  # non-blank, right-trimmed lines before they are compared, so what remains is content.
  norm() { sed -e 's/[[:space:]]*$//' | grep -v '^$'; }
  if [ "$(printf '%s\n' "$e" | norm)" = "$(printf '%s\n' "$b" | norm)" ]; then
    continue
  fi
  drift=$((drift+1))
  el=$(printf '%s' "$e" | grep -c '' || true); bl=$(printf '%s' "$b" | grep -c '' || true)
  first=$(diff <(printf '%s\n' "$e" | norm) <(printf '%s\n' "$b" | norm) 2>/dev/null \
          | grep -m1 '^[<>]' | cut -c1-90)
  printf '  %-10s DRIFTED — entry %s lines, published %s. First difference: %s\n' "$tag" "$el" "$bl" "${first:-?}"
  if [ -n "$EMIT" ]; then
    printf '%s\n' "$e" > "$EMIT/$tag.md"
    printf '             gh release edit %s --repo %s --notes-file %s/%s.md\n' "$tag" "$REPO" "$EMIT" "$tag"
  else
    printf '             fix: re-run with --emit <dir>, then gh release edit %s --notes-file <dir>/%s.md\n' "$tag" "$tag"
  fi
done < <(printf '%s\n' "$TAGS")

echo
if [ "$drift" -eq 0 ]; then
  echo "RESULT: $checked release(s) checked, every one matches its entry."
else
  echo "RESULT: $drift of $checked release(s) no longer match their entry. A correction that never"
  echo "        reached the release leaves the page most readers see still carrying the error."
fi
exit 0
