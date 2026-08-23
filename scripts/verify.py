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
    # By MARKER, like both readers in preflight.sh. "By name" was an ordinary English phrase and
    # any sentence containing it was read as the pin — measured 2026-08-15, one citation under the
    # §10 heading and all three readers returned the ticket's version.
    # No positional fallback. One stood here and it silently restored the defect the by-name read
    # exists to remove: measured 2026-08-15 with the anchor reworded, the primary missed, the
    # fallback returned 0.4.26 from a different section, and nothing said it had fallen back. A
    # fallback that cannot announce itself turns this check into the thing it replaced, one
    # copy-edit away. Missing the anchor now warns, which is the honest outcome.
    if ref.count("<!-- cli-pin -->") > 1:
        fail(f"REFERENCE carries {ref.count('<!-- cli-pin -->')} `<!-- cli-pin -->` markers — every "
             f"reader takes the first, so a second one is a second pin")
    m_pin = re.search(r"\*\*v(\d+\.\d+\.\d+)\*\* <!-- cli-pin -->", ref)
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
              "property"}                  # workspace shape; not the volatile issue/chat
# `plugin` was classified 2026-08-15 on arrival in CLI 0.4.26 and **removed 2026-08-23**, because
# the CLI removed the group: `multica plugin` is `unknown command` at 0.4.32. The recipe would
# have called it and hashed an error. What let that sit is below — this pair of checks agreed
# with a document, and both were stale in the same direction.
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
    # The check above compares a document against a constant, so it is silent when BOTH are stale
    # — which is exactly what happened to `plugin`: classified on arrival in 0.4.26, removed from
    # the CLI by 0.4.32, and still agreed upon by these two for six releases while the recipe would
    # have hashed an `unknown command`. The unclassified-group check below catches an ADDED group;
    # nothing caught a REMOVED one until this. Measured 2026-08-23.
    # a CLI group that is neither hashed nor knowingly ignored is unclassified
    top = subprocess.run(["multica", "--help"], capture_output=True, text=True).stdout
    groups = set(re.findall(r"^  ([a-z][a-z-]+):", top, re.M))
    # The other direction, and the one that was missing: a class we hash that the CLI no longer
    # exposes. The recipe would run `multica <gone> list`, get `unknown command` on stderr, and
    # hash the empty stdout — a stable hash for a class that does not exist, which reads as
    # "nothing drifted here" forever. Only assert when the CLI answered at all, so a broken
    # `--help` cannot empty the set and condemn every class at once.
    if groups:
        for grp in sorted(STRUCTURAL - groups):
            fail(f"`{grp}` is hashed as workspace structure and the CLI has no such group — "
                 f"the recipe would hash an `unknown command`. Remove it from STRUCTURAL and "
                 f"from the fingerprint loop, and say in the changelog that the class is gone")
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


# ── the staleness note's own number must match the file it describes ────────────────────────
# REFERENCE's header note says how many sections carry no date. That number is a claim about the
# file it sits in, it moves whenever a section is measured or added, and nothing read it back —
# it was already wrong once (it said "nine of thirteen" while counting the table of contents as a
# section). A count in prose about the document holding it is the cheapest possible form.
def check_undated():
    try:
        ref = open("REFERENCE.md", encoding="utf-8").read()
    except OSError:
        return
    # The note is read by the SECTIONS IT NAMES, not by a word-number, and its absence is a
    # failure rather than a silent skip. The first form matched one phrasing and returned early on
    # any other — measured 2026-08-20: rewording the note to name its sections made this check stop
    # running entirely, with nothing said. A checker that goes quiet when its subject is reworded is
    # a checker that reports the claim it was written to verify, which is the escape this release
    # has now deleted four times in four places.
    secs = re.split(r"\n## ", ref)[1:]
    DATED = re.compile(
        r"(measured|checked|verified|re-checked|re-verified)[^.\n]{0,60}"
        r"(20\d\d-\d\d-\d\d|CLI 0\.4\.\d+|v0\.4\.\d+)"
        r"|(20\d\d-\d\d-\d\d|CLI 0\.4\.\d+|v0\.4\.\d+)[^.\n]{0,60}"
        r"(measured|checked|verified|re-checked|re-verified)", re.I)
    # ONE line, in one shape — `> **Undated**: §5 · §6 · …`. The first form read the whole note
    # including its prose, so every `§N` mentioned in an aside was taken for a claim: measured
    # 2026-08-20, an explanation naming §1, §2 and §3 turned into three false disagreements. The
    # same lesson as the CLI pin's marker, one file over: a list a checker reads must be a list,
    # not a sentence that contains one.
    # **And exactly one line, guarded** — `re.search` takes the FIRST match in the whole file, so
    # a second `**Undated**:` line anywhere above the real note silently becomes the note. This is
    # the identical defect the `<!-- cli-pin -->` marker got a `count != 1` guard for in this same
    # release, in this same file, 200 lines up: the lesson was learned about one reader and not
    # carried to its neighbour. Measured 2026-08-21 (pass twelve) with a decoy line.
    notes = re.findall(r"^>?\s*\*\*Undated\*\*:[^\n]*$", ref, re.M)
    if len(notes) > 1:
        fail(f"REFERENCE carries {len(notes)} `**Undated**:` lines — this checker takes the "
             "first, so a second one silently becomes the staleness note. Exactly one, and the "
             "others reworded")
        return
    m = re.search(r"^>?\s*\*\*Undated\*\*:([^\n]*)$", ref, re.M)
    if not m:
        fail("REFERENCE carries no `**Undated**:` line — the shape this checker reads, and the "
             "one a reader checks before trusting a behavioural section. (The message here named "
             "'Still not measured:', a wording that cannot satisfy the check: a maintainer who "
             "wrote exactly what was asked would be refused again. Measured 2026-08-21.) "
             "thing a reader checks before trusting a behavioural section, and nothing states it")
        return
    claimed_secs = set(re.findall(r"§(\d+)", m.group(1)))
    actual_secs = set()
    for s in secs:
        if s.startswith("Contents") or DATED.search(s):
            continue
        n = re.match(r"(\d+)\.", s)
        if n:
            actual_secs.add(n.group(1))
    if claimed_secs != actual_secs:
        missing = sorted(actual_secs - claimed_secs, key=int)
        extra = sorted(claimed_secs - actual_secs, key=int)
        bits = []
        if missing: bits.append("undated and not named: §" + ", §".join(missing))
        if extra: bits.append("named but dated: §" + ", §".join(extra))
        fail("REFERENCE's staleness note disagrees with the file — " + "; ".join(bits))
    else:
        print(f"  staleness note: names §{', §'.join(sorted(actual_secs, key=int))}, and that is "
              f"what is undated")


