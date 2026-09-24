#!/usr/bin/env bash
# The publish gate held against bash itself, not against what its author expects bash to do.
#   bash scripts/test-gate-vs-bash.sh
#
# **Every case in test-outward-gate.sh states the verdict its author expected**, and in 0.4.18 the
# gate's heredoc blanker was out-guessed five times by commands where that expectation and bash
# disagreed — each found by a lens reading the code, none by a suite. Here the oracle is bash: each
# command runs in /bin/bash against stubs, *published* is read from what the stubs were asked to
# do, and the gate's verdict must agree.
#
# **Reading a result.** A publish the gate lets through is a HOLE. A refusal where nothing would
# have published is LOUD, and fails the suite — except for a case whose reason starts with
# `SYNTAX:`, which marks a command bash itself rejects, where a refusal costs nothing. **Adding a
# case** is one line in CASES: the command, and in a few words what it probes (with `SYNTAX:` in
# front if bash rejects it) — and see TAKES_ARG if it uses a global option that takes an argument.
# **A real outward tool named by its path** — `/usr/bin/git …` — cannot be
# stubbed, so the sandbox refuses to execute it and the refusal counts as the act having been
# tried: only commands that ARE outward acts belong in a case that names a tool by its path.
#
# **It cannot publish, by construction, four ways over** — measured necessary on 2026-09-24, when
# a lens testing this very gate with a stub `git` pushed a real branch: the installed gate refused
# the command that made the stub, the lens did not notice, and PATH fell through to the real git.
# So (1) PATH holds the stubs and an allowlist of harmless tools and nothing else, under `env -i`;
# (2) every stub is checked present before each run; (3) bash runs under `sandbox-exec` with the
# network denied; and (4) the same sandbox refuses to EXECUTE any binary named like an outward
# tool outside the stub directory, by any path. A canary proves (4) before any case runs.
# **Without `sandbox-exec` it runs no bash at all, and reports that as a failure** — a suite that
# skips itself green is the false clean this repository keeps paying for. On a machine without it,
# run the suite on macOS; CI already does.
#
# Two code mutants must each open a HOLE, or the suite has no teeth: a terminator matched anywhere
# in a line rather than as the whole line, and a dry-run window that runs past the substitution
# holding the act.
set -u
cd "$(dirname "$0")/.." || exit 1
exec python3 - <<'PY'
import json, os, re, shutil, subprocess, sys, tempfile

GATE = os.path.abspath("hooks/outward-gate.py")
SBX = "/usr/bin/sandbox-exec"
STUBBED = ["git", "gh", "npm", "npx", "yarn", "pnpm", "docker", "podman", "vercel", "flyctl", "fly",
           "netlify", "wrangler", "kamal", "cap", "make", "just", "terraform", "kubectl", "helm",
           "curl", "wget", "ssh", "scp", "rsync", "sudo"]
SAFE = ["cat", "echo", "printf", "env", "mkdir", "sh", "bash", "python3", "true", "false", "sed",
        "grep", "tee", "date"]
SCRIPTS = ["deploy", "predeploy", "pre-deploy"]
# which of each tool's global options take an argument — the oracle's only model of a CLI, and
# the place a case using another such option must add it
TAKES_ARG = {"git": {"-C", "-c", "--git-dir", "--work-tree", "--namespace"},
             "gh": {"-R", "--repo"}, "npm": {"--prefix", "-w", "--workspace"},
             "yarn": {"--cwd"}, "pnpm": {"-C", "--dir", "--filter"},
             "docker": {"--context", "-c", "-H", "--host", "--config", "-l", "--log-level"},
             "podman": {"--connection", "--url"}, "make": {"-C", "-f", "--directory", "--file"},
             "just": {"-f", "--justfile", "-d", "--working-directory"}}
DRY = re.compile(r"--dry[-_]run(?:=(?:true|1|yes))?", re.I)
# bash words a refused execution two ways: `…/git: Operation not permitted` for a binary, and
# `…/git: /bin/sh: bad interpreter: Operation not permitted` for a script — both are the act tried
DENIED = re.compile(r"(?:^|[\s/])(%s): (?:\S+: bad interpreter: )?Operation not permitted"
                    % "|".join(map(re.escape, STUBBED)), re.M)
