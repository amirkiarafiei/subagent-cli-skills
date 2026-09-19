> **Checked against the official OpenAI documentation on 2026-09-19. Not run against an installed binary — confirm with `codex --help` before trusting a flag.**

## Authentication

`OPENAI_API_KEY`, or `codex login` for a ChatGPT-account/device-code login. `codex logout` clears
stored credentials.

## Models

No dedicated `exec`-time flag to print the full model catalog is confirmed in the same depth as
other flags; the docs reference **`codex debug models`** for inspecting available models — verify
this against the installed binary before relying on it. Select the model for a run with `--model`,
`-m <identifier>`. Reasoning effort/tier is a separate, model-independent setting (see below), not
part of the model string. Interactively, `/model` changes the model and effort mid-session. Search
the web / [Artificial Analysis](https://artificialanalysis.ai/) for current identifiers and pricing
— names and retirement dates change often enough that a pinned one can fail outright.

Reasoning effort is set independently of the model, e.g. via a config override such as
`-c model_reasoning_effort="<level>"` — do not look for a separate "thinking" model name.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `exec "prompt"` (alias `e`) | Run Codex non-interactively; exits after the response. Prompt is positional. |
| `--sandbox`, `-s <read-only\|workspace-write\|danger-full-access>` | Sandbox policy for model-generated shell commands. |
| `--ask-for-approval`, `-a <never\|on-request\|on-failure\|untrusted>` | Approval policy. Root-level flag; the docs' own examples highlight `on-request` and `never`. |
| `--dangerously-bypass-approvals-and-sandbox` (alias `--yolo`) | Sets sandbox to `danger-full-access` and approval policy to `never` together. Only in an already-hardened environment. |
| `--model`, `-m` | Specify the model to use. |
| `--profile`, `-p <name>` | Layer a named configuration profile. |
| `--json` | Print newline-delimited JSON events instead of formatted text. |
| `--output-last-message`, `-o <path>` | Write the assistant's final message to a file. |
| `--ignore-user-config` | Skip loading the standard configuration file. |
| `--cd`, `-C <path>` | Set the project directory (root-level flag). |
| `--image`, `-i <path>` | Attach an image to the prompt (root-level flag). |

## Approvals and permissions

- `codex exec` **defaults to `AskForApproval::Never`** even with no flag set — headless mode does
  not wait on approval by default.
- `--ask-for-approval never` suppresses prompts but does **not** by itself grant network access —
  that's the separate `sandbox_workspace_write.network_access` config key.
- `--dangerously-bypass-approvals-and-sandbox` / `--yolo` is the single flag for "no sandbox, no
  approvals" — use it for unattended delegation, only in a hardened environment.
- **Unanswered approval, documented behavior:** the official docs state plainly that when an
  approval is needed but unavailable in non-interactive mode, **"Codex exits with an error."** It
  does not stall.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `exec` (alias `e`) | Run non-interactively. |
| `review` | Run a code review non-interactively. |
| `resume` | Resume a previous interactive session (picker by default; `--last` for most recent). |
| `login` / `logout` | Manage authentication. |
| `agents` | Browse agent sessions on the shared local app-server daemon. |
| `features list` / `enable <name>` / `disable <name>` | Manage feature flags in `config.toml`. |
| `debug models` | Inspect available models (verify against your install). |

## Configuration and paths

- `config.toml` — global settings; a project-level profile can be layered with `--profile`.
- `AGENTS.md` — instruction pipeline for a repo; create/update via `/init` in an interactive session.
- Sessions are saved locally and resumed with `codex resume`; `--ephemeral` on other commands
  avoids saving rollout files for a cleaner CI/CD run.

## Documentation

- Official docs: <https://developers.openai.com/codex/cli>,
  <https://developers.openai.com/codex/cli/reference>
- Vendor card in this skill: [SKILL.md](SKILL.md)

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
