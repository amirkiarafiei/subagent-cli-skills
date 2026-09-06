---
name: pi-cli
description: Delegates large multi-step work to the Pi CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, and JSON-event-driven runs. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Pi CLI (subagent/task delegation)

> **Documented, not verified.** Written from Pi's published docs (pi.dev) on 2026-09-06 and **not**
> checked against an installed binary. Before trusting any flag here, run `pi --help`; on a mismatch use
> what the binary actually offers and tell the user which line in this file is wrong.

Use **Pi** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad
refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay
orchestrator: smaller prompts, less context burn.

## When to use Pi

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Event-driven monitoring**: `--mode json` emits a JSON-lines event stream (`agent_start`, `message_update` deltas, `tool_execution_*`, `agent_end`) — ideal for watching a long delegation.
- **Multi-provider model choice**: `--provider` and `--model <provider/id>` with a `--thinking` level.
- **Attachments**: files are referenced with `@` (`pi -p @screenshot.png "What's in this image?"`).
- **User explicitly asks** for Pi or "use Pi for this."

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Untrusted or destructive work.** Pi's docs state it "does not include a built-in sandbox" and that
  built-in tools "can read files, write files, edit files, and run shell commands with the permissions of
  the pi process." There is no tool-approval gate to fall back on — see below.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Low ROI (Return on Investment)**: if the task requires high precision over a single line, or composing the Handoff Table costs more than editing the file yourself.

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Pi does not see the main session's full
thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted
edits.

When composing the **single Pi prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, "use X not Y"—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, "no new deps," etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. "summarize then list files changed," "report only—no edits," or "apply edits with minimal diff." |

**After Pi returns**, pull **decisions and constraints** back into the main thread (what it assumed, what
it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs
that might diverge unless they share the same briefing.

## Model Selection & Discovery (Mandatory)

**Run `pi --list-models [search]`** for the model strings this install accepts. Models are given as
`--model <provider/id>` with an optional `:<thinking>` suffix, alongside `--provider <name>` (e.g.
`anthropic`, `openai`, `google`). Concrete IDs are **NOT DOCUMENTED** beyond that pattern — ask the
binary. `--thinking` accepts `off`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`. Use the web for
pricing and benchmarks only.

## Programmatic usage (required)

You **MUST** use Pi programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Non-interactive** | `-p`, `--print` — "Print response and exit". **The prompt itself is POSITIONAL.** |
| **Event stream** | `--mode json` (JSON lines) or `--mode rpc` (stdin/stdout RPC) |
| **Model** | `--provider <name>`, `--model <provider/id>`, `--thinking <level>` |
| **Ephemeral run** | `--no-session` (unsaved) |
| **Project trust** | `-a`, `--approve` / `-na`, `--no-approve` — **see below, this is not tool approval** |
| **Tool scoping** | `--tools <list>` / `-t`, `--exclude-tools <list>` / `-xt`, `--no-builtin-tools` / `-nbt`, `--no-tools` / `-nt` |
| **Auth override** | `--api-key <key>` |

> **Pi has no tool-approval gate, so there is nothing to bypass — and nothing to invent.** Unlike its
> peers, Pi ships **no `--yolo`-style approve-all flag**, because it has no per-tool-call permission
> system at all. Its docs are explicit: Pi "does not include a built-in sandbox," and built-in tools run
> "with the permissions of the pi process."
>
> `-a/--approve` means **"Trust project-local files for this run"** and `-na/--no-approve` means
> **"Ignore project-local files for this run."** That governs whether `.pi/settings.json`, project
> resources, extensions and project skills are *loaded* — **not** whether a tool call is allowed. Do not
> present it as an auto-approve flag.
>
> In headless use this is simply not a stall risk: **"Non-interactive modes (`-p`, `--mode json`, and
> `--mode rpc`) do not show a trust prompt."** Without a saved decision, untrusted project resources are
> ignored (global `defaultProjectTrust`: `ask` default, or `always` / `never`).
>
> ⚠️ The flip side is that a delegated Pi run has your full user permissions with no gate. Pi's own docs
> recommend running untrusted work "in a container, VM, micro-VM, remote sandbox, or policy-controlled
> sandbox." Scope risky delegations with `--tools`/`--no-tools` rather than reaching for a bypass that
> does not exist.

Pass `--approve` only when the delegation genuinely needs project-local skills or settings loaded.
**No exit-code table is documented** — treat empty output as failure rather than trusting the status.

## Command pattern

Composed from individually documented flags (not quoted verbatim from a single doc example):

```bash
pi -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" 2>&1
```

With the JSON event stream, for a long run you want to watch:

```bash
pi --mode json "GOAL: [goal] | ..." 2>&1
```

The docs' own verbatim examples, for reference: `pi -p "text"`, `pi --mode json "Your prompt"`,
`pi @README.md "prompt"`.

## After Pi returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly. This matters
  more here: there was no approval gate between Pi and your filesystem.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## If the call fails or hangs

Headless runs fail quietly more often than they fail loudly:

- **Wrap the call in an external timeout.** A headless CLI can stall before its own timeout arms. Pi
  documents **no timeout or limit flag at all**, so the bound must come from outside.
- **Exit 0 is not success.** If stdout is empty, treat the run as failed and read stderr — a tool
  permission the CLI could not prompt for, and a prompt that never arrived, both look like success.
- **Never carry a flag habit across CLIs.** The same short flag means different things in different
  tools — in OpenCode `-p` is `--password`, so passing a prompt to it silently empties the message and
  hangs the run forever. In Pi `-p` is `--print` and the prompt is positional. Confirm every flag
  against `pi --help`.
- **An unrecognized-flag error means this skill is stale, not that the task is impossible.** Run
  `pi --help`, proceed with the flags that exist, and tell the user which line here needs updating.
- **Missing project skills or settings is a *trust* symptom, not a bug.** Headless runs show no trust
  prompt, so untrusted project resources are silently ignored. Re-run with `--approve` if the delegation
  needed them.

## Quick prompts

- **Delegate implementation**: `pi -p "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]"`
- **Investigate (report only)**: `pi -p "GOAL: Map how [feature] works | SCOPE: [paths] | CONSTRAINTS: do not edit any file | OUTPUT: concise file:line map" --no-tools`
- **Watch a long run**: `pi --mode json "GOAL: [large task] | ..."`
- **Scoped, lower-risk pass**: `pi -p "GOAL: [task] | ..." --tools read,grep`
- **With project skills loaded**: `pi -p "GOAL: [task] | ..." --approve`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, JSON events, trust model, skills, auth: [reference.md](reference.md)