V = "git push origin main"

CASES = [
    (V, "the plain act"),
    ("echo testing --dry-run\n" + V, "a dry-run flag echoed on another line"),
    ("# preview with --dry-run first\n" + V, "a dry-run flag in a comment above"),
    (V + "  # --dry-run tested this path yesterday", "a dry-run flag in a trailing comment"),
    ("$(" + V + ") --dry-run", "a dry-run flag outside a substitution"),
    ("`" + V + "` --dry-run", "a dry-run flag outside backticks"),
    ("git push --dry-run origin main && npm publish", "one act dry, the next real"),
    ("git push --dry-run origin main", "a real dry run"),
    ("npm publish --dry-run", "a real dry run, npm"),
    ("npm --dry-run publish", "a dry-run flag before the subcommand"),
    ("npm publish --dry-run=false", "a dry-run flag that says no"),
    ("npm publish --dry-run=true", "a dry-run flag that says yes"),
    ("git push origin mainX--dry-run", "a dry-run flag glued to another word"),
    ("git -C . push origin main", "a global option before the subcommand"),
    ("git --work-tree . push origin main", "a long option with a separate argument"),
    ("git --git-dir=.git push origin main", "a --opt=value before the subcommand"),
    ("git -C . push --dry-run origin main", "a global option, and a real dry run"),
    ("gh -R o/r release create v1", "gh with a repository option"),
    ("npm --prefix x publish", "npm with a prefix option"),
    ("docker --context x push img", "docker with a context option"),
    ("make -C . deploy", "make with a directory option"),
    ("/usr/bin/git push origin main", "a real tool named by its path"),
    ("npm --prefix publish-tools publish", "an option argument starting with a subcommand word"),
    ("gh -R pr-team/repo release create v1", "the same, for gh"),
    ("npm --prefix run-scripts run deploy", "the same, before run deploy"),
    ('git -c "user.name=x y" push origin main', "a quoted option value with a space"),
    ('git -c user.name="x y" push origin main', "a value quoted inside the word"),
    ('"./my tools/git" push origin main', "a quoted tool path with a space"),
    ('gh release create v1 -n "notes (x) y" --dry-run', "a real dry run after a quoted parenthesis"),
    ('"git" push origin main', "a bare tool name in quotes"),
    ('git "push" origin main', "the verb quoted whole"),
    ("npm 'publish'", "the verb quoted whole, npm"),
    ('gh "release" create v1', "one word of a two-word act quoted"),
    ("git push origin branch$((1+1)) --dry-run", "arithmetic, then a real dry run"),
    ("git push origin <(echo hi) --dry-run", "process substitution, then a real dry run"),
    ('gh release create v1 -n "Released $(date "+%Y-%m-%d (UTC)")" --dry-run',
     "a real dry run after quotes nested inside $(…)"),
    ('git push origin "$(echo "a;b")" --dry-run', "a separator inside nested quotes, then a real dry run"),
    ("gh release create v1 -n notes\\) --dry-run", "an escaped parenthesis, then a real dry run"),
    ('echo "text $(echo "inner<<EOF") more"\n' + V + "\nEOF", "a quote in $(…) inside \"…\""),
    ('echo "text `echo "inner<<EOF"` more"\n' + V + "\nEOF", "a quote in backticks inside \"…\""),
    ('echo "${X:-"a<<EOF"}"\n' + V + "\nEOF", "a quote in ${…} inside \"…\""),
    ("echo $'a\\'<<EOF'\n" + V + "\nEOF", "$'…' is not an opener"),
    ("echo $((1<<EOF))\n" + V + "\nEOF", "$((…)) is not an opener"),
    ('git commit -m "first line\n <<X"\n' + V + "\nX", "a quote from an earlier line"),
    ("cat <<EOF\n  EOF\ncat <<Y\nEOF\n" + V + "\nY", "a terminator is the whole line"),
    ("cat > f.md <<EOF && git add f.md && " + V + "\nbody\nEOF", "a heredoc and a push, one line"),
    ("cat > f.md <<'EOF'\n" + V + "\nEOF", "a heredoc body is data"),
    ("cat<<EOF > r.md\n" + V + "\nEOF", "cat<<EOF, no space"),
    ("cat > d.md <<-EOF\n\t" + V + "\n\tEOF", "a tab-indented <<-"),
    ("cat <<A <<B\n" + V + "\nA\n" + V + "\nB", "two bodies on one line"),
    ("cat <<A <<B\nx\nA\ny\nB\n" + V, "two bodies, then a push"),
    ("echo hi # <<X\n" + V + "\nX", "an opener in a comment"),
    ("cat > a.md <<'A'\nexample: cat <<EOF\nA\n" + V + "\ncat > b.md <<'EOF'\ntext\nEOF",
     "an opener inside a body"),
    ("./scripts/deploy --prod", "a deploy script"),
    ("./scripts/predeploy", "a local check named predeploy"),
    ("./scripts/pre-deploy", "a local check named pre-deploy"),
    ('git commit -m "how `' + V + '` works"', "backticks in a message run"),
    ('git commit -m "describe how to git push later"', "a plain message"),
    ("(cd . && git push)", "a subshell"),
    ('bash -c "' + V + '"', "a shell-runner's quote"),
    ("env A=1 B=2 C=3 D=4 E=5 F=6 " + V, "six assignments"),
    ("python3 - <<'PY'\nprint('a vercel deploy')\nPY", "a heredoc fed to python"),
    ('x="$(printf "%s" "a")"; ' + V, "a substitution, then the act"),
    ("echo \"${X:-it's}\"\n" + V, "SYNTAX: bash 3.2 reads the ' as a quote that never closes"),
    ("echo \"${X:-it's}\" <<EOF'\n" + V + "\nEOF", "SYNTAX: the same, with a fake opener"),
]

