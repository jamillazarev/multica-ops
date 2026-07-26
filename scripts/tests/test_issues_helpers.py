#!/usr/bin/env python3
"""Offline tests for scripts/issues.py helpers — no live CLI, no pytest.

Run:  python3 scripts/tests/test_issues_helpers.py   (exit 0 = all pass)

Covers the pure logic that decides what resume.sh reruns, plus the graceful-failure
path the reviewer reproduced (`resume.sh --dry-run --project <bad-id>` must exit with a
clean error, never a JSONDecodeError traceback). The CLI is monkeypatched, so these run
anywhere.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))  # scripts/
import issues as I  # noqa: E402

results = []


def check(name, cond):
    results.append((name, bool(cond)))


def expect_exit(name, fn, code):
    try:
        fn()
    except SystemExit as e:
        check(name, e.code == code)
    except BaseException as e:  # a raw traceback is exactly the failure we forbid
        check(name, False)
        print(f"    {name}: unexpected {type(e).__name__}: {e}")
    else:
        check(name, False)


# ---- _loads: shapes it must survive (BOOTSTRAP §8) ----
check("_loads clean array", I._loads('[{"a":1}]') == [{"a": 1}])
check("_loads wrapper object", I._loads('{"issues":[]}') == {"issues": []})
check("_loads human line before json",
      I._loads('Created task.\n{"runs":[{"status":"failed"}]}') == {"runs": [{"status": "failed"}]})
check("_loads control chars stripped", isinstance(I._loads('[{"t":"a\x01b"}]'), list))
check("_loads garbage -> {}", I._loads("total garbage, no json") == {})
check("_loads empty -> {}", I._loads("") == {})
check("_loads None -> {}", I._loads(None) == {})

# ---- is_agent_error: every branch ----
check("agent_error in error string",
      I.is_agent_error({"status": "failed", "error": "limit hit (agent_error) resets 14:00"}) is True)
check("agent_error as status", I.is_agent_error({"status": "agent_error"}) is True)
check("agent_error in reason (case-insensitive)",
      I.is_agent_error({"status": "failed", "reason": "AGENT_ERROR"}) is True)
check("other failure is not agent_error",
      I.is_agent_error({"status": "failed", "failure_reason": "timeout"}) is False)
check("completed is not agent_error", I.is_agent_error({"status": "completed"}) is False)
check("cancelled excluded even if text matches",
      I.is_agent_error({"status": "cancelled", "error": "agent_error"}) is False)
check("empty run is not agent_error", I.is_agent_error({}) is False)

# ---- latest_run: sort by timestamp, else last; wrapper or bare list; empty ----
I._run = lambda _: json.dumps({"runs": [
    {"status": "completed", "created_at": "2026-07-01T00:00:00Z"},
    {"status": "failed", "error": "agent_error", "created_at": "2026-07-25T00:00:00Z"}]})
lr = I.latest_run("X")
check("latest_run picks newest by timestamp", lr.get("status") == "failed" and I.is_agent_error(lr))

I._run = lambda _: 'History:\n[{"status":"failed","error":"agent_error"}]'  # bare list + human line
check("latest_run reads bare-list wrapper", I.is_agent_error(I.latest_run("X")) is True)

I._run = lambda _: json.dumps([{"status": "failed", "error": "agent_error"}, {"status": "completed"}])
check("latest_run no-timestamp falls back to last row", I.latest_run("X").get("status") == "completed")

I._run = lambda _: "[]"
check("latest_run empty history -> {}", I.latest_run("X") == {})

# ---- graceful failure: non-zero exit + clean error, never a traceback (point 3) ----
I._run_full = lambda args: ("", 1, "project not found: bad-id")
expect_exit("all_issues bad project -> SystemExit(2)", lambda: I.all_issues("bad-id"), 2)
expect_exit("project_ids CLI failure -> SystemExit(2)",
            lambda: I.project_ids(), 2)

I._run_full = lambda args: ("not json at all", 0, "")  # rc 0 but garbage
check("all_issues rc0-garbage returns [] (no crash)", I.all_issues("p") == [])
expect_exit("project_ids rc0-garbage -> 'no projects matched'",
            lambda: I.project_ids(), "no projects matched")

# ---- all_issues: bare array and wrapper + pagination ----
I._run_full = lambda args: (json.dumps([{"id": "1"}, {"id": "2"}]), 0, "")
check("all_issues reads a bare array", [i["id"] for i in I.all_issues("p")] == ["1", "2"])

_pages = [json.dumps({"issues": [{"id": "a"}], "has_more": True}),
          json.dumps({"issues": [{"id": "b"}], "has_more": False})]
_seq = iter(_pages)
I._run_full = lambda args: (next(_seq), 0, "")
check("all_issues paginates on has_more", [i["id"] for i in I.all_issues("p")] == ["a", "b"])

# ---- report ----
failed = [n for n, ok in results if not ok]
for n, ok in results:
    print(("PASS " if ok else "FAIL ") + n)
print(f"\n{len(results) - len(failed)}/{len(results)} passed")
sys.exit(1 if failed else 0)
