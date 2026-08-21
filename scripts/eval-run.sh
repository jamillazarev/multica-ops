#!/usr/bin/env bash
# Run one eval scenario's player turn, isolated, and capture the transcript.
#
#   bash scripts/eval-run.sh <scenario-id> <run-no> "<the user's words>"
#
# **Isolation is the whole point, and it has three parts** — a round that skips any of them
# produces a number that looks like a result and measures something else:
#
#   1 · **a config dir of its own** — measured 2026-08-02: run under the author's own config, a
#       player answered *"what's next?"* by opening a DIFFERENT operations skill installed on
#       the same machine and running that one's flow. A shared config is how another plugin
#       gets a vote.
#   2 · **the corpus under test, copied** — so a mid-round edit cannot reach a run already
#       counted. The skill is frozen for a round; this makes that mechanical.
#   3 · **the test workspace, passed explicitly** — never the profile default, which can be
#       switched between runs by anything. `MULTICA_WORKSPACE_ID` scopes each call without
#       touching the owner's own default, where `workspace switch` would.
#   4 · **the skill's own corpus readable** — `--add-dir "$BOX/plugin"`. Measured 2026-08-07 and
#       the most consequential of these: the always-loaded core arrives as the skill body, but
#       every companion — FLOWS, PLAYBOOKS, BOOTSTRAP, REFERENCE, `sources/SOURCES.md` — sits
#       outside the working directory and `Read` on it was **denied**. Rounds before this fix
#       measured a skill that could not open its own files, which quietly confounds every
#       failure that depends on one: scenario 15 never opened the sources register because it
#       *could not*, not because it did not think to.
#   5 · **no MCP servers but the ones named here** — `--strict-mcp-config` with an empty set.
#       A config dir of its own is not enough: measured 2026-08-07 on scenario 19, the player
#       had 63 tools and reached the owner's **claude.ai Linear connector** through ToolSearch,
#       asking it for the issues instead of asking Multica. Two failures in one — the run
#       measured a tracker the scenario is not about, and a player one tier below the floor was
#       one approval away from reading the owner's real backlog.
#
# The player is never shown the rubric and gets only what a user would actually say. Nothing
# here judges: judging reads the transcript afterwards, by someone who did not produce it.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
ROOT=$PWD

SID=${1:?usage: eval-run.sh <scenario-id> <run-no> <query>}
RUN=${2:?usage: eval-run.sh <scenario-id> <run-no> <query>}
QUERY=${3:?usage: eval-run.sh <scenario-id> <run-no> <query>}

# NB: no apostrophe in this message. Inside ${VAR:?word} bash opens a quote on it and the
# script dies two dozen lines later with an EOF error that names the wrong place entirely.
: "${EVAL_WORKSPACE_ID:?set EVAL_WORKSPACE_ID to the TEST workspace id, never the real one}"
: "${EVAL_PLAYER_MODEL:=claude-sonnet-4-6}"   # a tier below the team's floor
: "${EVAL_TURNS:=55}"                          # raised 40→55 next door: interviews need them
OUT=${EVAL_OUT:-$ROOT/evals/transcripts}
mkdir -p "$OUT"

command -v claude >/dev/null || { echo "no claude CLI on PATH"; exit 2; }

# The config home PERSISTS; the corpus copy does not.
#
# Isolation is about *what the player can reach* — other installed skills, the owner's own
# settings — and a dedicated config dir gives that whether or not it is recreated per run. What
# it cannot give is credentials: a fresh home is not logged in, and there is no flag that keeps
# the main home's auth while restricting its plugins. So the home is made once, logged into
# once, and reused for the round. Credentials are keychain-scoped per home
# (`Claude Code-credentials-<sha256(home)[:8]>`), so this never touches the main login — and a
# long round needs its own anyway, because copied tokens lose the refresh race.
EVAL_HOME=${EVAL_HOME:-$HOME/.mops-eval-home}
mkdir -p "$EVAL_HOME"

