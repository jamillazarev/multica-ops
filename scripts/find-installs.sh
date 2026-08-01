#!/usr/bin/env bash
# Find every install of this skill on the machine: the version each one is on, the route that
# updates it, and — separately flagged — the installs nothing would ever complain about: symlinks
# resolving to nowhere, copies sitting silently on an old version, and config mounts pointing at
# paths that no longer exist.
#
#   bash scripts/find-installs.sh              # list installs, flag the broken and the stale
#   bash scripts/find-installs.sh <dir>...     # also sweep extra roots (workspace installs)
#
# Exit 0: every install found is current. Exit 1: at least one is broken or stale.
#
# Why this exists: "updated all three harnesses" was once reported on a machine that had
# fourteen installs — nine of them symlinks resolving to a directory that did not exist, so the
# skill was wired into nine harnesses and loading in none of them, and two more copies sat on the
# previous version. Every one of those states is silent by construction: a broken symlink fails
# only when followed, a drifted copy announces nothing, and a config mount outlives the path it
# points at. The claim "updated everywhere" is only as good as the list of everywhere, and this
# script generates that list rather than recalling it.
set -uo pipefail

HOME_DIR="${HOME}"
NAME="multica-ops"

# The version the machine should be on: the newest any install carries. Computed in pass one,
# compared in pass two — the source checkout, when present, is just another row.
found_paths=""
found_versions=""
found_kinds=""
found_routes=""
found_flags=""
newest=""

# semver-ish max: sort -V exists on macOS since coreutils-adjacent sort does not — emulate.
ver_ge() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)" = "$1" ]; }

read_version() {
  # $1: a directory that might hold an install. Echoes the version or "no manifest".
  # A bare-skill mount points at skills/advisor, which carries its version in SKILL.md
  # frontmatter rather than a manifest — so SKILL.md counts, and so does walking up: a
  # symlink into the middle of a repo copy has the copy's manifests above it.
  local d="$1" m up
  for up in "" "/.." "/../.."; do
    for m in ".claude-plugin/plugin.json" "plugin.json" "gemini-extension.json" "package.json"; do
      if [ -f "$d$up/$m" ]; then
        /usr/bin/python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("version","no version field"))
except Exception: print("unreadable manifest")' "$d$up/$m"
        return
      fi
    done
    if [ -f "$d$up/SKILL.md" ]; then
      sed -n 's/^version:[[:space:]]*//p' "$d$up/SKILL.md" | head -1 | grep . || echo "no version field"
      return
    fi
  done
  echo "no manifest"
}

add() {
  # add <path> <kind> <route> <flag> <version>
  found_paths="${found_paths}$1
"
  found_kinds="${found_kinds}$2
"
  found_routes="${found_routes}$3
"
  found_flags="${found_flags}$4
"
  found_versions="${found_versions}$5
"
  if [ -n "$5" ] && printf '%s' "$5" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    if [ -z "$newest" ] || ver_ge "$5" "$newest"; then newest="$5"; fi
  fi
}

seen() { printf '%s' "$found_paths" | grep -Fxq "$1"; }

