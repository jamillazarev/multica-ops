#!/usr/bin/env bash
# deps-report.py — the updates sorted by what they ask of the owner, and the why of each thing the
# project uses — shown on a throwaway project where `mise`, `npm` and `osv-scanner` are shims that
# print the shapes their own sources produce (read 2026-09-11, cited in the script) and log every
# call they receive.
#
# **Three code mutants, each against the one assertion it should break**: the two mise answers
# merged into one (so "inside the pin" names the newest version outside it), mise's failed-lookup
# warning ignored (so offline reads as current), and a `]` inside a quoted requirement ending the
# array (so every dependency after `pydantic[email]` vanishes from the why view). A mutant that
# does not apply is reported as such — a toothless test and an unapplied mutation look identical.
#
# **Run on every python3 this machine offers**, the system one included: the script reads TOML by
# hand so that it never needs `tomllib`, which is 3.11+, and only a run on the old one shows that.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/p/_ops" "$T/bin" "$T/sys" "$T/fix"
CALLS="$T/calls.log"; : > "$CALLS"; export CALLS

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
# grep -c: no pipe can eat it · runs of spaces squeezed on both sides, so a column's width is not asserted
has() { [ "$(printf '%s\n' "$OUT" | tr -s ' ' | grep -cF -- "$(printf '%s' "$1" | tr -s ' ')")" -gt 0 ]; }

# ── the project ──────────────────────────────────────────────────────────────────────────────────
cd "$T/p"
git init -q . && git config user.email t@f.t && git config user.name T
cat > mise.toml <<'EOF'
[tools]
python = "3.12"
node = "22"
"github:BeaconBay/ck" = "latest"

[bootstrap.packages]
"brew:ffmpeg" = "latest"
"brew:package-stack" = "latest"   # a row `ck` must not vouch for this by substring
EOF
printf '{ "mcpServers": { "sentry": { "command": "npx", "env": { "SENTRY_TOKEN": "${SENTRY_TOKEN}" } } } }\n' > .mcp.json
printf '{ "name": "app", "dependencies": { "react": "^18.2.0", "lodash": "^4.17.0", "ms": "^2.1.0" },\n  "devDependencies": { "vitest": "^1.0.0" } }\n' > package.json
printf '{}\n' > package-lock.json
cat > pyproject.toml <<'EOF'
[project]
name = "svc"
dependencies = [
  "requests>=2.31",
  "pydantic[email]>=2",   # a bracket inside a string is not the end of the array
  "rich>=13",
]

[project.optional-dependencies]
docs = ["mkdocs>=1.5"]

[tool.poetry.group.dev.dependencies]
pytest = "^8"
EOF
printf '# lock\n' > poetry.lock
cat > _ops/TOOLING.md <<'EOF'
# Tooling

| Tool | What it's for | Replaces | Licence | Access | Wired how | Checked |
|---|---|---|---|---|---|---|
| python | the backend runtime | the system python | PSF | none | `mise.toml` | 2026-09-11 |
| ck | finding notes phrased differently | grep alone | MIT | none | `mise.toml` | 2026-09-11 |
| sentry | error tracking | log grepping | free tier | `${SENTRY_TOKEN}` | `.mcp.json` | 2026-09-11 |
EOF
cat > _ops/DECISIONS.md <<'EOF'
# Decisions

- 2026-09-01 — react over preact: the design system ships React components.
- 2026-09-02 — requests, not httpx: the service is synchronous.
- 2026-09-03 — the items list is paginated server-side.
EOF
git add -A && git commit -qm fixture

# ── what the tools print: the shapes from their own sources ──────────────────────────────────────
cat > "$T/fix/mise-within.json" <<'EOF'
{ "python": { "name": "python", "requested": "3.12", "current": "3.12.4", "bump": null,
              "latest": "3.12.7", "source": { "type": "mise.toml", "path": "/p/mise.toml" } },
  "node":   { "name": "node", "requested": "22", "current": null, "bump": null,
              "latest": "22.9.0", "source": { "type": "mise.toml", "path": "/p/mise.toml" } } }
EOF
cat > "$T/fix/mise-bump.json" <<'EOF'
{ "python": { "name": "python", "requested": "3.12", "current": "3.12.4", "bump": "3.13",
              "latest": "3.13.1", "release_url": "https://www.python.org/downloads/release/python-3131/",
              "source": { "type": "mise.toml", "path": "/p/mise.toml" } },
  "node":   { "name": "node", "requested": "22", "current": null, "bump": "24",
              "latest": "24.8.0", "source": { "type": "mise.toml", "path": "/p/mise.toml" } } }
