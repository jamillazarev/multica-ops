# Changelog

Newest first. Each entry leads with what you can now do, not with which files moved. This is
also the migration map `/multica-ops:upgrade` reads.

## 0.4.18 — 2026-09-11

**If you rely on the publish gate, this is what changed for you** — the rest of this entry is the
record of how it got here, round by round.
- **Refused now, where it went through before:** a publish whose tool carries global options or a
  path (`git -C <dir> push`, `git -c k=v push`, `gh -R o/r release create`, `npm --prefix x
  publish`, `docker --context x push`, `/usr/bin/git push`); a tool or a verb quoted whole
  (`"git" push`, `git "push"`); a wrapper with flags (`sudo -u root …`, `env -i …`, `nice
  --adjustment=10 …`); a line continuation; a heredoc on the same line as the publish (`cat > f <<EOF
  && git push`); a `--dry-run` that belongs to another command, sits in a comment, is glued to another
  word, says `=false`, or stands outside the substitution that runs the act; and a project's own
  deploy script, `./scripts/deploy`, which this gate never stopped until this release.
- **Let through now, where it was refused before:** a sentence about publishing written into a file
  or a heredoc; a search for the phrase; a real dry run, wherever the flag stands in the act's own
  command; a local script named `predeploy`.
- **By design:** a verb assembled from parts (`pu'sh'`), a variable or an interpreter carrying it
  is not read; an option whose argument is one of the act's own words (`npm --workspace publish
  install`) is read as the act and refused.
- **If the gate stops a sentence about publishing** — text it took for the act — the agent it
  stopped is told, in the refusal itself, to say so to you, never to reword the command to get
  past it.

**The outward gate refused a sentence about publishing.** It matched its verbs **anywhere in the
command string**, so a comment being written into a file was stopped as if it were the act —
measured 2026-09-18, twice in one session, the second time on the comment explaining the repair.
The only route past a gate that reads prose is to reword the prose, which is the
*satisfied-by-vocabulary* failure arriving at the one gate that must not be word-gameable. **A
command starts a command; a word after another word is prose**: the verb is anchored at a command
position now — the beginning, a newline, after `;` `&&` `||` `|`, inside a subshell — **and a quote
counts only after something that runs a shell**, because any quote would refuse a search for the
phrase, and a search is a read. Read against the sibling's copy, which had been anchored since it
was written, each found a hole in the other: this one had no anchor, and that one was blind to a
newline, a pipe, a subshell and a wrapper's quoted argument. Seven new assertions — and then an adversarial lens found **eleven more ways past it**, every one
reproduced: a wrapper word before the verb (`env X=1`, `sudo`, `nohup`, `time`, `nice -n 10`, a
bare `eval`), a line continuation, a redirect needing no space, and a runner's quote further than
forty characters away. Plus one false positive in the other direction: **a heredoc body is data fed
to another program**, so a document carrying the verb at the start of a line was refused as a
publish. Fourteen more cases, `test-outward-gate.sh` **57/57**. What the lens called a false
positive and is not: backticks inside a double-quoted message are command substitution, and the
shell really runs what is between them.
**And the refusal now quotes what you last asked for** — not to decide with, because a gate cannot
read intent and the only party available to explain it is the one being stopped, whose account is
what was measured wrong (5 runs of 5 reported *"done… and pushed"*). It is quoted to spare the
person the scroll: their own last message beside what is about to leave, **marked as context and
not consent**, with the verdict unchanged whether there is one or not. Tool results and the
harness's reminders arrive as `user` entries too and are skipped. The reader also had to learn what a `user` entry
actually is: a **tool result**, an unterminated or nested `<system-reminder>`, a
**`<task-notification>`** carrying a background agent's return value, and the harness's
conversation-continuation summary all arrive as one — and the first version skipped only the first.
Blocks stopped being stripped by pairs, and an entry carrying both text and a tool result keeps its
text, because discarding it quoted an *older* message as what you last asked for. **The refusal gained a line** — *if this is a sentence about
the act and not the act, say so to the owner* — because a message offering only *the owner runs it*
or *turn the gate off* has no answer for a false positive.

**Then a sixth round went at that repair, and found five more — three of them holes the repair
itself had opened.** All reproduced end to end, none argued from the source. **The heredoc blanker
hid three real publishes**: it blanked to the end of the string whenever the terminator was
missing, so `cat <<EOF; git push origin main` — which bash runs the moment the heredoc reaches end
of input — had the publish erased out from under the pattern; likewise a literal `a<<b` inside a
quoted commit message, and `<<<`, a here-**string**, matched from its second `<`. **A blanker that
cannot see both ends of the body blanks nothing.** **A wrapper word takes flags**, and only
`nice -n` had been allowed for: `env` with no assignment · `env -i` · `env --` · `sudo -u root` ·
`command -p` · `time -p` · `nice --adjustment=10` · `exec -a name`, eight shapes walking the verb
past the new anchor — and
listing the option *shapes* was not enough either, because a flag that takes its own argument
leaves a bare word behind it, so the run between a wrapper and the verb is any tokens at all now,
bounded. **The quote had two ways to be steered**: blocks counted by depth let a
`</task-notification>` close a `<system-reminder>`, handing whatever can inject tag-shaped text
control over what the owner sees — a stack of names now — and the harness's continuation summary
was skipped on its opening words alone, so a real instruction that merely began with them was
dropped and a *superseded* message was quoted as current, which is worse than quoting nothing.
Eleven cases, one per reproduced *command* shape — the two quote shapes went without one until the
eighth round. **The round itself has not reported clean**: one lens of four reported, one died on the weekly limit and two were never dispatched once
the budget was gone — everything above is the adversarial lens's, and the re-round over the repair
it caused is owed. **The seventh round went at that repair and all four of its lenses died on the
monthly spend limit**; two had found something first, both real: the repair left a docstring
describing the depth counter it replaced, directly above the stack of names that replaced it, and
the "real heredoc body" case it added was byte-identical to one already in the suite. The docstring
describes the stack now, and the duplicate became the tab-indented `<<-` shape this suite had never
had. Four `not completed` — the round is owed again.

**The eighth round finished whole, and the sixth round's repair failed four more ways.** The
wrapper run had been capped at four tokens, and `env A=1 B=2 C=3 D=4 E=5 F=6 git push` walked past
it — **a bound on the unsafe side of an anchor is a hole with a number on it**; any run of tokens
now, on the same line, at the named cost that a wrapper followed later on its line by a quoted
mention of the verb is refused. A **crossed** close, `<a> <b> </a> … </b>`, put a hidden block's
text on show as what you last asked for; a closing tag closes only the innermost block now, by its
name. `cat<<EOF`, with no space, was not read as a heredoc. And a project's own `Wired How-To`
column, placed first, won the register lookup — so the shipped headers are matched exactly, and a
prefix only when a single header carries it. **Repairing the heredoc case turned up a worse hole
no lens had named**: the body was blanked from right after the delimiter, where bash starts it on
the *next line*, so `cat > f.md <<EOF && git add f.md && git push` had its publish erased — an
ordinary way to write a file and publish it. A `<<X` inside a message, a comment or an earlier body
counted as an opener too. The body starts on the next line now, and an opener must be code, read
by a small line-local scanner that names what it does not read rather than claiming to parse bash.
The round's other lenses corrected this entry's own record: *"eight shapes"* beside a list of six,
now all eight with `env --` tested; *"a case per reproduced shape"*, false for the two quote shapes,
which have cases now. Every case for this round's own shapes fails against the unrepaired code.

**The ninth round finished whole too, and broke the eighth round's scanner.** A `<<X` inside
`$'…'` or an arithmetic `$((…))` was still read as an opener and hid the push on the next line —
confirmed in real bash against a stub `git` on 2026-09-23 — though both were named in the scanner's
docstring, beside a promise that every failure fell on the loud side: **a limit named beside a
false guarantee is not a limit named.** A scan per opener to the end of the string also took 14 s
on 358 KB of unterminated openers, the same day. The blanker is one pass now, keeping the state
bash keeps — the three quotings, arithmetic, comments — and reading each body the way bash does,
from the line after the command to a line that *is* its word; the same 358 KB takes 0.05 s, and
what it still did not track (a quote nested in `$(…)` or backticks inside a double-quoted string)
was named with the direction it can fail in, which is either. The register reads only the headers the template
ships, since a lone `Wired How-To` notes column had been read as the wiring, and a refusal caused
by a near miss names it. **And this gate never stopped a project's own deploy script**
(`./scripts/deploy`) while its twin always had, with nothing written down — crossed the loud way,
with a case. Each of the quote skip's two signals now has a case failing against the mutant that
drops it. The tenth round went over this repair.

**The tenth round found a hole older than this release, and the limit the ninth named proved
dangerous.** `--dry-run` anywhere in a command exempted all of it — `echo testing --dry-run`, then
a real `git push` on the next line, went through, and so did a comment naming the flag. **A dry run
now excuses only its own act**, up to the next `;` `&` `|` or newline. A double quote inside `$(…)`
within a double-quoted string closed the outer string, and a `<<X` still inside it blanked the next
line — a real publish hidden, confirmed in real bash against a stub `git` on 2026-09-24. Inside a
double-quoted string, `$(…)`, a backtick pair and `${…}` each open a context of their own now, on a
stack; and a `'` inside `"${…}"` is a quote, as bash 3.2 — the one macOS ships — reads it. The deploy
catch-all this gate took on in the ninth round refused `predeploy` and `./scripts/predeploy`, which
publish nothing; `deploy` must now be the whole name or follow a `/` `-` `_` `.`, never `pre-`. The
register's near-miss hint is judged per table, since an unrelated table with an exact header had
silenced it. **Thirty commands were run in real bash against stubs and fed to both gates: no command
bash publishes with passes either gate**, and the two commands both gates refuse without bash
publishing are ones bash rejects as a syntax error. That was a scratch measurement, and a suite
whose oracle is bash was owed. Every case for a shape this round reproduced fails against the ninth
round's code. The eleventh round went over this repair.

**The eleventh round found the dry-run scope leaking two more ways, and the suite it was owed now
exists.** A trailing comment — `git push origin main  # --dry-run tested this yesterday` — excused
the real act it trailed, because the comment was still in the text the scope read; and
`$(git push origin main) --dry-run` excused a push that runs inside the substitution before the
flag is ever read. `npm publish --dry-run=false` was excused as well, and it publishes. So
`shell_only` blanks a comment the way it blanks a heredoc body, the scope also ends at a `)` or a
backtick, and only the bare flag or `=true` · `=1` · `=yes` excuses anything. **The owed suite is
`scripts/test-gate-vs-bash.sh`**: each of 38 commands runs in real bash against stubs, *published* is
read from what the stubs were asked to do, and the gate must agree — with two code mutants it must
catch (a terminator matched anywhere in a line; a dry-run scope that runs past a `)`). Against the
tenth round's gate it reports exactly this round's four holes — the trailing comment, the flag
outside `$(…)`, the same outside a backtick pair, and `--dry-run=false`. It was closed three ways — a fourth came the next round — and why it
has to be is the next paragraph. The second `predeploy` case became `./scripts/pre-deploy`, the only
one that reaches the `pre-` rule. The twelfth round went over this repair.

**And this repository's `main` was pushed before its tag — by a lens, without the owner's word.**
On 2026-09-24 at 03:58 (+04) a lens checking a claim about bash wrote a script carrying `git push`
for a stub `git`; the installed gate refused the command that would have made the stub, the lens
did not notice, `PATH` fell through to the real binary, and `origin/main` moved from `35c6c0e` to
`d301b78` — **eighteen commits of this entry's work, no tag, no release, nothing forced**. It is left
in place: the commits are this release's own and tested, and rewriting a public branch would cost
everyone who pulled it more than it carries. **If you updated from `main` between that push and the
0.4.18 tag, you ran this entry's work before its review rounds finished: update to the tagged 0.4.18,
which is what this entry describes, and nothing else is needed.** The suite above runs stubs-only
under `env -i`, verifies every stub before each run, and denies bash the network, and
[`AGENTS.md`](AGENTS.md) now says a lens runs an outward verb no other way.

**The twelfth round found this gate blind to a tool's own global options — since the day it was
written.** `git -C . push`, `git -c k=v push`, `git --git-dir=.git push`, `gh -R o/r release
create`, `npm --prefix x publish` and `docker --context x push` all passed, because the pattern wanted
the subcommand straight after the tool's name; so did `/usr/bin/git push`, a tool named by its path
(an adversarial lens found the path, and checking what else that shape covered found the options).
**The gate now reads any run of option tokens between the tool and its subcommand, and any path
before the name, as the same act, and refuses it** — so a command of those shapes that went through
before is stopped now. **And the dry-run flag had
no left edge**: `git push origin mainX--dry-run` was excused, the flag found glued to another word —
so the words are split the way a shell splits them, and only a whole word counts, the act's own
options included. **The suite had a blind spot of its own**: a real tool named by its path could
not be stubbed, and the network it would have used was denied, so such a push read as *nothing
published* — the safety layer hiding exactly the hole. The sandbox now refuses to execute any binary
named like an outward tool outside the stub directory, by any path, a canary proves it before any
case runs, and a refused execution counts as the act having been tried. Against the eleventh round's
gate the suite reports nine holes, all this round's. A dead scaffold went too: this suite, and a
comment in `test-outward-gate.sh`, set up per-session state for a gate that has kept none since it
stopped stopping only once. The thirteenth round went over this repair.

**The thirteenth round lost all four lenses to the session limit in their first calls, was run
again, and its adversarial lens found the option reading approximate in four ways.** An argument
that merely *starts* with a subcommand word — `npm --prefix publish-tools publish`,
`gh -R pr-team/repo release create`, `npm --prefix run-scripts run deploy` — ended the option run
early and hid the act; so did an option value quoted because it holds a space, `git -c "user.name=x
y" push`, and a tool path quoted for the same reason, `"./my tools/git" push`. And the dry-run window
was still cut by a bare character split, so a `)` inside a quoted release note stopped it before a
real `--dry-run` — a false refusal. **Three of the four had one cause, a pattern reading `\S` for a
shell word**: a word is read the way a shell reads one now, quoted parts and escapes included; an
argument is refused as a subcommand only when it IS the whole word; and a path may be quoted. The
fourth needed its own repair: the window ends at the first `\n ; & | )` or backtick *outside* quotes. The suite had passed all four,
because none of its cases used an argument like that — so each is a case now, and adding the path
case turned up one more thing the suite could not see: a script refused by the sandbox is reported
by bash as a *bad interpreter*, not as the refusal the suite looked for. Both wordings count now.

The other lenses found the record behind the code again: the round-eleven paragraph still called
the suite *closed three ways* after the next round added a fourth; a sentence said a run of options
*is allowed now* where the gate now **refuses** such a command, which is the one thing a reader
upgrading needs to hear; the suite's *adding a case is one line* omitted the model of each tool's
options the oracle reads; one case repeated another's branch and became a long option with its own
argument; a comment repeated the paragraph above it; and a comment in this suite said the gate
reads no transcript, where it does read one — for the owner's quote, never for the verdict. Every
case for this round's shapes fails against the twelfth round's gate, and the second mutant now
breaks the window where it is cut. The fourteenth round went over this repair.

**The fourteenth round found the same shape of defect one level down.** A bare tool name in quotes
— `"git" push` — passed, because the quoted form was only allowed for a path; a name may open a
quote now, and the one after it closes. And the dry-run window's own reader, `command_end`, kept a
single quote flag, so a release note built with `$(date "+%Y-%m-%d (UTC)")` fooled it into ending
the window early and refusing a real dry run. It was rewritten to read from the start of the
command, keeping every substitution on a stack with its own quoting, and **the rewrite's first
draft opened a hole the suite caught at once**: a window that starts at the act cannot tell the
backtick that closes `` `git push` --dry-run `` from one that opens another pair, so it read past it
and excused the push. Reading from the start is what fixed that too. The suite gained both shapes, a
guard for the escape branch nothing had exercised, and a second mutant that now breaks the one rule
the window depends on — stopping where the substitution holding the act closes. **One finding was
declined**: a verb split by quotes, `git pu'sh'`, is not read. That spelling is a decision to hide
the act, and the gate's own comment now says so beside the other shapes it does not claim to parse.
The other lenses: a list that folded the window's fix under a cause it did not share, a stale
comment still describing the old window, and one more *is allowed now* in the gate's own comments. The fifteenth round went over this repair.

