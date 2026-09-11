#!/usr/bin/env python3
"""What the project depends on, why, and how much each available update matters.

Run from a project's root, as the skill's `scripts/deps-report.py`:

    deps-report.py          the updates — asks the tools that know; needs the network
    deps-report.py --why    what the project uses and why — its own files only, offline

**The updates come from the tools that already know**, never from a list kept here:

    mise outdated --json --local           mise.toml: the newest version INSIDE each pin
    mise outdated --json --local --bump    ... and the newest at all, OUTSIDE it
    npm outdated --json --long             package.json: `wanted` inside the range, `latest` beyond
    osv-scanner scan source --recursive --format json .    published vulnerabilities, every lockfile

and each answer is sorted by what it asks of the owner:

    security      a published vulnerability in something the project ships — act first
    outside pin   newer than what the project pinned: a decision, and the release notes are its map
    inside pin    a newer build of what was already chosen — routine
    missing       declared, and not installed on this machine
    not checked   the tool that would know is absent, offline, or answered in a shape not read here

**The line between routine and decision is the project's own pin, not the version's numbering**
(PLAYBOOKS.md → *When something it needs has a newer version*). The last line says what was asked,
so an empty report reads as *current* and never as *nobody looked*.

**It never installs, upgrades, trusts or changes anything** — `mise trust` included. A report, not a
gate: it exits 0 whatever it finds. The gate on what is declared is the guard's §19.

What each tool prints was read from its own source on 2026-09-11, not assumed:
  mise `src/toolset/outdated_info.rs` — `latest` is the newest INSIDE the pin without `--bump` and
    the newest AT ALL with it, so the two answers are kept apart and never merged; `current` is null
    when not installed; **a tool whose lookup failed is dropped from the JSON, leaving only a warning
    on stderr** — so an empty answer beside that warning is "not checked", never "current". Never
    `-l`: it means `--bump` today and becomes `--local` in mise 2027.8.5.
  npm `lib/commands/outdated.js` — an object keyed by name, whose value becomes an ARRAY when one
    name is outdated in two places; `current` absent when not installed; exit 1 whenever anything
    is outdated, which is one reason no exit code is read here.
  osv-scanner `docs/output.md` — vulnerabilities grouped by shared aliases, so one advisory published
    under two ids is counted once.
"""
import json, os, re, shutil, subprocess, sys

ORDER = ("security", "outside pin", "inside pin", "missing", "not checked")
JS_OTHER = ("pnpm-lock.yaml", "yarn.lock", "bun.lock", "bun.lockb")
LOCKS = {"package-lock.json": "js", "pnpm-lock.yaml": "js", "yarn.lock": "js", "bun.lock": "js",
         "poetry.lock": "python", "uv.lock": "python", "Pipfile.lock": "python",
         "requirements.txt": "python", "Cargo.lock": "rust", "go.mod": "go", "Gemfile.lock": "ruby",
         "composer.lock": "php", "pubspec.lock": "dart", "mix.lock": "elixir"}


def run(cmd):
    """(stdout or None, stderr) — exit codes are not verdicts here (see the docstring)."""
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    except (OSError, subprocess.TimeoutExpired) as e:
        return None, str(e)
    return r.stdout, r.stderr


NOISE = re.compile(r"\bWARN\b|Version:|Run with --verbose|error parsing config file")


def telling_line(text):
    """The line that says why — not the last one. mise ends every refusal with *"Run with --verbose"*
    and prints unrelated warnings first (measured on 2026.9.5), so its last line names nothing."""
    lines = [l.strip() for l in (text or "").splitlines() if l.strip()]
    told = [l for l in lines if re.search(r"ERROR|\berror\b|ERR!", l) and not NOISE.search(l)]
    rest = [l for l in lines if not NOISE.search(l)]
    return (told or rest or lines or ["no output"])[0][:160]


def as_object(out, err, who, where, report):
    """The parsed JSON object, or None with a `not checked` line saying why — never silence."""
    if not (out or "").strip():
        report.append(("not checked", where, "%s answered nothing: %s" % (who, telling_line(err))))
        return None
    try:
        doc = json.loads(out)
    except ValueError:
        report.append(("not checked", where, "%s answered in a shape not read here: %s" % (who, telling_line(out))))
        return None
    if not isinstance(doc, dict):
        report.append(("not checked", where, "%s answered in a shape not read here" % who))
        return None
    return doc


