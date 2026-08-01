#!/usr/bin/env bash
# Overview: counters by status + assigned/in-flight list + what is waiting on a human.
#
# Waiting work must not look alive. `blocked` is a status someone SET, with a reason
# (GLOSSARY) — on a board it is otherwise indistinguishable from work in progress, so it
# is listed separately and with an age. The age is `updated_at`, i.e. LAST TOUCHED: the
# platform stores no status-change timestamp, so a rename resets it. Read it as "nothing
# has happened here for N days", which is the question that matters anyway.
#
# Usage: bash status.sh [<project-id>]
set -euo pipefail
cd "$(dirname "$0")"

TSV="$(python3 issues.py ${1:-})"

echo "Issues by status:"
printf '%s\n' "$TSV" | cut -f2 | sort | uniq -c | sort -rn | sed 's/^/  /'

echo
echo "Assigned and not finished:"
printf '%s\n' "$TSV" | awk -F'\t' '$3!="" && $2!="done" && $2!="cancelled" && $2!="blocked" {printf "  [%s] %s\n", $2, $6}'

echo
echo "Waiting on a human (blocked, oldest first):"
printf '%s\n' "$TSV" | AGE_NOW="$(date -u +%s)" python3 -c '
import calendar, os, sys, time
now = int(os.environ["AGE_NOW"])
rows = []
for line in sys.stdin.read().splitlines():
    f = line.split("\t")
    if len(f) < 7 or f[1] != "blocked":
        continue
    try:
        secs = now - calendar.timegm(time.strptime(f[6][:19], "%Y-%m-%dT%H:%M:%S"))
    except Exception:
        secs = -1            # an unparseable timestamp is not an age of zero
    rows.append((secs, f[5]))
rows.sort(reverse=True)
for secs, title in rows:
    if secs < 0:
        age = "  ?"
    elif secs >= 86400:
        age = f"{secs // 86400:>2}d"
    else:
        age = f"{secs // 3600:>2}h"
    print(f"  [{age}] {title}")
if not rows:
    print("  (nothing blocked)")
'

total=$(printf '%s\n' "$TSV" | grep -c . || true)
assigned=$(printf '%s\n' "$TSV" | awk -F'\t' '$3!=""' | grep -c . || true)
echo
echo "total: ${total} · assigned: ${assigned}"