# **Probe, never infer.** The first version of this checked for `$EVAL_HOME/.credentials.json`
# — a file that does not exist on macOS at all, where credentials live in the keychain. It read
# "not logged in" on a home that was fine, and would have read "logged in" on a keychain entry
# that is present but empty, which is exactly the state a half-finished login leaves behind.
# The only honest test is asking the CLI. It costs one tiny turn and is cached for the round,
# because a probe per run would cost more than the check is worth.
# **`--check-only` is parsed HERE, before anything it should not pay for.** Its own comment
# called it free; it was not — the login probe below spends a real CLI turn, and a missing login
# refused the run outright, so exercising the preconditions needed credentials the preconditions
# have nothing to do with. That is why the suite could not test the fixture guard without a
# logged-in home. Measured 2026-08-21 (pass twelve). Flag positions only, never `$3`.
_check_only=no
_i=0
for _a in "$@"; do _i=$((_i+1)); [ "$_i" -le 3 ] && continue
  [ "$_a" = "--check-only" ] && _check_only=yes; done

if [ "$_check_only" = no ] && [ ! -f "$EVAL_HOME/.eval-login-ok" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  # `timeout` is Homebrew's on macOS, not the system's. Without it this probe fails with 127,
  # matches neither case below, and the run refuses a home that is perfectly logged in — the
  # same "probe, never infer" mistake in a new place. Used when present, skipped when not.
  _tmo=$(command -v timeout || command -v gtimeout || true)
  probe=$(CLAUDE_CONFIG_DIR="$EVAL_HOME" ${_tmo:+$_tmo 120} claude -p "reply with exactly: OK" \
          --model "$EVAL_PLAYER_MODEL" --max-turns 1 2>&1 | head -3)
  case "$probe" in
    *"Not logged in"*|*"/login"*) : ;;
    *OK*) touch "$EVAL_HOME/.eval-login-ok" ;;
  esac
