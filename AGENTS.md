# Agent entry point

This repository ships one skill: **multica-ops** — a Mops (Executive Advisor) that builds and
runs an autonomous company of AI agents on [Multica](https://multica.ai).

Whatever harness you are (Claude Code, Codex, Cursor, Windsurf, Gemini CLI, …):
read **[SKILL.md](SKILL.md)** and follow it.
Slash commands are a Claude Code plugin convenience; every flow works from natural
language in any agent — "set up my team", "join this project", "status", "add a
feature: …".

Requires the `multica` CLI on the machine, pointed at a workspace:
`multica setup cloud`, or `multica setup self-host --server-url …` for your own server.