# ── the always-loaded core must not pay for a sentence a companion already holds ────────────
# The core is read by every agent on every run; a companion is read when its trigger fires. A
# sentence in both is paid twice, and the size budget cannot see it — the budget knows how big
# the core is, not how much of it is redundant. Measured 2026-08-15 at ~9.3k tokens: exactly one
# sentence of 142 was duplicated, so there is nothing cheap left to move, and this check exists
# to keep that true rather than to discover it again.
def check_fingerprint_count():
    """The prose count beside STRUCTURAL must be the length of STRUCTURAL.

    `plugin` was classified 2026-08-15 and the sentence next to the list still said eight for
    six days — a number a reader trusts, describing a set they cannot see. Found 2026-08-21.
    A count in prose beside a list in code is only ever a claim; this makes it a checked one.
    """
    WORDS = {8: "Eight", 9: "Nine", 10: "Ten", 11: "Eleven", 12: "Twelve", 13: "Thirteen"}
    n = len(STRUCTURAL)
    want = WORDS.get(n)
    try:
        pb = open("PLAYBOOKS.md", encoding="utf-8").read()
    except OSError:
        return
    m = re.search(r"\*\*(\w+) classes plus members, resources and the repo pointer", pb)
    if not m:
        fail("PLAYBOOKS no longer states the fingerprint class count in the shape this checker "
             "reads (`**N classes plus members, resources and the repo pointer`)")
    elif want is None:
        warn(f"STRUCTURAL holds {n} classes and this checker has no word for that number")
    elif m.group(1) != want:
        fail(f"PLAYBOOKS says {m.group(1)} fingerprint classes; verify.py's STRUCTURAL holds {n} "
             f"({want}). A class nobody hashes is drift nobody sees, and a count nobody checks "
             f"is how the list and its description part company")
    else:
        print(f"  fingerprint: PLAYBOOKS and STRUCTURAL agree at {n} classes")


_BLOCK_START = re.compile(r"^(\s*([-*+]|\d+[.)])\s|\s*#{1,6}\s|\s*>|\s*\||\s*```|\s*<)")
def _soft_flatten(text):
    """Join lines the hard wrap broke, and KEEP every newline that is a block boundary.

    The patterns that read this use `[^.\n]` to stay inside one sentence, so a newline is their
    stop character — which makes the choice made here the whole behaviour of the check.

    **Both directions were wrong once.** Flattening nothing missed the mutant: this corpus hard
    wraps at ~98 columns, so a retracted rule became invisible the moment it straddled a line
    break, and the guard reported clean over the sentence it exists to refuse (measured
    2026-08-21, in this guard's own first hour). Flattening EVERYTHING then matched across
    headings, blank lines and list items — none of which contains a full stop — so honest prose
    under two unrelated headings read as one sentence (measured 2026-08-23: a heading, a bullet
    about mentions, a second heading, and a bullet about counters being free, matched as a single
    claim). The middle is the only correct answer: a wrapped paragraph is one sentence, and a new
    block is a new thought.

    **Same-length substitution, always** — newline to a single space, or newline kept. Every
    offset still points at the original byte, so the reported line number stays true; that is
    load-bearing, not tidiness, because the caller counts newlines up to `m.start()`.
    """
    lines = text.split("\n")
    out = []
    for i, ln in enumerate(lines[:-1]):
        nxt = lines[i + 1]
        joinable = ln.strip() and nxt.strip() and not _BLOCK_START.match(nxt)
        out.append(ln + (" " if joinable else "\n"))
    out.append(lines[-1])
    return "".join(out)