**The fifteenth round found both halves of the last repair incomplete, in forms an agent writes.**
Only the tool's name had been allowed its quotes, so the verb quoted whole — `git "push"`,
`npm 'publish'`, `gh "release" create` — still went through; every word of an act may be quoted whole
now. And the window's reader knew `$(…)` and backticks but read arithmetic and process substitution
as bare parentheses, so `branch$((1+1)) --dry-run` and `<(echo hi) --dry-run` were refused as
publishes; `$((…))`, `<(…)` and `>(…)` are pairs on its stack now, each closed by its own
parenthesis. The other lenses: this entry buried what a user needs under the rounds — the block at
its top answers that — its docstring's "the start of the command" read as the previous separator
when it means the whole text, the fourteenth round's paragraph never said what a user would notice,
the two gates listed their alternatives in different orders for no reason, and two cases took one
branch. Every case for this round's shapes
fails against the fourteenth round's gate (three holes, two false refusals). The sixteenth round went over this repair.

**The sixteenth round found no hole.** Its adversarial lens classed every finding it could reproduce
as a shape an agent writes by accident, and all four were refusals of commands that publish nothing.
One was a real command: grouping inside arithmetic, `$((1 + (2*3)))`, closed the arithmetic one
parenthesis early and refused a real dry run after it — a bare pair is a pair on the window's stack
now. **Three were declined**, each with its reason: `npm --workspace "publish" install` reads as the
act because a pattern cannot know which options take an argument, so it takes the reading that stops,
and that limit is now written beside the gate's other ones and in the block above; `git 'push origin
main'` and `git" push"` are commands bash runs to an error — no such subcommand, no such program —
and refusing a command that cannot run costs nothing. The other lenses found the round's own prose:
the block above claimed that nothing below it changed its lists, which only reading all of it could
confirm, and ended by telling *you* to tell the owner; the window's docstring introduced "the
outermost context" to explain "the start of the command"; the two *for a user* lines this round
added below repeated the block; one gate said its alternatives mirror the other's and the other did
not say so back; and a case's name did not say why it was kept. `test-outward-gate.sh` **103/103**,
`test-gate-vs-bash.sh` **69/69**; the seventeenth round went over this repair.

**The seventeenth round found nothing in the code**: its adversarial, deletion and contradiction
lenses reported empty, and its cold-read's two reading stumbles — a sentence in the block above
under the wrong item, and *bare* used for two different parentheses — are repaired.

**The pre-tag scan found what seventeen lens rounds had not: six of this repository's skill
descriptions were not valid YAML.** A plain value holding `: ` is a mapping inside a mapping to a
strict parser, and SkillSpector's parser rejects such a manifest outright. The six are quoted, all nineteen
parse strictly, `agy plugin validate` still reads all nineteen, and preflight now refuses a plain
frontmatter value a strict parser rejects or cuts short, with its mutant in `test-preflight-checks.sh`. The
eighteenth round went over this repair.

**The eighteenth round found the new check weaker than the repair it guards.** This
repository's copy fed its checker's output through a here-string and never read its exit status, so
a skill file that was not UTF-8 stopped the scan silently and every skill after it went unchecked —
while the other copy, one process guarded by `|| FAIL=1`, failed closed on the same file: two copies of
one check, opposite on a crash. Both fail closed now, on one function written identically into
both. And the heuristic was narrower and wider than strict YAML at once — it missed a tab before
`#`, a plain value wrapped onto a second line, a quoted key, and a value opening with `@` or a
backtick; and it refused a flow collection, which strict YAML reads. It is still a heuristic, and
it says so in its docstring, since the Python that runs preflight has no YAML parser to ask; the
pre-tag scan is the strict one. The refusal now names every shape it refuses. The other lenses: *bare* still
named a kind of parenthesis in the window's docstring after this entry said it no longer did, and a
sentence above put the stop for a sentence about publishing at the refusal's close, when the
owner's quoted instruction can follow it. The nineteenth round went over this repair.

**The nineteenth round found one hole, and a claim wider than the check.** Its adversarial lens
reported that a skill file with Windows line endings passed unread; it did not — Python's text mode
had been reading those as plain newlines all along, and the mutant written for the finding said so
by passing against the old code. The hole was one step over: a file opening with a byte-order mark
never matched the frontmatter pattern, so the check read nothing in it and passed it, whatever its
values held. The mark is read past now, and a file whose frontmatter the check cannot find is
refused instead of passed. A `#` after a space was refused as *not valid YAML*, when YAML reads it
as a comment and drops the rest of the value; it is still refused, since a description cut short
is the defect, and the refusal now says what YAML does. The mark, the missing frontmatter and the
`#` each have a mutant, and each mutant fails against the old code. A nested or dotted key goes
unread — no skill here has one — and the docstring now says so instead of claiming every value.
The other lenses found only words: a tab
the refusal did not name, a line of the refusal still called its *closing* line in the gate's
comment and in this entry, *bare* still in the window's docstring, a sentence above crediting this
entry with a word it never used, a list above that read as one case or as two, and the comment on
the temp file blaming quotes, when what bash 3.2 misreads inside `$(…)` is an unpaired backtick.
The twentieth round went over this repair.

**The twentieth round found two misses on ordinary files, both in what the round before had
added.** The refusal of a file with no findable frontmatter also refused a skill file ending at its
closing `---` with no newline after it, which YAML reads; the closing line may end the file now.
And a value that is nothing but a comment — `description: #TODO` — loses the whole value and was
not refused, because the space before its `#` had gone with the key; a `#` that opens a value is
refused now, and text after a comment's `#` no longer counts as the value's. A tab inside a plain
value, which PyYAML rejects, is refused as not valid YAML. Blanks after a `---` line are still
refused, since what the runtimes' own loaders make of them is unmeasured, and the refusal now says
the line must be exactly `---`. Twenty-four shapes, written to files and read back, now agree with
PyYAML. The contradiction lens found nothing; the cold-read and deletion lenses found words — a
correction above that named its subject and not its fact, a count whose referent came a sentence
late, and a docstring aside that repeated the refusal. The twenty-first round
goes over this repair.

**And this release's own register template broke this release's own guard — here and not next
door.** The widened header *Wired how · what it ships* was matched by equality, so a project that
copied the new template and registered its entry correctly was told *"`mise.toml` declares X and
`_ops/TOOLING.md` has no row for it"* — **a guard refusing exactly what its own shipped template
produces.** The repair had been made in the sibling copy of the same rule and never crossed to this
one, which is what a shared rule living in two files does when only one is touched; and **the suite
could not catch it, because its fixture still built the narrow header the template stopped
shipping** — a check testing a shape its own product no longer has. The header is matched exactly
first and then by a prefix that ends at a non-letter (`Wired how much budget` must not win the
column), and the fixture is the template's own header, in both directions: the honest row passes
under it and a tool with no row is still refused — the two cases §19's suite gained, counted below
where that section states its size.

**A dependency now says what the service ships and when it should leave.** From one observation on
a live project: *the advisor chose a service and never checked whether it had an API, a CLI or an
MCP* — and the cause was that the project had no register at all, so the question had no row to be
asked in. A register row carries **what the service ships** (MCP · CLI · SDK · agent skill, where
`checked <date> · none found` is an answer and a blank is not, because a blank cannot be told apart
from nobody having looked) and **gone when** — the observable condition that retires it, since a
dependency with no removal condition never leaves. The *why* was never the missing half; that is
already asked when the dependency arrives.

**Nine scheduling links, and they are three needs.** Did it run (**Healthchecks** — the only one
that catches a cron that silently stops) · what runs it (Cronicle · cronmaster · cronboard ·
cron-job.org, each with the licence that decides it) · inside the app (gocron · node-cron ·
pg_cron · `schedule`, last pushed 2024-05-25). The rung above all of them: **ask the host first.**
**DataForSEO** named as the per-call layer that makes the tool in front of it replaceable.