def files_where(keep):
    """Tracked files whose basename passes `keep`, anywhere in the tree, plus untracked ones at the root."""
    found = set(f for f in os.listdir(".") if os.path.isfile(f) and keep(f))
    r = subprocess.run(["git", "ls-files", "-z"], capture_output=True, text=True)
    if r.returncode == 0:
        found.update(p for p in r.stdout.split("\0") if p and keep(os.path.basename(p)) and os.path.exists(p))
    return sorted(found)


def rel(path):
    """A path the tool printed, relative to here — through the symlink as well as around it: on a
    Mac `/var` is `/private/var`, and a tool may print either."""
    return min((os.path.relpath(path), os.path.relpath(os.path.realpath(path))), key=len)


def vtuple(v):
    m = re.match(r"v?(\d+(?:\.\d+)*)", v or "")
    return tuple(int(x) for x in m.group(1).split(".")) if m else None


def newer(a, b):
    ta, tb = vtuple(a), vtuple(b)
    return ta is not None and tb is not None and ta > tb


# ── the updates ────────────────────────────────────────────────────────────────────────────────

def mise_updates(report, asked):
    conf = next((f for f in ("mise.toml", ".mise.toml") if os.path.exists(f)), None)
    if not conf:
        return
    if not shutil.which("mise"):
        report.append(("not checked", conf, "mise is not installed here — it is what reads this file, "
                       "and installing it is the owner's word (PLAYBOOKS.md)"))
        return
    asked.append("mise (%s)" % conf)
    if re.search(r"^\s*\[bootstrap\.packages\]", open(conf, encoding="utf-8").read(), re.M):
        report.append(("not checked", "[bootstrap.packages]", "versions: mise's `outdated` reads `[tools]` "
                       "only — the OS's own manager answers: `brew outdated` · `apt list --upgradable` · "
                       "`winget upgrade`"))
    within_out, e1 = run(["mise", "outdated", "--json", "--local"])
    beyond_out, e2 = run(["mise", "outdated", "--json", "--local", "--bump"])
    if "not trusted" in (e1 or "") + (e2 or ""):
        # measured on 2026.9.5: `[bootstrap.packages]` makes mise refuse the whole file until trusted
        report.append(("not checked", conf, "mise will not read it until it is trusted on this machine — "
                       "`mise trust` is the owner's word, since a trusted file can install system packages"))
        return
    within = as_object(within_out, e1, "mise", conf, report)
    beyond = as_object(beyond_out, e2, "mise", conf, report)
    # a failed lookup is DROPPED from the JSON and survives only as this warning
    for tool in sorted(set(re.findall(r"Error getting latest version for ([^:\s]+)", (e1 or "") + (e2 or "")))):
        report.append(("not checked", tool, "mise could not look up its newest version — offline, or the "
                       "backend refused; nothing below speaks for it"))
    for name in sorted(set(within or {}) | set(beyond or {})):
        wi = (within or {}).get(name) or {}
        bi = (beyond or {}).get(name) or {}
        if not isinstance(wi, dict) or not isinstance(bi, dict):
            continue
        cur = wi.get("current") or bi.get("current")
        req = wi.get("requested") or bi.get("requested") or "?"
        if not cur:   # and if the pin is behind too, installing it and moving it are one decision
            behind = "; the pin is behind as well — `%s` would become `%s`, newest %s" % (
                req, bi["bump"], bi.get("latest", "?")) if bi.get("bump") else ""
            report.append(("missing", name, "pinned `%s` in %s, not installed on this machine%s" % (req, conf, behind)))
            continue
        if wi.get("latest") and wi["latest"] != cur:
            report.append(("inside pin", name, "%s → %s, inside `%s`" % (cur, wi["latest"], req)))
        if bi.get("bump"):
            url = bi.get("release_url")
            report.append(("outside pin", name, "the pin `%s` would become `%s` — newest %s%s" % (
                req, bi["bump"], bi.get("latest", "?"), "; notes: %s" % url if url else "")))


