#!/usr/bin/env python3
"""Resolve, archive and verify entries for the sources register (sources/SOURCES.md).

The register carries every slow-rotting claim the skill makes; this ships with it so an
entry is never hand-typed from memory. `verify.py` asks whether the docs are still true at
release; this is the intake and upkeep tool for the one file that answers "where did you
get this".

    python3 scripts/fetch-source.py --resolve 2411.10109                 # arXiv id
    python3 scripts/fetch-source.py --resolve 10.1038/s41586-026-10742-x # DOI (Crossref)
    python3 scripts/fetch-source.py --resolve https://example.org/paper  # landing-page title
    python3 scripts/fetch-source.py --archive https://arxiv.org/abs/2411.10109
    python3 scripts/fetch-source.py --verify                             # walk the register
    python3 scripts/fetch-source.py --verify-citations                   # walk it backwards

`--resolve` fetches metadata (arXiv API for arXiv ids, Crossref for DOIs, the page <title>
otherwise) and prints a ready SOURCES.md block skeleton stamped with today's check-date —
you still write the distillate, set the licence and fill cited-by by hand. `--archive`
best-effort triggers a Wayback Save Page Now and prints the availability-API snapshot link;
a failure degrades to a warning, never an error. `--verify` GETs every live URL in the
register with a browser-ish UA and reports what no longer resolves, with the remediation
ladder: transient? → bot-block? → hunt the successor.

`--verify-citations` walks the same register in the other direction — each entry's
`Cited-by: file:line` back into the docs. Both edges matter: `--verify` proves the evidence
still exists, this proves the skill still uses it. Offline, so it is the cheap one to run.

Stdlib only — no network library beyond urllib, so it runs anywhere Python does.
"""
import argparse
import datetime
import json
import re
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET

TODAY = datetime.date.today().isoformat()
_BROWSER_UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
               "(KHTML, like Gecko) Chrome/126.0 Safari/537.36")


def _get(url, timeout=25, ua=_BROWSER_UA, method="GET"):
    req = urllib.request.Request(url, headers={"User-Agent": ua}, method=method)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.status, r.read()


# ── identifier classification ───────────────────────────────────────────────────
_ARXIV_RE = re.compile(r"^(?:arxiv:)?(\d{4}\.\d{4,5})(v\d+)?$", re.I)


def classify(ident):
    ident = ident.strip()
    m = _ARXIV_RE.match(ident)
    if m:
        return "arxiv", m.group(1)
    if ident.lower().startswith("10.") or "doi.org/10." in ident.lower():
        doi = re.sub(r"^.*doi\.org/", "", ident, flags=re.I)
        return "doi", doi
    if re.search(r"/(?:abs|pdf)/(\d{4}\.\d{4,5})", ident):
        return "arxiv", re.search(r"(\d{4}\.\d{4,5})", ident).group(1)
    return "url", ident


# ── skeleton emitter — one shape, so a wrong entry is visibly wrong ──────────────
def emit(entry_id, citation, live, licence, note):
    print(f"### {entry_id} · {note}")
    print(f"- **Citation:** {citation}")
    print(f"- **Live:** {live}")
    print(f"- **Archive:** archive: pending  (run: fetch-source.py --archive {live})")
    print(f"- **Licence:** {licence}")
    print("- **Distillate:** {{one paragraph, own words — what it shows, not what it is}}")
    print(f"- **Check-date:** {TODAY}")
    print("- **Cited-by:** {{file:line, …}}")


def resolve(ident):
    kind, key = classify(ident)
    if kind == "arxiv":
        return resolve_arxiv(key)
    if kind == "doi":
        return resolve_doi(key)
    return resolve_url(key)


def resolve_arxiv(arxiv_id):
    url = f"http://export.arxiv.org/api/query?id_list={arxiv_id}"
    try:
        _, body = _get(url)
    except Exception as e:  # noqa: BLE001
        print(f"! arXiv API did not answer for {arxiv_id}: {e}", file=sys.stderr)
        return 1
    ns = {"a": "http://www.w3.org/2005/Atom"}
    root = ET.fromstring(body)
    entry = root.find("a:entry", ns)
    if entry is None or entry.find("a:title", ns) is None:
        print(f"! no arXiv record for {arxiv_id} — check the id", file=sys.stderr)
        return 1
    title = " ".join(entry.find("a:title", ns).text.split())
    authors = [a.find("a:name", ns).text for a in entry.findall("a:author", ns)]
    published = (entry.find("a:published", ns).text or "")[:4]
    who = authors[0] + (" et al." if len(authors) > 1 else "")
    citation = f'{who} "{title}." arXiv:{arxiv_id} ({published}).'
    emit(f"arxiv-{arxiv_id}", citation, f"https://arxiv.org/abs/{arxiv_id}",
         "arXiv non-exclusive (free to read) — cite + archive + our distillate",
         f"{who} {published}")
    return 0