classify_path() {
  # A found filesystem entry that was not claimed by a harness-specific probe.
  # $1: path  $2: route to report for it
  local p="$1" route="$2" target v flag=""
  if [ -L "$p" ]; then
    target=$(readlink "$p")
    case "$target" in /*) ;; *) target="$(dirname "$p")/$target" ;; esac
    if [ ! -e "$p" ]; then
      # -e follows the link: a symlink whose chain ends nowhere. The install that is wired in
      # and loads nothing — the state nine harnesses were in when this script was written.
      add "$p" "symlink" "$route" "BROKEN -> $target" "-"
      return
    fi
    v=$(read_version "$p")
    add "$p" "symlink -> $target" "follows its target" "" "$v"
    return
  fi
  [ -d "$p" ] || return 0
  v=$(read_version "$p")
  add "$p" "copy" "$route" "" "$v"
}

# ---- pass one: the harnesses whose install state lives in a config, not a directory listing ----

# Claude Code: the plugin registry names the version it believes is installed.
reg="$HOME_DIR/.claude/plugins/installed_plugins.json"
if [ -f "$reg" ]; then
  /usr/bin/python3 -c 'import json,sys
d=json.load(open(sys.argv[1])); name=sys.argv[2]
for key,entries in d.get("plugins",{}).items():
    if key.split("@")[0]==name:
        for e in entries:
            print(e.get("installPath","?")+"\t"+e.get("version","?"))' "$reg" "$NAME" |
  while IFS=$(printf '\t') read -r p v; do
    echo "CLAUDE	$p	$v"
  done > /tmp/.find-installs.$$ || true
  while IFS=$(printf '\t') read -r _ p v; do
    flag=""
    [ -d "$p" ] || flag="BROKEN — registry names a path that does not exist"
    add "$p" "plugin, Claude Code" "claude plugin marketplace update $NAME && claude plugin update $NAME@$NAME" "$flag" "$v"
  done < /tmp/.find-installs.$$
  rm -f /tmp/.find-installs.$$
fi

# Codex: enabled in config.toml, bytes in the cache.
if [ -f "$HOME_DIR/.codex/config.toml" ] && grep -q "\"$NAME@" "$HOME_DIR/.codex/config.toml" 2>/dev/null; then
  cdir=$(find "$HOME_DIR/.codex/plugins/cache/$NAME" -maxdepth 2 -mindepth 2 -type d 2>/dev/null | sort | tail -1)
  if [ -n "$cdir" ]; then
    v=$(read_version "$cdir")
    add "$cdir" "plugin, Codex" "codex plugin marketplace upgrade && codex plugin add $NAME@$NAME" "" "$v"
  else
    add "$HOME_DIR/.codex/plugins/cache/$NAME" "plugin, Codex" "codex plugin marketplace upgrade && codex plugin add $NAME@$NAME" "BROKEN — enabled in config.toml, nothing in the cache" "-"
  fi
fi

# Gemini CLI extension.
gdir="$HOME_DIR/.gemini/extensions/$NAME"
if [ -e "$gdir" ]; then
  v=$(read_version "$gdir")
  add "$gdir" "extension, Gemini CLI" "uninstall then gemini extensions install <url> --consent — update follows RELEASES, not tags, and \`extensions update\` hangs (2026-08-01: killed at 120s and again at 240s; uninstall+install took seconds)" "" "$v"
fi

# Antigravity, global location.
adir="$HOME_DIR/.gemini/config/plugins/$NAME"
if [ -e "$adir" ]; then
  v=$(read_version "$adir")
  add "$adir" "plugin, Antigravity" "git pull --ff-only in place if it is a clone (it usually is — checked 2026-08-01), else re-copy the source or agy plugin install <url>" "" "$v"
fi

# hermes: a mount in config.yaml is an install even though no file lands anywhere — and it
# outlives the directory it points at, which is how a cleanup elsewhere silently unplugs it.
hcfg="$HOME_DIR/.hermes/config.yaml"
if [ -f "$hcfg" ]; then
  grep -E '^[[:space:]]*-[[:space:]]+/' "$hcfg" | sed -E 's/^[[:space:]]*-[[:space:]]+//' | while read -r p; do
    case "$p" in *"$NAME"*) echo "$p" ;; *) ;; esac
  done > /tmp/.find-installs-h.$$ || true
  while read -r p; do
    if [ -d "$p" ]; then
      v=$(read_version "$(dirname "$p")")
      [ "$v" = "no manifest" ] && v=$(read_version "$p")
      add "$p" "mount, hermes (config.yaml external_dirs)" "repoint or update the directory it mounts" "" "$v"
    else
      add "$p" "mount, hermes (config.yaml external_dirs)" "repoint or update the directory it mounts" "BROKEN — config mounts a path that does not exist" "-"
    fi
  done < /tmp/.find-installs-h.$$
  rm -f /tmp/.find-installs-h.$$
fi

# ---- pass two: directories and symlinks named after the skill, wherever harnesses keep them ----

scan_roots="$HOME_DIR/.agents $HOME_DIR/.claude/skills $HOME_DIR/.openclaw $HOME_DIR/.opencode $HOME_DIR/.cursor $HOME_DIR/.kimi $HOME_DIR/.pi $HOME_DIR/.factory $HOME_DIR/.copilot $HOME_DIR/.skills-manager $HOME_DIR/.config"
for extra in "$@"; do scan_roots="$scan_roots $extra"; done

for root in $scan_roots; do
  [ -e "$root" ] || continue
  find "$root" -maxdepth 4 -name "$NAME" \( -type d -o -type l \) 2>/dev/null | while read -r p; do
    echo "$p"
  done
done | sort -u > /tmp/.find-installs-s.$$ || true
while read -r p; do
  seen "$p" && continue
  # A directory inside an already-listed install is the install, not a second one.
  dup=0
  while read -r kp; do
    [ -n "$kp" ] || continue
    case "$p" in "$kp"/*) dup=1 ;; esac
  done <<EOF
$found_paths
EOF
  [ "$dup" = 1 ] && continue
  classify_path "$p" "a copy is moved only by re-copying the source; a symlink follows its target"
done < /tmp/.find-installs-s.$$
rm -f /tmp/.find-installs-s.$$

# ---- report ----

if [ -z "$found_paths" ]; then
  echo "no installs of $NAME found under $HOME_DIR (scanned: registry configs + $scan_roots)"
  exit 0
fi

echo "installs of $NAME on this machine (newest version seen: ${newest:-unknown}):"
echo

bad=0
i=1
total=$(printf '%s' "$found_paths" | grep -c '')
while [ "$i" -le "$total" ]; do
  p=$(printf '%s' "$found_paths"    | sed -n "${i}p")
  k=$(printf '%s' "$found_kinds"    | sed -n "${i}p")
  r=$(printf '%s' "$found_routes"   | sed -n "${i}p")
  f=$(printf '%s' "$found_flags"    | sed -n "${i}p")
  v=$(printf '%s' "$found_versions" | sed -n "${i}p")
  status="ok"
  if [ -n "$f" ]; then
    status="$f"; bad=1
  elif [ -n "$newest" ] && [ "$v" != "$newest" ]; then
    # The state nothing reports: bytes present, loading fine, and old. A copy in this state
    # answers every probe except "which version" — so which version is the probe.
    status="STALE — $v while $newest exists on this machine"; bad=1
  fi
  echo "  $p"
  echo "      $k · version $v · $status"
  echo "      update route: $r"
  echo
  i=$((i+1))
done

if [ "$bad" = 1 ]; then
  echo "RESULT: at least one install is broken or stale. 'Updated everywhere' is false until this list is clean."
  exit 1
fi
echo "RESULT: every install found is on $newest. Scanned: plugin registries + $scan_roots — a workspace-scoped install outside these roots is not covered; pass its parent as an argument."
exit 0