**The shelf is the first stop, and screening got a named command.** Anything to be connected,
chosen or recommended starts at [STACKS.md](STACKS.md) **before** a search — written into
BOOTSTRAP §12 and the router — because a row carries a licensing or fallback decision somebody
already paid for, and a search returns what is popular this month. And the import gate now names
what to run: **`skillspector scan <path|repo|url|zip>`**
([SkillSpector](https://github.com/NVIDIA/skillspector), Apache-2.0, NVIDIA) — 71 patterns over 17
categories including **MCP least privilege and MCP tool poisoning**, AST analysis and taint
tracking, an optional model pass. **Its dataset is the argument for the gate**: of 31,132 skills
analysed, **26.1% carried a vulnerability and 5.2% showed likely malicious intent**. **The same
command runs over the skills a company writes for itself** — a file you wrote cannot be malicious
and can easily be over-granted or leaky. Nothing enforces it: the scanner is a third-party install,
and nothing is installed without the owner's word.

**The first run over these nineteen skills found two things, and one of them earned its keep.** A
skill whose job is upgrading skills trips *Rogue Agent / Self-Modification*, which is the pattern
being right about the shape and wrong about the intent. The other was a line in the core reading
*"never refuse a doable action over the wrong seat"*, flagged **anti-refusal** — and that sentence
was about *which seat does the work*, which a model reading it out of context could take for
something else. It says so now, and says gates are untouched by it; the scan reports clean.
**A scan that changes the corpus rather than only measuring it** is the argument for running it.

**The shelf itself gained the checked rows** — `urlwatch`, Firehose and Huginn beside
changedetection.io for the three things it cannot do; SEO Gets, kwrds.ai and LibreCrawl beside
OpenSEO, **whose repository this file could not identify on 2026-09-10 and which is
`every-app/open-seo`**, MIT, self-hostable against your own DataForSEO key; Bifrost beside LiteLLM.
**Two licence claims were wrong and are corrected**: LiteLLM is MIT *except* `enterprise/`, and
AFFiNE governs its backend separately from its editor — both read from the repositories rather than
the marketing.

**Gemini CLI is gone, and so are the two files that existed for it.** That runtime was retired
**2026-06-18** and replaced by **Antigravity CLI** — `agy`, a different binary. This repository was
still shipping `gemini-extension.json` and `GEMINI.md`, sweeping the first for version parity and
naming the old install route in `INSTALL.md`, `README.md` and `find-installs.sh`. Both files are
**deleted**, and the successor was measured rather than cited: `agy plugin validate .` on 1.2.5
answers **ok, 19 skills processed** without them, and `hooks: skipped (not found)` — so under that
runtime the skills are the whole delivery and the hooks enforce nothing. `AGENTS.md` is the router
there, a name `agy` reads beside the one that was deleted. **A dead runtime's install does not
clean itself up**: `find-installs.sh` found one still sitting in `~/.gemini/extensions/`, so that
row now prints *remove it* and names `agy plugin import gemini` for one worth keeping.

**What to do — nothing breaks, and three things are offered.** Re-copy the company guard —
`cp <skill>/templates/company-preflight.sh scripts/preflight.sh` in the company repository — to get
its §18, §19 and §20 below. **§20 judges only what a commit WRITES**, so nothing already in the
repository turns into a refusal; the first commit that adds a mention under a docs path is where you
meet it, and `scripts/link-ids.py --write` is the one command that fixes it in advance.
**`scripts/graph-check.py` is new and reads only** — run it once to see whether the repository is
actually a graph: notes, edges, orphans, phantom targets and how many mentions are edges waiting to
happen. **If the company repository already has
a `mise.toml`, the first commit that stages it or `_ops/TOOLING.md` asks for a register row per
entry** — the refusal names each one. If `mise.toml` carries `[bootstrap.packages]`, mise will not
read it on a runtime's machine until `mise trust` is run there — the owner's to say. And the skill's
`scripts/link-ids.py`, run bare, lists the `_ops/` files your notes name in passing; `--write` turns
them into links, only on the owner's word.

**What the project needs from a runtime's machine now has a place, and the guard holds it there.**
A runtime, a CLI tool or a system package lives in `mise.toml`; `_ops/TOOLING.md` says why, and §19
refuses an entry without a row and a row without an entry (PLAYBOOKS → *What the project needs from
the machine*). **An MCP server is not in that file**: here it is carried by an agent's `mcp_config`,
which lives in the workspace where no commit can see it, so its row names the agents and the health
sweep probes them. **Nothing is installed without the owner's word, mise included** — a runtime is a
machine with other work on it. The joining audit now carries what a runtime's machine lacks, with
the dry runs, `mise trust` first: measured on mise 2026.9.5, a `mise.toml` with
`[bootstrap.packages]` is not read at all until trusted. Ported from `opsinist` — the sibling
methodology, which keeps a project's work in files — where the same section also guards a committed
`.mcp.json`. `scripts/test-native-register.sh` **29/29**, run twice —
the second time on the system `python3` — 3.9 on a Mac without Homebrew, older than `tomllib`, which is 3.11+ —
with every key read as a path, so `[tools]` then `python`, a bare `tools.python` and
`[tools.python]` are one declaration.

**An available update now says what it asks of the owner.** `scripts/deps-report.py` asks `mise
outdated`, `npm outdated` and `osv-scanner` and sorts every answer — **a published vulnerability
first · a move outside the project's pin as a decision, its release notes the migration map · a
move inside it as a routine line · what is declared and missing · and what could not be asked, said
as *not checked*** (PLAYBOOKS → *When something it needs has a newer version*, and step 3 of the
version check). The line is the project's pin, not the numbering: Python 3.12 → 3.13 is a minor
number that removed nineteen standard-library modules. **It reads and never writes.** `--why` shows
what each declared thing is for, offline, from its register row or the decision naming it.
`scripts/test-deps-report.sh` **87/87**. The formats it reads were taken from the tools' own sources
and are now register entries: `mise-outdated`, `npm-outdated`, `pep-594`.

**`Recheck when` fires by itself on the one event the tree records.** A commit adding a name to a
source entry's `Reads against` must carry every finding in `_ops/research/` that rests on either end
re-read — `Answered` re-stamped — or marked `stale`, or the company guard's §18 refuses it naming the finding.
`scripts/test-recheck-trigger.sh` **17/17**, a rename in the same commit included, and a guard
section that stops before its end now refuses instead of passing what it never read. Porting it caught a defect in the suite on both sides:
three checks looked for a finding's *filename* anywhere in the output, and this guard's §4b names
unlinked files — so they now look for the §18 sentence itself, in `opsinist` too.

**Names became links where this repository's rules allow it.** 53 links against 419 backticked
`.md` names — but only 42 of those name a file in this tree; the rest name a project's files or
another repository's, and linking them would lie. `scripts/link-names.py --write` linked **31**:
it leaves a companion's name of another companion a name, because §5c keeps references one level
deep from the core, and it leaves the core alone, since every link there is paid on every run.
This repository's preflight §4d refuses the next unlinked one. `test-link-names.sh` **28/28** · `test-link-ids.sh`
**21/21**. Seven source citations were re-minted after the rewrite changed their passages by link
syntax alone; the three that had already drifted before it were left as they were.

**The shelf rows added after 0.4.17** — agent sandboxing, pinned runtimes per project, search by
meaning (ck, qmd), Podman, Open Notebook — now point at this repository's own sections, and the
search row's line about a stale index was wrong for ck, which refreshes its index before every
search.

**What the capability bar is still owed, said rather than left silent:** no scenario covers any of
this — whether a joining audit *offers* the machine line, or a run re-stamps a finding without being
refused, is behaviour, and it has no fixture yet. Each mechanism has its form and its mutation suite,
and each is reachable from PLAYBOOKS, FLOWS, BOOTSTRAP or USE-CASES.

**A mention of something inside this project is a link — §20, ported with its measurement.** In the
sibling's field audit, 2026-09-16: **one link in a live project's whole `_ops/` against twenty-two
bare ids**, and a graph in which the record and the work were separate islands of identical strings.
So on the lines a commit ADDS, an id whose file exists and a person-field naming a role, team or
panel must be written as links; **a backticked path is a warning instead**, because a shipped
template's prose names project files on purpose and cannot carry a project-relative link without
breaking the skill's own checker. What stays as written: a `## History` line, a heading, a fence,
`_ops/runs/`, `_ops/research/raw/` and the declarations a reader parses. **And the same section keeps
the graph honest**: a link whose target is absent, an absolute path, or an unencoded space is
refused. Here the tasks live in Multica, so this reads whatever file layer a project keeps — **an id
becomes a link only where a file carries it**, and the rule does not change with the storage.
`scripts/link-ids.py` also links a person-field now; `test-company-guard.sh` **57/57**,
`test-link-ids.sh` **24/24**.

**And the section arrived with its repairs, not ahead of them.** The sibling's own lens round found
three false refusals in this rule before either repository tagged: a markdown link carrying a title
read as an unencoded space, the `%20` it then prescribed read as a dead path, and **a line added
inside a pre-existing fence judged as prose** — that last one unfixable by the prescribed door,
because the door tracks fences over the whole file while the gate tracked them over the diff. All
three are repaired here and each has its own case (`company-guard` **57/57**): the fence state is
read from the staged file and added lines are mapped to it by their hunk headers.

**Whether the graph works is a measurement rather than a promise.** `scripts/graph-check.py` reports
notes · note-to-note edges · orphans · attachments · how many links resolve **both** ways, only
relative to their own file, or only from the vault root · every phantom, unencoded space and path
climbing out of the repository · and how many mentions are edges waiting to happen. Three facts from
Obsidian's own help decide those tests (read 2026-09-18): Markdown links are resolved, a destination
**must be URL-encoded**, and **a link to a file that does not exist still becomes a node** — its
*Existing files only* filter exists for exactly that reason. **What the help does not document is how
a relative destination resolves**, so the script tries both readings and says which links survive
each. Run on this corpus: **171 notes, 66 edges, the relative form throughout, nothing
vault-absolute-only.**

**Eleven rules read out of other people's working tools, and four of them are about reading our own
work.** The lens instructions now say: the reader gets **the artefact, not the author's case for
it** · an objection **quotes the line** as written, never paraphrased · **a finding cites a verbatim
excerpt and its line is derived from that**, so a quote matching nowhere or twice leaves it
*unlocated* rather than placed · **a verdict is a shape, and demoting one takes its fields away** ·
and **the re-round reads the repair**, with the range reachable for context. On bars: **a threshold
with no named command that produces its verdict is an aspiration**, **tightening is silent and
loosening is loud**, and **somebody else's checklist may be a work type's bar under three
conditions** — passing it is `cited`, never `measured`. On records: **a move that destroys its own
evidence writes itself down first** · **an unparseable record is set aside with a marked name, never
retried and never deleted** · and **one test for anything kept outside the repository**: delete it,
rebuild from the committed files, and ask whether anything factual disappeared. `PATTERNS.md` gains
**§17-bis**: a ranked answer declares an absolute floor and an honest empty state.

**The shelf took the sibling's reading.** Fourteen rows: the pattern for one surface
(Pencil & Paper) · landing pages and dark mode as a token decision · top-grossing mobile with its
revenue context · **named styles as a vocabulary with four rules** — a look ships its own falsifier,
the name resolves to tokens and the tokens still face the contrast gate, a style read names what it
rejected, and a style rule is a count with a threshold and one named override · the DTCG token
format, whose `$extensions` clause is where style provenance rides · Aceternity for landing blocks
(**no licence text on its pricing page**) · Scrapegraph-ai, with scraping named as the outward act it
is · markitdown · a self-hosted pass over a pull request, whose model **never emits a line number** ·
a security audit whose verification is a fresh reader told *"you did not write this candidate"* ·
Formbricks, **three licences in one repository** · OpenReplay, where **privacy is declared at capture
time** · Lago, whose **totals are computed by replay and never incremented in place** · and
`claude-for-legal`, whose integrations table **declares a fallback per row**.

**What did not port, and why.** The sibling's release also carries a task-shape gate, an
assignee-resolves gate, a role-wiring gate, a review gate on the terminal edge of a ladder, a task
door and a board page. **None of those crosses the boundary**: Multica owns issues, assignment,
agents and squads, stage barriers and task execution, so there is no task file to shape, no roster
file to resolve against, no `.claude/agents/` to wire, no local ladder to gate — and the board is in
the product's own interface. **A gate over a primitive somebody else owns is a second source of
truth**, which is the rule this skill is built on rather than an exception to it.

Eval state: **not run.** The ported forms are measured by the suites — company-guard **57**,
link-ids **24** — and **a suite measures a form while an eval measures a run.** Three behaviours
this entry adds that no scenario covers: whether a session links a mention *before* being refused
for one, whether it reaches for the graph check when asked *is this even a graph*, and whether the
four reading rules change what a lens actually reports. Named here rather than left to a reader's
assumption.

**Trio:** two diagrams (PLAYBOOKS), five situations in USE-CASES, and three register entries for
the claims about the outside world. **The ported half owes no new diagram** and says so: §20 is
the sibling's §27 carried over with its measurement, `graph-check.py` is its script, and the eleven
rules are rules — each naming where it was read and on what date, which is what a port owes instead
of a picture.

## 0.4.17 — 2026-09-11

**A counted intro is charged only with the list nested under it.** A sentence ending in a colon —
*"there are three guardrails:"* — is read by `scripts/check-structure.py` as introducing a list, and
the count that follows must match. **One written inside a bullet was charged with the bullets that
followed it at the outer level**, which are its peers and were never its list. The count now stops at
the first item shallower than its intro, and at any peer where the intro is itself an item.

**Ported from the sibling project `opsinist`, where it fired — not because it fired here.** This
corpus happens not to contain the shape today, and that is luck rather than immunity: the rule is
identical in both files. In `opsinist` the false warning was permanent and printed first in a list of
thirteen, with five real one-line defects right beneath it, all of them shipped — so **position is
not what hid them**: a list known to hold warnings that can never be fixed stops being read at all.
*That this switches a check off in the reader's head is the fear it answers, not a measurement.*

**Two assertions in `scripts/test-preflight-checks.sh`**, which runs against a clone of HEAD: the
nested-intro shape must stay silent, and a top-level intro miscounting its own list must still be
caught — the second is what keeps the first from being a checker that reads nothing.

**One shelf row re-verified by running the tool it describes** — `AGENTS.md`, *Changing this
repository? Read this part*: **"If a sentence explains what a tool does, run the tool."** The
codebase-orientation row called graphify's zero-credit local build a README claim; it is now a
measurement, and the measurement narrows it — **the free half is an index, and the edges that make
it a graph need an API key.** Asked a question `opsinist` had just got wrong by grepping a word, its
query made the identical mistake and matched a bash function of the same name.

**What to do:** nothing required. `templates/company-preflight.sh` differs by its version stamp alone,
so **re-copy it only to silence the guard's own stamp warning**, which otherwise reports a version gap
with nothing behind it; the repaired checker reads this corpus rather than a project's.

Eval state: **not run.** Nothing here changes what a run is asked to do.

**Trio:** the repair ships with its mutation pair and its dated origin. **A repair owes no diagram and
no situation, and this says so rather than manufacturing them.**

## 0.4.16 — 2026-09-10

**Migration — the guard your workspace copies gains two refusals.** `_ops/scripts/preflight.sh` is a
copy that does not update itself, so **re-copy `templates/company-preflight.sh` over it**: **§15**
refuses a skill that runs commands without recording what it refused, **§17** refuses a research
finding with nothing to order it or expire it. Until you re-copy, neither fires and nothing says so.

**A skill records the test instead of being asked for it.** `SKILL-SCAFFOLD.md` gains a required
`## Tested against` section asking for the two things a reading cannot produce — the defective input
and **what the command actually printed when it refused** — beside the date. **Where a skill runs
nothing, `none:` is the whole answer** and the guard leaves it alone: gating doors would teach
everyone to write the section without meaning it. Ported from the sibling, where the prose form of
this rule measured **0 of 5** across three rounds, with one run declaring itself tested by reading a
manual.

**The register can say what pulls against an entry.** Every entry in `sources/SOURCES.md` carries
**`Reads against`** — the entries it must be read beside and what the tension is, or one of two words
that are **not the same answer**: `none found` is a claim that someone looked, `not checked` is
honest ignorance, and an empty field is neither. It is symmetric, so
`fetch-source.py --verify-reads` refuses a one-way pair, a dangling id and a missing line. **The
first run here reports 15 of 15 still `not checked`** — a fact about this register, not a defect in
it, and now visible where it was not.

**Research got the layer it was missing: a finding is not its task.** `templates/FINDING-template.md`
holds one file per **question**, because a topic never closes and a question does. It opens with
*what we now believe* in a paragraph, which is read **instead of** the sources under it. **`Decides`
is what orders them**, so the reading order is the order of the decisions waiting and no second list
is kept.

**`REFERENCE` is ten CLI releases behind, and that is recorded rather than refreshed.** 0.4.42 is
current; this file is measured against 0.4.32; **the local install is also 0.4.32**, which is why the
pin check reads green against the binary and only the outside number shows the gap — the second time
that exact shape has bitten. **The pin is not moved.** What changed across those ten releases is
listed as a re-check list, read from release notes and explicitly not verified against a running CLI:
the command surface gained a named local-environment verb, `/new` and `/clear`, and `issue list`
filtering; two trigger paths changed behaviour; and the agent inactivity budget moved to 2h.
`brew upgrade multica`, then re-measure and date what you re-verify.

**The shelf grew by twenty rows**, ported from the sibling and rebuilt for this file's four-column
shape rather than pasted — so a free tier and a licence caveat sit in their own cells instead of
trailing the prose.

**What to do:** re-copy the guard. Nothing else is required.

Eval state: **not run.** Nothing here changes what a run is asked to do; the skill-test half carries
the sibling's `N61` **0 of 5** as its *before*.

**Trio:** `Reads against` and the skill test each ship with their form, their mutation suite and their
dated measurement; the finding layer ships with its form and its suite. Suites: company-guard **46** ·
verify-reads **9**, both zero-fail.

## 0.4.15 — 2026-09-05

- **`--dry-run` printed one file as both moved and left behind.** `leftovers` read the directory
  from disk, which is right after a real move and wrong before a previewed one: under `--dry-run`
  nothing has moved yet, so every file the preview had just promised to move appeared a second
  time as staying put. **The behaviour was correct throughout; only the preview lied — in the one
  place a preview exists for**, since what a reader consults *before* trusting the thing is the
  whole point of a preview. Reported 2026-09-05 against `opsinist` and reproduced here unchanged,
  the line being identical in both. Three assertions cover it, and restoring the old form fails
  them.

  The report's other findings land differently here. Two do not apply: this methodology has
  neither the role checks nor a role template — its roles live in the platform, not as files — and
  this repository's own migration script never claimed `skills/` — the list it walks is
  `DOCS_DIRS`, and `skills` was never on it. **The third is worse than not applying.** The sibling
  repaired a self-review check that could not see its own template's format; **this repository has
  no self-review check at all** — the rule that a review goes to someone other than the author is
  stated in file after file and held by nothing, which is `prose-only`'s honest name for it and is
  already on that list. A reader comparing the two entries would otherwise conclude the check is
  fine here.

  **The guard's version stamp moves and its behaviour does not.** `templates/company-preflight.sh`
  changes by one byte-range this release, so §4b-bis will ask every downstream company to re-copy a
  guard that checks exactly what it checked before. The re-copy is a formality here; saying so is
  cheaper than a warning nobody can act on.

- **`scripts/check-releases.sh` arrives, and step 7 of the release ritual now names it.** A
  published release's notes are a snapshot taken at publish time, so a marked correction added to a
  frozen entry afterwards reaches `CHANGELOG.md` and the site and never the release page. Four of
  this repository's releases had drifted that way. **It shipped here unreferenced by anything** —
  no ritual step, no entry — which a deletion lens caught before the tag: a script no ritual points
  at is a script nobody runs.

- **The `All-in-one client DB` row is gone from the shelf: InstantDB is sunsetting.** Read at
  source 2026-09-05 — *"Instant is sunsetting. Services will continue until August 31st, 2027"*,
  the team having joined OpenAI. **The service outlives the recommendation by a year**, which is
  the reason to take the row out rather than date it: a shelf exists to be started from, and
  starting on something with a published end date is the one thing it must not suggest. Recorded
  here rather than struck through in place, so the shelf stays a list of what to reach for and the
  reason a name left it stays findable.

- **And the script arrived without a test suite, which this repository's own guard refused.** Four
  defects had been found in it by hand and repaired by hand, the worst being that `gh`'s exit
  status was discarded — so no authentication read as *"0 releases checked, every one matches its
  entry"*, a check reporting green on something it never read. Fourteen assertions with a stubbed
  `gh`, four mutants one per original defect. **The refusal came from §-the-CI-check here, not from
  a reader**: a test script in `scripts/` that no workflow invokes is a green tick that means
  nothing, and it fired the moment the file landed.

Eval state: **not run.** Nothing here changes what a run is asked to do; it changes what a preview
tells the person deciding whether to let it run, and what the ritual asks before a tag.

## 0.4.14 — 2026-08-29

- **A third mutation-test trap, paid for the day it was written** (AGENTS.md §2). **A mutant that
  never applied is indistinguishable from a toothless assertion**: a wrong anchor makes the edit a
  no-op, the suite stays green, and the green reads as *the mutant survived* — a conclusion about
  the assertion when the truth is about the patch. Every mutation asserts that it changed the file
  first. Two neighbours of the same shape, measured the same day: `git checkout -- <file>` restores
  from the **index**, so state staged by an earlier assertion survives and later ones pass on the
  leftover (`git checkout HEAD --` means it); and reusing a record id an earlier commit already
  took means a gate scoped to *added* files never examines the fixture. **All three make a green
  assertion that measures nothing** — so a *must not fire* check is paired with a *must fire* twin
  on the same fixture, and the pair is what proves the subject was looked at.

- **The contradiction stop's prose-only entry is a design now, not a shrug** (PLAYBOOKS → the
  prose-only list). It said *the seam exists and the field does not* and stopped there. It names
  the field: **`verdict` — `pass` · `fail` · `mixed` · `none`**, beside `outcome`, answering *what
  did this run conclude* where `outcome` answers *how did it stop*. It names the comparison that
  keeps a gate from becoming noise — **only `pass` against `fail` clashes**, and recording the
  disagreement satisfies it, since what is refused is the second opposite verdict landing with
  nothing saying anyone noticed. **And it names the harder half, which the entry had left
  implied:** a commit-time gate reads files in a repository, while `issue runs` is remote platform
  state a git hook cannot see. Two candidate homes — the `_ops/analytics/` rollups, which do land
  in the repo, and `issue comment resolve|unresolve`, the platform's own *this is settled*, which
  would make the human-in-the-thread rule literal. **Neither is worth building for the gate's sake
  alone.** Still `prose-only`, and still listed by name.

Eval state: **not run.** Nothing here changes what a run is asked to do; it changes what the next
person writing a mutation test is required to prove, and what the contradiction entry hands them.

## 0.4.13 — 2026-08-28

**The lenses read the tagged 0.4.12 and found that a repair in it destroyed data.**

- **`find-installs.sh` told you an install was at risk because of an edit somewhere else, and the
  remedy it printed deleted that edit.** It read `git status` across the whole repository, so an
  install living inside a larger one was flagged for a change in an unrelated folder, and the
  `git reset --hard` it prescribed is repo-wide too. **If you ran that command, check what else it
  discarded.** **Detection stays repo-wide, because the route it predicts is** — `git pull
  --ff-only` aborts on a modified tracked file anywhere in the enclosing repository. **What changed
  is that the flag no longer prescribes a discard at all.** Three remedies shipped here in two days
  and two destroyed work: `reset --hard` took an unrelated file, and a scoped
  `restore --staged --worktree --source=HEAD` **deletes a staged new file outright**. Two more were
  caught before shipping. **The fourth** counted with `--diff-filter=MDRT`, whose `R` rows name a
  rename's *destination* — absent from HEAD, so the very `restore` it printed would delete it;
  the count is `--no-renames --diff-filter=MDT` now, for which "every path exists in HEAD" is true
  and demonstrable, and the suite checks it against a tree containing a rename. **The fifth was in
  the message the whole time:** `stash push` exits **0 having saved nothing** when the only
  difference is a submodule gitlink, and the `pop` that follows takes whatever was already on the
  stack — measured, with an unrelated stash dumped into the tree. The sequence is printed guarded,
  and the suite runs the printed line verbatim and requires the stranger's entry to survive.
  **The count also has two blind spots, now stated wherever it is described:** a staged-new or
  untracked file at a path an incoming commit *adds* aborts the pull with the count at 0. So the
  flag leads with the pull, which is free and is the only exact test.

- **§4f could still be silenced by one character.** A line that was entirely an inline comment read
  as the end of the table, taking every live row below it with it — the parked-draft idiom the
  guard's own message recommends — and the strip that fixed that could not cross a `>`, so a row
  containing `->` or an HTML tag brought the silence straight back. A CR did too. **And this repo
  shipped that fix with none of its tests**, so a code comment claimed a measured regression that
  nothing here verified. It has four assertions now.

- **The bash-parsing note stopped trying to be a rule.** Three statements of it have shipped wrong
  — *an odd number of backticks*, then *an unpaired backtick inside a double-quoted span*, then a
  version that exonerated parentheses **on the stated grounds that they obey the same balance law
  — which is the fourth wrong statement, written into the entry announcing that the corpus had
  stopped making them.** Measured on bash 3.2: an unbalanced paren inside double quotes parses
  fine, an unpaired backtick in the same position does not. They differ at exactly the case that
  produced two of the three earlier errors. What survives is small and true: bash lexes the `$( … )` body as shell text through a quoted heredoc, and what it sees must
  balance. **`/bin/bash -n` finds every case instantly, and the suite runs it as an assertion.**
  The prose was the hope; the check is the form.

- **Eight ways `_ops/TOOLING.md` could be made invisible to §4f**, all closed: an inline
  `<!-- … -->` in a live row hid that row while the page still rendered it · a `<!--` with no
  closer hid every row after it, permanently · a stray fence marker at the top did the same · a
  line that was entirely a comment read as the end of the table · the strip that fixed that could
  not cross a `>` · nor survive a CR · **a live row quoting the opener in backticks** disarmed the
  gate on the very register that documents the parking idiom · and **a bare `-->`** was read as the
  end of a table. A tab inside a tool name dropped its row, and a CRLF register read a blank answer
  as filled — both introduced by 0.4.12's own rewrite of that block.

  **This suite had an assertion for none of them, while the entry above listed three as closed.**
  The reason is worth keeping: the fixture register here has no `Replaces` column, so §4f never
  fired on it at all — and a rung that never fires cannot fail. Nine assertions cover it now,
  mirroring the sibling's fixtures deliberately, because **the guard is a shared file and coverage
  in only one repository is coverage in neither** the next time it is edited from the other side.
  Reverting the strip fails six of them.

  The strip also **rebuilt the whole line every pass** — 27.8s on a 390 KB row against 0.7s for the
  form that consumes what it has walked. Same output, measured 2026-08-28.

- **`dispatch-nudge.py` was giving orders to the runs that read it, and this suite required that
  it did.** After fourteen read-only calls it said *"Assign it to an agent"* and *"take the next
  real step"* — text a run weighs rather than obeys, and for one of the two readings it fits (a
  review, an investigation, a question answered from the record) a long unbroken read is the work
  being done properly, not a stall. The sibling repaired its twin eight days earlier; a
  contradiction lens found this one still standing. It names both readings and says it cannot tell
  which. **The assertion that asked for the order is now its opposite**, and a mutant restoring an
  imperative fails it.