passed = failed = 0


def bad(msg):
    global failed
    failed += 1
    print("FAIL: " + msg)


def finish(code=None):
    print("gate-vs-bash: %d passed, %d failed" % (passed, failed))
    sys.exit(code if code is not None else (1 if failed else 0))


if not os.access(SBX, os.X_OK):
    bad("no sandbox-exec on this machine — this suite never runs bash with the network reachable, "
        "so it ran nothing; run it on macOS")
    finish(1)

# the real path: the sandbox matches paths after symlinks, and /var is one on macOS
tmp = os.path.realpath(tempfile.mkdtemp(prefix="gate-vs-bash-"))
box, stubs, safe = (os.path.join(tmp, d) for d in ("box", "stubs", "safe"))
log = os.path.join(tmp, "calls.log")
for d in (box, stubs, safe, os.path.join(box, "scripts")):
    os.makedirs(d)
PROFILE = ('(version 1)(allow default)(deny network*)'
           '(deny process-exec (regex #"/(%s)$"))(allow process-exec (subpath "%s"))'
           % ("|".join(map(re.escape, STUBBED)), stubs))


def outside_any_repo(path):
    p = os.path.realpath(path)
    while True:
        if os.path.exists(os.path.join(p, ".git")):
            return False
        up = os.path.dirname(p)
        if up == p:
            return True
        p = up


def write_exe(path, name):
    # one line per call: the name, then every argument tab-separated, so quoting survives the log
    with open(path, "w") as f:
        f.write('#!/bin/sh\n{ printf "%%s" "%s"; for a in "$@"; do printf "\\t%%s" "$a"; done; '
                'printf "\\n"; } >> "%s"\n' % (name, log))
    os.chmod(path, 0o755)


for t in STUBBED:
    write_exe(os.path.join(stubs, t), t)
for t in SAFE:
    real = shutil.which(t)
    if real:
        os.symlink(real, os.path.join(safe, t))
for name in SCRIPTS:
    write_exe(os.path.join(box, "scripts", name), "script-" + name)
# a tool under a path with a space in it: the sandbox refuses to execute it, which is the point
os.makedirs(os.path.join(box, "my tools"))
write_exe(os.path.join(box, "my tools", "git"), "git")


def sandboxed(cmd):
    env = ["/usr/bin/env", "-i", "PATH=%s:%s" % (stubs, safe), "HOME=" + box, "LC_ALL=C"]
    return subprocess.run(["/usr/bin/sandbox-exec", "-p", PROFILE] + env + ["/bin/bash", "-c", cmd],
                          cwd=box, capture_output=True, text=True, timeout=15)


