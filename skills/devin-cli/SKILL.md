---
name: devin-cli
description: Delegates large multi-step work to Devin CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for multi-step implementation, repo-wide changes, and autonomous sandboxed runs. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Devin CLI (subagent/task delegation)

> **Documented, not verified.** Written from Devin's published CLI docs on 2026-09-06 and **not** checked
> against an installed binary. Before trusting any flag here, run `devin --help`; on a mismatch use what
> the binary actually offers and tell the user which line in this file is wrong. This matters more than
> usual for Devin — see the permission-mode conflict below.

Use **Devin CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad
refactors, or repo-wide changes—similar to handing a **task to a subagent**. You stay orchestrator:
smaller prompts, less context burn.

## When to use Devin CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Repo-wide changes**: Devin indexes connected repositories and discovers skills across them.
- **Autonomous runs**: an `autonomous` permission mode auto-approves everything **except file writes**, with an OS sandbox enforcing the boundary instead of prompts (requires `--sandbox`).
- **Exportable results**: `--export out.json` captures a run for later inspection.
- **User explicitly asks** for Devin or "use Devin for this."

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: if the task requires high precision over a single line, or composing the Handoff Table costs more than editing the file yourself. Delegate only when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Devin does not see the main session's
full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and
wasted edits.

When composing the **single Devin prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, "use X not Y"—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, "no new deps," etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. "summarize then list files changed," "report only—no edits," or "apply edits with minimal diff." |

**After Devin returns**, pull **decisions and constraints** back into the main thread (what it assumed,
what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel
runs that might diverge unless they share the same briefing.

## Model Selection & Discovery (Mandatory)

**Run `devin models list --format json`** for the model strings this install accepts. The docs mention a
`--model` flag and a `DEVIN_MODEL` environment variable, and show `--model opus` in an example, but **do
not enumerate the accepted IDs** — so ask the binary rather than copying from here. `/fast` is documented
as switching to "SWE-1.6 Fast". Use the web for pricing and benchmarks only.

## Programmatic usage (required)

You **MUST** use Devin CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p`, `--print [PROMPT]` — "Non-interactive output mode, exits after response" |
| **Auto-approval** | `--permission-mode <MODE>` — see the conflict note below |
| **Sandboxed autonomy** | `--sandbox` — required by the `autonomous` mode |
| **Model** | `--model <MODEL>` (or `DEVIN_MODEL`) |
| **Export a run** | `--export out.json` |
| **Config file** | `--config <PATH>` |
| **Workspace trust** | `--respect-workspace-trust [true\|false]` (defaults `true`) |

Documented permission modes: `normal` (default), `accept-edits`, `smart` (auto-approves edits; a fast
model judges other actions and falls back to prompting), `dangerous`, and `autonomous` (requires
`--sandbox`; auto-approves everything **except file writes**). The mode is also settable via the
`DEVIN_PERMISSION_MODE` environment variable.

> ⚠️ **Devin's own two doc pages disagree on the name of the bypass mode.** The essential-commands page
> calls it `bypass` (aliases `/yolo`, `/dangerous`); the command reference lists the CLI mode as
> `dangerous`. **Do not guess.** Run `devin --help` (or `devin --permission-mode` with an invalid value)
> to see which spelling this build accepts, use that, and tell the user which name was correct so this
> file can be fixed. Whichever it is, the documented behaviour is the same: it "auto-approves **all**
> tool calls."

The prompt can also be passed after `--` (`devin -- add a login page`), but for delegation use `-p` so
the run is explicitly non-interactive and exits. **No exit-code table is documented** — treat empty
output as failure rather than trusting the status alone.

## Command pattern

Composed from individually documented flags (not quoted verbatim from a single doc example). Resolve
`<bypass-mode>` against `devin --help` before first use:

```bash
devin -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" \
  --permission-mode <bypass-mode> 2>&1
```

The docs' own verbatim examples, for reference:

```bash
devin -p "list all TODO comments"
devin --permission-mode accept-edits -- fix the failing tests
devin --sandbox -- run the migration script
```

## After Devin returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## If the call fails or hangs

Headless runs fail quietly more often than they fail loudly:

- **Wrap the call in an external timeout.** A headless CLI can stall before its own timeout arms. Devin
  documents no general wall-clock limit (`--timeout` exists only on `devin cloud drs run`), so the bound
  must come from outside.
- **Exit 0 is not success.** If stdout is empty, treat the run as failed and read stderr — a tool
  permission the CLI could not prompt for, and a prompt that never arrived, both look like success.
- **Never carry a flag habit across CLIs.** The same short flag means different things in different
  tools — in OpenCode `-p` is `--password`, so passing a prompt to it silently empties the message and
  hangs the run forever. Confirm every flag against `devin --help`.
- **An unrecognized-flag error means this skill is stale, not that the task is impossible.** Run
  `devin --help`, proceed with the flags that exist, and tell the user which line here needs updating.
  A rejected `--permission-mode` value is the expected first failure here — see the conflict note above.

## Quick prompts

- **Delegate implementation**: `devin -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --permission-mode <bypass-mode>`
- **Edits without full bypass**: `devin -p "GOAL: [task] | ..." --permission-mode accept-edits`
- **Investigate (report only)**: `devin -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map"`
- **Sandboxed autonomous run**: `devin -p "GOAL: [task] | ..." --permission-mode autonomous --sandbox`
- **Capture the run**: `devin -p "GOAL: [task] | ..." --permission-mode <bypass-mode> --export out.json`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, permission modes, models, skills, auth: [reference.md](reference.md)
