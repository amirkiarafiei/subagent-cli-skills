# OpenHands CLI — reference

> **Checked against the official documentation on 2026-11-05; not run against an installed binary.**
> Latest release on PyPI: `openhands` 1.16.0. Confirm with `openhands --help` before trusting a flag.
>
> **Maintenance status:** the official headless page says "The OpenHands CLI is no longer actively
> maintained" and points to Agent Canvas. The GitHub repo is not archived and was last pushed
> 2026-10-22. The signals conflict.

## Install

`uv tool install openhands --python 3.12` (Python 3.12+, uv 0.11.6 or newer), or
`curl -fsSL https://install.openhands.dev/install.sh | sh`. A Docker route also exists. Source:
<https://docs.openhands.dev/openhands/usage/cli/installation>.

## Authentication

The official installation page says the CLI prompts for the required LLM settings on first run and
stores them in `~/.openhands/agent_settings.json`. No separate headless login command is documented.

## Models

No CLI command to list available models is documented. Official installation page: LLM settings live
in `~/.openhands/agent_settings.json`, are asked for on first run, and are reused later. Upgrading from
a pre-1.0.0 CLI needs the settings set up again. The official headless page does not say how a headless
run selects its model, so configure it once interactively first.

Earlier versions of this card named `LLM_MODEL`, `LLM_API_KEY`, `LLM_BASE_URL` and an
`--override-with-envs` flag. **The official docs mention none of them.** DeepWiki (third-party,
source-derived) says no such variables or flag exist. They were removed here. Confirm with
`openhands --help`. For capability and price
comparisons, check [Artificial Analysis](https://artificialanalysis.ai/) and the vendor's own
documentation, since no fixed model list is published here.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `--headless` | Run without the interactive UI, for scripting and automation. |
| `-t`, `--task` | Provide a task description directly. |
| `-f`, `--file` | Load a task description from a file. |
| `--json` | Enable structured JSONL output streaming events (actions and observations). |
| `--resume` | Resume a previous conversation. |

One of `-t`/`--task` or `-f`/`--file` is required to run headless — there is no bare positional prompt
form.

## Approvals and permissions

No separate approve-all flag exists, and none is needed: the official docs state plainly, **"Headless
mode always runs in `always-approve` mode."** Every action executes automatically without confirmation,
and this cannot be changed — `--llm-approve` (the interactive approval toggle) is documented as
unavailable in headless mode. There is no three-level scheme and no documented case of a tool call that
still can't be resolved: headless is unconditionally auto-approve.

## Subcommands

None beyond the top-level flags are documented in the sources used here.

## Configuration and paths

| Component | Path |
|---|---|
| LLM settings (after interactive first run) | `~/.openhands/agent_settings.json` |
| CLI preferences | `~/.openhands/cli_config.json` |
| MCP servers | `~/.openhands/mcp.json` |
| Conversation history | `~/.openhands/conversations` |

All four paths are from the official installation page.

## Documentation

- Vendor documentation: <https://docs.openhands.dev/openhands/usage/cli/headless> and
  <https://docs.openhands.dev/openhands/usage/cli/installation>
- **Checked against the official documentation on 2026-11-05; not run against an installed binary**
  (PyPI `openhands` 1.16.0). Confirm with `openhands --help` before trusting a flag.

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