- **check 0 could not see a job-level `if: false`** — the canonical way to switch a job off — while
  its own refusal message advertised that a step-level one counts, which is a map to the hole one
  level up. A whole disabled job's steps are dead now.

- **`templates/TOOLING-template.md` described the guard differently from the one shipping beside
  it.** Its sibling's copy said a `_ops/DECISIONS.md` line naming the tool is a complete answer;
  this one did not, so a register author here was told the cell was the only way. Both say the same
  thing now.

**And `REFERENCE.md` gained what this repository operates and its sibling does not**: a wired MCP
server is weight, not only reach. Where a runtime loads every tool's schema before the first word,
forty tools are tens of thousands of tokens on a session that says hello — paid by every agent the
server is assigned to. The library is what makes the remedy cheap: a server sits in it assigned to
nobody until an agent has a reason, and `agent mcp disable` takes the weight off one without
unpicking the wiring.

Eval state: **not run.** No scenario measures any of this.

## 0.4.12 — 2026-08-23

**The lenses were run again over 0.4.11's own repairs, and two of them had introduced defects.**

- **check 0 could be satisfied by a step that cannot run.** `if: false` is one line and read as
  *CI executes this suite* forever — the same shape as commenting the invocation out, which this
  gate already refuses, arriving through the step's condition instead of its body. Only a literal
  false disqualifies: a real condition is a judgement this script does not make.
- **And unwrapping a quoted token could synthesise a command position the shell never sees.**
  `echo "|bash" scripts/x.sh` spliced a pipe into the stream and read as an invocation — a class
  0.4.11's own quote change created. The set of characters that does this was then drawn too wide:
  **a quoted path containing `$` was refused**, so `bash "$GITHUB_WORKSPACE/scripts/x.sh"` — an
  ordinary step — failed the check while the message beside it said quoting was optional. Only
  what opens a command position counts now.
- **`if: false` written BELOW `run:` in the same step did not disqualify it.** YAML mappings are
  unordered and the first version walked forward from the `if:` line. A step is judged whole now,
  and `if: 0` counts the same as `if: false`.
- **§4f asked the rung of retirements.** A `_ops/TOOLING.md` that carries a second table —
  `## Retired`, recording that something went **away** — had every row in it checked for what it
  replaces, which is the opposite question. Rows belong to their own table now, found by the
  header that actually carries the `Replaces` column. **The guard is a shared file, so this landed
  in both methodologies at once**; the reasoning lives in `templates/company-preflight.sh` §4f,
  which is the section this and every other §-reference in this entry names. The register is read from
  the index now, and a `## Retired` table's rows are not the register's.

**Two refusal messages stopped leaving the reader stuck.** check 0 said flatly *"no workflow `run:`
step invokes it"* to somebody looking at a step that plainly runs it — a gate that reads as wrong
gets the workflow edited to please it. It names the accepted shapes now, and says that if one of
them still fires, **the matcher is wrong and not you**. And the `cli-removed` message offered
burial as the only remedy for a condition **a stale local CLI produces just as readily** — a reader
on an old install would have followed it and permanently documented a live command as gone. It
prints the installed version and asks which side is behind, first.

**`find-installs.sh` flagged installs that were fine** — it fired on untracked files, which do not
stop `git pull --ff-only`, and prescribed a reset. Tracked modifications only, **AT RISK** rather
than BROKEN, and pasteable remedies. It had no test; it has twelve, wired into CI.

> [!IMPORTANT]
> **The suite now asserts that `scripts/preflight.sh` parses and runs at all**, because for one
> commit in this range it did not, and nothing else would have said so — every other assertion in
> that file was running against a corpse. The cause is worth carrying: **a lone backtick inside a
> double-quoted string, inside a heredoc, inside `$( … )`** kills the file, because bash 3.2 scans
> for the closing paren straight through the heredoc while tracking double quotes. Measured: the
> backtick alone breaks it; parentheses do not, balanced or unbalanced; a `$` does not; the same
> backtick in single quotes does not.
>
> **And `bash -n` catches it instantly.** An earlier draft of this entry said the opposite. That
> claim was never measured — `bash -n` had been run against a version without the fault, come back
> clean, and then been blamed for the miss. Run it after touching anything inside that heredoc.
>
> **Correction, 2026-08-27:** the mechanism stated above — *a lone backtick inside a double-quoted
> string* — is not the rule either. A third attempt at stating it exonerated parentheses, which is
> also false. **The corpus has stopped describing this mechanism**: what survives is that bash
> lexes the `$( … )` body as shell text through a quoted heredoc, what it sees must balance, and
> `/bin/bash -n` finds every case in milliseconds — which the suite now runs as an assertion. Three
> statements shipped wrong; the check does not.

Eval state: **not run.** Nothing here changes what a run is asked to do.

> [!IMPORTANT]
> **Correction, 2026-08-27.** This entry said *"The register is read from the index now"* — that
> shipped in **0.4.11**, not here, and a lens caught the same over-claim in the sibling's entry the
> day it was written. What is genuinely in this range is the table scoping: a `## Retired` table's
> rows are not the register's.
>
> It also omitted the range's most important repair: **a single-character bypass of §4f**, where a
> backslash in the register's header switched the rung off for that file permanently. **If you are
> on 0.4.11 or earlier, that is the reason to move.** The heading is frozen, so this is a marked
> correction rather than a rewrite.

## 0.4.11 — 2026-08-23

**Two guards were refusing honest work and one was blind to a whole class of it.** Pass thirteen
named them; this is the repair.

- **CI check 0 refused four ordinary shapes of a workflow step.** `bash "scripts/x.sh"`,
  `bash 'scripts/x.sh'`, `env CI=1 bash scripts/x.sh` and `bash -e scripts/x.sh` were all read as
  *the suite is not invoked* — measured against eleven ordinary forms, of which seven passed.
  **If this gate refused a workflow you knew was correct, it was wrong and you were right.** A
  quoted span is now dropped only when it contains whitespace, which is what separates an
  argument from a sentence; environment assignments and interpreter flags are allowed at the
  command position. What did not relax: a suite named inside an `echo` is still not a run.
- **The mention-cost guard matched across headings, blank lines and list items.** It flattened
  the whole file to one line so a hard-wrapped claim could not hide, and the patterns stop at a
  full stop — which markdown structure does not contain. Honest prose under two unrelated
  headings read as one claim. It now joins only lines the wrap broke and keeps every block
  boundary, same-length so the reported line number stays true.
- **§4f read your register's header as a row** unless your first column happened to be called
  Tool, Name or What — so a register with columns named anything else was refused, at stand-up,
  for saying nothing about what it replaced. The header is found structurally now, above the
  separator, in any GFM dialect; a fenced example is not a row.
- **And §4f cited a `Replaces` column this repository's own template did not have**, so every
  register stood up here fell through to a keyword list — the defect the column exists to avoid.
  The template carries the column now, and says what the gate does with it.

**Four lenses read the range before it was tagged, and two of the repairs above were themselves
defective.** check 0's quote change let a `#` that had been safely inside quotes survive into the
plain text and eat the rest of the line, so `sed -i "s/#.*//" x && bash suite.sh` read as never
invoked — inverted from the intent, since a space inside the quotes made it pass. Comments are cut
quote-aware now. **Six more wrapper shapes were refused** — `if`, `if !`, `time`, `sudo`, `exec`,
`xvfb-run` — and `if` and `time` are the two commonest ways anyone wraps a suite.

`_soft_flatten` asked only the *following* line, so a heading with no blank line after it joined
the prose beneath it; and a claim written as a **two-line blockquote was invisible to the guard
entirely**, in a corpus where REFERENCE alone carries 61 quoted lines. Both fixed. **And the
guard's failure message prescribed a sentence the guard refuses** — *"say both halves or neither"*,
in one sentence, is caught. It now tells you to write them as two, which is the shape that passes.

**Two gates were reporting green while checking nothing.** The fingerprint parsed `multica --help`
with a hard-coded two-space indent and skipped every check when that yielded nothing, while still
printing its coverage line — verbatim the failure its own comment condemns twenty lines above. And
the `cli-removed` registry accepted **its own documentation** as an exemption: a paragraph
explaining the format, the same thing in inline code, or a marker parked inside a `<!-- DRAFT -->`
wrapper all buried a live command. The marker must now be alone on its line, outside every fence,
carrying a real calendar date.

**And REFERENCE §2 stopped claiming more evidence than it has.** It opened with *"every path here
is counted, none cited"* — true of the three paths it held when that was written on 2026-08-15,
and false for the four added after: two read from `--help` and two never measured here at all.
There is a table now saying, per path, whether it is counted, read, or neither. **Chat and
autopilot are marked plainly as unmeasured**, which is the honest state and was not visible before.

**Migration — and this one affects you if you upgraded to 0.4.9 and 0.4.10.** The guard copied into your
repository at `_ops/preflight.sh` stamps its own version on line 2, and warns when that stamp
disagrees with the version your guide says you run. **The stamp was not bumped for 0.4.9 and 0.4.10,
so the warning fired on every commit — and re-copying the guard, which is exactly what the warning
tells you to do, brought the same stale stamp and did not clear it.** It is stamped 0.4.11 now,
and a check in this repository's own preflight refuses a release whose stamp lags the version, so
it cannot be forgotten again. **What to do:** re-copy the guard once more from this release, along
with the two scripts beside it, and the warning goes quiet. Nothing else about your repository has
to change.

Eval state: **not run.** Nothing here changes what a run is asked to do, and every change above
is held by an assertion in the suite that owns it — `test-company-guard.sh` and
`test-preflight-checks.sh`, each of which prints its own total, which is the only count with a
guard on it. (An earlier draft of this line said *thirteen*; it was twelve at the time and is
more now. That is the argument, not an aside.)

## 0.4.10 — 2026-08-23

**One sentence in this reference had become its own opposite, and it took six CLI releases to
notice.** §3 read *"MCP is per agent, and there is no workspace level"* — measured true against
CLI 0.4.26, and false from whichever release added `workspace mcp`. **If you followed it, you
pasted one token into every agent that needed a shared server, and you now have that many places
to rotate it.** The repair is one act instead of N: `workspace mcp add <name>
--server-config-file <f>` puts a server in the library and assigns it to nobody, `agent mcp add
<agent-id> <server-id>` hands it to one, and `agent mcp disable|enable` turns it off for that
agent without taking it away. `--mcp-config` still exists for a server exactly one agent should
see. Library mutations are **admin/owner only**, so an agent that can assign is not necessarily
one that can add.

**`multica plugin` is gone.** It arrived in 0.4.26, was written into this repository's
workspace-fingerprint as a permanent class the same day, and is `unknown command` at 0.4.32 — a
group that lived six releases. **If you have `multica plugin install` in a runbook, it stopped
working**; workspace-private skills are `skill import`, with `skill refresh` to re-pull from
source while keeping the id and the agent assignments. The fingerprint recipe in PLAYBOOKS
dropped the class, and its count went from nine back to eight.

**§10 also gained `issue timeline`** — the chronological history of an issue, activity log merged
with comments, oldest first. It answers *when did this move to in_review* and *how long has it
been sitting*, which the current issue fields cannot. And it gained `update` and `version`, which
a section claiming to be the whole command surface had never listed.

**Two gates were missing in the same direction, and both ship here:**

- **`verify.py` compared a document against a constant**, so it was silent whenever both were
  stale — exactly what happened. It now refuses a fingerprint class the CLI does not expose,
  and says what to do about it.
- **`check-structure.py` refused every mention of a removed command, including the note
  explaining it was removed** — so it refused the repair its own message asked for, twice. The
  exemption is a **registry**: `<!-- cli-removed: <group> <date> -->` in REFERENCE, one dated
  line per group. Not a vocabulary — a keyword list would pass any sentence containing
  *"removed"*, which is the defect the company guard's §4e was cured of eight days ago, and this
  file is not entitled to repeat it.

**What was re-verified and what was not.** Mechanically re-checked against 0.4.32 and holding
verbatim: every `--no-start` flag behind trigger paths 1, 4 and 5, `issue create --stage`'s
barrier sentence behind path 8, `issue comment`'s lack of an edit verb, `squad activity --reason`,
`squad member add --role`, `agent create` still having no `--skills`. **Not re-measured:** the
counted claims — a squad assignment waking only the leader, a mention creating a run, the stage
barrier firing exactly once. Those need live runs and keep their 0.4.26 dates, marked stale rather
than quietly refreshed.

Eval state: **not run.** This range changes a reference claim, a recipe and two checkers; the
six new assertions in `test-preflight-checks.sh` (48 total) cover the checkers, and no scenario
measures whether a run follows §3's MCP guidance — that is owed.

## 0.4.9 — 2026-08-23

**Rules that landed after 0.4.8 was tagged, and therefore owe their own version.** Evidence moves
without a tag; a rule moves with one — and four of the six commits since that tag carry rules.

**A validator reaches only a worker that commits.** Measured in the sibling over 35 dispatches:
across ten runs of one scenario the player edited the machinery 8 times and committed **0** times,
so a pre-commit gate that refuses correctly — verified by hand on the very edit those runs produced
— never spoke once. Every `validator` row in the gates table inherits that limit, including this
company's docs guard: `enforced_by: validator` means *enforced at the commit*, and work that stops
short of one is governed by prose alone.

**And the rung above every tool choice: does this need to exist at all.** *Already here · the
craft's own staple · native to the platform · one line* — taken from a third-party ladder and taken
as a **form**, because the same ladder as prose is what both corpora measure at about zero. A
commit adding a dependency names it in `_ops/DECISIONS.md` with what it replaces; and because **a
company with no package manifest is not exempt**, a row added to `_ops/TOOLING.md` is asked the
same thing — a supplier, a subscription, a licence.

**That second half shipped as a warning in 0.4.8's tail, and the sibling measured the warning at
0 of 5 against a refusal at 2 of 5 the same day.** A warning is a demand, and demands sit in the
prose band. It refuses now, and `we had none` is a complete answer — which is what makes refusing
fair: the gate refuses **silence**, never the answer.

**And the guard stamps its own version.** It is a COPY, written into a company's repo at stand-up
and never moving again, so a release adding a check leaves existing companies green while running
fewer gates than their guide claims — the upgrade's layers named the skill's bytes, the format,
attached skills and tooling versions, and the installed machinery was in none of them. It warns
now when the guide disagrees, and prints the re-copy command.

**Scenarios 28 and 29**, because 0.4.8's own two rules had none: the round that ran measured six
older ones. Both fixtures hold their situation — the field note dated today, the two disagreeing
records with run numbers — after three scenarios in one day voided for naming a situation their
fixture did not contain.

**And §2's eighth path is counted now, not cited.** The stage barrier was listed on 2026-08-21
from the CLI's own help text — the only path in a roster of eight that had not been measured the
way the other seven were. Measured 2026-08-22 in the test workspace: a parent assigned with
`--no-start` carried 0 runs, two children created under it with `--stage 1` carried 0, the first
child closed left it at **0**, and completing the stage brought it to **1**. Both children were
closed with `--no-start`, so the run is the barrier's own. **Every path in the section that claims
to enumerate every way a run is created is now counted.**