def npm_updates(report, asked):
    if not os.path.exists("package.json"):
        return
    other = [f for f in JS_OTHER if os.path.exists(f)]
    if other and not os.path.exists("package-lock.json"):
        report.append(("not checked", other[0], "versions: this project's package manager is not npm, "
                       "and its own `outdated` is not read here"))
        return
    if not shutil.which("npm"):
        report.append(("not checked", "package.json", "npm is not installed here"))
        return
    asked.append("npm (package.json)")
    out, err = run(["npm", "outdated", "--json", "--long"])
    doc = as_object(out, err, "npm", "package.json", report)
    if doc is None:
        return
    e = doc.get("error")
    if isinstance(e, dict) and "wanted" not in e and ("code" in e or "summary" in e):
        report.append(("not checked", "package.json", "npm could not answer: %s" % (e.get("summary") or e.get("code"))))
        return
    for name in sorted(doc):
        entries = doc[name] if isinstance(doc[name], list) else [doc[name]]
        for d in entries:
            if not isinstance(d, dict):
                continue
            label = name + (" (dev)" if d.get("type") == "devDependencies" else "")
            if len(entries) > 1 and d.get("dependent"):
                label += " in %s" % d["dependent"]
            cur, wanted, latest = d.get("current"), d.get("wanted"), d.get("latest")
            if not cur:
                report.append(("missing", label, "`%s` wanted, not in node_modules on this machine" % wanted))
                continue
            if newer(wanted, cur):
                report.append(("inside pin", label, "%s → %s, inside the range in package.json" % (cur, wanted)))
            if newer(latest, wanted):
                report.append(("outside pin", label, "newest %s is beyond the range in package.json, which "
                               "stops at %s%s" % (latest, wanted, "; home: %s" % d["homepage"] if d.get("homepage") else "")))


def osv_updates(report, asked):
    locks = files_where(lambda b: b in LOCKS)
    if not locks:
        return
    shown = ", ".join(locks[:3]) + (" …" if len(locks) > 3 else "")
    if not shutil.which("osv-scanner"):
        report.append(("not checked", shown, "security: osv-scanner is not installed here — it is what "
                       "knows the published vulnerabilities, and installing it is the owner's word"))
    else:
        asked.append("osv-scanner (%d lockfile%s)" % (len(locks), "" if len(locks) == 1 else "s"))
        out, err = run(["osv-scanner", "scan", "source", "--recursive", "--format", "json", "."])
        doc = as_object(out, err, "osv-scanner", shown, report)
        for res in (doc or {}).get("results") or []:
            src = rel((res.get("source") or {}).get("path") or "?")
            for p in res.get("packages") or []:
                pkg = p.get("package") or {}
                groups = p.get("groups") or [{"ids": [v.get("id")]} for v in p.get("vulnerabilities") or []
                                             if v.get("id")]
                if not groups:
                    continue
                ids = [(g.get("ids") or ["?"])[0] for g in groups]
                report.append(("security", "%s %s" % (pkg.get("name", "?"), pkg.get("version", "")),
                               "%d advisor%s, via %s: %s" % (len(ids), "y" if len(ids) == 1 else "ies", src,
                                                            ", ".join(ids[:4]) + (" …" if len(ids) > 4 else ""))))
    # versions in the ecosystems this report does not ask — said, so silence never reads as "current"
    by_lang = {}
    for f in locks:
        lang = LOCKS[os.path.basename(f)]
        if lang != "js":
            by_lang.setdefault(lang, []).append(f)
    for lang, fs in sorted(by_lang.items()):
        report.append(("not checked", ", ".join(fs[:3]), "versions: %s packages are listed by their own "
                       "`outdated`, which this report does not read" % lang))


def updates():
    report, asked = [], []
    mise_updates(report, asked)
    npm_updates(report, asked)
    osv_updates(report, asked)
    why = Why()
    report = [r for i, r in enumerate(report) if r not in report[:i]]   # a refusal said twice is said once
    for cls in ORDER:
        for c, name, detail in report:
            if c != cls:
                continue
            w = why.short(re.sub(r" .*", "", name)) if cls != "not checked" else None
            print("%-12s %s — %s%s" % (cls, name, detail, "  [why: %s]" % w if w else ""))
    if not report and not asked:
        print("dependencies: nothing declared here that this report reads — no mise.toml, package.json or lockfile")
        return
    if not [r for r in report if r[0] != "not checked"]:
        print("current: nothing newer was reported by what was asked")
    print("\nasked: %s." % (" · ".join(asked) if asked else "nothing — every tool that would know is missing here"))
    print("Nothing was installed or changed. Each update is the owner's to accept, at the next boundary, "
          "never under work in progress (PATTERNS.md §7).")


# ── why: what the project uses, and the reason, from its own files ───────────────────────────────

