---
name: gemini-cli
description: Delegates large multi-step work to Gemini CLI like a subagent—include full goal, prior decisions, scope, and constraints in prompts so isolated sessions stay aligned with the main thread (context handoff per Cognition-style delegation). Use for heavy edits, exploration, web search, @codebase_investigator, @generalist, or @gemini-cli-security. Skip for trivial one-shot tasks or when everything is already in context.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Gemini CLI (subagent/task delegation)

Use **Gemini CLI** to run a **separate long-horizon pass** over the repo: multi-step implementation, broad refactors, batch file writes, or deep exploration—similar to handing a **task to a subagent**. You stay orchestrator: smaller prompts, less context burn, often lower spend than doing the same work entirely in-session.

Inside Gemini CLI, **subagents** are specialists. Prefer **`@name` prefix** in the Gemini prompt to force one (e.g. `@codebase_investigator Map auth flow`). Core specialists include `codebase_investigator`, `generalist`, and `gemini-cli-security`.

## When to use Gemini CLI

- **Large or multi-step work**: several files, phases, or checkpoints (feature slice, migration, test suite, docs sweep).
- **Heavy code generation or editing**: Gemini drives `--yolo` tool use while you summarize outcomes and merge.
- **Parallel mental lane**: you continue planning or reviewing while Gemini runs a bounded task (optionally background—see [reference.md](reference.md)).
- **Built-in specialists**: `@codebase_investigator` for architecture / dependency mapping; `@generalist` for heavy multi-file subtasks with isolated context; `@gemini-cli-security` for security-focused passes.
- **Powerful Web Search**: Delegate deep research or API documentation searches to Gemini to leverage its integrated Google Search grounding. Use this when the main agent needs up-to-date information not present in the local context.
- **Fresh tool stack**: Google Search grounding, MCP tools, and other Gemini-only capabilities.
- **User explicitly asks** for Gemini or “use Gemini for this.”

## When not to use

- **Small / single-step** tasks answerable with one or two edits or a short explanation.
- **Tight feedback loops** where the user wants rapid back-and-forth refinement in one thread.
- **Secrets or policy-sensitive** flows—avoid piping credentials; redact before delegating.
- **Already-loaded context** where duplicating the whole plan adds no value—handle locally.

## Delegation and context (critical)

Isolated subagent context saves tokens but **splits the story**: Gemini does not see the main session's full thread. Poor handoffs cause misread subtasks, conflicting assumptions (stack, style, APIs), and wasted edits—see Cognition’s discussion of **sharing context** and **implicit decisions** in multi-step setups.

When composing the **single Gemini prompt**, treat it as passing **enough shared state**, not just a title:

| Include | Why |
|--------|-----|
| **Original goal** | Same north star as the user—not only the immediate micro-task. |
| **Decisions already made** | Framework, patterns, naming, auth approach, “use X not Y”—anything that would otherwise be guessed wrong. |
| **Scope** | Paths, modules, env (@paths), and explicit **out of scope** / do-not-touch areas. |
| **Constraints** | Performance, a11y, compatibility, review gates, “no new deps,” etc. |
| **Expected output** | e.g. “summarize then list files changed,” “report only—no edits,” or “apply edits with minimal diff.” |

**After Gemini returns**, pull **decisions and constraints** back into the main thread (what it assumed, what it changed, open risks). Prefer **sequential** delegations with explicit carry-over over parallel runs that might diverge unless they share the same briefing.

If the delegation would need a long transcript to be safe, **summarize** the relevant parts into the prompt (compressed “state of the union”) rather than a one-line subtask.

## Model Selection & Discovery (Mandatory)

**MANDATORY: Search the web for latest Gemini model names/aliases and pricing before selecting a model.** Names change monthly; using stale names causes failures.

- **Default (Simple Tasks)**: `flash` (Alias for latest `gemini-3.1-flash-preview`). Use for speed, research, and formatting.
- **Heavy Tasks**: `pro` (Alias for latest `gemini-3.1-pro-preview`). Use for deep reasoning and large-scale refactors.
- **Strategy**: Always default to `flash` to minimize costs. Only escalate to `pro` for critical architecture tasks after verifying latest version and cost via search.

## Programmatic usage (required)

You **MUST** use Gemini CLI programmatically. Do **NOT** start interactive sessions.

| Requirement | Flag |
|-------------|------|
| **Auto-approval** | `--yolo` or `-y` |
| **Silent output** | `-o text` (for clean response) |
| **Model Selection** | `-m [model_name/alias]` |
| **JSON stats** | `-o json` (if statistics are needed) |

## Command pattern

```bash
gemini "[prompt with @paths as needed]" --yolo -o text -m flash 2>&1
```

## After Gemini returns

- **Review** diffs and security-sensitive areas (XSS, injection, auth)—do not merge blindly.
- **Run** project checks (`lint`, `test`, `typecheck`) as appropriate.
- **Compress** results for the user: summarize results for the user instead of pasting huge logs unless asked.
- **Reconcile context**: note decisions, files touched, and remaining risks so the **main** session stays aligned.

## Quick prompts

- **Delegate implementation**: `gemini "Implement [feature] per [spec]. Touch only [dirs]. Apply with tools; do not ask for confirmation." --yolo -o text`
- **Investigate**: `gemini "@codebase_investigator Map how [feature] works; output a concise file:line map." --yolo -o text`
- **Web Search**: `gemini "Search for the latest documentation of [library] and summarize the breaking changes in version [version]." --yolo -o text`
- **Security**: `gemini "@gemini-cli-security Audit @./src for injection/XSS/auth issues; report with severities." --yolo -o text`

## More detail

- Delegation checklist (short): [reference.md](reference.md#delegation-checklist)
- Flags, JSON output, sessions, subagents, Auto Memory, worktrees, model steering: [reference.md](reference.md)