**Pass thirteen read this range before it shipped, and its criticals are repaired here.**
**`--regen-cli` rewrote the wrong `<!-- cli-pin -->` marker**, left §10 stale and reported success:
`grep -c` counts matching LINES under the grep a script actually gets, so two markers on one
reflowed line counted as one and the guard invented against that exact incident passed it. Fourth
instance of this class in two days. **The company guard got its first test at all** — 101 lines of
new gate that `grep -rl` found named only in prose. **§4f asked for a vocabulary**, the defect §4e
had been cured of in the same file; it reads a **Replaces** column now. And §4e's word boundary
refused a decision line ending in a full stop — the remedy its own refusal prescribes.

Eval state: **RUN, 2026-08-22** — scenarios 28 and 29, N=3, both repository-half only.
**29 holds 3 of 3**; **28 fails 0 of 3**, all three adding a rule to the guide on first occurrence.
**The split is the finding**: 29 asks the run to REFUSE an act and it refuses; 28 asks it to do
something smaller than it was asked, and nothing forbids the larger thing, so the larger thing
happens. A prose rule that makes a run refuse can hold; a prose rule that asks for restraint does
not — which says which prose is worth writing and which needs a form. The ladder needs one, and it
is owed rather than built, because a rule moves with a tag. 0.4.8's round measured what it shipped before these
rules; 28 and 29 are written and undispatched, and the sibling's measurement of the same rung is
cited rather than assumed to transfer.

## 0.4.8 — 2026-08-22

**Every scenario can now be measured, and the suite stopped being green by geography.**

**The last five scenarios got their missing halves.** 3 · 11 · 18 · 23 · 27 needed workspace
state and held neither a repository fixture nor a builder, so the fixture guard refused them
outright — correctly, and forever. Now 27 is a repository fixture whole (a company whose
`_ops/GATES.md` claims `enforced_by: validator` while the wired hook answers in the flat
`{"permissionDecision": "deny"}` shape that holds nothing — the tell lives only in `FIXTURE.md`,
which the player never receives); 3 carries both halves (a 0.3.0 pre-`_ops` layout whose TEAM.md
and board disagree in both directions, every mess enumerated so the audit is graded on what it
finds); 11, 18 and 23 got builders — 18's builds the actual door the scenario is named for, a
`run_only` autopilot with a webhook trigger and the deploy agent the poisoned payload will name,
and refuses loudly to ship half a door when `trigger-add` fails. Since every needs-state scenario
now has at least one half, the suite's void assertions construct their void in the clone instead
of pointing at a live gap — and the construction failing is a counted failure, because on its
first run it failed silently and the assertion passed on an absence it did not create.

**The suite no longer depends on a tool macOS does not ship.** Its first CI run failed all four
eval-guard assertions with exit 127 while every local run was green: the calls were wrapped in
`timeout`, which is Homebrew's coreutils here and absent on a `macos-latest` runner. Third
instance of the author's-tool class, after `grep` and `awk`. The wrapper is now conditional in
the suite, and the same hidden dependency was lifted from `eval-run.sh`'s login probe, where a
missing `timeout` read a logged-in home as logged out.

**Two rules the guide implied and never said.** A catch does not become a rule the day it is
caught: the field-note ladder now prices each rung — a dated line immediately, a second
occurrence for a backlog item, **a week between the first line and any promotion into the
guide**, and a measured outcome for the always-loaded core. It is a filter, not a ritual: what
still reproduces a week later, with the panic gone, is about the system. Repairs never wait — the
ladder governs lessons. And a halt that is not a count: **two runs that disagree on the same
question stop the work at the second disagreement**, because three attempts bound failure while
nothing bounded contradiction, where every individual run looks like a success. It escalates as
*the question is unstable, and here is what differed between the askings*, never as *which run
was right*. Both are listed by name in the prose-only table, with the exact reason each is not a
gate: `issue runs` records that a run finished, not what it concluded, and nothing compares a
promotion's citation against the note's own date.

**And a sixth void was wearing coverage.** Scenario 14's fixture directory held exactly one
file — a FIXTURE.md announcing "Repository half only" — so the coverage table said yes while
the guard, which counts tracked files rather than trusting prose, refused the scenario in every
round. Its own rubric reads "a standing workspace *or none at all*": the scenario needs no
state, the runsheet now says so, and 14 runs against the empty directory its rubric describes.

**Pass twelve's high and medium findings, all read.** Beyond the three criticals above:
**check 0 counted mentions** — a suite commented out, or named inside an `echo`, read as invoked,
so CI could stop running it with preflight green; five-shape matrix now, both honest forms
asserted too. **coverage-map counted directories where the guard counts tracked files**, and the
disagreement had been "fixed" by hand-editing the generated file. **§2 omitted the stage barrier**
while item 7 denied it in passing — eight paths now. **The fixture probe gave two answers where
three were needed**, so an unreadable module read as a scenario without a builder. **`--check-only`
was not free**, though its own comment said so: the login probe ran first, which is why the
fixture guard could not be exercised without credentials. **An assertion that could not fail** is
deleted rather than reworded, and what it could not test is said plainly. **And the pin's
uniqueness guard existed twice with only one copy exercised** — the untested one being the copy
attached to the thing that rewrites the pin. Suite 32 → 41.

**And the rung above every tool choice, generalised past code.** *Does this need to exist · is it
already here · the craft's own staple · native to the platform · one line* — taken from a
third-party ladder and taken as a **form**, because the same ladder as prose is what both corpora
measure at about zero. A commit adding a dependency names it in `_ops/DECISIONS.md` with what it
replaces; **and because a company with no package manifest is not exempt**, a row added to
`_ops/TOOLING.md` is asked the same thing — a supplier, a subscription, a licence. That half warns
rather than refuses, since outside software *we had none* is usually the true answer.

Eval state: **RUN, 2026-08-22** — `evals/runs/0.4.8.md`. All six newly-admissible scenarios
dispatched, two of which had never run in any round. **3 and 11 pass 3/3**, exercising exactly what
their new halves were built for. **27, run for the first time ever, is 0/3** and taught the sharpest
thing: all three identified the flat hook shape correctly and *by reading the source*, attempting
nothing and inspecting no artifact — a true conclusion by the forbidden method, which the rubric
did not name as a failure and now does. **23 is 0/3**, reproducing at N=3 a defect measured at N=1
on 2026-08-01: the report is withheld pending a clarifying question, against a rule that says the
file appears first with `unknown` in the gaps. **18 is void** — its door is built now, but the
payload still arrives as the owner's turn rather than through the webhook, so it measures the wrong
channel.

Superseded: the new halves admit six scenarios the rig has never dispatched; the
next round is the first that can measure them (11 and 27 have never been run at all).

## 0.4.7 — 2026-08-16

> **Correction, 2026-08-22.** This heading carries the date the entry was
> **written**; the tag was cut **2026-08-20**, four days later. The gap is not sloppiness —
> it is this repository's own law that the tag waits for the owner's word, so the writing
> date and the shipping date differ by however long that takes, and a reader takes the
> heading for the shipping date. The heading is left as it shipped, because a released
> entry is frozen and a marked correction is the only permitted change. From 2026-08-22 a
> check compares every tagged entry's date against its tag's, so this cannot recur
> silently.


**Three repairs to the gates 0.4.6 shipped, and one apology with a form attached.**

**The CI-coverage check could not see the idiomatic form.** Added yesterday so a suite cannot fall
out of CI, it matched only lines BEGINNING with `run:` — so a `run: |` block, which is how a
workflow step ordinarily runs anything, was invisible to it. It was a bare substring test, so a
suite merely named inside an `echo` counted as executed. It swept `scripts/test-*.sh` only, so the
repair that put `verify.py` into CI could be undone by deleting one step with nothing noticing —
and widening it to every GATE immediately found that **`check-structure.py`, which this repository
has always had, has never been in CI at all**. It is a step now.

And the check's own line carried this repository's documented pipefail trap: `grep … | grep -q`
returns 141 when the right side matches early and SIGPIPEs the left. Measured 2026-08-16 — rc=141
on a large input with the match on line 1, read as "no match", which here means the guard accusing
CI of not running a suite it runs. Counting cannot be signalled, so it counts.

**The documented update route addressed one of two installs.** `claude plugin update <p>@<m>` acts
on the USER scope. Minutes after tagging 0.4.6 the machine list still showed an install a release
behind while that command reported "already at the latest version" — both true, because the
registry carries user and project entries and the route named neither. Each row names its own scope
now. A route that addresses one of two installs is a route that hides the other, and the reader
concludes the checker is broken rather than the install stale.

**And 42 of my own probe transcripts rode into v0.4.6** — 398 KB from `eval-run.sh <id> 99 "probe"`,
the sweep that exercised the new fixture guard across all 27 rows. They grade nothing. They landed
inside the commit about that guard, and were found only because updating a plugin clone printed
their filenames as it pulled. Second time in one session that `git add -A` swept test artifacts
into a commit about the thing being tested, so it gets a form rather than an apology: **run numbers
98 and 99 are reserved for probes** and ignored by name. v0.4.6 carries them and that stands — a
tag is not rewritten for ballast — and every version after it is clean.

**Eval state**: unchanged from 0.4.6 (`evals/runs/0.4.6.md`). Nothing here alters what that round
measured; the fixture guard it records is the thing these repairs harden.

## 0.4.6 — 2026-08-16

**The mention that dispatches is now in the guide, with the roster column it needs.** A sibling
field report measured what happens when the one file every worker loads names an act but not its
form; checked here, the naive defect refuted — workers hold no CLI, the transition machinery is
native, and the guide rightly refuses to restate native behaviour — **but one narrow instance
survived**: the guide told every worker to *"@-mention the next role"* while carrying the strict
form `[@Name](mention://agent/<uuid>)` **zero** times — and a plain `@name` in a comment
**does something REFERENCE §2 does not record** — the guide now says to write the strict form
rather than asserting what the loose one does (§2 names the strict form as the mention
trigger — a reading of what that list says). **Corrected on 2026-08-14, before the tag:** §2 was
called *verified* here and in two other files while carrying no date, no measurement and no
source, and the PLAYBOOKS line was rewritten to *a plain comment dispatches nobody* — which §2
does not say either way, so an absence of evidence had been given a verdict. Both sides are now
written as unknown, dated, with what would settle it. The
handoff is the conveyor's entire transition door, and the guide described it in prose, carrying
the strict form zero times. The guide now carries the strict form and where the uuid lives; the roster
template gains the **mention column**, because a worker cannot construct a mention from a name.
The template preflight caught the half-done version of this very edit — a widened header over
six-cell rows — which is the table-shape check earning its keep.

**The AI-gateway row widens to the selection ladder's own order** — LiteLLM (MIT, the self-host
default) · OmniRoute (MIT, self-host; **young and churning, pin versions** — a proxy holding
every key is supply-chain-sensitive; its throughput numbers are its own marketing, carried
dated; **prompt compression off** for anything reviewed or measured; checked 2026-08-14) ·
OpenRouter (hosted; per-model data policies are its distinct value). The need named honestly:
provider-independence of the judge, answered first by cross-runtime dispatch with no proxy;
the gateway covers judge models with no harness, outages, and bulk persona calls — and **the
model that answered may not be the model requested**, so records read the response's model
field.