fi
if [ "$_check_only" = no ] && [ ! -f "$EVAL_HOME/.eval-login-ok" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  # Ask once, clearly, instead of failing 125 times with "Please run /login" in a transcript
  # that then looks like a scenario result.
  cat >&2 <<EOF
The eval home at $EVAL_HOME is not logged in, so every run would return
"Not logged in" and be recorded as a void, not a result. Log it in once — this is yours to run,
it does not touch your main login, and one login covers the whole round:

  CLAUDE_CONFIG_DIR=$EVAL_HOME claude

then /login inside it, and exit.
EOF
  exit 3
fi

# The corpus copy IS per run, and that is the part that must be: it freezes the skill under
# test so a mid-round edit cannot reach a run already counted.
BOX=$(mktemp -d "${TMPDIR:-/tmp}/mops-eval-${SID}-${RUN}-XXXX") || exit 2
trap 'rm -rf "$BOX"' EXIT
mkdir -p "$BOX/plugin" "$BOX/work"

# **The player needs a working directory of its own — this is the third leg of isolation, and
# leaving it out produced five transcripts that looked like results.** Measured 2026-08-07 on
# scenario 1: run from this repository, the player answered *"I don't see a landing page — this
# is the multica-ops skill development repo"*, which is a correct thing to say about the wrong
# situation. One run went further and read the owner's actual website project two directories
# up. A player with the whole machine under it is not in the scenario, it is in your home
# folder, and the transcript does not say so.
#
# **Capability is granted; the choice is what is measured.** Measured 2026-08-07: with the
# headless default, five runs of scenario 1 ended at *"I need write permission to edit
# index.html"* — five transcripts scoring the harness's permission mode, not the skill. But the
# opposite error is worse: if the harness blocks the push, a transcript cannot tell **the skill
# asked first** from **the skill was not allowed**, and asking first is the whole assertion. So
# edits are auto-accepted and `git`/`multica` are allowed inside the disposable box, and what
# gets scored is what the player *chose* to do with that. Everything else still needs approval
# nobody is there to give, which keeps the blast radius at the box.
#
# So: a scratch `work/` per run, and the scenario's fixture copied into it if one exists.
if [ -d "$ROOT/evals/fixtures/$SID" ]; then
  cp -R "$ROOT/evals/fixtures/$SID/." "$BOX/work/" || exit 2
  # `FIXTURE.md` documents the situation for whoever maintains it — including what the scenario
  # is testing. Copied into the player's working directory it is the answer key, and the player
  # reads it: measured 2026-08-07 on scenario 19, three runs of three quoted it back
  # ("the fixture warns it's 6 levels deep"). It stays in the repository and never in the box.
  rm -f "$BOX/work/FIXTURE.md"
  FIXTURE=evals/fixtures/$SID
else
  FIXTURE=none
fi
# A git repo either way: half the flows read the tree's history, and "not a repository" is a
# situation none of these scenarios is about.
( cd "$BOX/work" && git init -q && git add -A >/dev/null 2>&1 \
  && git -c user.email=eval@local -c user.name=eval commit -qm fixture >/dev/null 2>&1 ) || true
# A real remote, pointing at a bare repo inside the box. Without one, `git push` fails on "no
# remote" and the transcript cannot distinguish **it chose not to push** from **it could not**
# — and for an outward-action scenario that is the entire question. The remote is local, so a
# push that does happen goes nowhere but here.
git init -q --bare "$BOX/remote.git" 2>/dev/null \
  && ( cd "$BOX/work" && git remote add origin "$BOX/remote.git" ) 2>/dev/null || true

# Copy only what ships. `.git` and the eval material are excluded on purpose — a player that
# can read the rubric is not measuring the corpus, it is reading the answer key.
tar -cf - --exclude=.git --exclude=evals --exclude=company --exclude=node_modules . \
  | (cd "$BOX/plugin" && tar -xf -) || exit 2

# **The workspace half is rebuilt before EVERY run, not once per scenario.** Measured
# 2026-08-07 on scenario 12: the player was asked to fire an agent and it did — archived it,
# deleted the squad — so runs 2 through 5 arrived at a workspace the earlier runs had already
# changed, and their "nothing to reassign" was true of the wreckage rather than of the
# situation. A scenario that acts on its own fixture invalidates every run after the first
# unless the situation is rebuilt, and the rubric says the same thing about scenario 24's board.
# **A scenario the runsheet says needs state, with no builder, is REFUSED — not run and shrugged
# at.** `eval-fixture.py` prints "its builder is not written yet" and the round used to carry on,
# producing a transcript that looks gradeable and measures a player standing in an empty
# workspace. Measured 2026-08-15: a focused round dispatched 18 and 27 this way — 18's poisoned
# webhook payload arrived as the OWNER's own words, which is a different scenario with a
# different right answer, and two of 27's three runs reported "the repository is empty" while
# the third inspected THIS repository's own gate. Six of the eleven scenarios the runsheet marks
# `rubric-setup` have no builder. The sibling paid for this exact shape with a void round whose
# headline measured nothing; the lesson travels as a refusal rather than as a paragraph.
# A scenario's state has TWO independent halves and the runsheet has one yes/no, so the guard is
# written to see what is MISSING rather than to guess which half was meant. Every `FIXTURE.md`
# states the model outright: "**Repository half only.** Where a scenario needs workspace state as
# well, its builder lives in `scripts/eval-fixture.py`."
#
#   repository half : tracked files under evals/fixtures/<id>/ beyond FIXTURE.md itself
#   workspace half  : an entry in eval-fixture.py's BUILDERS
#
# Refuse only when a scenario the runsheet marks as needing state has NEITHER. Measured 2026-08-15
# (pass ten), against all 27 rows:
#   the first form ($3 == rubric-setup, no builder)  refused 6 and MISSED scenario 27 — one of the
#     two voids it was written to prevent, named in its own commit message and round record
#   "$5 == yes, no builder"                          refused six at the time this was written
#     fully provisioned with 5-7 tracked files — it would report "the rig is broken" about
#     scenarios that build fine, which is what the first attempt did and was rewritten to avoid
#   "…or a fixtures/<id> directory exists"           refuses 5, re-admitting 14, 15 and 26; 14's
#     directory holds exactly one tracked file, FIXTURE.md, a prose stub whose on-disk `_ops/`
#     is untracked and vanishes in a clone
# This form refuses NOTHING-AT-ALL and WARNS where one half is present and the other is not,
# which is information the operator can act on rather than a wall.
# **The list that used to sit here — "refuses 3 · 11 · 14 · 18 · 23 · 27" — is gone rather than
# corrected, because it was a dated claim about a corpus that moves.** On 2026-08-21 all six got
# halves (3 and 27 repository, 3 · 11 · 18 · 23 builders, 14 declared needs-fixture=no), so the
# sentence became false for every id it named on the day the work it described was finished. A
# check's comment may say what the check DOES; the moment it enumerates which inputs it currently
# refuses, it has copied a table that lives elsewhere and will rot without anyone editing it.
# The three lines above record how this form was CHOSEN, with the counts measured that day. They
# are history, not a live claim — the ids they name have moved since (2026-08-21), and a comment
# that enumerates current inputs rots without anyone editing it. Kept as dated reasoning; nothing
# reads them.
needs_state=$(grep -vE '^#' "$ROOT/evals/runsheet.tsv" | awk -F'\t' -v s="$SID" '$1==s {print $5}')
if [ "$needs_state" = "yes" ]; then
  repo_half=$(cd "$ROOT" && git ls-files "evals/fixtures/$SID" 2>/dev/null | grep -cv 'FIXTURE\.md$' || true)
  has_builder=no
  _probe_err=$(mktemp)
  # The probe assigns the three codes ITSELF. Reading them off python's own exit status does not
  # work: an unhandled exception exits 1, which is the same code as "this scenario has no
  # builder" — so the two answers arrived indistinguishable no matter what the caller did with
  # them. Measured 2026-08-21, on the first run of the repair that was supposed to separate them.
  python3 -c "
import sys, importlib.util
try:
    spec = importlib.util.spec_from_file_location('f', sys.argv[1])
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
except BaseException as e:
    print(type(e).__name__ + ': ' + str(e), file=sys.stderr); sys.exit(2)
sys.exit(0 if sys.argv[2] in getattr(m, 'BUILDERS', {}) else 1)" \
    "$ROOT/scripts/eval-fixture.py" "$SID" 2>"$_probe_err"; _probe_rc=$?
  # THREE answers, not two. `&& has_builder=yes` collapsed "this scenario has no builder" (exit 1)
  # and "the module does not load at all" (exit 2 — a syntax error, an import error, the wrong
  # interpreter) into the same `no`, so a broken eval-fixture.py read as a scenario legitimately
  # lacking a builder, and the refusal below sent the reader to write a builder into a file that
  # cannot be parsed. Measured 2026-08-21 (pass twelve).
  case "$_probe_rc" in
    0) has_builder=yes ;;
    1) has_builder=no ;;
    *) echo "REFUSED: scripts/eval-fixture.py could not be loaded (exit $_probe_rc) — this is not \
a scenario without a builder, it is the module itself being unreadable, and every scenario's \
builder is unreachable until it is fixed: $(head -c 300 "$_probe_err" | tr '\n' ' ')" >&2
       rm -f "$_probe_err"; exit 6 ;;
  esac
  rm -f "$_probe_err"
  if [ "${repo_half:-0}" -eq 0 ] && [ "$has_builder" = "no" ]; then
    echo "REFUSED: scenario $SID is marked needs-fixture=yes and has NEITHER half of its state — \
no tracked files under evals/fixtures/$SID/ beyond FIXTURE.md, and no builder in \
scripts/eval-fixture.py. Running it anyway produces a transcript that grades a player standing in \
an empty workspace with an empty repository. Provision one half, or change the runsheet." >&2
    exit 4
  fi
  if [ "${repo_half:-0}" -eq 0 ]; then
    echo "note — scenario $SID has a builder but no tracked repository half" >&2
  elif [ "$has_builder" = "no" ]; then
    echo "note — scenario $SID has a repository half ($repo_half tracked files) but no \
workspace builder; anything the rubric expects to find in the workspace will be absent" >&2
  fi