class Why:
    """The reason for an entry: its register row, else the decision line naming it, else nothing."""

    def __init__(self):
        self.reg = {}
        col = None
        try:
            lines = open("_ops/TOOLING.md", encoding="utf-8").read().splitlines()
        except OSError:
            lines = []
        for line in lines:
            if not line.lstrip().startswith("|"):
                col = None
                continue
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if col is None:
                heads = [re.sub(r"[`*\s]", "", c).lower() for c in cells]
                col = next((i for i, h in enumerate(heads) if h.startswith("whatit")), -1)
                continue
            if col < 0 or "{{" in line or set(line.replace("|", "").strip()) <= set("-: "):
                continue
            if col < len(cells):
                self.reg[re.sub(r"[`*\s]", "", cells[0]).lower()] = cells[col]
        try:
            self.decisions = list(enumerate(open("_ops/DECISIONS.md", encoding="utf-8").read().splitlines(), 1))
        except OSError:
            self.decisions = []

    def row(self, name):
        """By the exact name or one exact segment of it, never a substring — the guard's §19 matches
        the same way, so `ck` does not vouch for `package-stack`."""
        bare = name.split(":", 1)[1] if ":" in name else name
        for key in [name.lower(), bare.lower()] + [p.lower() for p in re.split(r"[/.]", bare) if p]:
            if key in self.reg:
                return self.reg[key]
        return None

    def decision(self, name):
        """The first DECISIONS.md line naming it as a word — the line the guard's §4e asks for when a
        dependency is added. A full stop after the name still ends it, as in §4e."""
        pat = re.compile(r"(?<![A-Za-z0-9@/_.-])%s(?![A-Za-z0-9@/_-]|\.[A-Za-z0-9])" % re.escape(name), re.I)
        for no, text in self.decisions:
            if pat.search(text):
                return no, re.sub(r"^\s*(?:[-*+]|\d+[.)])\s+", "", text).strip()   # the line, not its list marker
        return None

    def short(self, name):
        r = self.row(name)
        if r:
            return r
        d = self.decision(name)
        return "DECISIONS.md:%d" % d[0] if d else None


def toml_entries(path, want):
    """(name, table) for the wanted keys, from TOML read by hand — no `tomllib`, which is 3.11+ and
    absent from the system python a Mac without Homebrew has. The guard's §19 reads mise.toml the
    same way, for the same reason. `want(table, key)` returns a name, "[]" for an array of
    requirement strings, or None; with key None it is asked about a table header itself."""
    out, table, arr = [], "", None
    for raw in open(path, encoding="utf-8"):
        line = "" if raw.lstrip().startswith("#") else re.sub(r"\s+#[^\"']*$", "", raw.rstrip("\n"))
        bare = re.sub(r'"[^"]*"|\'[^\']*\'', "", line)      # brackets inside strings are not syntax
        if arr is not None:
            arr[1].append(line)
            if "]" in bare:
                out += [(n, arr[0]) for n in requirement_names(" ".join(arr[1]))]
                arr = None
            continue
        m = re.match(r"^\s*\[\[?\s*([^\]]+?)\s*\]\]?\s*$", line)
        if m:
            table = m.group(1).replace('"', "").replace("'", "")
            name = want(table, None)
            if name:
                out.append((name, table))
            continue
        m = re.match(r'^\s*(?:"([^"]+)"|\'([^\']+)\'|([A-Za-z0-9_.@:/+-]+))\s*=\s*(.*)$', line)
        if not m:
            continue
        got = want(table, m.group(1) or m.group(2) or m.group(3))
        if got == "[]":
            if "]" in re.sub(r'"[^"]*"|\'[^\']*\'', "", m.group(4)):
                out += [(n, table) for n in requirement_names(m.group(4))]
            else:
                arr = (table, [m.group(4)])
        elif got:
            out.append((got, table))
    return out


def requirement_names(buf):
    """The names out of PEP 508 strings: `"pydantic[email]>=2"` → pydantic."""
    return [re.split(r"[\s\[<>=!~;@(]", a or b, maxsplit=1)[0]
            for a, b in re.findall(r'"([^"]+)"|\'([^\']+)\'', buf) if (a or b)]


def mise_want(table, key):
    if key is None:
        m = re.match(r"^tools\.(.+)$", table)
        return m.group(1) if m else None
    return key if table in ("tools", "bootstrap.packages") else None


def pyproject_want(table, key):
    if key is None:
        return None
    if (table == "project" and key == "dependencies") or table in ("project.optional-dependencies",
                                                                    "dependency-groups"):
        return "[]"
    if re.match(r"^tool\.poetry\.(dev-dependencies|dependencies|group\.[^.]+\.dependencies)$", table):
        return None if key == "python" else key
    return None


