#!/usr/bin/env python3
"""Verify the skill against the world outside it.

`check-structure.py` asks whether the docs are well-formed. This asks whether they are
still **true**: that every command and flag we hand a user exists, that the sources we
send agents to still answer, and — with `--live` — that the read-only surface the flows
depend on actually runs.

    python3 scripts/verify.py              # commands, flags, and the CLI pin (offline-ish)
    python3 scripts/verify.py --sources    # also resolve the skill-pack and doc URLs
    python3 scripts/verify.py --live       # also execute the read-only CLI calls for real

`--live` never writes: it runs only commands on the allow-list below, which are all
reads. It needs a logged-in CLI and a workspace, so it is for a developer machine, not CI.
"""
import argparse, glob, json, re, shutil, subprocess, sys, urllib.request

FAIL, WARN = [], []
def fail(m): FAIL.append(m)
def warn(m): WARN.append(m)

DOCS = sorted(set(glob.glob("*.md")) | set(glob.glob("templates/*.md")))

# ── 1. every recipe in a code block must be a real command with real flags ───────
_help_cache = {}
def help_for(tokens):
    """Deepest valid subcommand path: `agent skills add` is three levels, not two."""
    for n in range(len(tokens), 0, -1):
        path = tuple(tokens[:n])
        if path not in _help_cache:
            r = subprocess.run(["multica", *path, "--help"], capture_output=True, text=True)
            _help_cache[path] = r.stdout if r.returncode == 0 and "USAGE" in r.stdout else None
        if _help_cache[path]:
            return " ".join(path), _help_cache[path]
    return None, None

def check_recipes():
    if not shutil.which("multica"):
        warn("multica CLI not installed — command and flag claims went unverified")
        return 0
    recipes = set()
    for f in DOCS:
        for blk in re.findall(r"```(?:sh|bash)?\n(.*?)```", open(f, encoding="utf-8").read(), re.S):
            for line in re.sub(r"\\\n\s*", " ", blk).split("\n"):
                line = line.strip().lstrip("$ ").split("#")[0].strip()
                if line.startswith("multica "):
                    recipes.add((f, line))
    flags = 0
    for f, line in sorted(recipes):
        tokens = [t for t in line.split()[1:] if re.fullmatch(r"[a-z][a-z-]*", t)]
        path, h = help_for(tokens)
        if not h:
            fail(f"{f}: `{line[:70]}` — no such command")
            continue
        for fl in re.findall(r"(?<![\w-])--[a-z][a-z-]*", line):
            flags += 1
            if fl not in h:
                fail(f"{f}: `{line[:60]}` promises {fl}, which `multica {path}` does not have")
    print(f"  recipes: {len(recipes)} command lines, {flags} flags")
    return len(recipes)

# ── 2. the CLI pin in REFERENCE §10 must match what is installed ────────────────
def check_pin():
    if not shutil.which("multica"):
        return
    installed = subprocess.run(["multica", "version"], capture_output=True, text=True).stdout
    m_inst = re.search(r"(\d+\.\d+\.\d+)", installed)
    m_pin = re.search(r"CLI v?(\d+\.\d+\.\d+)", open("REFERENCE.md", encoding="utf-8").read())
    if m_inst and m_pin and m_inst.group(1) != m_pin.group(1):
        warn(f"REFERENCE pins CLI {m_pin.group(1)}, installed is {m_inst.group(1)} — "
             f"regenerate §10 if the surface moved")

# ── 3. the sources we send agents to must still answer ──────────────────────────
def check_sources():
    urls = set()
    for f in DOCS:
        t = open(f, encoding="utf-8").read()
        urls |= set(re.findall(r"\]\((https?://[^)\s]+)\)", t))
        # skill-pack prefixes are written as bare paths in a table, not as links
        urls |= {"https://" + u.rstrip("/<") for u in
                 re.findall(r"`(github\.com/[\w./-]+?)/tree/", t)}
    ok = 0
    for u in sorted(urls):
        try:
            req = urllib.request.Request(u, method="HEAD", headers={"User-Agent": "multica-ops-verify"})
            with urllib.request.urlopen(req, timeout=20) as r:
                if r.status < 400:
                    ok += 1
        except Exception as e:
            code = getattr(e, "code", None)
            if code in (403, 405, 429):        # bot-blocked or HEAD-averse, not dead
                ok += 1
            else:
                warn(f"source does not resolve: {u} ({code or type(e).__name__})")
    print(f"  sources: {ok}/{len(urls)} resolve")