EOF
# what mise 2026.9.5 printed on 2026-09-11 for an untrusted mise.toml with [bootstrap.packages]:
# the reason on the third line, and a last line that names nothing
cat > "$T/fix/mise-untrusted.txt" <<'EOF'
mise WARN  netrc file /home/u/.netrc has insecure permissions (mode: 644). Should be 0600 or 0400
mise ERROR error parsing config file: /p/mise.toml
mise ERROR Config files in /p/mise.toml are not trusted.
Trust them with `mise trust`. See https://mise.jdx.dev/cli/trust.html for more information.
mise ERROR Version: 2026.9.5 macos-arm64 (2026-09-10)
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
EOF
cat > "$T/fix/npm.json" <<'EOF'
{ "react":  { "current": "18.2.0", "wanted": "18.3.1", "latest": "19.1.0", "dependent": "app",
              "location": "/p/node_modules/react", "type": "dependencies", "homepage": "https://react.dev/" },
  "lodash": [ { "current": "4.17.20", "wanted": "4.17.21", "latest": "4.17.21", "dependent": "app",
                "location": "/p/node_modules/lodash", "type": "dependencies" },
              { "current": "4.17.15", "wanted": "4.17.21", "latest": "4.17.21", "dependent": "web",
                "location": "/p/web/node_modules/lodash", "type": "dependencies" } ],
  "vitest": { "wanted": "1.6.0", "latest": "3.2.0", "dependent": "app",
              "location": "/p/node_modules/vitest", "type": "devDependencies" } }
EOF
cat > "$T/fix/osv.json" <<'EOF'
{ "results": [ { "source": { "path": "PROJECT/package-lock.json", "type": "lockfile" },
    "packages": [ { "package": { "name": "lodash", "version": "4.17.15", "ecosystem": "npm" },
      "vulnerabilities": [ { "id": "GHSA-p6mc-m468-83gw", "aliases": ["CVE-2020-8203"] },
                           { "id": "CVE-2020-8203", "aliases": ["GHSA-p6mc-m468-83gw"] } ],
      "groups": [ { "ids": ["GHSA-p6mc-m468-83gw", "CVE-2020-8203"] } ] } ] } ] }
EOF
sed -i.bak "s#PROJECT#$T/p#" "$T/fix/osv.json" && rm -f "$T/fix/osv.json.bak"

# the shims: log the call, print the canned answer for the mode the test set
cat > "$T/bin/mise" <<EOF
#!/bin/bash
PATH=/usr/bin:/bin   # the shim's own tools — the report's PATH is the one under test
echo "mise \$*" >> "\$CALLS"
case "\${MISE_MODE:-normal}" in
  untrusted) cat "$T/fix/mise-untrusted.txt" >&2; exit 1 ;;
  offline)   echo '{}'; echo "mise WARN  Error getting latest version for node: failed to fetch" >&2
             echo "mise WARN  Error getting latest version for python: failed to fetch" >&2; exit 0 ;;
esac
case " \$* " in *" --bump "*) cat "$T/fix/mise-bump.json" ;; *) cat "$T/fix/mise-within.json" ;; esac
EOF
cat > "$T/bin/npm" <<EOF
#!/bin/bash
PATH=/usr/bin:/bin   # the shim's own tools — the report's PATH is the one under test
echo "npm \$*" >> "\$CALLS"
case "\${NPM_MODE:-normal}" in
  error)    echo '{ "error": { "code": "ENOTFOUND", "summary": "request to https://registry.npmjs.org/react failed" } }' ;;
  garbage)  echo 'npm ERR! code E401' ;;
  pkgerror) echo '{ "error": { "current": "1.0.0", "wanted": "1.0.2", "latest": "1.0.2", "dependent": "app", "type": "dependencies" } }' ;;
  *)        cat "$T/fix/npm.json" ;;
esac
exit 1
EOF
cat > "$T/bin/osv-scanner" <<EOF
#!/bin/bash
PATH=/usr/bin:/bin   # the shim's own tools — the report's PATH is the one under test
echo "osv-scanner \$*" >> "\$CALLS"
cat "$T/fix/osv.json"; exit 1
EOF
chmod +x "$T/bin/mise" "$T/bin/npm" "$T/bin/osv-scanner"
ln -s "$(command -v git)" "$T/sys/git"
# bash for the shims' shebang is /bin/bash, an absolute path — PATH needs only python3 and git

report() { OUT=$(cd "$T/p" && PATH="$1" python3 "$2" ${3:-} 2>&1); RC=$?; }

