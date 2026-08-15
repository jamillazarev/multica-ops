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

# ── 2. the CLI pin in REFERENCE §10 must match what is installed — AND what exists ─────
def _newest_release():
    """The newest published CLI, or None when it cannot be asked.

    The pin check used to compare REFERENCE against the INSTALLED binary only. Measured
    2026-08-15: both said 0.4.12 while 0.4.26 was current — fourteen releases, shipped almost
    daily, and the check was green the whole way because it was comparing two stale things to
    each other. A platform that ships daily needs the outside number, not the local one.
    """
    for cmd in (["gh", "release", "view", "--repo", "multica-ai/multica", "--json", "tagName",
                 "-q", ".tagName"],
                ["brew", "info", "--json=v2", "multica"]):
        if not shutil.which(cmd[0]):
            continue
        try:
            out = subprocess.run(cmd, capture_output=True, text=True, timeout=25).stdout
        except Exception:
            continue
        m = re.search(r"(\d+\.\d+\.\d+)", out)
        if m:
            return m.group(1)
    return None


def _ver(s):
    return tuple(int(x) for x in s.split("."))


def check_pin():
    ref = open("REFERENCE.md", encoding="utf-8").read()
    # By name, like both readers in preflight.sh: the first vX.Y.Z in the file stopped being
    # the pin the moment a ticket citation was written above §10, and a ticket's version and
    # this repository's pin are indistinguishable to a positional read.
    # No positional fallback. One stood here and it silently restored the defect the by-name read
    # exists to remove: measured 2026-08-15 with the anchor reworded, the primary missed, the
    # fallback returned 0.4.26 from a different section, and nothing said it had fallen back. A
    # fallback that cannot announce itself turns this check into the thing it replaced, one
    # copy-edit away. Missing the anchor now warns, which is the honest outcome.
    m_pin = re.search(r"of `multica` \*\*v(\d+\.\d+\.\d+)", ref)
    if not m_pin:
        warn("REFERENCE names no CLI version — every claim about the platform is undated")
        return
    pinned = m_pin.group(1)

    if shutil.which("multica"):
        installed = subprocess.run(["multica", "version"], capture_output=True, text=True).stdout
        m_inst = re.search(r"(\d+\.\d+\.\d+)", installed)
        if m_inst and m_inst.group(1) != pinned:
            warn(f"REFERENCE pins CLI {pinned}, installed is {m_inst.group(1)} — "
                 f"regenerate §10 if the surface moved")

    newest = _newest_release()
    if newest and _ver(newest) > _ver(pinned):
        a, b = _ver(pinned), _ver(newest)
        behind = b[2] - a[2] if a[:2] == b[:2] else "several"
        warn(f"REFERENCE pins CLI {pinned}; {newest} is published — {behind} release(s) behind. "
             f"Every claim in REFERENCE was measured against {pinned}. Re-verify §2 (trigger "
             f"paths), §3 (what is native) and §10 (the surface) before trusting them, and date "
             f"what you re-verify")

# ── 3. the sources we send agents to must still answer ──────────────────────────
_BROWSER_UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
               "(KHTML, like Gecko) Chrome/126.0 Safari/537.36")

def _alive_via_browser_get(u):
    """Some hosts refuse this script's HEAD — ffmpeg.org resets the connection, dev.vk.com
    answers 418 — yet serve a normal page to a browser. Confirm liveness with one real GET
    before believing a source is dead. This stays a *liveness check*, not a blanket pass: a
    genuinely dead URL 4xx/5xx-es or raises here too, and still warns."""
    try:
        req = urllib.request.Request(u, headers={"User-Agent": _BROWSER_UA})
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status < 400
    except Exception as e:
        return getattr(e, "code", None) in (403, 405, 429)   # bot-blocked to the GET too, still alive

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
            if code in (403, 405, 429):                    # pre-existing: bot-blocked / HEAD-averse
                ok += 1
            elif code == 401 and "unsplash.com" in u:      # Unsplash's within.website bot challenge —
                ok += 1                                     # it blocks even a browser GET, so allow by domain
            elif _alive_via_browser_get(u):                # HEAD-hostile host: confirm alive with a real GET
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
              "property", "plugin"}        # workspace shape; not the volatile issue/chat
