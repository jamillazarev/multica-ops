# Getting started

From nothing to a running team. If you have never used Multica, start at step 1 — the whole
thing is a few minutes, and after the last step you never type a command again unless you want
to.

## Contents

- [What you need](#what-you-need)
- [1 · Install the skill](#1-install-the-skill)
- [2 · Just say what you're making](#2-just-say-what-youre-making)
- [3 · Answer three questions, then it takes over](#3-answer-three-questions-then-it-takes-over)
- [4 · Getting the new version](#4-getting-the-new-version)
- [Make the skill load, at both ends of the model range](#make-the-skill-load-at-both-ends-of-the-model-range)

## What you need

- **An agent CLI** you already talk to — Claude Code, Cursor, Codex, Windsurf, Gemini CLI. Mops
  runs inside it.
- **The `multica` CLI** — the small binary that connects your machine to a Multica workspace.
  **You install this one** (cloud, self-hosted and the desktop app are different choices, so Mops
  points you at [multica.ai](https://multica.ai) rather than guessing); everything after it is
  Mops's job.

That's it. Once the CLI answers, Mops takes over — no account-setup marathon, no dashboard to
configure.

## 1 · Install the skill

Pick the line for your harness:

```sh
# any agent, via skills.sh
npx skills add jamillazarev/multica-ops

# Claude Code as a plugin (adds slash commands)
claude plugin marketplace add jamillazarev/multica-ops
claude plugin install multica-ops@multica-ops

# into a Multica workspace, as an agent skill
multica skill import --url github.com/jamillazarev/multica-ops/tree/v0.4.4/skills/mops
```

**All three routes were run end to end — measured, not assumed** (the first two on 2026-07-31,
the import re-measured 2026-08-01, each against the version current that day). **What is
measured is the route, never the tag in the line above** — that moves with every release, and
claiming a fresh measurement for a tag that did not exist when the run happened is exactly the
kind of true-looking sentence this file is careful about. Four things worth knowing before you
paste:

- **The plugin route is two commands, two steps.** In-session, `/plugin` opens the same thing as
  a **menu**: paste **only the source** — `jamillazarev/multica-ops` — into its *Add Marketplace*
  field, then install from the list. Both lines in that one field is an error it hands straight
  back.
- **The import URL points at the folder that holds `SKILL.md`, not at the repository.** Here that
  is `skills/mops`. The repository root answers *"The Multica service is temporarily unavailable
  (server error)"* — the CLI mislabelling a 502, which `--debug` shows for what it is. Measured
  both ways on 2026-08-01.
- **Pick one route per harness, not both.** The plugin manifest (`.claude-plugin/`) sits at the
  repository root while the corpus sits in `skills/mops/`, and a skills.sh install names the
  *repository* rather than a folder — so it copies the manifest too, Claude Code sees two plugins
  of one name, and **the installed plugin wins while the copy reads "not loaded"**. No duplicate
  commands, and the copy still serves every *other* harness from `~/.agents/skills/`; delete
  `~/.claude/skills/multica-ops` if you want the message gone.
- **`~/.agents/skills/multica-ops` is load-bearing even if you never chose it.** Found on a real
  machine 2026-08-01: **Factory and Pi both install as a symlink into that path**, and if no
  route ever created it, both links are **broken while looking installed** — the directory
  listing shows the name, and nothing resolves. `scripts/find-installs.sh` reports them as
  `BROKEN`, which is how these two were found. **If you use either harness, put the repository
  there** (a clone, or `rsync -a --delete --exclude .git`) and the links come alive.

In Claude Code the commands arrive **namespaced** — `/multica-ops:init`, `/multica-ops:status`,
and `/multica-ops:mops <anything>` as the free-text front door. The prefix is how plugin commands
always work: it is what stops two plugins colliding over one verb. Everywhere else there are no
slash commands and none are needed — plain language reaches every flow.

## 2 · Just say what you're making

You don't need to know a command. Say what you want — *"set up a team for my Android app"*, *"I
have a Linear backlog, move it here"* — or type **`/multica-ops:mops`** on its own, or even "hi".

**Mops runs "day zero" for you** — six checks, reported as one list with the fix for anything
missing, not six separate prompts:

| Check | If it's missing |
|---|---|
| **Multica installed?** | **This one is yours.** Mops points you at [multica.ai](https://multica.ai) — cloud, self-hosted, or the desktop app (it bundles the CLI) — and picks up as soon as `multica version` answers. It won't install it for you: the options differ enough that guessing is worse than waiting |
| **Up to date?** | tells you what's newer and the line to run — **on a self-hosted server the update is yours, and the server goes first** |
| **Signed in?** | `multica setup cloud`, or `multica setup self-host --server-url …` for your own server |
| **A workspace?** | creates one, or confirms which if you have several |
| **Daemon running?** | `multica daemon start` — this is what actually executes the work |
| **A runtime?** | your agent CLI, auto-detected on PATH — install one if none, then restart the daemon |

Installing or updating anything on your machine is **reported, never done behind your back** —
it's your call, and Mops names exactly what each step does and why. One caveat worth knowing:
`daemon status` answers about the CLI's own profile, so it can read `stopped` while the desktop
app keeps runtimes online. **`multica runtime list` is the probe that tells you whether work can
actually run.**

## 3 · Answer three questions, then it takes over

Once the environment is ready, Mops reads what you have and routes you — you never pick a
command:

| What you have | Where it goes |
|---|---|
| nothing yet | **`/multica-ops:init`** — it *shapes* the work with you, then staffs a team |
| a Multica workspace already | **`/multica-ops:join`** — audits it, then fixes in batches you approve |
| a backlog in Linear / Jira / a CSV | **`/multica-ops:import`** — moves it over, unassigned, nothing runs by itself |
| a question, nothing to build | **`/multica-ops:consult`** — an answer, and no machinery unless it leads there |
| a list of tasks, you'll set the order | **`/multica-ops:mops crew`** — executors and gates, you're the manager |
| a one-hour job | **`/multica-ops:quick <task>`** — one or two agents, build → review, no machinery |

**These are the commands you type** — in full, `/multica-ops:init`, `/multica-ops:join`, so you
copy rather than translate. Plain language always works too ("set up a team"). There is no bare
`/init` and no short `/mops`: outside Claude Code there are no slash commands at all.

The interview adapts to you. Tired of questions? Say **"you decide"** and Mops proposes the whole
setup as one list to confirm or tweak. Want to be closely involved, or barely? That is the first
thing it asks — and it decides how much else you are asked at all.

## 4 · Getting the new version

Say **"is there a new version?"** or run **`/multica-ops:upgrade`**. Mops fetches the update
itself. **New content applies the next time a file is read** — you only restart when the release
adds or renames a command or touches a hook, and **Mops tells you which case it is**. Then it
migrates your workspace, re-screens any imported skills, **tells you the line to update the CLI**
(yours to run, and only when the team is idle), and finishes with a plain-language tour of what
changed.

**Upgrading from an older version?** Slash commands exist only on a Claude Code **plugin**
install, and older releases used different names — so `/multica-ops:upgrade` may say *unknown
command*. Two paths that work from **any** version:

1. **Say "upgrade"** in plain language — no slash needed; Mops runs the flow and gives you the
   one line to run.
2. **Update the install yourself, then restart your agent:** `claude plugin update multica-ops`
   (Claude Code plugin) or `npx skills add jamillazarev/multica-ops` (skills.sh install).

And **"updated everywhere" is a claim about a generated list, never about memory** — run
`bash scripts/find-installs.sh` before updating and again after. It walks every install of this
skill on the machine, reports its version and its update route, and **exits non-zero on a broken
symlink or a silently stale copy**.

## Make the skill load, at both ends of the model range

**Add a trigger rule to the always-on surface your runtime reads** — open the `multica-ops` skill
before acting on requests about running the company, its issues, agents, squads, budgets or
shipping, **on anything that spends, ships, deletes or changes the shape of the team**, and on
questions about how to run work.

**Which surface, per runtime** — this repository already ships two of them:

| Runtime | The surface | 
|---|---|
| Antigravity | `rules/multica-ops.md`, shipped here and always on |
| Gemini CLI | `GEMINI.md`, shipped here |
| Claude Code / Codex in a repo | that repo's `CLAUDE.md` or `AGENTS.md` |
| **the Multica workspace itself** | **the shared guide and the Mops agent's instructions** — there is no `AGENTS.md` in a workspace; the workspace is the company, not a git checkout |

**Both ends need it, for opposite reasons.** A light model may not open the skill because it does
not connect the request to it. **A strong one may not open it because it does not need to**:
measured 2026-08-01 in the sibling project, three runs of *"I want to build a macOS app that
fixes system audio. Set it up."* on a tier above the advisor's floor **invoked no skill and read
no corpus file** — they wrote the app and compiled it. That is a defensible reading of the
request, which is exactly why the rule cannot be left to discovery. **Capability suppresses
recourse to a methodology**, and the anchor is what makes the choice explicit instead of implicit.