def check_mention_cost():
    """No file may still call a member/issue mention FREE.

    **Why a form, and not a fourth careful sentence.** REFERENCE §2 measured on 2026-08-15 that
    *any* comment on an issue with an assignee creates a run, mention or not — and the old rule
    ("a mention of a member or an issue is free") survived that retraction in THREE places at
    once: the always-loaded SKILL.md, the GLOSSARY row whose whole job is that a word means
    exactly one thing, and REFERENCE §10, which advised the costly act as the thrifty one. Found
    2026-08-21 (pass twelve). Three sites, one retraction, and no reader noticed for two releases.

    The pattern is deliberately narrow: it fires on *free* or *costs nothing* said within a short
    span of a member/issue mention. Section §2 itself is exempt — it is where the measurement
    lives, and it says "wakes nothing" about the genuinely free case (an UNASSIGNED issue).
    """
    FREE = re.compile(
        r"(mention(ing)?[^.\n]{0,80}(member|person|issue)[^.\n]{0,80}(is free|costs nothing|"
        r"does not cost|are free)"
        r"|(a member or an issue)[^.\n]{0,40}(it is )?\*\*free\*\*)", re.I)
    bad = []
    scope = sorted(set(DOCS) | set(glob.glob("skills/**/*.md", recursive=True)))
    for f in scope:
        try:
            text = open(f, encoding="utf-8").read()
        except OSError:
            continue
        # **Match on a flattened copy**, because this corpus hard-wraps at ~98 columns and the
        # patterns above use `[^.\n]` to stay inside one sentence — so the retracted rule became
        # INVISIBLE the moment it happened to straddle a line break. Measured 2026-08-21, on this
        # guard's own first hour: after the core was rewrapped to fit its line budget, the planted
        # mutant went undetected, and the guard reported clean over the sentence it exists to
        # refuse. Newline → space is a SAME-LENGTH substitution, so every offset still points at
        # the original byte and the reported line number stays true.
        flat = _soft_flatten(text)
        for m in FREE.finditer(flat):
            line = text.count("\n", 0, m.start()) + 1
            bad.append(f"{f}:{line}")
    if bad:
        fail("a member/issue mention is called free in " + ", ".join(bad) +
             " — REFERENCE §2 (measured 2026-08-15) found that ANY comment on an assigned issue "
             "creates a run. The mention adds no run of its own; the comment carrying it is not "
             "free. Say both halves or neither")
    else:
        print(f"  mention cost: {len(scope)} file(s) read, skills included — none calls a "
              f"member/issue mention free")


def check_core_overlap():
    core_p = "skills/mops/SKILL.md"
    try:
        core = open(core_p, encoding="utf-8").read()
    except OSError:
        return
    def norm(s):
        return re.sub(r"\s+", " ", re.sub(r"[*`\[\]()]", "", s)).strip().lower()
    sents = [s.strip() for s in re.split(r"(?<=[.!?])\s+", core) if len(s.strip()) > 90]
    companions = {}
    for f in DOCS:
        if f in ("README.md", "CHANGELOG.md", "AGENTS.md", "CLAUDE.md") or f.startswith("templates/"):
            continue
        try:
            companions[f] = norm(open(f, encoding="utf-8").read())
        except OSError:
            pass
    dup = []
    for s in sents:
        n = norm(s)[:110]
        if len(n) < 90:
            continue
        for name, body in companions.items():
            if n in body:
                dup.append((name, s[:90]))
                break
    # One is the known, deliberate overlap (the external-text rule, which SECURITY restates in
    # its own context). More than that is the core paying rent twice and is worth a look.
    if len(dup) > 1:
        warn(f"{len(dup)} sentences of the always-loaded core also appear verbatim in a "
             f"companion — every agent pays those on every run: "
             + "; ".join(f"{n} — {s[:60]}…" for n, s in dup[:3]))
    else:
        print(f"  core overlap: {len(dup)} sentence(s) of {len(sents)} also in a companion")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--sources", action="store_true", help="resolve every documented URL")
    ap.add_argument("--live", action="store_true", help="run the read-only CLI surface")
    a = ap.parse_args()

    print("verify — multica-ops")
    check_recipes()
    check_fingerprint()
    check_prose_only()
    check_undated()
    check_mention_cost()
    check_fingerprint_count()
    check_core_overlap()
    check_pin()
    if a.sources: check_sources()
    if a.live: check_live()

    for m in FAIL: print(f"  ✗ {m}")
    for m in WARN: print(f"  ! {m}")
    print("  ✓ verified" if not FAIL else f"  ✗ {len(FAIL)} claim(s) no longer true")
    sys.exit(1 if FAIL else 0)