fi
if [ -f "$ROOT/scripts/eval-fixture.py" ]; then
  # The build's exit code is the thing that matters, and `|| true` threw it away — so the guard
  # above could confirm a builder EXISTS while the build itself failed, and the run went ahead
  # against a workspace the fixture never made. That is the same shape as the refusal it sits
  # under, one line lower: a precondition asserted and not checked. Measured 2026-08-15 (pass ten).
  if ! EVAL_WORKSPACE_ID="$EVAL_WORKSPACE_ID" python3 "$ROOT/scripts/eval-fixture.py" "$SID" build >&2; then
    # The message is gated on what was actually checked. It asserted "has a builder and it FAILED"
    # for EVERY scenario, including those the module has no builder for — so a CLI outage or an
    # expired token on such a scenario would have produced a refusal naming a builder that does not
    # exist, sending the reader to fix a file with nothing in it. Measured 2026-08-20 (pass eleven).
    if [ "${has_builder:-no}" = yes ]; then
      echo "REFUSED: scenario $SID has a builder and it FAILED — the workspace half was not \
created, so the run would grade a player standing in a workspace the fixture never made. Fix the \
builder, or check the workspace credentials." >&2
    else
      echo "REFUSED: scenario $SID has NO builder, and the fixture module still exited non-zero — \
so this is not a missing builder, it is the module or the workspace being unreachable. Check the \
CLI and the credentials before reading anything into a round." >&2
    fi
    exit 5
  fi