CARGO = r"^(?:target\..+\.|workspace\.)?(?:dev-|build-)?dependencies"


def cargo_want(table, key):
    if key is None:
        m = re.match(CARGO + r"\.(.+)$", table)
        return m.group(1) if m else None
    return key if re.match(CARGO + "$", table) else None


def kind_of(table):
    if "dev" in table:
        return "dev"
    return {"project.optional-dependencies": "optional", "dependency-groups": "group"}.get(table, "")


def is_manifest(b):
    return b in ("package.json", "pyproject.toml", "Cargo.toml", "go.mod", "Gemfile", "composer.json") \
        or re.match(r"^requirements.*\.txt$", b) is not None


def manifest_deps(path):
    """(name, kind) for each dependency the manifest declares, or None when it does not parse."""
    base = os.path.basename(path)
    try:
        text = open(path, encoding="utf-8").read()
        if base in ("package.json", "composer.json"):
            doc = json.loads(text)
            keys = (("dependencies", ""), ("devDependencies", "dev"), ("optionalDependencies", "optional"),
                    ("peerDependencies", "peer")) if base == "package.json" else \
                   (("require", ""), ("require-dev", "dev"))
            return [(n, kind) for k, kind in keys for n in sorted(doc.get(k) or {})
                    if not (base == "composer.json" and (n == "php" or n.startswith("ext-")))]
        if base.startswith("requirements"):
            return [(re.split(r"[\s\[<>=!~;@]", l.strip(), maxsplit=1)[0], "") for l in text.splitlines()
                    if l.strip() and not l.strip().startswith(("#", "-"))]
        if base == "pyproject.toml":
            return [(n, kind_of(t)) for n, t in toml_entries(path, pyproject_want)]
        if base == "Cargo.toml":
            return [(n, kind_of(t)) for n, t in toml_entries(path, cargo_want)]
        if base == "go.mod":
            names, block = [], False
            for l in text.splitlines():
                s = l.split("//")[0].strip()
                if s.startswith("require ("):
                    block = True
                elif block and s == ")":
                    block = False
                elif block and s:
                    names.append((s.split()[0], ""))
                elif s.startswith("require ") and len(s.split()) > 1:
                    names.append((s.split()[1], ""))
            return names
        if base == "Gemfile":
            return [(g, "") for g in re.findall(r'^\s*gem\s+["\']([^"\']+)["\']', text, re.M)]
    except (OSError, ValueError, AttributeError):
        return None
    return None


def why_view():
    why = Why()
    groups = []
    conf = next((f for f in ("mise.toml", ".mise.toml") if os.path.exists(f)), None)
    if conf:
        groups.append(("the machine — %s" % conf, [(n, "") for n, _ in toml_entries(conf, mise_want)]))
    if os.path.exists(".mcp.json"):
        try:
            servers = json.load(open(".mcp.json", encoding="utf-8")).get("mcpServers") or {}
            groups.append(("MCP servers — .mcp.json", [(n, "") for n in sorted(servers)]))
        except (ValueError, AttributeError):
            groups.append(("MCP servers — .mcp.json", None))
    for mf in files_where(is_manifest):
        groups.append(("packages — %s" % mf, manifest_deps(mf)))
    if not groups:
        print("nothing declared here: no mise.toml, .mcp.json or package manifest")
        return
    total = in_reg = in_dec = 0
    for title, entries in groups:
        print(title)
        if entries is None:
            print("  (not read — the file does not parse)")
            continue
        seen = set()
        for name, kind in entries:
            if not name or name in seen:
                continue
            seen.add(name)
            total += 1
            label = name + (" (%s)" % kind if kind else "")
            r = why.row(name)
            d = None if r else why.decision(name)
            if r:
                in_reg += 1
                print("  %-34s %s" % (label, r))
            elif d:
                in_dec += 1
                print("  %-34s DECISIONS.md:%d — %s" % (label, d[0], d[1][:110] + ("…" if len(d[1]) > 110 else "")))
            else:
                print("  %-34s — no why recorded" % label)
    gap = total - in_reg - in_dec
    print("\n%d declared · %d with a why (%d in the register, %d in the decisions) · %d without." % (
        total, in_reg + in_dec, in_reg, in_dec, gap))
    if gap:
        print("Those predate the register or are a gap. A line in _ops/DECISIONS.md naming one gives it a "
              "why — the same line the guard's §4e asks for when a dependency is added.")


if __name__ == "__main__":
    why_view() if "--why" in sys.argv[1:] else updates()
    sys.exit(0)