# ── 4. live read-only smoke over the surface the flows actually depend on ───────
# Every entry is a read. Nothing here creates, updates, assigns or deletes.
SMOKE = [
    (["workspace", "list", "--output", "json"], "workspaces"),
    (["project", "list", "--output", "json"], "projects"),
    (["agent", "list", "--output", "json"], "agents"),
    (["squad", "list", "--output", "json"], "squads"),
    (["skill", "list", "--output", "json"], "skills"),
    (["label", "list", "--output", "json"], "labels"),
    (["runtime", "list", "--output", "json"], "runtimes"),
    (["workspace", "member", "list", "--output", "json"], "members"),
    (["issue", "list", "--output", "json"], "issues"),
]
def check_live():
    if not shutil.which("multica"):
        warn("--live needs the multica CLI")
        return
    for cmd, what in SMOKE:
        r = subprocess.run(["multica", *cmd], capture_output=True, text=True)
        if r.returncode != 0:
            fail(f"live: `multica {' '.join(cmd)}` exited {r.returncode} — {r.stderr.strip()[:90]}")
            continue
        body = r.stdout.strip()
        if not body:
            continue                                   # empty is a valid answer
        try:
            json.loads(body)
        except json.JSONDecodeError:
            fail(f"live: `multica {' '.join(cmd)}` returned unparseable JSON — "
                 f"the flows read this with json.loads")
    print(f"  live: {len(SMOKE)} read-only calls")


# ── the fingerprint must hash every structural object the CLI exposes ───────────
# Drift detection is only as complete as this list. When Multica gains an object type,
# the fingerprint is blind to it until someone adds it — so verify the recipe covers
# every structural group, and flag any new CLI group to be classified.
STRUCTURAL = {"agent", "squad", "skill", "label", "autopilot", "project", "runtime",
              "property"}                       # workspace shape; not the volatile issue/chat
IGNORE = {"issue", "chat", "attachment", "auth", "config", "daemon", "setup", "update",
          "user", "version", "login", "repo", "workspace", "completion", "help"}
def check_fingerprint():
    if not shutil.which("multica"):
        return
    try:
        recipe = open("PLAYBOOKS.md", encoding="utf-8").read()
    except OSError:
        return
    m = re.search(r"for k in ([a-z ]+); do", recipe)          # the fingerprint loop
    hashed = set(m.group(1).split()) if m else set()
    hashed |= {"member", "project resource"} if "member list" in recipe else set()
    for grp in sorted(STRUCTURAL):
        if grp not in hashed and grp not in recipe:
            fail(f"fingerprint recipe (PLAYBOOKS) does not hash `{grp}` — drift in it goes unseen")
    # a CLI group that is neither hashed nor knowingly ignored is unclassified
    top = subprocess.run(["multica", "--help"], capture_output=True, text=True).stdout
    groups = set(re.findall(r"^  ([a-z][a-z-]+):", top, re.M))
    for g in sorted(groups - STRUCTURAL - IGNORE - hashed):
        warn(f"CLI group `{g}` is new — decide if it is workspace structure the fingerprint "
             f"should hash, then add it or add it to IGNORE")
    print(f"  fingerprint: {len(STRUCTURAL)} structural classes covered")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--sources", action="store_true", help="resolve every documented URL")
    ap.add_argument("--live", action="store_true", help="run the read-only CLI surface")
    a = ap.parse_args()

    print("verify — multica-ops")
    check_recipes()
    check_fingerprint()
    check_pin()
    if a.sources: check_sources()
    if a.live: check_live()

    for m in FAIL: print(f"  ✗ {m}")
    for m in WARN: print(f"  ! {m}")
    print("  ✓ verified" if not FAIL else f"  ✗ {len(FAIL)} claim(s) no longer true")
    sys.exit(1 if FAIL else 0)