def fail_closed():
    """Stop the suite if anything that keeps bash harmless is not in place."""
    missing = [t for t in STUBBED if not os.access(os.path.join(stubs, t), os.X_OK)]
    if missing or not outside_any_repo(box) or not os.access(SBX, os.X_OK):
        bad("the harness is not closed (missing stubs %s, or inside a repository) — stopped before "
            "running bash" % missing)
        finish(1)


# the canary: a real outward binary, by its own path, must not execute inside the sandbox
fail_closed()
_real = next((shutil.which(t) for t in STUBBED if shutil.which(t)), None)
if _real:
    r = sandboxed("%s --version" % _real)
    if not DENIED.search(r.stderr):
        bad("the sandbox let %s execute — stopped before running any case" % _real)
        finish(1)
    passed += 1


def is_act(tool, args):
    """What the stub was asked to do, read as the tool would read it."""
    if tool.startswith("script-"):
        return tool == "script-deploy"
    i, takes = 0, TAKES_ARG.get(tool, set())
    while i < len(args) and args[i].startswith("-"):
        i += 2 if args[i] in takes else 1
    rest = args[i:]
    first, two = rest[:1], rest[:2]
    return ((tool == "git" and first == ["push"])
            or (tool == "gh" and two in (["release", "create"], ["pr", "create"]))
            or (tool in ("npm", "yarn", "pnpm") and (first == ["publish"] or two == ["run", "deploy"]))
            or (tool in ("docker", "podman") and first == ["push"])
            or (tool in ("make", "just") and "deploy" in rest)
            or (tool in ("vercel", "flyctl", "fly", "netlify", "wrangler", "kamal", "cap")
                and first == ["deploy"]))


def published(cmd):
    fail_closed()
    if os.path.exists(log):
        os.remove(log)
    try:
        r = sandboxed(cmd)
    except subprocess.TimeoutExpired:
        return None
    if DENIED.search(r.stderr):
        return True                              # a real outward tool was reached for, by its path
    try:
        calls = open(log).read().splitlines()
    except FileNotFoundError:
        return False
    for c in calls:
        tool, *args = c.split("\t")
        if is_act(tool, args) and not any(DRY.fullmatch(a) for a in args):
            return True
    return False


# this gate's verdict needs nothing but the command — no repository, no state between calls; the
# transcript feeds only the owner's quote in the refusal, which this suite does not read


def refuses(gate, cmd):
    p = {"hook_event_name": "PreToolUse", "tool_name": "Bash", "session_id": "s",
         "transcript_path": "", "tool_input": {"command": cmd}}
    r = subprocess.run([sys.executable, gate], input=json.dumps(p), capture_output=True, text=True)
    return r.returncode == 2


truth = [(cmd, why, published(cmd)) for cmd, why in CASES]
for cmd, why, pub in truth:
    if pub is None:
        bad("bash timed out on: " + why)
        continue
    ref = refuses(GATE, cmd)
    if pub and not ref:
        bad("HOLE — bash publishes and the gate allows it: " + why)
    elif ref and not pub and not why.startswith("SYNTAX:"):
        bad("LOUD — the gate refuses and bash publishes nothing: " + why)
    elif why.startswith("SYNTAX:") and pub:
        bad("a case marked as a bash syntax error published: " + why)
    else:
        passed += 1

MUTANTS = [
    ("a terminator matched anywhere in a line",
     'if (line.lstrip("\\t") if dash else line) == word:', "if word in line:"),
    ("a dry-run window that runs past the substitution holding the act",
     "if depth is not None and len(stack) == depth:", "if False:"),
]
src = open(GATE).read()
for name, a, b in MUTANTS:
    if src.count(a) != 1:
        bad("MUTATION DID NOT APPLY: " + name)
        continue
    mdir = os.path.join(tmp, "mutant", "hooks")
    os.makedirs(mdir, exist_ok=True)
    mgate = os.path.join(mdir, os.path.basename(GATE))
    open(mgate, "w").write(src.replace(a, b))
    holes = sum(1 for cmd, why, pub in truth if pub and not refuses(mgate, cmd))
    if holes:
        passed += 1
    else:
        bad("the mutant survived — %s — no case tells it from the gate" % name)

shutil.rmtree(tmp, ignore_errors=True)
finish()
PY
