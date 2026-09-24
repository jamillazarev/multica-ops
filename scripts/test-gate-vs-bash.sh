#!/usr/bin/env bash
# The publish gate held against bash itself, not against what its author expects bash to do.
#   bash scripts/test-gate-vs-bash.sh
#
# **Every case in test-outward-gate.sh states the verdict its author expected**, and in 0.4.18 the
# gate's heredoc blanker was out-guessed five times by commands where that expectation and bash
# disagreed — each found by a lens reading the code, none by a suite. Here the oracle is bash: each
# command runs in /bin/bash against stubs, *published* is read from what the stubs were asked to
# do, and the gate's verdict must agree. A publish the gate lets through is a HOLE; a refusal where
# nothing would have published is LOUD, and only the commands listed as bash syntax errors may be.
#
# **It cannot publish, by construction, three ways over** — measured necessary on 2026-09-24, when
# a lens testing this very gate with a stub `git` pushed a real branch: the installed gate refused
# the command that made the stub, the lens did not notice, and PATH fell through to the real git.
# So (1) PATH holds the stubs and an allowlist of harmless tools and nothing else, under `env -i`;
# (2) every stub is checked present before each run, and a missing one stops the suite; (3) bash
# runs under `sandbox-exec` with the network denied, so even a real binary would reach nothing.
# **Without `sandbox-exec` it does not run bash at all**, and reports that as a failure rather than
# a pass — a suite that skips itself green is the false clean this repository keeps paying for.
#
# Two code mutants must each open a HOLE, or the suite has no teeth: a terminator matched anywhere
# in a line rather than as the whole line, and a dry-run window that runs past a `)`.
set -u
cd "$(dirname "$0")/.." || exit 1
exec python3 - <<'PY'
import json, os, re, shutil, subprocess, sys, tempfile

GATE = os.path.abspath("hooks/outward-gate.py")
SBX = "/usr/bin/sandbox-exec"
PROFILE = "(version 1)(allow default)(deny network*)"
STUBBED = ["git", "gh", "npm", "npx", "yarn", "pnpm", "docker", "podman", "vercel", "flyctl", "fly",
           "netlify", "wrangler", "kamal", "cap", "make", "just", "terraform", "kubectl", "helm",
           "curl", "wget", "ssh", "scp", "rsync", "sudo"]
SAFE = ["cat", "echo", "printf", "env", "mkdir", "sh", "bash", "python3", "true", "false", "sed",
        "grep", "tee"]
SCRIPTS = ["deploy", "predeploy", "pre-deploy"]
ACTS = ("git push", "npm publish", "yarn publish", "pnpm publish", "docker push", "podman push",
        "gh release create", "gh pr create", "npm run deploy", "yarn run deploy", "pnpm run deploy",
        "make deploy", "just deploy", "vercel deploy", "flyctl deploy", "fly deploy",
        "netlify deploy", "wrangler deploy", "kamal deploy", "cap deploy", "script deploy")
DRY = re.compile(r"--dry[-_]run(?:=(?:true|1|yes))?$", re.I)
V = "git push origin main"

# (command, why) — the commands bash itself rejects are the only ones allowed to be LOUD
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
    ("npm publish --dry-run=false", "a dry-run flag that says no"),
    ("npm publish --dry-run=true", "a dry-run flag that says yes"),
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


if not os.access(SBX, os.X_OK):
    bad("no sandbox-exec on this machine — this suite never runs bash with the network reachable, "
        "so it ran nothing; run it on macOS")
    print("gate-vs-bash: %d passed, %d failed" % (passed, failed))
    sys.exit(1)

tmp = tempfile.mkdtemp(prefix="gate-vs-bash-")
box, stubs, safe = (os.path.join(tmp, d) for d in ("box", "stubs", "safe"))
log = os.path.join(tmp, "calls.log")
for d in (box, stubs, safe, os.path.join(box, "scripts")):
    os.makedirs(d)


def outside_any_repo(path):
    p = os.path.realpath(path)
    while True:
        if os.path.exists(os.path.join(p, ".git")):
            return False
        up = os.path.dirname(p)
        if up == p:
            return True
        p = up


def write_exe(path, body):
    with open(path, "w") as f:
        f.write("#!/bin/sh\n" + body + "\n")
    os.chmod(path, 0o755)


for t in STUBBED:
    write_exe(os.path.join(stubs, t), 'printf "%%s\\n" "%s $*" >> "%s"' % (t, log))
for t in SAFE:
    real = shutil.which(t)
    if real:
        os.symlink(real, os.path.join(safe, t))
for name in SCRIPTS:
    write_exe(os.path.join(box, "scripts", name), 'printf "%%s\\n" "script %s $*" >> "%s"' % (name, log))


def fail_closed():
    """Stop the suite if anything that keeps bash harmless is not in place."""
    missing = [t for t in STUBBED if not os.access(os.path.join(stubs, t), os.X_OK)]
    if missing or not outside_any_repo(box) or not os.access(SBX, os.X_OK):
        bad("the harness is not closed (missing stubs %s, or inside a repository) — stopped before "
            "running bash" % missing)
        print("gate-vs-bash: %d passed, %d failed" % (passed, failed))
        sys.exit(1)


def published(cmd):
    fail_closed()
    if os.path.exists(log):
        os.remove(log)
    env = ["/usr/bin/env", "-i", "PATH=%s:%s" % (stubs, safe), "HOME=" + box, "LC_ALL=C"]
    try:
        subprocess.run([SBX, "-p", PROFILE] + env + ["/bin/bash", "-c", cmd], cwd=box,
                       capture_output=True, timeout=15)
    except subprocess.TimeoutExpired:
        return None
    try:
        calls = open(log).read().splitlines()
    except FileNotFoundError:
        return False
    for c in calls:
        if c.startswith(ACTS) and not any(DRY.match(w) for w in c.split()):
            return True
    return False


# the gate keeps once-per-session markers in a state directory: this run gets its own, and every
# call its own session, so no verdict is a marker left by the call before it
state = os.path.join(tmp, "state")
os.makedirs(state)
calls = [0]


def refuses(gate, cmd):
    calls[0] += 1
    p = {"hook_event_name": "PreToolUse", "tool_name": "Bash", "session_id": "gvb-%d" % calls[0],
         "transcript_path": "", "tool_input": {"command": cmd}}
    r = subprocess.run([sys.executable, gate], input=json.dumps(p), capture_output=True, text=True,
                       env=dict(os.environ, MOPS_GATE_DIR=state))
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
    ("a dry-run window that runs past a `)`",
     're.split(r"[\\n;&|)`]"', 're.split(r"[\\n;&|]"'),
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
print("gate-vs-bash: %d passed, %d failed" % (passed, failed))
sys.exit(1 if failed else 0)
PY
