#!/bin/sh
# Installs the short `/mops` command once, on first session with this plugin active.
#
# Why do it rather than ask: plugin commands are namespaced (`/multica-ops:mops`), so
# without this the user learns one form, is later offered a second, and has to remember
# which they have. This is a file in their own Claude config — local, private, reversible
# with one `rm` — not an action on an outside system, so the bar is "tell them", not "ask".
#
# Three things it will not do: overwrite a `/mops` that already exists (it may be theirs),
# recreate one the user deleted on purpose, or print anything after the first run.
set -u

COMMANDS_DIR="${HOME}/.claude/commands"
TARGET="${COMMANDS_DIR}/mops.md"
MARKER="${HOME}/.claude/.multica-ops-alias"
# No cwd fallback: run outside the plugin, "." would copy whatever ./templates/mops-alias.md
# happens to be in the current repo into a global, auto-loading slash command.
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] || exit 0
SOURCE="${CLAUDE_PLUGIN_ROOT}/templates/mops-alias.md"

# Already handled once — either installed, or installed-and-since-deleted. Either way,
# the user's current state is the user's decision.
[ -e "$MARKER" ] && exit 0

# Something already owns /mops — including a symlink, which -e alone would follow and
# write through. Record that we saw it and never touch it again.
if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
  printf 'existing\n' > "$MARKER" 2>/dev/null || true
  exit 0
fi

[ -f "$SOURCE" ] || exit 0

mkdir -p "$COMMANDS_DIR" 2>/dev/null || exit 0
# Write to a temp file and move it into place: cp is not atomic, and a session killed
# mid-copy would otherwise leave a truncated command that the next run mistakes for the
# user's own and preserves forever.
TMP="${TARGET}.multica-tmp.$$"
if cp "$SOURCE" "$TMP" 2>/dev/null && mv -f "$TMP" "$TARGET" 2>/dev/null; then
  printf 'installed\n' > "$MARKER" 2>/dev/null || true
  echo "multica-ops: added /mops as a shortcut for /multica-ops:mops — remove any time with: rm ~/.claude/commands/mops.md"
else
  rm -f "$TMP" 2>/dev/null || true
fi
exit 0
