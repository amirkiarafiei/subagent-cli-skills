# OpenHands CLI — reference

> **Checked against the official OpenHands documentation on 2026-09-19. Not run against an installed
> binary — confirm with `openhands --help` before trusting a flag.**

## Authentication

Configured via environment variables. `LLM_API_KEY` supplies the provider key; there is no separate
`omp login`-style command documented for headless auth.

## Models

No CLI command to list available models is documented. Configure the model with environment variables:

- `LLM_MODEL` — provider-prefixed identifier, e.g. `openhands/<identifier>` (via the OpenHands-hosted
  provider) or `<provider>/<identifier>` for a direct provider.
- `LLM_API_KEY` — the corresponding API key.
- `LLM_BASE_URL` — optional custom endpoint.

On first interactive run, OpenHands walks through choosing a provider and model and persists the choice
to `~/.openhands/settings.json`; `--override-with-envs` forces `LLM_MODEL`/`LLM_BASE_URL` from the
environment to take precedence over that saved configuration for a given run. For capability and price
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
| `--override-with-envs` | Force `LLM_MODEL`/`LLM_BASE_URL` env vars to override saved settings. |

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
| Persisted settings (after interactive first run) | `~/.openhands/settings.json` |

## Documentation

- Vendor documentation: <https://docs.openhands.dev/openhands/usage/cli/headless> and
  <https://docs.openhands.dev/openhands/usage/llms/openhands-llms>
- **Checked against the official documentation on 2026-09-19. Not run against an installed binary —
  confirm with `openhands --help` before trusting a flag.**

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
