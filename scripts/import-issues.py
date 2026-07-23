#!/usr/bin/env python3
"""Create Multica issues from a normalized JSON file, resumably.

Extraction is per-source and is the agent's job (Linear MCP or GraphQL, `gh issue list
--json`, a CSV export...). What every import shares is this part: parents before children,
skip what already exists, never assign on the way in. That is what this script does, so a
half-finished import is continued rather than restarted or duplicated.

Input: a JSON array. Only `source_id` and `title` are required.

    [{"source_id": "LIN-482",           # the idempotency key — must be stable
      "title":     "Search returns nothing for names",
      "body":      "...",               # the FULL body (Linear: `content`, not `description`)
      "status":    "backlog",           # already mapped to Multica's columns
      "priority":  "high",              # already mapped from the source's scale
      "start_date":"2026-08-01",        # YYYY-MM-DD
      "due_date":  "2026-08-14",
      "labels":    ["bug"],             # must already exist in the workspace
      "parent":    "LIN-400",           # a source_id from this same file
      "url":       "https://linear.app/…/LIN-482"}]

    python3 scripts/import-issues.py backlog.json --project <ID>          # dry run
    python3 scripts/import-issues.py backlog.json --project <ID> --apply

Deliberately absent: assignees. Assigning enqueues a task and spends budget, so imported
work arrives cold and is assigned afterwards, one decision at a time.
"""
import argparse, json, subprocess, sys, tempfile, os

def multica(*args, check=True):
    r = subprocess.run(["multica", *args], capture_output=True, text=True)
    if check and r.returncode != 0:
        raise RuntimeError(f"multica {' '.join(args)}\n{r.stderr.strip()}")
    return r.stdout.strip()

def existing_source_ids(project):
    """Issues already carrying a source_id, so a rerun continues instead of duplicating."""
    seen = {}
    try:
        issues = json.loads(multica("issue", "list", "--project", project, "--output", "json") or "[]")
    except (RuntimeError, json.JSONDecodeError) as e:
        sys.exit(f"could not list existing issues — refusing to risk duplicates: {e}")
    for it in issues if isinstance(issues, list) else issues.get("issues", []):
        iid = it.get("id")
        if not iid:
            continue
        try:
            meta = json.loads(multica("issue", "metadata", "get", iid, "source_id", check=False) or "null")
        except json.JSONDecodeError:
            meta = None
        val = meta.get("value") if isinstance(meta, dict) else meta
        if val:
            seen[str(val)] = iid
    return seen

def create(item, project, apply):
    args = ["issue", "create", "--title", item["title"], "--project", project,
            "--status", item.get("status", "backlog"), "--output", "json"]
    tmp = None
    if item.get("body"):
        tmp = tempfile.NamedTemporaryFile("w", suffix=".md", delete=False,
                                          dir=os.getcwd(), encoding="utf-8")
        tmp.write(item["body"]); tmp.close()
        args += ["--description-file", os.path.basename(tmp.name)]
    for flag, key in (("--priority", "priority"), ("--start-date", "start_date"),
                      ("--due-date", "due_date")):
        if item.get(key):
            args += [flag, item[key]]
    if item.get("_parent_id"):
        args += ["--parent", item["_parent_id"]]
    if not apply:
        print("  would create:", " ".join(args[2:]))
        if tmp: os.unlink(tmp.name)
        # a placeholder so children resolve their parent — a dry run that reported
        # false failures would be worse than no dry run at all
        return f"dry-run:{item['source_id']}"
    try:
        out = json.loads(multica(*args) or "{}")
    finally:
        if tmp: os.unlink(tmp.name)
    iid = out.get("id")
    if not iid:
        raise RuntimeError(f"no id returned for {item['source_id']}")
    multica("issue", "metadata", "set", iid, "source_id", item["source_id"])
    if item.get("url"):
        multica("issue", "metadata", "set", iid, "source_url", item["url"])
    for label in item.get("labels", []):
        multica("issue", "label", "add", iid, label, check=False)
    return iid

def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("file"); ap.add_argument("--project", required=True)
    ap.add_argument("--apply", action="store_true", help="without it, nothing is written")
    a = ap.parse_args()

    items = json.load(open(a.file, encoding="utf-8"))
    missing = [i for i, x in enumerate(items) if not x.get("source_id") or not x.get("title")]
    if missing:
        sys.exit(f"items at {missing[:5]} lack source_id or title — fix the extraction first")
    dupes = {x["source_id"] for x in items if [y["source_id"] for y in items].count(x["source_id"]) > 1}
    if dupes:
        sys.exit(f"duplicate source_ids in input: {sorted(dupes)[:5]}")

    done = existing_source_ids(a.project)
    print(f"{len(items)} in file · {len(done)} already imported · "
          f"{'APPLYING' if a.apply else 'dry run, nothing will be written'}")

    # parents first, so --parent has something to point at
    order = sorted(items, key=lambda x: bool(x.get("parent")))
    created, skipped, failed = 0, 0, []
    for item in order:
        sid = item["source_id"]
        if sid in done:
            skipped += 1; continue
        parent = item.get("parent")
        if parent:
            if parent not in done:
                failed.append((sid, f"parent {parent} not imported yet")); continue
            item["_parent_id"] = done[parent]
        try:
            iid = create(item, a.project, a.apply)
            if iid: done[sid] = iid
            created += 1
        except Exception as e:                        # one bad row must not kill the batch
            failed.append((sid, str(e).splitlines()[0]))

    print(f"created {created} · skipped {skipped} · failed {len(failed)}")
    for sid, why in failed[:20]:
        print(f"  ! {sid}: {why}")
    if failed:
        print("rerun this command to continue — imported rows are skipped by source_id")
        sys.exit(1)

if __name__ == "__main__":
    main()