suite() {   # $1 = a label, $2 = the python3 to run on
  ln -sf "$2" "$T/sys/python3"
  local WITH="$T/bin:$T/sys" BARE="$T/sys" S="$HERE/deps-report.py" L="[$1]"
  [ "$(PATH="$BARE" command -v python3)" = "$T/sys/python3" ] || bad "$L the shim python is not first — nothing below proves the claim"

  # ── the honest twin ────────────────────────────────────────────────────────────────────────
  : > "$CALLS"; report "$WITH" "$S"
  [ "$RC" = 0 ] && ok || bad "$L exited $RC with findings in hand — a report must exit 0"
  has 'Warning' && bad "$L the interpreter's own warnings reached the report: $(printf '%s\n' "$OUT" | grep Warning | head -1)" || ok
  has 'security     lodash 4.17.15 — 1 advisory, via package-lock.json: GHSA-p6mc-m468-83gw' && ok \
    || bad "$L the vulnerability was not reported once, under its group's first id"
  has 'inside pin   python — 3.12.4 → 3.12.7, inside `3.12`' && ok || bad "$L python's update inside the pin is missing"
  has '3.12.4 → 3.13.1' && bad "$L 'inside the pin' named the newest version OUTSIDE it — the answers were merged" || ok
  has 'outside pin  python — the pin `3.12` would become `3.13` — newest 3.13.1; notes: https://www.python.org/' && ok \
    || bad "$L python's move outside the pin, with its notes, is missing"
  has 'missing      node — pinned `22` in mise.toml, not installed on this machine; the pin is behind as well — `22` would become `24`, newest 24.8.0' && ok \
    || bad "$L node, not installed and behind its pin, is not said"
  has 'inside pin   react — 18.2.0 → 18.3.1, inside the range in package.json' && ok || bad "$L react inside its range is missing"
  has 'outside pin  react — newest 19.1.0 is beyond the range in package.json, which stops at 18.3.1' && ok \
    || bad "$L react beyond its range is missing"
  has 'lodash in app — 4.17.20 → 4.17.21' && has 'lodash in web — 4.17.15 → 4.17.21' && ok \
    || bad "$L npm's array form (one name outdated in two places) lost an entry"
  has 'missing      vitest (dev) — `1.6.0` wanted' && ok || bad "$L a dev dependency not installed is not said"
  has 'not checked  poetry.lock — versions: python packages' && ok || bad "$L python versions went unsaid — silence would read as current"
  has "not checked  [bootstrap.packages] — versions: mise's \`outdated\` reads \`[tools]\` only" && ok \
    || bad "$L system packages' versions went unsaid — mise outdated does not read them"
  has '[why: the backend runtime]' && has '[why: DECISIONS.md:3]' && ok || bad "$L an update did not carry its why"
  has 'asked: mise (mise.toml) · npm (package.json) · osv-scanner (2 lockfiles).' && ok || bad "$L the report did not say what it asked"
  _s=$(printf '%s\n' "$OUT" | grep -n '^security' | head -1 | cut -d: -f1)
  _o=$(printf '%s\n' "$OUT" | grep -n '^outside pin' | head -1 | cut -d: -f1)
  _i=$(printf '%s\n' "$OUT" | grep -n '^inside pin' | head -1 | cut -d: -f1)
  [ -n "$_s" ] && [ -n "$_o" ] && [ -n "$_i" ] && [ "$_s" -lt "$_o" ] && [ "$_o" -lt "$_i" ] && ok \
    || bad "$L the order is not security → outside the pin → inside it"
  # it asked and changed nothing: no verb that installs, upgrades or trusts, and never mise's `-l`
  [ "$(grep -cE ' (install|upgrade|use|trust|update|ci|fix|up|i|u|apply|prune)( |$)' "$CALLS")" = 0 ] && ok \
    || bad "$L a call could change the machine: $(grep -E ' (install|upgrade|use|trust|update|ci|fix|up|i|u|apply|prune)( |$)' "$CALLS" | head -1)"
  [ "$(grep -c '^mise ' "$CALLS")" = 2 ] && [ "$(grep '^mise ' "$CALLS" | grep -c -- '--local')" = 2 ] \
    && [ "$(grep -cE '^mise .* -l( |$)' "$CALLS")" = 0 ] && ok || bad "$L mise was not asked twice with --local and without -l"

  # ── mise offline: the failed lookups are dropped from the JSON, so they must be said ─────────
  : > "$CALLS"; MISE_MODE=offline report "$WITH" "$S"
  has 'not checked  node — mise could not look up its newest version' \
    && has 'not checked  python — mise could not look up its newest version' && ok \
    || bad "$L an offline mise read as current"

  # ── mise refuses an untrusted file: said, and the report does not trust it ───────────────────
  : > "$CALLS"; MISE_MODE=untrusted report "$WITH" "$S"
  has "not checked  mise.toml — mise will not read it until it is trusted on this machine — \`mise trust\` is the owner's word" && ok \
    || bad "$L an untrusted mise.toml was not said as such"
  [ "$(printf '%s\n' "$OUT" | grep -c 'mise.toml —')" = 1 ] && ok || bad "$L one refusal of one file was said more than once"
  [ "$(grep -c trust "$CALLS")" = 0 ] && ok || bad "$L the report ran mise trust"

  # ── npm: an error object, an unreadable answer, and a package that is really named `error` ──
  NPM_MODE=error report "$WITH" "$S"
  has 'not checked  package.json — npm could not answer: request to https://registry.npmjs.org/react failed' && ok \
    || bad "$L npm's error object was not said"
  NPM_MODE=garbage report "$WITH" "$S"
  has 'not checked  package.json — npm answered in a shape not read here: npm ERR! code E401' && ok \
    || bad "$L a non-JSON npm answer was not said"
  NPM_MODE=pkgerror report "$WITH" "$S"
  has 'inside pin   error — 1.0.0 → 1.0.2' && ok || bad "$L a package named \`error\` was taken for npm's error object"

  # ── nothing that would know is installed: every source said as not checked, exit 0 ──────────
  report "$BARE" "$S"
  [ "$RC" = 0 ] && has 'not checked  mise.toml — mise is not installed here' \
    && has 'not checked  package.json — npm is not installed here' \
    && has 'security: osv-scanner is not installed here' \
    && has 'asked: nothing — every tool that would know is missing here.' && ok \
    || bad "$L with no tools, the report did not say so"

  # ── --why: offline, and every entry with its reason or its absence ───────────────────────────
  : > "$CALLS"; report "$WITH" "$S" --why
  [ "$(grep -c . "$CALLS")" = 0 ] && ok || bad "$L --why called a tool — it must read only the project's files"
  for _p in 'python                             the backend runtime' \
            'github:BeaconBay/ck                finding notes phrased differently' \
            'brew:package-stack                 — no why recorded' \
            'sentry                             error tracking' \
            'react                              DECISIONS.md:3 — 2026-09-01 — react over preact' \
            'requests                           DECISIONS.md:4' \
            'ms                                 — no why recorded' \
            'pydantic                           — no why recorded' \
            'rich                               — no why recorded' \
            'mkdocs (optional)' 'pytest (dev)' 'vitest (dev)'; do
    has "$_p" && ok || bad "$L --why is missing: $_p"
  done
  has '15 declared · 5 with a why (3 in the register, 2 in the decisions) · 10 without.' && ok \
    || bad "$L the why view's count is wrong: $(printf '%s\n' "$OUT" | grep declared)"
}