fi

# `--check-only` stops here, after every precondition and before the dispatch. It exists so the
# guard above can be TESTED: nothing invoked this script — not a suite, not a workflow — and the
# assertions written for the fixture guard reimplemented its logic inside the test file, so the
# copy agreed with itself no matter what shipped. Measured 2026-08-20 (pass eleven), and it is the
# same escape this release deleted from the pin assertions two commits earlier. A dispatch costs a
# real player turn, which is why the guard went untested; this makes the preconditions free to run.
# Only the flag POSITIONS are searched, never `$3` — the operator's own query. A scenario asked
# "does --check-only work?" would otherwise have stopped the run and reported its preconditions
# ok, which looks exactly like a pass. Measured 2026-08-21 (pass twelve).
[ "$_check_only" = yes ] && { echo "preconditions ok: $SID"; exit 0; }

STAMP=$OUT/${SID}-run${RUN}
{
  echo "scenario: $SID"
  echo "run: $RUN"
  echo "player-model: $EVAL_PLAYER_MODEL"
  echo "workspace: $EVAL_WORKSPACE_ID"
  echo "corpus-sha: $(cd "$ROOT" && git rev-parse --short HEAD 2>/dev/null || echo uncommitted)"
  echo "corpus-dirty: $(cd "$ROOT" && [ -n "$(git status --porcelain)" ] && echo yes || echo no)"
  echo "fixture: $FIXTURE"
  echo "query: $QUERY"
} > "$STAMP.meta"

cd "$BOX/work" || exit 2
CLAUDE_CONFIG_DIR="$EVAL_HOME" \
MULTICA_WORKSPACE_ID="$EVAL_WORKSPACE_ID" \
  claude -p "$QUERY" \
    --plugin-dir "$BOX/plugin" \
    --model "$EVAL_PLAYER_MODEL" \
    --max-turns "$EVAL_TURNS" \
    --permission-mode acceptEdits \
    --allowedTools "Bash(git:*)" "Bash(multica:*)" \
    --mcp-config '{"mcpServers":{}}' --strict-mcp-config \
    --add-dir "$BOX/plugin" \
    --output-format stream-json --verbose \
    > "$STAMP.jsonl" 2> "$STAMP.err"
rc=$?

echo "rc=$rc" >> "$STAMP.meta"
echo "$STAMP"
exit $rc
