---
name: antigravity-cli
description: Delegates large multi-step work to Antigravity CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, web search, @codebase_investigator, @generalist, or @gemini-cli-security. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Antigravity CLI (subagent/task delegation)

Use **Antigravity CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Inside Antigravity CLI, **subagents** are specialists. Prefer **`@name` prefix** in the prompt to force one (e.g. `@codebase_investigator Map auth flow`). Core specialists include `codebase_investigator`, `generalist`, `gemini-cli-security`, and `code-review`.

## When to use Antigravity CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Antigravity drives automated tool use while you summarize outcomes and merge.
- **Parallel mental lane**: you continue planning or reviewing while Antigravity runs a bounded task in the background (optionally background—see `/tasks` or TUI `/agents` panel).
- **Built-in specialists**: `@codebase_investigator` for architecture / dependency mapping; `@generalist` for heavy multi-file subtasks with isolated context; `@gemini-cli-security` for security-focused passes.
- **Powerful Web Search**: Delegate deep research or API documentation searches to Antigravity to leverage its integrated web search grounding.
- **Fresh tool stack**: Native Google search grounding, MCP tools, sandbox protection, and other Antigravity-only capabilities.
- **User explicitly asks** for Antigravity or “use Antigravity CLI for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.
- **Low ROI (Return on Investment)**: If the task requires high precision over a single line or if the time to compose the Handoff Table exceeds the time to simply edit the file locally. Delegation should only be used when the "mental offloading" outweighs the "handoff overhead."

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Antigravity does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits.

When composing the **single Antigravity prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, env (@paths), and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Verification** | Explicit command (e.g. `npm test`, `lint`) the subagent **must** run and pass before returning. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

**After Antigravity returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed “state of the union”) rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Gemini model names/aliases and pricing before selecting a model.** You should also consult [Artificial Analysis](https://artificialanalysis.ai/) for the most up-to-date benchmarks, pricing, and model performance data. Names change frequently.

- **Default (Simple Tasks)**: `gemini-3.5-flash` (Use for speed, research, and formatting).
- **Heavy Tasks**: `pro` / `gemini-3.5-pro` (Use for deep reasoning and large-scale refactors).
- **Strategy**: Always default to `gemini-3.5-flash` to minimize costs. Only escalate to pro versions for critical architecture tasks after verifying latest version and cost via search.

## Programmatic usage (required)

You **MUST** use Antigravity CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag / Option |
|-------------|---------------|
| **Auto-approval** | `--dangerously-skip-permissions` or `--yolo` |
| **Silent output** | `-o text` (for clean response) |
| **Model Selection** | `--model [model_name/alias]` |
| **No Startup Delay**| `--bare` |

## Command pattern

```bash
agy "[prompt with @paths as needed]" --dangerously-skip-permissions -o text --model gemini-3.5-flash 2>&1
```

## After Antigravity returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `agy "GOAL: [goal] | DECISIONS: [decisions] | SCOPE: [paths] | CONSTRAINTS: [constraints] | VERIFICATION: [test_command] | OUTPUT: [format]" --dangerously-skip-permissions -o text --model gemini-3.5-flash`
- **Investigate**: `agy "@codebase_investigator GOAL: Map how [feature] works | SCOPE: [paths] | OUTPUT: concise file:line map" --dangerously-skip-permissions -o text`
- **Web Search**: `agy "GOAL: Find latest documentation for [library] | CONSTRAINTS: focus on breaking changes in [version] | OUTPUT: summary report" --dangerously-skip-permissions -o text`
- **Security**: `agy "@gemini-cli-security GOAL: Audit for injection/XSS/auth issues | SCOPE: @./src | OUTPUT: report with severities" --dangerously-skip-permissions -o text`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, JSON output, sessions, subagents, sandbox, and model steering: [reference.md](reference.md)