mutant() {   # $1 = what it breaks, $2 = the text to replace, $3 = its mutant, $4 = mode env, $5 = the line that must go missing, $6 = args
  cp "$HERE/deps-report.py" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  OUT=$(cd "$T/p" && env $4 PATH="$T/bin:$T/sys" python3 "$T/mut.py" ${6:-} 2>&1)
  has "$5" && bad "the suite did not catch the mutant: $1" || ok
}

PY=$(python3 -c 'import sys; print(sys.executable)')   # the interpreter, not an asdf or pyenv shim
suite "python3 on PATH" "$PY"
SYS=/usr/bin/python3
if [ -x "$SYS" ] && [ "$("$SYS" -c 'import sys; print(sys.executable)')" != "$PY" ]; then
  suite "system $("$SYS" --version 2>&1)" "$SYS"
fi

ln -sf "$PY" "$T/sys/python3"
mutant "the two mise answers merged into one" \
  'wi = (within or {}).get(name) or {}' 'wi = dict((within or {}).get(name) or {}, **((beyond or {}).get(name) or {}))' \
  'MISE_MODE=normal' 'inside pin   python — 3.12.4 → 3.12.7'
mutant "mise's failed-lookup warning ignored" \
  'for ([^:\s]+)", (e1 or "") + (e2 or "")' 'for ([^:\s]+)", ""' 'MISE_MODE=offline' 'not checked  node — mise could not look up'
mutant "a bracket inside a quoted requirement ends the array" \
  'if "]" in bare:' 'if "]" in line:' 'MISE_MODE=normal' 'rich                               — no why recorded' --why

echo "deps-report: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