# `plugin` classified 2026-08-15, on arrival in CLI 0.4.26: a workspace-private Skill Plugin
# is installed into a workspace and changes what its agents can do — the same category as
# `skill`, which is already here. This repository does not use them yet; the fingerprint
# hashes them so that the day one appears, the drift is seen rather than discovered.
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
    # No `or grp not in recipe` escape. It was a substring test over the whole document, and
    # every one of these names appears in PLAYBOOKS' prose — so the gate could not fail for any
    # of them. Measured 2026-08-15: `plugin` deleted from the loop, verify.py exits 0 and still
    # prints its coverage line. A gate that reports the claim it was written to check is worse
    # than no gate, because the green is read as evidence.
    for grp in sorted(STRUCTURAL):
        if grp not in hashed:
            fail(f"fingerprint recipe (PLAYBOOKS) does not hash `{grp}` — drift in it goes unseen")
    # a CLI group that is neither hashed nor knowingly ignored is unclassified
    top = subprocess.run(["multica", "--help"], capture_output=True, text=True).stdout
    groups = set(re.findall(r"^  ([a-z][a-z-]+):", top, re.M))
    for g in sorted(groups - STRUCTURAL - IGNORE - hashed):
        warn(f"CLI group `{g}` is new — decide if it is workspace structure the fingerprint "
             f"should hash, then add it or add it to IGNORE")
    # What the recipe covers, not what the list declares — the two were the same number until
    # the escape above let them diverge, and the declared one is the one that cannot be wrong.
    print(f"  fingerprint: {len(hashed & STRUCTURAL)}/{len(STRUCTURAL)} structural classes covered")


# ── every self-declared prose-only rule must be on the named list ───────────────────────────
# `README.md`, `PATTERNS.md`, `SECURITY.md` and `PLAYBOOKS.md` all promise that prose-only rules
# are "listed by name", and nothing read the promise back. Measured 2026-08-15: two rules called
# themselves `prose-only` at the place they were defined — the council's declaration line and the
# empty-document rule — and neither was on the list. A promise four documents make is a form's
# job. The check is by FILE, not by wording: a document that declares a prose-only rule must be
# cited somewhere in the list, so a new declaration cannot arrive unlisted.
DECLARE_IN = ["FLOWS.md", "REFERENCE.md", "STACKS.md", "ROLES.md", "BOOTSTRAP.md"]
def check_prose_only():
    try:
        pb = open("PLAYBOOKS.md", encoding="utf-8").read()
    except OSError:
        return
    m = re.search(r"\*\*The prose-only list, by name\*\*.*?(?=\n#{2,} )", pb, re.S)
    if not m:
        fail("PLAYBOOKS has no 'prose-only list, by name' section — four documents promise it")
        return
    listed = m.group(0)
    cited = 0
    for f in DECLARE_IN:
        try:
            body = open(f, encoding="utf-8").read()
        except OSError:
            continue
        if "`prose-only`" not in body:
            continue
        stem = f[:-3]                       # FLOWS.md → FLOWS
        if stem in listed:
            cited += 1
        else:
            fail(f"{f} declares a rule `prose-only` and the named list never cites {stem} — "
                 f"a rule that calls itself unenforced belongs on the list that names them")
    # Only on success, and counting what was actually cited. A line reporting the claim it was
    # written to check is the defect this same file's fingerprint gate carried until today.
    if not FAIL:
        print(f"  prose-only: {cited} declaring document(s), each cited on the named list")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--sources", action="store_true", help="resolve every documented URL")
    ap.add_argument("--live", action="store_true", help="run the read-only CLI surface")
    a = ap.parse_args()

    print("verify — multica-ops")
    check_recipes()
    check_fingerprint()
    check_prose_only()
    check_pin()
    if a.sources: check_sources()
    if a.live: check_live()

    for m in FAIL: print(f"  ✗ {m}")
    for m in WARN: print(f"  ! {m}")
    print("  ✓ verified" if not FAIL else f"  ✗ {len(FAIL)} claim(s) no longer true")
    sys.exit(1 if FAIL else 0)
