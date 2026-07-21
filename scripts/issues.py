#!/usr/bin/env python3
"""Paginated, corruption-tolerant issue listing for Multica.

Survives the two CLI traps: pages cap at 100 (needs --offset pagination) and raw
control characters in descriptions break json.loads (sanitized here).

Usage:
  python3 issues.py                # all projects in the workspace
  python3 issues.py <project-id>   # one project
  MULTICA_PROJECT_FILTER=<substr> python3 issues.py   # projects whose title contains substr

Prints TSV: id, status, assignee_id, assignee_type, parent_issue_id, title.
"""
import json
import os
import re
import subprocess
import sys


def _clean(s: str) -> str:
    return re.sub(r"[\x00-\x1f]", " ", s)


def _run(args):
    return subprocess.run(["multica", *args], capture_output=True, text=True).stdout


def project_ids() -> list:
    d = json.loads(_clean(_run(["project", "list", "--output", "json"])))
    projs = d if isinstance(d, list) else d.get("projects", [])
    filt = os.environ.get("MULTICA_PROJECT_FILTER", "")
    ids = [p["id"] for p in projs if filt in (p.get("title") or "")]
    if not ids:
        sys.exit("no projects matched")
    return ids


def all_issues(pid: str) -> list:
    out, off = [], 0
    while True:
        d = json.loads(_clean(_run(
            ["issue", "list", "--project", pid, "--output", "json",
             "--limit", "100", "--offset", str(off)])))
        batch = d.get("issues", [])
        out += batch
        if not d.get("has_more") or not batch:
            break
        off += len(batch)
    return out


if __name__ == "__main__":
    pids = [sys.argv[1]] if len(sys.argv) > 1 else project_ids()
    for pid in pids:
        for i in all_issues(pid):
            print("\t".join([
                i["id"],
                i.get("status") or "",
                i.get("assignee_id") or "",
                i.get("assignee_type") or "",
                i.get("parent_issue_id") or "",
                (i.get("title") or "").replace("\t", " "),
            ]))
