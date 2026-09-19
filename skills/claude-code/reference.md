> **Checked against the official Anthropic documentation on 2026-09-19. Not run against an installed binary — confirm with `claude --help` before trusting a flag.**

## Authentication

`ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `CLAUDE_CODE_OAUTH_TOKEN`, or `claude login`. There is
no `CLAUDE_API_KEY`. Under `--bare`, only `ANTHROPIC_API_KEY` or `apiKeyHelper` (via `--settings`)
work — OAuth and keychain auth are not read, so a subscription-authenticated session fails.
Bedrock/Vertex/Foundry use their own provider credentials and are unaffected by `--bare`.

## Models

No CLI subcommand to print the model catalog is confirmed. Anthropic ships short family aliases
(fast/cheap, balanced-default, flagship, a highest-capability tier, plus long-context `[1m]`
variants, and a `default` value that clears any override) that resolve to the current generation —
prefer an alias over a dated snapshot ID. Select with `--model <alias-or-id>`; switch mid-session
with `/model`. Which model an alias resolves to can differ by provider (direct API vs. Bedrock vs.
Vertex vs. Foundry) — pin `ANTHROPIC_DEFAULT_*_MODEL` env vars if you need a stable resolution
across a fleet. Search the web / [Artificial Analysis](https://artificialanalysis.ai/) for current
names and pricing before picking one for the user.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--print`, `-p` | Execute prompt and exit (non-interactive). Prompt is positional/stdin, not this flag's value. |
| `--bare` | Minimal mode: skips hooks, LSP, plugin sync, auto-memory, keychain reads, and CLAUDE.md auto-discovery. |
| `--permission-mode <mode>` | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`, or `manual` (alias for `default`, v2.1.200+). |
| `--dangerously-skip-permissions` | Equivalent to `--permission-mode bypassPermissions`. Bypasses all confirmation prompts. |
| `--allowedTools`, `--disallowedTools` | Scope tool grants/denials without a full bypass, e.g. `--allowedTools "Bash,Read,Edit"`. |
| `--permission-prompts none` | Deny anything that would prompt instead of waiting on a permission host (v2.1.259+). |
| `--permission-prompt-tool <mcp-tool>` | Route permission prompts to an MCP tool in non-interactive mode. |
| `--model` | Specify the model to use. |
| `--output-format` | `text` (default), `json`, or `stream-json`. |
| `--max-turns` | Limit the number of agentic turns. |
| `--add-dir` | Grant access to an additional directory. |
| `--settings` | Inline JSON or file path to apply settings for this session only. |

## Approvals and permissions

- `--permission-mode auto` runs unattended behind a classifier-backed safety check.
- `--dangerously-skip-permissions` / `--permission-mode bypassPermissions` bypasses every prompt.
- **Do not use `--permission-mode plan`** for delegation — it is a read-only planning mode, not an
  auto-approving one, and stalls waiting for a human to approve the plan.
- **Unanswered approval, documented behavior:** in a `-p` run with no permission host attached,
  anything that would prompt is **denied by default** — there is nothing to stall on. If a
  permission host is attached (an Agent SDK `canUseTool` callback, or `--permission-prompt-tool`),
  the run waits on that host unless you also pass `--permission-prompts none`, which denies instead
  of waiting and tells Claude not to retry. With `--output-format stream-json`, each denial appears
  as a `permission_denied` system message and is listed in the final result's `permission_denials`.

## Subcommands

- `claude -p "prompt"` — headless one-shot run.
- `claude agents` — browse/launch agents; accepts `--permission-mode`, `--model`, `--effort`,
  `--dangerously-skip-permissions`, `--settings`, `--add-dir`, `--plugin-dir`, `--mcp-config`,
  `--strict-mcp-config`, `--cwd` (v2.1.14x+).

## Configuration and paths

- `~/.claude/settings.json` (or project `.claude/settings.json`) — permission `allow`/`deny` rules,
  default model, etc. Run `/status` inside an interactive session to confirm a settings file loaded.
- CLAUDE.md is auto-discovered unless `--bare` is set, in which case pass context explicitly via
  `--add-dir`, `--system-prompt`, `--settings`, `--agents`.

## Documentation

- Official docs: <https://code.claude.com/docs/en/cli-reference>,
  <https://code.claude.com/docs/en/headless>, <https://code.claude.com/docs/en/permission-modes>,
  <https://code.claude.com/docs/en/model-config>
- Vendor card in this skill: [SKILL.md](SKILL.md)

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
