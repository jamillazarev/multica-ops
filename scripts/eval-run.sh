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
#   4 · **no MCP servers but the ones named here** — `--strict-mcp-config` with an empty set.
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
if [ ! -f "$EVAL_HOME/.eval-login-ok" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  probe=$(CLAUDE_CONFIG_DIR="$EVAL_HOME" timeout 120 claude -p "reply with exactly: OK" \
          --model "$EVAL_PLAYER_MODEL" --max-turns 1 2>&1 | head -3)
  case "$probe" in
    *"Not logged in"*|*"/login"*) : ;;
    *OK*) touch "$EVAL_HOME/.eval-login-ok" ;;
  esac
fi
if [ ! -f "$EVAL_HOME/.eval-login-ok" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
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
if [ -f "$ROOT/scripts/eval-fixture.py" ]; then
  EVAL_WORKSPACE_ID="$EVAL_WORKSPACE_ID" python3 "$ROOT/scripts/eval-fixture.py" "$SID" build >&2 || true
fi

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
    --output-format stream-json --verbose \
    > "$STAMP.jsonl" 2> "$STAMP.err"
rc=$?

echo "rc=$rc" >> "$STAMP.meta"
echo "$STAMP"
exit $rc
