#!/usr/bin/env bash
# Run one review lens over the release diff, by a reader that did not write it.
#
#   bash scripts/lens.sh deletion|adversarial|contradiction|cold-read [<base-ref>]
#
# **The contract asks for four lenses by someone who did not write the text** (AGENTS.md →
# *Cutting a release*), and the author cannot be that someone. This runs each lens as an
# isolated headless session — its own config home, none of the owner's connectors, no memory of
# the session that wrote the corpus — which is the same isolation the eval players run under and
# for the same reason: a reader who watched the text being written reads its intent, not its
# words.
#
# **The honest limit, stated rather than buried:** this is the same model family as the author,
# so it is independent of the *session* and not of the *model*. The corpus's own rule prefers a
# different provider, and a lens pass here does not discharge that — it is the floor, not the
# ceiling.
#
# **It cannot edit the corpus, and that is not the same as read-only.** `Write`, `Edit` and
# `NotebookEdit` are denied, so no lens can change a file it is reviewing. Bash is not denied —
# a lens needs `git diff` and `grep` — and a shell redirect is a write the tool list never sees:
# measured 2026-08-07, the four lenses left **fifteen megabytes of `.tmp_*.txt` scratch** in the
# working tree while this comment claimed read-only. The claim is now accurate and the scratch
# is swept below. A lens reports; the author repairs.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

LENS=${1:?usage: lens.sh deletion|adversarial|contradiction|cold-read [base-ref]}
BASE=${2:-$(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~1)}
HOME_DIR=${EVAL_HOME:-$HOME/.mops-eval-home}
OUT=company/lenses; mkdir -p "$OUT"

case "$LENS" in
  deletion) ASK="**The deletion lens.** For each thing this diff adds, ask what would break if it were simply removed. Name every addition that would cost nothing to delete — a paragraph restating a rule that already has a home, a check that cannot fail, a section that exists because it seemed owed. Quote the line and say what it duplicates. Length is a cost paid by every reader forever." ;;
  adversarial) ASK="**The adversarial lens.** Read this as someone looking for the sentence that parses, links correctly, and is false. Hunt specifically for: a claim about the outside world stated without evidence; a number quoted rather than measured; a capability described as existing when the diff only describes it; a gate said to hold something it cannot hold; an example that no longer matches the rule it demonstrates. Quote each and say why it is wrong or unproven." ;;
  contradiction) ASK="**The contradiction lens.** This corpus states rules in several files on purpose, and they drift apart silently. Find every pair that now disagrees — a rule changed in one file and left standing in another, a word used in two senses, a default stated differently in two places, a table and the prose beside it. Quote both sides and name which is newer." ;;
  cold-read) ASK="**The cold-read lens.** You have never seen this project. Read the changed files as a newcomer whose job depends on understanding them. Where do you lose the thread? Which term is used before it is defined? Which instruction cannot be followed because it assumes something unstated? Which sentence did you have to read twice? Be specific about where you stopped understanding, not about style." ;;
  *) echo "unknown lens: $LENS"; exit 2 ;;
esac

command -v claude >/dev/null || { echo "no claude CLI on PATH"; exit 2; }
# The reviewable surface, not the evidence: transcripts are 45 machine-written JSONL files and
# a lens spending its turns on them reads nothing a human would. Fixtures are situations, not
# claims. Both are excluded, and the prompt says they were.
DIFF=$(mktemp)
git diff "$BASE"...HEAD -- '*.md' 'scripts/*' 'hooks/*' 'templates/*' '.github/*' \
    ':!evals/transcripts/*' ':!evals/fixtures/*' > "$DIFF" 2>/dev/null \
  || git diff "$BASE" -- '*.md' 'scripts/*' 'hooks/*' 'templates/*' > "$DIFF"
lines=$(wc -l < "$DIFF" | tr -d ' ')

PROMPT="You are reviewing a documentation-and-tooling change to a skill called multica-ops,
before it is released. You did not write any of it.

$ASK

The diff is at $DIFF ($lines lines) — the corpus, scripts, hooks, templates and workflows.
Eval transcripts and fixtures are deliberately excluded: they are evidence and situations, not
claims. The full repository is the working directory.

**Work in this order, and budget your turns** — the ceiling is real and a lens that runs out
mid-read reports nothing at all, which scores the same as a lens nobody ran: read the diff file
first and completely; then open **only** the files you need to confirm a specific suspicion;
then write the report. Do not survey the repository. Six well-evidenced findings beat forty
gestures, and one confirmed contradiction is worth more than a page of things that look odd. Report findings as a numbered list, each with the file, the quoted
text, and what is wrong with it. **If a lens finds nothing, say so explicitly** — a silent lens
is indistinguishable from one that was never run. Do not edit anything."

CLAUDE_CONFIG_DIR="$HOME_DIR" claude -p "$PROMPT" \
  --model "${LENS_MODEL:-claude-sonnet-4-6}" \
  --max-turns "${LENS_TURNS:-150}" \
  --permission-mode acceptEdits \
  --disallowedTools "Write" "Edit" "NotebookEdit" \
  --mcp-config '{"mcpServers":{}}' --strict-mcp-config \
  > "$OUT/$LENS.md" 2>"$OUT/$LENS.err"
rc=$?
rm -f "$DIFF"
# Whatever the lens redirected into the tree while working. Named explicitly rather than
# wildcarded over the repo: a cleanup that guesses is how a review deletes someone's work.
rm -f .tmp_*.txt
echo "$OUT/$LENS.md (rc=$rc, $(wc -l < "$OUT/$LENS.md" | tr -d ' ') lines)"
exit $rc
