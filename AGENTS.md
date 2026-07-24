# Agent entry point

This repository ships one skill: **multica-ops** — a Mops (Executive Advisor) that builds and
runs an autonomous company of AI agents on [Multica](https://multica.ai).

**Using the skill?** Whatever harness you are (Claude Code, Codex, Cursor, Windsurf, Gemini
CLI, …): read **[SKILL.md](SKILL.md)** and follow it. Slash commands are a Claude Code plugin
convenience; every flow works from natural language in any agent — "set up my team", "join
this project", "status", "add a feature: …".

Requires the `multica` CLI on the machine, pointed at a workspace:
`multica setup cloud`, or `multica setup self-host --server-url …` for your own server.

---

## Changing this repository? Read this part.

Two scripts guard it. Run them; they are fast and they have caught real defects:

```sh
bash scripts/preflight.sh            # form: is the documentation well-made?
python3 scripts/verify.py --live     # truth: do the commands and sources still exist?
```

### What the automation cannot check — and what you must therefore read

The scripts verify **shape and existence**. They are blind to whether a paragraph is still
*correct*, and every expensive defect this repo has shipped was of exactly that kind: a
statement that parsed perfectly, linked correctly, and was false. So before you commit,
**read for these six things** — as a human, or as an agent asked to review, but never assume
a green hook covered them.

**1 · Does this contradict another file?** Rules live in several places on purpose (core,
companion, guide template) and drift apart silently. The core once said squad leaders
"never implement" while ROLES made working craft leads out of them; both files were
internally consistent and the pair was wrong. **If you change a rule, grep for it
everywhere** and fix every copy in the same commit.

**2 · Is the framing still the current one?** Text ages by being outrun, not by breaking.
The docs-site introduction described version 1.x long after 2.1 shipped — every sentence
true when written, the whole page misleading. **When you add a capability, ask what page now
describes an older product.**

**3 · Does a claim about the outside world still hold?** `verify.py` checks commands, flags
and URLs. It cannot check that a command still *means* what we say it means: `multica setup`
exists and prints configuration, while our text implied it performs setup. **If a sentence
explains what a tool does, run the tool.**

**4 · Are the numbers still measured?** Any figure about ourselves rots — the guide template
was quoted at ~1.7k tokens after it had grown. One such claim is now checked automatically;
the rest are not. **If you quote a size, a count or a share, re-measure it.**

**5 · Does the example still match the rule?** EXAMPLES.md and the templates demonstrate the
standard the prose describes. Change the standard and the demonstration quietly becomes the
counter-example.

**6 · Is this reachable?** A capability that no command, use case, routing trigger or index
points at does not exist for the agent who needs it. The hook checks command coherence; it
cannot tell that a *concept* has no door.

### Writing the changelog

The changelog is the migration map `/upgrade` reads, and it is also what a stranger uses to
decide whether to adopt this. Both audiences want the same thing: **what changed for me, and
what must I do differently.**

- **Lead with the capability or the consequence, not the discovery.** "`/import` brings a
  backlog over from Linear" — not "we noticed imports were unhandled".
- **A fix is worth an entry when it changes what a reader should do**: a recipe they may have
  copied, a behaviour they relied on. Say it plainly and briefly, including the remedy.
- **The story of how a defect was found belongs in the commit message**, where the next
  maintainer will look for it. It does not belong in the release notes, and a changelog full
  of self-audit reads as a product made of bugs rather than one kept honest.
- **Never rewrite a released entry's substance.** Versions are public; correct forward.

### Cutting a release

A version bump is not just a changelog entry. Before you tag:

1. **Refresh the evals.** Every new behaviour needs a scenario, or it has no regression test —
   evals go stale silently (2.3 shipped a release behind until caught by hand). preflight warns
   when the version bumped and `evals/README.md` didn't.
2. **Run the four review lenses** (deletion · adversarial · contradiction · cold-read) on the
   changed skill — they find the class of defect no script can: a sentence that parses, links
   and is false. This is not optional for a minor or major; a patch can skip it.
3. **Keep the guards current — they rot too.** A new capability usually needs a new check, and
   this session's guards were mostly added *reactively*, after a defect shipped. Ask *before*:
   does this change need a guard, or break an existing one's assumption? The rot surfaces are
   the guards' own hardcoded lists — `verify.py`'s `STRUCTURAL`/`IGNORE` object sets and `SMOKE`
   calls, `check-structure.py`'s section-contiguity and command checks, the CLI pin. A guard
   that no longer matches reality passes silently, which is worse than no guard.
4. **`bash scripts/preflight.sh` and `python3 scripts/verify.py --live` green**, and the docs
   site rebuilds.
5. **Changelog** leads with the capability or the consequence, not the archaeology of how a
   defect was found (that goes in the commit message).