def resolve_doi(doi):
    url = f"https://api.crossref.org/works/{doi}"
    try:
        _, body = _get(url, ua="multica-ops-fetch-source (mailto:me@jamillazarev.com)")
    except Exception as e:  # noqa: BLE001
        print(f"! Crossref did not answer for {doi}: {e}", file=sys.stderr)
        return 1
    msg = json.loads(body).get("message", {})
    title = (msg.get("title") or ["(no title)"])[0]
    container = (msg.get("container-title") or [""])[0]
    year = ""
    for k in ("published-print", "published-online", "published", "issued"):
        parts = msg.get(k, {}).get("date-parts", [[None]])
        if parts and parts[0] and parts[0][0]:
            year = str(parts[0][0])
            break
    auth = msg.get("author", [])
    who = (auth[0].get("family", "") if auth else "") + (" et al." if len(auth) > 1 else "")
    citation = f'{who} "{title}." {container} ({year}). doi:{doi}.'.replace("  ", " ")
    emit(f"doi-{doi.replace('/', '-')}", citation, f"https://doi.org/{doi}",
         "copyrighted — citation + archive link + our distillate (no copy)",
         f"{who or container} {year}")
    return 0


def resolve_url(url):
    try:
        _, body = _get(url)
    except Exception as e:  # noqa: BLE001
        print(f"! landing page did not answer: {url} ({e})", file=sys.stderr)
        return 1
    m = re.search(r"<title[^>]*>(.*?)</title>", body.decode("utf-8", "replace"), re.I | re.S)
    title = " ".join(m.group(1).split()) if m else "(no <title> found)"
    emit("url-CHANGEME", f'"{title}." {url} (checked {TODAY}).', url,
         "{{detect: free / copyrighted / math}} — set the tier by hand", title[:48])
    return 0


# ── archive ─────────────────────────────────────────────────────────────────────
def archive(url):
    save = f"https://web.archive.org/save/{url}"
    avail = f"https://archive.org/wayback/available?url={url}"
    try:
        status, _ = _get(save, timeout=40)
        print(f"  Save Page Now → {save}  (HTTP {status})")
    except Exception as e:  # noqa: BLE001
        print(f"! Save Page Now did not complete for {url}: {e}  — archive stays 'pending'",
              file=sys.stderr)
    print(f"  availability API → {avail}")
    try:
        _, body = _get(avail, timeout=25)
        snap = json.loads(body).get("archived_snapshots", {}).get("closest", {})
        if snap.get("url"):
            print(f"  snapshot: {snap['url']}  ({snap.get('timestamp', '?')})")
        else:
            print("  snapshot: none yet — Wayback may take a minute; re-run availability")
    except Exception as e:  # noqa: BLE001
        print(f"! availability API did not answer: {e}", file=sys.stderr)
    return 0


# ── verify ──────────────────────────────────────────────────────────────────────
_LADDER = "remediation: transient? re-run → bot-block (403/405/429)? already alive → else hunt the successor URL"


def _alive(url):
    """True if the URL serves. Mirror verify.py: a HEAD-hostile host that 403/405/429s to a
    real browser GET is bot-blocked, not dead."""
    try:
        status, _ = _get(url, method="HEAD")
        return status < 400, status
    except urllib.error.HTTPError as e:
        if e.code in (403, 405, 429):
            return True, e.code
        try:
            status, _ = _get(url, method="GET")
            return status < 400, status
        except urllib.error.HTTPError as e2:
            return e2.code in (403, 405, 429), e2.code
        except Exception as e2:  # noqa: BLE001
            return False, type(e2).__name__
    except Exception:  # noqa: BLE001
        try:
            status, _ = _get(url, method="GET")
            return status < 400, status
        except Exception as e2:  # noqa: BLE001
            return getattr(e2, "code", None) in (403, 405, 429), getattr(e2, "code", type(e2).__name__)


def verify():
    try:
        text = open("sources/SOURCES.md", encoding="utf-8").read()
    except OSError:
        print("! sources/SOURCES.md not found — run from the repo root", file=sys.stderr)
        return 1
    urls = []
    for m in re.finditer(r"^- \*\*(?:Live|Archive|PDF)[^:]*:\*\*\s*(https?://\S+)", text, re.M):
        u = m.group(1).rstrip(").,")
        if "web.archive.org/web/2026" not in u:  # skip templated archive globs
            urls.append(u)
    urls = sorted(set(urls))
    dead = 0
    for u in urls:
        ok, code = _alive(u)
        if not ok:
            dead += 1
            print(f"  ✗ {u} ({code})")
    print(f"  register: {len(urls) - dead}/{len(urls)} live URLs resolve")
    if dead:
        print(f"  {_LADDER}")
    return 1 if dead else 0


_STOP = {"language", "models", "research", "skill", "skills", "should", "because", "between",
         "carries", "different", "against", "instead", "without", "already", "little"}