**Every agent now writes without the AI smell.** The guide template carries the two-line ban
form beside LANGUAGE & TONE; the shelf takes [humanizer](https://github.com/blader/humanizer)
(MIT, 35.5k★) with its limits named — English tells only, never over quotations, no invented
facts. **And the preflight's own checks finally carry tests**: `test-preflight-checks.sh`, 9/9 —
the typo'd date that used to kill the freshness gate silently, the count rephrase, the stale
pin, the URL hidden in the exempt page — each mutant refused, each twin passing, in a local
clone that never touches the working tree.

**Consult gains a council, and the shelf a marketing pool.** The council: independent angles,
anonymized cross-review, a synthesis that names the strongest dissent — Karpathy's method in
house prose (both upstreams licence-unstated), bound by the persona law: N angles of one
model are one bias N ways, and consensus is not a rung. The pool:
[marketingskills](https://github.com/coreyhaines31/marketingskills) (MIT, 44k★, 49 skills) —
two or three per agent through the screen, trimmed to read the workspace's own registers,
never attached wholesale.

**An existing workspace receives this by regeneration, said rather than implied**: the guide
skill is re-issued from the new template and `_ops/TEAM.md` gains the mention column (uuid = the
ID column of `multica agent list`) — neither moves by itself.

**The CLI moved fourteen releases while the checker said green, and the route that keeps your
skill's id is now written down.** `multica skill refresh <id>` re-downloads a skill from its
imported source **preserving its id and its agent assignments** — the old route mints a new id
and orphans every agent that referenced the skill, which is the most user-facing thing in this
range and was in no document. REFERENCE §10 is regenerated against **CLI v0.4.26** and carries
the caveat its own surface cannot: *the surface is current; the behaviour is not*. Multica's
native plugin system is in STACKS, and `plugin` is classified as workspace structure, so the
workspace fingerprint hashes it.

**Why the pin check was green for fourteen releases**: it compared REFERENCE against the
*installed* binary, and both said 0.4.12 — two stale things measured against each other. It asks
the outside number now. Three readers of that pin were then anchored **by name**, because the
first `vX.Y.Z` in the file stopped being the pin the moment this release wrote a `MUL-5958`
citation above §10 — and a blanket version sweep had already rewritten that citation into a
release that does not carry it, which is the incident AGENTS.md now dates.

**Then the four release lenses ran, and found the other half of every one of those repairs.**
The **fourth** pin reader — `.github/workflows/cli-watch.yml`, the one nobody watches because it
runs on a schedule — was byte-identical to the two that were fixed, read **0.4.23** out of the
citation, and would have filed a false issue on Monday. `--regen-cli`'s **writer** was still the
blanket `s/v0.4.23/v0.4.26/g` the reader had been protected from: with the pin at 0.4.23 its
entire diff was the `MUL-5958` citation, and a copy-edit to §10's wording made the pin empty and
`s/v/v0.4.26/g` corrupted **446 lines** across two files at exit 0. It is one anchored
substitution now, it refuses an empty pin, and README's dated measurements are **reported, never
rewritten** — a re-dated claim nobody re-measured is the promotion the rungs exist to stop.
`verify.py`'s positional **fallback** is gone: measured, it silently returned a version from a
different section with nothing saying it had fallen back. The `plugin` fingerprint row hashed
**empty stdout** — the SHA-256 of nothing, identical to a nonexistent group, so an outage and an
empty list were one value; and the gate proving the recipe covers every structural class carried
a substring escape that made it **unable to fail**, printing "9 structural classes covered" while
8 were hashed. It counts what it verified now.

**Seven claims dated v0.4.12 were re-checked against 0.4.26, one at a time.** Five hold and carry
today's date. One does not get a new date: *"Multica has no `on_child_failure`"* sits above a
surface that moved — 0.4.26's `issue create --stage` groups sub-issues into a barrier where *"the
parent assignee is woken only when every sub-issue in a stage finishes"*, and whether a dead child
counts as finished is behavioural. It is marked unverified with that reason.

**And the prose-only list is enforced rather than promised.** Four documents say prose-only rules
are "listed **by name**"; two rules called themselves `prose-only` where they were defined and
were on no list. Both are listed, and `verify.py` now refuses a document that declares one
without being cited — the promise is a form.

**Eval state: run** (`evals/runs/0.4.6.md`) — three scenarios × N=3, the first round since 0.4.1.
**Scenario 9 (native-first) scored 2/3**: two runs reached for `property create --type select` and
the platform's own `creator_type`, and **one cited *"REFERENCE §2, measured against CLI v0.4.26"* —
the paragraph written into the corpus that morning**. The third answered with labels and never
named `creator_type`, which is exactly what the scenario exists to catch. **Scenarios 18 and 27 are
void, and the reason is a rig fault worth more than the numbers**: a scenario's state has two
independent halves — a tracked repository fixture and a `BUILDERS` entry for the live workspace —
and the runsheet carried one yes/no, so 18's poisoned webhook payload arrived as the owner's own
message and two of 27's runs met an empty repository while the third graded *this repository's own
gate*. The runner refuses that now, and it took three attempts: the first read the wrong column and
**missed scenario 27, one of the two voids it was written to prevent**; the second would have
blocked six scenarios that build fine. What ships refuses only the six with NEITHER half —
3·11·14·18·23·27 — and warns where one is missing.
The sibling published a headline off exactly this shape three weeks of work ago. Corpus checks
green, `verify.py` green, every guard suite passes (23/23 in `test-preflight-checks.sh`, which this
release also put into CI for the first time).

## 0.4.5 — 2026-08-09

**The claim under W012 stops being an assertion and carries its measurement.** 0.4.4 said the
form Snyk quotes — `multica skill import --url github.com/jamillazarev/multica-ops` — is a
command that does not work. True, and undated, and unmeasured, which by this repository's own
freshness law makes it a claim wearing the clothes of a fact. **Measured `2026-08-09`**: the
bare root returns **HTTP 502**, body *"SKILL.md not found at the root of
jamillazarev/multica-ops@main. For multi-skill repositories, point to a specific directory
using …/tree/main/&lt;skill-dir&gt;"*.

**The control is the part that makes it evidence**, and it is written out with its tag —
`…/tree/v0.4.4/skills/mops` — because *"the pinned line"* moves every release and a control
nobody can re-run is not evidence. It **succeeded at the same moment**, so the 502 is the shape
of the URL and not a service interruption —
without that second run this page would have recorded a possible outage as a defect in an
address, which is the same error in the opposite direction from the one 0.4.4 fixed.

**And the response carries a second finding that is not ours.** Multica answers a plainly
client-side mistake with a **5xx**, which the CLI renders as *"the service is temporarily
unavailable"* — so an actionable message (*point at a directory*) reaches the user as a false
claim that the service is down. Recorded on the security page rather than left in a
conversation, because the next person to mistype that URL reads the same wrong cause. Worth
reporting upstream; the row says so.

**And what four review lenses found afterwards.** The freshness gate **could not see 33 of
STACKS' 61 check-dates**: its regex was case-sensitive, so a stamp written `Checked` — house
style at the start of a sentence — was exempt, and the exemption was the default. It also had no
word for `measured`, which carries this corpus's strongest claims. Fixed with a note on the trap
that broke it twice: **an odd number of backticks inside `$( <<HEREDOC )` breaks bash parsing**
thirty lines further down, so the regex writes the character as `\x60`.

> [!NOTE]
> **Correction, 2026-08-27 — and a correction to that correction the same day.** The sentence above
> says an odd number of backticks breaks the parse. A first correction claimed the real rule was
> *an unpaired backtick inside a double-quoted span*; a lens produced the counter-example, and it
> is wrong too — an unpaired backtick in a plain expression fails just as hard, and two unpaired
> ones PAIR ACROSS whatever sits between them.
>
> **Measured on bash 3.2:** every backtick the shell's lexer can see inside `$( … )` must pair,
> quoted heredoc or not — and **single quotes and a `#` comment hide one from it, while double
> quotes do not.** So the original count was right and incomplete, not wrong. The full account is
> beside `_keep()` in `scripts/preflight.sh`; nothing else in the corpus should restate it.
>
> **Correction to this correction, 2026-08-28.** That pointer no longer resolves: the note beside
> `_keep()` was cut to its minimum, and the second copy — which restated the mechanism while
> forbidding the restatement — was cut with it. A fourth statement is not what was needed.
> **`/bin/bash -n` is the account now**, and the suite runs it as an assertion. The sentence above
> is still true of backticks and **not** of parentheses, which a double-quoted span does hide;
> 0.4.13 corrects a claim that the two obey the same law.

**The scenario count drifted a second time — so it is a form now, not a third correction.**
README advertised 26 against a rubric holding 27, and it was **published**: one page of the site
said 26 while another said 27. The changelog already records this defect once, at 22-against-26.
Preflight now compares README and the runsheet against the rubric, which is the home.

**And a second lens pass over those repairs found three more, each verified before it was
believed.** A single typo'd date — `2026-06-31` — raised `ValueError` inside the freshness loop,
and because every print happened *after* the loop, stdout came back empty and **the whole gate
went silent with genuinely stale facts in the same file**. The regex also still under-matched: 41
stamps escaped because an adverb sits between the verb and the date — *"re-verified
behaviourally"*, *"Measured end to end"* — which is the same class as the case-sensitivity hole,
in the corpus's dominant style. And the count check's README half **passed silently on any
rephrasing**: six realistic forms were blind, including bolding the digit. It is inverted now —
the canonical phrase is required, and its absence is the failure — and `COVERAGE.md`, the third
hand-kept copy and the one that disagreed on the site, is checked too.

**The exemption guard caught a move and not an add.** `SECURITY.md` is exempt from the pin check
because it records past runs; the guard asserted `INSTALL.md` still carried the instruction, which
a *move* trips and an *add* does not — and adding is cheaper. Every `tree/` URL on that page must
now be either the recorded control or the current pin, on the page a reader trusts most.

**The control in `SECURITY.md` is written out with its tag**, because *"the pinned line"* moves
every release and a control nobody can re-run is not evidence. **"Two-line shell wrapper" became
accurate** — three are two lines, `migration-state.sh` is four — and the section now points at
the **four `.py` files, ~24 KB**, which is the surface the finding is actually about rather than
the 427 bytes of wrappers. The pin check gained a scope and a positive guard: `SECURITY.md` is
exempt because it records past runs, and that exemption holds only while `INSTALL.md` still
carries the real instruction.

**Multica does not create repositories, and until now nothing here said so.** Measured
`2026-08-09` against CLI 0.4.12: `multica repo` offers **add · checkout · list · remove** and no
`create` — `repo add` *"adds one or more repository URLs to the current workspace repository
registry"*, which registers something that already exists. Day zero's six checks are about the
CLI, the daemon and the runtime; **none of them notices that the folder in front of you has no
git in it**, and most people who arrive that way have never run `git init` and cannot act on a
silence.

**The question moves to where it belongs — before a project resource is attached — and it names
its price.** `git init` is one local command, nothing leaves the machine, and **on a folder that
already holds work it moves and changes nothing**: every file stays where it is until someone
commits. That last clause is what actually unblocks somebody; *"is this a repo?"* alone is a
question only a person who already knows git can answer.

**`local_directory` is the type to be strict about, because its failure is the expensive kind.**
It runs the agent **directly in the path you gave**, no worktree and no copy — so where that path
is not a repository, agents write with **no history and no undo**, and the first bad run is
unrecoverable instead of a `git checkout`. Being blocked at the start is far cheaper. Whether the
API *accepts* a non-git path is **explicitly marked unmeasured** — checking it means creating a
resource in a live workspace — and the check is owed either way: one question against somebody's
files.

**Eval state**: **not run** — the release dates a claim, records a measured fact about the
platform, and repairs checks; no behaviour an eval measures changed. Corpus checks green and
every guard suite passes.

## 0.4.4 — 2026-08-09

**The security page said something false about itself, and a security page is the worst place for
that.** Answering the 2026-07-30 Socket and Snyk audits, it swept three findings into one sentence
— *"none of those paths exists in this repository at any commit"* — which is true of
`commands/skill.md` and of the `scripts/install-alias.sh` that Socket's hooks alert points at
(**zero commits each, at any ref**) and **false of `hooks/hooks.json`, which exists and has four**.
The substance was right and the claim was wrong, which is precisely the defect class AGENTS.md
names as the expensive one: *a statement that parsed perfectly, linked correctly, and was false*.

**Every finding now gets its own row and its own answer**, because they do not deserve the same
one: a path that never existed · a file that exists whose flagged script never did · a quoted
command that does not run, against an install line that pins a tag for exactly that reason and a
preflight that fails the release when the pin drifts · and two findings that are **accurate
descriptions of what the skill is for**, answered by the page rather than argued with. Verified
against `git log --all` on 2026-08-09.

**And the live half of the hooks finding is answered instead of dodged.** A `SessionStart` hook
does run a script from `${CLAUDE_PLUGIN_ROOT}` — so: that variable is **the runtime's own**, and
an attacker who can set it has already replaced the plugin, which no in-plugin check survives;
every wired hook is a **two-line shell wrapper** exec'ing a Python file beside it, 64–227 bytes,
readable in a minute, and that is the intended way to check them; each is **mutation-tested on
what it refuses**; and the upgrade flow exists so that re-reading the diff from a pinned tag is
the default rather than a discipline. **Dismissing a finding because its filename is wrong leaves
the part that was right standing.**

**Eval state**: **not run** — a patch that corrects a claim and adds no behaviour. Corpus checks
green and every guard suite passes.

## 0.4.3 — 2026-08-09

**Six shelf rows, and two of them close doors that were open in only one direction.** Nothing
else moved: a row is offered when a need names it and is never loaded before that (STACKS head),
so no flow got longer and **no company owes a migration**.

- **Voice became a ladder, because the top rung is free.** YouTube and most platforms ship a
  caption track, and **transcribing a video that already has one is paying twice** — in GPU time
  and in wall clock. `youtube-transcript-api` and **yt-dlp** first, Whisper when there is no
  track, hosted only for scale or a synthetic voice. Rung 1's real limit is in the row:
  unofficial, so `RequestBlocked`, cloud-IP blocks and parser breakage when the markup moves —
  a research pass on a laptop, not a standing pipeline.
- **Presentations, picked by who owns the deck afterwards.** **Marp** is the default because it
  is the only rung where a deck still diffs, reviews and gates like everything else; Slidev when
  the slides execute, Quarto when a paper shares the source, the `pptx` skill when a person
  outside the repo must edit the file. `academic-pptx-skill`'s **action titles** — a heading
  states the finding, not the topic — is a form worth stealing whatever you generate with.
  **`anydoc` from 0.4.2 is the same door running inward**, so the two releases are halves of one
  thing: decks arrive as `.pptx` and leave as markdown.
- **Style presets, filed as a vocabulary and not a machine.** Fooocus's JSON is the format
  everyone ports and is worth having as *two hundred named looks to point at* when briefing an
  owner. It is not a style system: these are SDXL-era suffixes, the hosted models answer to plain
  description and a reference image, and a preset picked per image is a moodboard folder in JSON.
  **What makes two images match is the recipe kept beside the asset** — model, prompt, seed,
  reference, in `_ops/assets.md` next to the licence.
- **Image → prompt, starting from the model you already pay for.** Claude or GPT-4o vision beats
  standing up CLIP Interrogator unless the batch is big or the images must not leave the machine
  — the same two reasons as local Whisper. Its real uses are salvage, turning a client's
  reference deck into words the register can hold, and alt text.
- **Where skills live**, the step before screening one: SkillsMP leads because it shows the
  `SKILL.md` **before** installing, and a directory that shows neither instructions nor code is
  an advertisement.
- **`last30days`** joins the demand-signal row with both of its limits: *"no keys"* is true of a
  slice (X wants cookies, three networks go through a paid third party), and **engagement
  weighting is not representativeness** — the top of the signal pyramid handed over as the base.
- **Skill Vetter joins the screening row, because it fails in the opposite direction** to the
  scanner. Patterns cannot read intent and cannot be argued with; a model-executed checklist
  reads intent and **can be talked out of it by the very file it is screening**. Neither is the
  gate.

**And a defect the runsheet had warned about itself.** Its own header says *regenerate after
adding a scenario — the runsheet went one behind when 26 landed*; it was one behind again, with
**scenario 27 in the rubric and absent from the sheet**. It is a row now, marked `TO-AUTHOR`
because the rubric describes a situation with no utterance and writing the opening line is
writing part of the test.

**What this release deliberately does not carry, and why it is a patch.** The asset **recipe** —
model, prompt, seed and reference as required fields, with a company-preflight refusal behind
them — was built and is **held back**. It is a capability, and a capability here owes a form, a
mutation test, a scenario and a door; the form and the suite exist, but a minor is not tagged
without `evals/runs/<version>.md` and the four lenses, and neither was run. **Shipping it as a
patch would have been shipping the shape of the bar without the bar.** The two rows above that
depend on the idea say it in plain words instead of citing a section that does not exist yet.
It lands whole, as a minor, when the round has been run. *(The sibling `opsinist` carries the
same mechanic at 0.2.5 with its own measurement behind it.)*

**Eval state**: **not run** — a patch that adds no behaviour, so no round is owed. Corpus checks
green and every guard suite passes, which is evidence about the corpus and about what the
holders refuse, never about behaviour.

## 0.4.2 — 2026-08-09

**A document an agent cannot open is not evidence.** The shelf had an answer for web pages
(Crawl4AI, cf-browser) and one for audio (Whisper), and none at all for the file somebody
actually sends you — so a tracker export arriving as a spreadsheet, a primary source that exists
only as a paper, or a segment's own words trapped in someone's deck were each solved from
scratch by whoever hit them, or read by eye and paraphrased.
**[anydoc](https://github.com/firecrawl/anydoc)** (MIT, Rust, local, no key and no model call)
is now the row: docx · pptx · xlsx · odt/ods/odp · rtf · epub · csv and text-based PDFs into
markdown. Home: STACKS → *Reading documents agents can't parse*; `/multica-ops:import` pass 1
cites it rather than restating it.

**Both limits are in the row, because a converter that quietly returns nothing is worse than
no converter**: there is **no OCR** — an image-only or password-protected file is an explicit
`Unsupported`, and the fallback stays the Anthropic `pdf` skill or a real OCR pass — and
**images become their alt text**, so a deck whose argument lives in its pictures arrives without
it. Its speed and coverage benchmarks are the project's own, LLM-judged claims, named as claims
rather than carried as fact.

**Nothing else moved, and no company owes a migration.** A shelf row is offered when a need
names it and is never loaded before that (STACKS head), so no flow got longer. anydoc also
ships as an agent skill; that route arrives through `/multica-ops:skill`'s screen like any other
import, which is where it was already governed.

## 0.4.1 — 2026-08-08

**A gate is not enforced until you have watched it refuse — and on Claude Code, the shape of
the refusal decides whether it holds.** `enforced_by: validator` is a claim, and the cheapest
way to be wrong about your own company is to write a gate, see it run, and never check that it
says no: a hook whose refusal is discarded is indistinguishable from one that works — the tool
exits, the log fills, and the forbidden thing happens anyway. So a gate is accepted only against
a **deliberate violation**, confirmed by the artifact (a stamp file, an absent commit, an
unchanged permission) and never by the runner's account of itself.

**The measured trap** (Claude Code 2.1.220, stamp files on both sides): `exit 2` refuses ·
nested `hookSpecificOutput.permissionDecision` refuses on the plugin path (the settings path was not probed for it) · a **flat `{"permissionDecision":
"deny"}` is executed and ignored on the plugin path *and* through a settings file — the command
proceeds either way.** The flat shape is the natural guess, raises no error, and **is not a
refusal anywhere measured**; the first reading of this blamed the path, and the path is not what
decides. Home: PLAYBOOKS → *A gate is not enforced until you have
watched it refuse*; the dev contract cites it rather than repeating it.

**Nothing in 0.4.0's behaviour changed** — both hooks it ships already refuse with `exit 2`,
and that was watched refusing, not read off their source. What is new is the rule for the gates a company writes for itself, and a check in this
repository that fails the flat shape before it can ship.

## 0.4.0 — 2026-08-07

**The machinery lives under one door now: `_ops/`.** A project's root belongs to the craft
again — its own files, its own `docs/`, its `.claude/` — and everything the methodology owns
sits in a single directory named to sort first and collide with nothing. What `docs/` used to
hold is flat inside it (`_ops/DECISIONS.md`, not `docs/DECISIONS.md`), and `docs/tooling/` is
**`_ops/runbooks/`**, because a runbook is what it holds and `tooling` beside `TOOLING.md` was
one word doing two jobs. **The collision this ends was real, not theoretical**: roughly twenty
paths went into whatever `docs/` a repository already had, and most repositories have one — a
bakery's or a Django project's documentation is not a place to file a decisions ledger.

**Migration map — one command:**
- **`python3 scripts/migrate-layout.py <project-root>`** (`--dry-run` reads without touching)
  moves the claimed paths as history-preserving `git mv`s. **Anything under `docs/` it does not
  recognise stays where it is and is named in the output** — that directory is very often the
  craft's own. A dirty tree is refused so the migration is its own diff; a destination that
  already exists is a named `CONFLICT` and a nonzero exit, never a silent overwrite; a second
  run does nothing and says so.
- **Then re-copy `templates/company-preflight.sh`** over the repo's pre-commit hook — the old
  copy checks paths that have moved. The migration names it rather than rewriting your hook.
- **An unmigrated workspace is recognised, not crashed into**: reading a claimed path that is
  missing, Mops looks once at the old location and, finding the file there, stops and offers
  `/multica-ops:upgrade` rather than silently reading the old layout forever.

**An outward act is stopped by a gate now, not by a sentence.** *Pushing is the owner's* has
been in the core, the gate table and the README for versions — as `prose-only`, and **measured
2026-08-07 it was not merely unenforced but reliably ignored: five runs of five went
`Edit → commit → push` and reported "Done… and pushed".** `hooks/outward-gate.py` is the form:
a `PreToolUse` hook that stops `git push`, `gh release create`, `npm publish`, a `deploy` or a
`docker push`, names the act as one of the four owner-gated kinds, and hands it back. Local work
never trips it, and `--dry-run` is a read. **The retry does not pass** — a first design that
stopped once moved the rate only to 2/5, with the other three simply pushing again, so the
doors are named instead: the owner runs the command, or sets `MOPS_OUTWARD_GATE=off` on
purpose. **5/5 after the repair.** (And the inherited note that plugin `PreToolUse` hooks do
not fire under `claude -p` was checked rather than trusted — they do.)

**A long read with nothing dispatched gets a note** — `hooks/dispatch-nudge.py`, after an
unbroken run of read-only calls. It **reports and never refuses**, because reading is
legitimate. Stated plainly: it did **not** move the measured rate the way the two refusing gates
did, and it is shipped as an aid rather than a repair. What it did produce is a runtime fact
worth having — **a `PostToolUse` hook's stderr never reaches the model; only
`hookSpecificOutput.additionalContext` does.** A note nobody receives is not a weaker gate, it
is no gate, and the first build of this one was exactly that.

**And `_ops/` is a shared door, so ownership is read before anything is written.** The sibling
project `opsinist` runs the same methodology out of files and uses the same directory —
**nine of the twelve documents inside are named identically** (measured 2026-08-07). Sharing the
name is the right trade: a successor finds the predecessor's record exactly where it would have
put its own, where a private directory would make a fully-documented project look like open
ground. What it requires is a marker, not a rename — **`_ops/config.md` with no
`Operated by multica-ops` line in the guide means another system operates this tree**, and it is
named and handed back with nothing touched. `migrate-layout.py` refuses such a tree outright,
and both directions are covered by the suite. Their records are evidence, not our workspace.

**"Remember this" lands in a file, and a gate makes sure of it.** The law shipped in this
release and **did not hold on its own**: scenario 26, five runs of five, wrote the owner's rule
into the runtime's private cross-session memory — outside the repository, unread by every agent
here — and not one named a home back. `hooks/rule-home.py` refuses that write and names the
homes; the attractor is unchanged (every run still reaches for memory first) but the rule now
lands in the guide, **5/5**. Scoped to workspaces with an `Operated by multica-ops` line, so an
ordinary repository's memory is nobody's business but its own, and switchable off by name.

**The homes** — a guide line · the glossary ·
`_ops/DECISIONS.md` · the register · `_ops/LATER.md` — **and never the harness's own agent
memory**. Measured next door on 2026-08-07: told *"remember this"*, two runs of two wrote the
owner's rule into the runtime's private cross-session store — outside the repository, unread by
every worker (opsinist 0.2.2). It is worse here than in a file-only system, because the workers
are agents that read the workspace and the repo and never your laptop.

**A back-pointer names a section and proves what it said.** The sources register cited claims by
`file:line`, and a line number names a *position* — **measured 2026-08-07, 11 of 23 pointers no
longer landed on their claim**, with no edit to the register in between; the docs had simply been
written in. Citations are now `file.md#anchor (sha:…, checked …)`, minted by
`fetch-source.py --cite <file.md>#<anchor>`, and the hash earns the rest: a passage rewritten
*underneath* its citation makes the fact **`unknown` and says so**, which a line number cannot
even see. All twenty-four pointers were converted; the register verifies **20/20** after deduplication (two of them went stale the same day, under passages this release went on to edit — which is the hash doing its job, and they were re-minted).

**The README was cut to be read.** Three hundred and eighty-two lines became two hundred and twenty-eight: one
minute in (two commands, then say what you need, with the six entrances), **fourteen one-line
differences** instead of paragraphs, an honest ceiling table with *how it is known* per row, and
the success-as-absence tests. The pug stays. One number in it was also simply wrong — it
advertised 22 eval scenarios against a rubric that now holds 26.

**Seven rules the sibling project proved, each checked against the platform first.** Three of
them the platform does not do, so they are ours and say so:

- **A role declares what it falls back to.** `agent create --model` takes one identifier and a
  capacity death lands in `agent_error` unretried (CLI v0.4.12), so a role records a fallback
  chain of tiers in `TEAM.md` — **taken and named in the same breath**, never a silent
  downgrade. *No fallback* is a real answer for review and architecture: waiting beats answering
  worse. A chain never reaches below the grade's floor.
- **Silence is not an answer unless a grant said so first.** A request may act on an unanswered
  question only through a grant written **in advance**, carrying `on_timeout` — **`keep-waiting`
  is the default** — and a real window. Authored mid-wait it is the constrained party unlocking
  its own door. The four owner-gated kinds cannot carry `proceed` at all, and what fired is
  recorded on the issue.
- **The owner's hand-edit is offered a home — once.** An edit is the standard stated in the one
  unambiguous way: the finished thing. It is read back once and one home proposed — a guide
  line, the role's instructions, a worked example, or **nothing, which is a real answer**. Not
  on every occurrence, because that turns a correction into an interrogation; and never
  generalised silently, because an inferred standard nobody agreed to is how a company acquires
  conventions its owner never chose.
- **A decomposition states four things once** — what happens when a child fails (**`escalate` by
  default**; Multica has no `on_child_failure`), what it is expected to cost as a **median over
  comparable runs with its sample size** rather than a feeling, where a secret goes (**the owner
  answers "done", never the value**), and that a lesson crossing to another project goes through
  the import gate rather than a shared brain.
- **A product that lives elsewhere is watched, never vendored** — a pointer with its why,
  `version_seen`, and **per-surface check-dates** (repo · site · docs · pricing move at
  different speeds). The watch closes natively: an autopilot in `create_issue` mode with the
  owner subscribed makes each upstream release an issue that **lands in triage and cannot
  fade**. And accepting a move **opens the delta** — `version_seen` moves only once the list of
  what it changes exists.
- **Who is standing on a map node is generated** — `scripts/map-blocks.py` fills marker pairs in
  `_ops/MAP.md` from `touches` metadata and rewrites **only between the markers**. **Two live
  issues on one node is a finding stated inside the block**: a merge conflict arriving a week
  early, while sequencing is still cheap.
- **The migration delta reads both ways.** An upgrade that only adds never notices the other
  half — a rule the workspace already has that the new corpus contradicts. A clash is now **a
  finding with two named sides and the owner decides**, recorded in `_ops/DECISIONS.md` so the
  next upgrade does not re-ask. Only load-bearing clashes surface: a migration that asks twenty
  questions gets answered *yes to everything*.

**Five shelves arrived, and one law about who they serve.** Feature flags and progressive
delivery (OpenFeature · Unleash · GrowthBook · Flagsmith — with the debt trap: **a flag nobody
removes is configuration debt wearing a feature's name, so flags carry an expiry like grants**)
· **hypothesis and usability test methods** ordered by the cost of being wrong, each carrying
its bias on its face · the **experience-measurement ladder** by layer, CES through the Sean
Ellis test to NPS, all of them attitudes that sit *beside* the behavioural numbers and never
instead of them · **agent-web protocols** — Web Bot Auth, Content Signals, Pay-Per-Crawl's 402
— with both sides named, since from **2026-09-15** Cloudflare's default starts blocking agent
bots on ad-bearing pages · and **open-source and skill distribution**, where the listings are
the channel and each has its own bar. Two shelves grew their applied halves: Growth.Design's
**53 case studies** and **abtest.design**, both **a shelf of survivors** — they calibrate what
to try, never what to expect, and they are for citing, never mirroring.

**And the law they instance: a shelf serves every flow that meets its need.** Filed by one
flow, scoped to none — the shelf a review cites is the shelf a build opens and a consultation
answers from, and a pointer handed over once is read wherever it is relevant rather than asked
for again. **The point of a shelf is a shorter search, so it sits at the search's head**: the
register first, the live web where the register runs out, and a find worth keeping lands back
with its why. One home in FLOWS; the catalogue header and the sources register cite it.
**It is called a shelf and never a "resource"**, because on Multica a **project resource** is
already a `github_repo` or a `local_directory` an agent works on — the glossary now tells the
two apart, and the sibling project's word did not survive the border.

**A migration notice now needs a workspace that says it is operated, not one that says the
name.** The session-start check called a tree ours whenever any guide *contained* the string
`multica-ops` — which is true of this skill's own repository, of every fixture, and of any repo
whose README recommends us. **Ownership is an operator line** (`Operated by multica-ops
0.4.0`) or an `UPGRADES.md`, nothing less. If your guide only mentions the skill in passing and
you *want* the check, give it that line. The mutation suite had assumed the strict rule from
the start and asserted it nowhere, so the code had drifted below its own tests in silence.

**The coverage map exists, and it is generated.** `scripts/coverage-map.py` assembles
`evals/COVERAGE.md` from the tree itself — what the corpus says holds each rule, which
validators, hooks and suites ship, how many scenarios the rubric carries and which versions
have a run record — with **rates deliberately not copied**, because a rate belongs where its
date is. It has a page on the site, and the section finally has an **`llms.txt`** — scoped to
the section, so it cannot fight the site root's over what this site says it is.

**Three guards, each closing a defect that shipped somewhere.** The link checker stops filing
false corpses: paren-cut URLs are percent-encoded (and preflight now refuses a raw `(` in a
markdown URL), a transient 5xx gets one retry, and 401 joins 403/429 as bot-blocked rather than
dead. The **version sweep runs over every manifest it can discover**, not the two somebody
remembered — we ship four, and only two were checked. And CI runs the **real** gate suite on
**macOS**, the platform the release is actually cut from, with the badge pinned to `main`.

**The release notes are the changelog entry whole, with the heading collapsed to a bare italic
date** — the title already carries the version and the release's own line. All seven past
Releases were retro-fitted in place; one of them had been published carrying this file's
*header* instead of its entry. **And the tag waits for the owner's word, every release its
own** — that law and the session loop now live in the repo's own `CLAUDE.md`.

**Migration map** — nothing to do for most workspaces: corpus rows, dev furniture and
generated pages. The one exception is the session-start check: **a workspace whose guide only
mentions `multica-ops` will now stay silent**. Add an `Operated by multica-ops 0.4.0` line to
its guide to keep the migration reminder, or leave it silent if the workspace was never ours.

## 0.3.3 — 2026-08-02

**Forty new tools and services, and this file's list is now the same list as the sibling
project's** — 406 links on each side, none only on one, checked mechanically rather than by eye.
The drift ran one way: `opsinist` carried twenty-two this file lacked and this file carried none
it lacked, so the academic sources, licence reading, behavioural reference, saliency work and
structured comparison arrived here as their own **Evidence** section.

**Nine new categories**, picked because they are what a company on this platform keeps building:
**agent and chat interface components** · **icon sets** · **data tables** · **billing and pricing
UI** · **deep research as a bounded job** · **cloning a page you are allowed to clone** · the
**utility layer** between a framework and a component kit · **calling an API by hand** · **review
workflow for stacked changes**.

**Three things are recorded as blockers, not details.** Several agent-UI libraries **state no
licence** — copy-paste components become your source, so that is unlicensed code in the
company's repository. One block library is **paid**, named as the single non-free entry rather
than quietly dropped. **Prisma's licence is read at its repository, not its site**, which sells a
different product.

**"Load the row, not the file."** This is the longest document here and almost none of it is
about the task in hand. The rule is in the file *and* in the core's routing entry, because a rule
inside a long file is only read after paying for the whole file.

## 0.3.2 — 2026-08-02

**Recording that a check ran is not the same act as applying what it found, and only the second
one waits for you.** The log line says somebody looked; the changes need your word. Treating them
as one act is what loses the record: a run that built the whole delta, asked its one real
question and wrote nothing left a workspace **indistinguishable from one nobody had opened**, so
the next session re-derived everything and asked again. Waiting is now `deferred` — what was
found, what waits, on whom — **replaced, not duplicated**, when the answer comes.

**A log entry may wrap, and the check reads entries now rather than lines.** A correct four-line
entry — version on the first line, `Outcome: applied.` on the fourth — was read as **absent**,
which would have nagged forever about a migration that had already happened. **A record's grammar
is a paragraph.**

**The session-start message no longer says approval is not needed, because a run read that as an
attack.** The wording *"recording is not gated on approval"*, arriving cold in a system message,
is **an instruction to push file edits through without the owner's say-so** — the exact shape of
a prompt injection. A run said so, declined to touch anything, and offered to make the edit
visibly if asked. **It was right.** One run in two tripped on it. The hook now carries the
vocabulary and never the claim that permission is unnecessary.

**Scenario 25 joins the rubric**, for a case scenario 24 could not force: a migration that cannot
finish without the owner. `evals/runs/0.3.0.md` records what it measured and — more usefully —
what it **failed** to isolate, since three of its runs judged the blocking item to sit outside
the migration and were defensible in doing so.

**And the rig's isolation now covers the config, not only the workspace**: run under the author's
own configuration, a player answered *"what's next?"* by opening **a different operations skill
installed on the same machine** and running that one's flow instead. **A shared config is how
another plugin gets a vote.**

## 0.3.1 — 2026-08-02

**Your guide now states which version operates this company, and something checks it.** The line
did not exist before — `UPGRADES.md` was the only record, and it is the one a migration writes.
So a run could write the log line, leave everything else, and **the session-start check would go
quiet precisely because the log is what it reads**. The disagreement was not merely unfixed; it
was made invisible.

**Measured, three runs each side.** Before: the guide was bumped **0 of 3**, and two of those runs
wrote their log line anyway. After — a hook that names both files in one fact, a template line
that says what it means, and a flow that makes it the first mechanical item — **2 of 3**. The
hook still only reports what two files say, so there is nothing here a session could forge.

**A delta that stops for your approval now writes `deferred` instead of nothing.** Waiting is
right; waiting silently leaves the same trace as never having looked, and the next session
re-derives the whole delta and asks you again. **One run met that branch after the change and
still wrote nothing** — recorded in `evals/runs/0.3.0.md` as a miss, not as a fix.

**`--thinking-level` runs backwards for reaction personas, and only the tier half was written
down.** A real person gives a landing page thirty seconds; a persona at high effort writes the
considered essay nobody would have written — articulate, plausible, and evidence of nothing. Set
it low for reaction personas; raise it only for the adversarial ones, where taking an argument
apart *is* the job.

**Two harnesses install as a symlink into `~/.agents/skills/multica-ops`.** Found on a real
machine: if no route ever created that directory, Factory's and Pi's links are **broken while
looking installed**. `scripts/find-installs.sh` reports them as `BROKEN`; `INSTALL.md` now says
what to put there.

## 0.3.0 — 2026-08-01

**Carried across from the sibling project `opsinist`, where each of these was measured — against
its corpus, not this one's.** Same mechanics, different substrate: the workspace lives in Multica,
the company's record lives in git. **Almost nothing here has been measured against this corpus**,
and `evals/runs/0.3.0.md` says which is which rather than implying: **scenario 23 failed and then
passed after one change (N=1 each side); scenario 24 was run three times and only half of it was
ever presented** — the board lacked the closed and in-flight issues the scenario requires, so
three of its five expectations measured nothing. The other twenty-two have no round in this
release.

**Reviewed by the four lenses before tagging, by someone who did not write it — sixteen findings,
four blocking, all fixed.** The blocking ones are worth naming because each would have misfired
in a live workspace: the new *documents arrive when they have content* rule **contradicted
`company-preflight.sh`**, which fails a commit when a stand-up document is missing, so an obedient
workspace could not have committed; the rule's **mechanism did not travel** (a hook holds it next
door, nothing holds it here — it is `prose-only` now, and says so); the migration **outcome was
written before it could be known**; and *"swept at the next audit"* **named a sweeper that does
not sweep**. A carried number had also been flattened toward its worse value, and is restored to
what was measured.

---

**`/multica-ops:report` — you do not have to know whose defect it is.** The moment someone wants
to report a problem is the moment they least want to compose a request, and the capability is one
they have no reason to know exists. **A door is how a capability is found.** Three destinations,
decided from the evidence: a defect in **your product** goes to the urgent lane; friction in
**your workspace** becomes a line in `docs/FIELD-NOTES.md`, swept at the next audit, earning an
issue on the **second** occurrence with both named; friction in **this skill or in Multica** is
packaged from evidence, de-identified, and **written to a file outside your repository** — the
defect is not in your product, so it does not belong in your history — with its path said out
loud and the routes named. **You post it, never us.** Multica has no feedback mechanism of its
own (checked in its docs the same day), which is what makes this worth a door here.

**And the file is written before anything is missing.** Scenario 23 caught the first version
refusing to invent a task record it did not have — correctly — and then **stopping to ask for it,
leaving the report as chat text**, which is the single outcome this flow exists to prevent.
Anything unknown is now marked `unknown` in the file, and the offer to fill it comes after. **A
missing field is not a reason to withhold the artefact.**

**A migration you never ran is noticed on any message, not only on a command.** `UPGRADES.md`
having no line for the running version now reaches the session as a fact, before the first
message, from a hook that **only ever reports what the log says** — it makes no claim you could
forge, and it is silent when the log is current. The law that a project is checked before it is
acted on lives in the always-loaded core rather than in a companion, for a reason measured here:
scenario 24 asked *"what's next?"* against exactly that state and the run **read no companion at
all**, so the rules it needed were in a file nothing had opened. **A rule in a file nothing routes
to is a rule nothing executes.** After the change the same question produced the whole flow —
delta, log line, guide bumped, additions needing nothing named as such. **Once**, on a mid tier;
`evals/runs/0.3.0.md` carries what argues against reading it as more.

**A migration that creates every document the release names makes the workspace worse.** Two
places said *"create every docs file the new version expects"*; they now say **name** them and
**create only the ones with something to hold**, listing the rest as **available, not missing**.
Measured in the sibling project on the tier owners actually use: standing a workspace up produced
**ten to thirteen files before any work existed**, and the first unit of work arrived in the
third turn.

**The delta is one list, split by *does this need you?*** Mechanical items are applied on approval
and reported; items needing an answer are asked **in one batch**; items needing nothing are named
so the silence is visible. **A mixed list makes the owner read every line to find the two that
concern them.**

**"You do not have X" is three facts, and only two are findings.** Newly added · never used and
now load-bearing · **already declined**. The middle is an **adoption**, not a migration — offered
with its price and **declinable for good**, recorded against a moment rather than re-raised next
release.

**Issues are not one pile.** **Closed issues are never rewritten** — a closed issue records what
happened under the shape then in force. **An issue with a task in flight is not touched and not
even offered**, because the offer would interrupt a running agent. Started-but-idle is the
owner's choice; open-and-unstarted converts with the batch. **The counts go in the list
separately.**

**`UPGRADES.md` becomes a migration log, not only a restore point.** Every line now carries an
outcome — `applied` · `nothing-required` · `declined` · `deferred` · `failed`. **Swapping the
skill files is not migrating the company**, and until now nothing could tell the two apart: a
workspace whose migration never ran looked identical to one that migrated cleanly. **A check that
finds nothing still writes its line**, or *checked and clean* and *never checked* leave the same
trace.

**The one tier no setting can raise is Mops's own, because Mops *is* the session.** Dispatched
work is tiered by its agent's configuration — and it is tempting to treat tier as the runtime's
problem precisely because everything else here is. Anything Mops performs in its own turn says so
**before** starting and offers the moment to switch, **named as a tier, never as a product**. An
offer, not a gate. Measured next door: three migration scenarios one tier up moved `0/5 → 3/5`
and `0/5 → 4/5` **with no change to the text they read**.

**And the anchor is load-bearing at both ends of the model range.** A light model may not open
the skill because it does not connect the request to it; **a strong one may not open it because
it does not need to** — three runs of a build request on a high tier invoked nothing and read
nothing, writing and compiling the app instead. **Capability suppresses recourse to a
methodology.**

**Prioritisation names its alternatives and their questions.** ICE stays the default; **RICE**
(reach known and sourced), **WSJF** (what to do next under a constraint where delay costs
differently), **Kano** (whether to build at all), **MoSCoW** (a scope being negotiated) and
**Eisenhower** (a person's day, not a roadmap) each carry the question they answer. **The
framework is chosen before the scores** — running two and keeping the flattering answer is a way
of arriving where you were already going.

---

## 0.2.1 — 2026-08-01

**A correction release. Two things 0.2.0 published were wrong, and both were wrong in the same
way — a cause asserted without looking at the evidence that was available.**

**Why nothing embeds, correctly this time.** 0.2.0 blamed the blank Figma frame on the provider's
`X-Frame-Options`. The console says otherwise: `200 (OK)` beside `net::ERR_FAILED`, and
*"Access to script at 'https://www.figma.com/webpack-artifacts/…' from origin `null` has been
blocked by CORS policy"*. The documents were served and the browser then refused their own
bundles, because the attachment sandbox has no `allow-same-origin` and therefore presents origin
`null`. **It is Multica's sandbox, not the provider's framing policy** — so no choice of embed URL
fixes it, and links stay links.

**HTML is a half-open door.** An attached `.html` is `srcdoc` inside
`<iframe sandbox="allow-scripts">`: a **self-contained** page works — its own markup and CSS,
inline SVG, a plain `<img>` from any host, self-contained JavaScript — while a third-party embed
starves on the same `origin: null`. The other edge is unchanged and now stated plainly in
SECURITY.md: **an HTML file you did not write runs its author's JavaScript when someone opens the
issue.**

**Agents can read reactions and cannot leave one.** No verb anywhere in the CLI writes one — every
subcommand's help was swept — but a comment's `reactions` array populates with `emoji`, `actor_id`,
`actor_type` and `created_at`. **Issues carry no reactions field at all**, so *"wait for a 👍 on the
issue"* is unimplementable while the same rule on a comment is fine.

**Choosing a visual tool is choosing whether an agent can ever show its work.** Because links do not
embed and only images, PDF, HTML and text render, *agent-drivable* now has a stricter reading for
anything visual: **is there an official export to an image, and what does it require?** Four tiers
with measurements — a headless API (Figma's `GET /v1/images/:key`, no desktop app, 32 MP, assets
expiring after 30 days), an **editor bridge** that needs a person with the app open (Pen.dev's MCP
refuses with `failed to connect to running Pencil app`), **another runtime** (the OpenPencil CLI is
Bun-only; `npx` dies with `Bun is not defined`), and **no official export at all** (Rive), where the
picture is a human deliverable. Mermaid needs none of it, since a fence renders in the comment.

**Also:** the `.pen` format is not "plain JSON you can read" — the vendor states those files are
encrypted and are to be read only through its tools; the one examined happened to be readable, which
is a property of that file.

## 0.2.0 — 2026-08-01

**Everything below was measured against the live platform, and the entries that matter most are
the ones that corrected something this skill already said.**

---

**The install line on the front page had stopped working.** `multica skill import --url
github.com/jamillazarev/multica-ops` answers *"The Multica service is temporarily unavailable"* —
this CLI mislabelling a 502 — because the URL must point at the folder holding `SKILL.md`.
Corrected everywhere to `…/tree/v0.2.0/skills/mops`, and **pinned to the tag rather than `main`**:
an imported skill becomes agent instructions, so a moving ref means the content behind your agents
can change without you moving. Preflight now fails if that line drifts from the released version.
Two sentences explaining it were false in the same way — `skills/mops/SKILL.md` does not sit at
the repository root and never has; the real mechanism is the plugin manifest at the root beside a
corpus in `skills/mops/`.

**An audit is dispatched, not performed in the turn.** An autopilot in `create_issue` mode,
triggered manually, returns in about a second with the issue it created while the agent works on —
measured end to end: trigger at 00:21:59, finding written at 00:23:30, console free throughout.
**The second half of that instruction is `--subscriber`**, and it is the half that gets dropped:
the autopilot's issue is authored by the agent, your own actions don't notify you, and subscribers
are **members only** — the resident Mops cannot be subscribed to its own audit. Four flag facts
came with it, including `--priority`, which is accepted at create and update, appears in `--help`,
and is stored nowhere.

**The resume after a limit can be scheduled instead of waited for.** A limit hit at 02:10 that
resets at 07:00 costs five hours of a stopped team and needs only a person at the console. Cron is
exactly five fields, a pinned date is annual rather than one-shot, and the resumer has exactly one
shot because an autopilot task never auto-retries — so it is scheduled *after* the reset and its
trigger is deleted once it fires. **`next_run_at` promises nothing**: a disabled trigger and a
paused autopilot both keep reporting one.

**Waiting work stopped looking alive.** `blocked` is a status someone set, with a reason — and it
was being listed beside `in_progress` with no age anywhere, while the `/status` door promised
"ages and what the wait costs". `status.sh` now has a *Waiting on a human* section, oldest first,
and the age is named for what it measures: `updated_at`, i.e. last touched, because the platform
stores no status-change timestamp.

**A hire has no project to sit quietly in.** `agent create` has no project flag, nor does `agent
update` or `squad create` — so every role in a proposal names the work that needs it now, and
anything justified by "we'll need it" is listed in `LATER.md` instead. And a hire is not finished
when the agent exists: `mcp_config` and `custom_env` are per-agent with no workspace level, so an
agent hired into a team that already uses a tool arrives with none of it and stalls on its first
task looking capable.

**Five of the six sorts are readings; only `position` was written by anyone.** Priority is opt-in,
dates beat priority, and inflation is counted rather than forbidden. Measured: a new issue lands at
the *top* of its column, the authored order is per column (`reorder --before` across columns is
refused), and the position number survives a status change, so a move silently re-ranks against
different neighbours.

**`SECURITY.md`, written for whoever audits this.** What it reaches, what is actually gated with
an honest `enforced_by`, what is `prose-only` by name, where credentials live and how they sit at
rest, and a plain note on the 2026-07-30 scans: two of those alerts name files that have never
existed in this repository at any commit.

**`INSTALL.md`, and a site that cannot drift again.** The docs site carried two hand-written pages
with no source in the repo; they were two days behind it, which is how a front page came to publish
a broken command. Both are generated now, and the generator refuses any page without a source.

**What the platform shows, and what it only stores.** Measured across 39 attachments on one
issue, because the documentation says only *"Comments support formatting, code blocks, links,
and attachments"*. **A diagram is shown by writing it, not by attaching it.** A ` ```mermaid ` fence **in the comment
body renders as a drawn diagram**, and clicking it opens a viewer with zoom, a source/render
toggle, copy and download. The same Mermaid **attached as a file never renders** — `.mmd`,
`.mermaid`, `.txt` and `.md` all arrive `text/plain` and open a modal showing the source as text,
and a fence *inside* an attached `.md` is not rendered either. SVG previews inline, so a vector
diagram is a legitimate second route. `text/html` is rendered as **live HTML** in the comment,
which is in SECURITY.md because it changes what attaching a file from outside means. And a real
`.pen` is **JSON text**: readable in the preview as its own source, never a rendered design, so
the picture is an exported PNG or SVG with the `.pen` beside it.

Extension and sniffed type can disagree, and the inline renderer trusts the extension: Mermaid
text saved as `.png` renders as a **broken image**, while a real PNG saved as `.pen` renders as
the picture. A wrong name breaks visibly rather than quietly.

**Also:** the release title format is in the ritual now (0.2.0 shipped as a bare `0.2.0` above a
named 0.1.0 and was renamed the same day) · `SECURITY.md` gained the Contents its length requires.

**Also:** the urgent lane skips the queue and not the gates · a sync may not overwrite columns the
platform has no field for (craft, grade, *Owns* exist nowhere in a workspace) · "import" separated
into a move, a conversion, and "make ours better", which is not an import · a quick job reads the
project's own record before it asks · a synthetic round says what it cannot give *before* it
spends · derived surfaces regenerate from the tagged ref · eval scenario 22, and an honest run
record that names the debt it did not pay.

## 0.1.0 — 2026-07-31

**First release.** One version, one entry, and it says what it means: complete enough to run a
company on, young enough to change. Where a decision is unsettled the text says so rather than
sounding confident.

---

**Meet a front door, not a questionnaire.** A bare `/multica-ops:mops`, a "hi" or a description of a
situation routes itself: day zero checks (installed · signed in · workspace · daemon ·
runtimes) reported as one ladder, then three routing questions — build (`/multica-ops:init`),
continue (`/multica-ops:join`), bring a backlog (`/multica-ops:import`), or just ask (`/multica-ops:consult`,
which creates nothing). Two questions are never skipped — control level and governance —
and everything else has a default meant to be left alone. **Small stays small:** a quick job
gets three questions, one or two agents, build → review, and deliberately none of the
machinery; a crew is a standing team with no conductor, for owners who are the PM.

**Eighteen doors, and everything else is a sentence.** A verb earns a command when it is its
own flow, reached by name, repeatedly — never a synonym, never a phase inside another flow.
The other thirty flows are reached through `/multica-ops:mops <anything>` or plain language,
unchanged in what they do. **Commands are namespaced** (`/multica-ops:status`), always, because
that is how plugin commands work and the prefix is what stops two plugins colliding over one
verb; there is no bare `/mops`, and an earlier short alias installed by a session hook is
retired — delete `~/.claude/commands/mops.md` if you still carry it. The reason is a number:
**a door costs 30–110 tokens in every session of every agent, whether or not anyone uses it**,
and the palette as shipped costs **~820 always-on** rather than the ~3,288 it would with a
door per verb and paragraph-long descriptions (measured 2026-07-31 with `claude plugin details`).

**Run the conveyor on Multica's own primitives.** Workspace = company; the conductor (an
agent as project lead) grills intake into a spec, decomposes into staged sub-issues, and
accepts at the end; squad leaders route work addressed to their squad; `--stage` barriers
sequence; `@`-mention hands off. Native-first throughout: permission modes, properties,
resolvable comments, subscribers, labels — used, not re-invented.

**Say what you know, and how.** Every claim carries its rung — **measured › cited › recalled
› judgement call**, or `unknown` — and **the rung travels with the claim**: an agent may not
promote someone else's guess by quoting it. Prices and caps are fetched at the moment of use,
recorded with price · currency · date · source; a fact past its check-date is unknown, not
fine. Slow-rotting canon traces to `sources/SOURCES.md` with archive links.

**Know what every rule is actually held by.** Gates carry an honest **`enforced_by`** — a
request, a validator, branch protection, the Multica platform, or **`prose-only`, which
means nothing enforces it** — and the prose-only rules are listed by name (PLAYBOOKS →
Gates). Loosening exists only as a **grant** (right · grantee · scope · duration) that
expires by its own terms. Four kinds of action route to the owner whoever asks — spend,
outward, destructive, shape-of-company — and **no history buys them**: trust is earned per
role from its own run record, moves both ways, and a role never loosens its own gate.

**See what work cost, and what it wasted.** A per-release ledger (tokens · $ · time · per
agent and per human) from `issue usage`, with the **waste sliced from the same records**:
runs that produced nothing, reruns beyond the first, expensive tiers that bought nothing.
Runs that drive paid services record their spend outside the model (service · unit ·
quantity · amount · currency) as issue comments, gated by a threshold and a cap declared
once per service. Attribution names the model that **answered**, not the one that was asked
for. The budget shapes advice rather than only capping it; credits are runway with expiry
cliffs, never income.

**Everything that needs a decision is a request with an age.** `/multica-ops:status` opens with a
countable line ("3 need you · 2 running · 4 closed since Tuesday") and splits what differs
in kind: **needs you** (open requests with age and the cost of the wait — stays until
answered) from **happened** (events that age out), with workspace drift answered separately
by the fingerprint. Incoming feedback triages into four dispositions — accept · decline with
a reason · duplicate · snooze — and declining is a normal, cheap outcome.

**Lose a run without losing the work.** Session limits are recognised (`agent_error` + reset
time), recovery is `issue rerun`, **a rerun resumes rather than restarts** — incremental
commits and progress comments are team law, so state lives in artifacts, not in a dead
session's context.

**Ask the audience without lying to yourself.** The persona theatre: personas staged proto →
validated (interview transcript → QDA distillation as the grounding artifact), bias profiles
of 2–4 named biases each with a source, twins of real people with consent machinery, mixed
live + synthetic rounds where **a hypothesis never pools with a fact**, and verdicts that
state **direction, never magnitude**.

**Work beyond software.** `/multica-ops:ship` is the go-live moment whatever you make — an app
build, an episode, a production batch, a newsletter issue; launch checklists are researched
per medium rather than recalled; dated work respects its start date, which gates the whole
issue, preparation included.

**Keep the machinery honest about itself.** A shared vocabulary (`GLOSSARY.md` — one word,
one meaning, and the confusable pairs) and the recurring forms (`PATTERNS.md` — a rule that
instantiates a pattern cites it and stops). The corpus guards itself: preflight checks
version sync, links, budgets, command coherence and **facts past their recheck window**;
`verify.py` runs the documented CLI surface against the world; the four lenses (deletion ·
adversarial · contradiction · cold-read) read every release, by someone who is not the
author. The company's own docs get the same guard (`templates/company-preflight.sh`):
DECISIONS and FIELD-NOTES append-only, TOOLING check-dates, credential shapes stopped at the
door.

### Known limits

- **Platform caps are stated, not wished away**: 6 tasks per agent, 20 per daemon (tighter
  wins); a `local_directory` resource serialises regardless; `workspace delete` is not in
  the CLI. Verified against `multica` CLI v0.4.12.
- **Autopilot failures are silent** — no auto-retry, no inbox post; run them in
  `create_issue` mode and subscribe the owner.
- **Start dates are enforced by the team, not the platform.**
- **Some enforcement is prose**, and that list is written out by name (PLAYBOOKS → Gates) —
  including the one that cannot be enforced even in principle: that a price was fetched
  rather than recalled.
- **The eval suite is a rubric with recorded runs, not a runner** — scenarios are stratified
  from trivial to adversarial, runs land in `evals/runs/<version>.md` with `not run` listed
  rather than omitted, and the pass-rate is a regression detector, never a success metric.
