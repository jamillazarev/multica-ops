#!/usr/bin/env bash
# Overview: counters by status + assigned/in-flight list.
# Usage: bash status.sh [<project-id>]
set -euo pipefail
cd "$(dirname "$0")"

TSV="$(python3 issues.py ${1:-})"

echo "Issues by status:"
printf '%s\n' "$TSV" | cut -f2 | sort | uniq -c | sort -rn | sed 's/^/  /'

echo
echo "Assigned and not finished:"
printf '%s\n' "$TSV" | awk -F'\t' '$3!="" && $2!="done" && $2!="cancelled" {printf "  [%s] %s\n", $2, $6}'

total=$(printf '%s\n' "$TSV" | grep -c . || true)
assigned=$(printf '%s\n' "$TSV" | awk -F'\t' '$3!=""' | grep -c . || true)
echo
echo "total: ${total} · assigned: ${assigned}"