def _anchors(e):
    """What proves a pointer still lands on its claim, in two forms — because prose cites a
    source two ways. **By name**: the surname, product or handle a sentence says out loud
    ("Park et al.", "FrugalGPT", "agentman"). **By substance**: the figures and terms the
    distillate carries, for the many claims that use a study's numbers without naming it.
    Either one near the pointer is proof enough; the first is also what we hunt for elsewhere
    in the file, since a name that lives 40 lines away is what drift looks like."""
    src = e["heading"] + " " + e["citation"]
    named = set(re.findall(r"\b([A-Z][A-Za-z]{3,})\b(?=\s*[,.\"]|\s+et\s+al)", src))
    named |= set(re.findall(r"`([\w-]{4,})`", src))
    named |= {w for w in re.split(r"[-_]", e["id"]) if len(w) >= 5}
    named |= set(re.findall(r"(?:^|\s)([a-z][a-z0-9]{4,})\s+—", e["citation"]))
    substance = {w for w in re.findall(r"[A-Za-z][A-Za-z-]{5,}", e["distillate"])}
    substance |= set(re.findall(r"\d{2,}", e["distillate"]))
    return ({w.lower() for w in named} - _STOP,
            {w.lower() for w in substance} - _STOP)


def verify_citations():
    """The register's other edge. Every entry names the `file:line` that cites it, and nothing
    ever checked that the line still does — a doc gains three paragraphs and the pointer
    quietly names an unrelated sentence. That is worse than a dead link: the claim still reads
    as sourced, and the source still reads as used, while the two no longer meet.

    Structure is proved (the file, the line, that it is not blank). Drift is only *claimed*
    where it can be shown: the pointer names neither the source nor its substance, while the
    source's name demonstrably lives elsewhere in that same file — then the nearest real
    occurrence is printed and the fix is a one-number edit. An entry whose name appears nowhere
    in the file cannot be judged either way and is left alone rather than guessed at; a guard
    that cries wolf is read once and then skipped, which is worse than not having it.
    """
    try:
        text = open("sources/SOURCES.md", encoding="utf-8").read()
    except OSError:
        print("! sources/SOURCES.md not found — run from the repo root", file=sys.stderr)
        return 1

    entries, cur = [], None
    for line in text.split("\n"):
        m = re.match(r"^### (\S+) · (.*)$", line)
        if m:
            cur = {"id": m.group(1), "heading": m.group(2), "citation": "",
                   "distillate": "", "cited": ""}
            entries.append(cur)
        elif cur and (m := re.match(r"^- \*\*(Citation|Distillate|Cited-by):\*\* (.*)$", line)):
            cur[m.group(1).lower().replace("cited-by", "cited")] = m.group(2)

    files, bad, drift, uncited, checked = {}, 0, 0, [], 0
    for e in entries:
        pointers = re.findall(r"([\w./-]+\.md):(\d+)", e["cited"])
        if not pointers:
            uncited.append(f"{e['id']} — Cited-by: {e['cited'] or '(empty)'}")
            continue
        named, substance = _anchors(e)
        for path, num in pointers:
            checked += 1
            if path not in files:
                try:
                    files[path] = open(path, encoding="utf-8").read().split("\n")
                except OSError:
                    files[path] = None
            lines = files[path]
            if lines is None:
                print(f"  ✗ {e['id']} → {path}:{num} — no such file"); bad += 1; continue
            n = int(num)
            if not 1 <= n <= len(lines):
                print(f"  ✗ {e['id']} → {path}:{num} — file has {len(lines)} lines"); bad += 1; continue
            if not lines[n - 1].strip():
                print(f"  ✗ {e['id']} → {path}:{num} — points at a blank line"); bad += 1; continue
            low = [l.lower() for l in lines]
            window = " ".join(low[max(0, n - 4):n + 3])
            # A substance word only counts where it is *distinctive*: "persona" is on every
            # third line of MODULES and proves nothing, "83" and "cookiy" are on two.
            rare = {a for a in substance if 0 < sum(a in l for l in low) <= 3}
            if any(a in window for a in named | rare):
                continue
            hits = [i + 1 for i, l in enumerate(low) if any(a in l for a in named)]
            if hits:
                near = min(hits, key=lambda h: abs(h - n))
                print(f"  ! {e['id']} → {path}:{num} — “{lines[n - 1].strip()[:52]}…”"
                      f" carries neither the name nor the finding; nearest is {path}:{near}")
                drift += 1

    for u in uncited:
        print(f"  ! uncited: {u}")
    print(f"  citations: {checked - bad - drift}/{checked} back-pointers land on their claim"
          + (f", {len(uncited)} entr{'y' if len(uncited) == 1 else 'ies'} cited by nothing" if uncited else ""))
    if drift:
        print("  remediation: move the line number to the nearest match above, or re-cite the claim")
    return 1 if bad else 0


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--resolve", metavar="ID", help="doi | arxiv-id | url → SOURCES.md skeleton")
    g.add_argument("--archive", metavar="URL", help="Wayback Save Page Now + availability link")
    g.add_argument("--verify", action="store_true", help="check every live URL in the register")
    g.add_argument("--verify-citations", action="store_true",
                   help="check every Cited-by back-pointer still lands on its claim")
    a = ap.parse_args()

    if a.resolve:
        sys.exit(resolve(a.resolve))
    if a.archive:
        sys.exit(archive(a.archive))
    if a.verify:
        sys.exit(verify())
    if a.verify_citations:
        sys.exit(verify_citations())
