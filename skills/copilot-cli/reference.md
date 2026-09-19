> **Checked against the official GitHub documentation on 2026-09-19. Not run against an installed binary — confirm with `copilot --help` before trusting a flag.**

## Authentication

`GH_TOKEN` or `GITHUB_TOKEN` (personal access token), set as an environment variable before running
`copilot` non-interactively.

## Models

No CLI subcommand or flag to print the model catalog is documented. Copilot is a **multi-provider
gateway** — several providers' models ship through the same `--model=<identifier>` flag —
availability varies by plan, org policy, and region. The official docs say the only way to see the
model strings for all available models is to run **`/model`** in an interactive session; there is no
documented headless-only listing. Search the web / [Artificial Analysis](https://artificialanalysis.ai/)
for current identifiers and pricing before picking one.

## Essential Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--prompt <PROMPT>` | Execute a prompt in non-interactive mode; exits when done. Prompt is this flag's value. |
| `-s` | Suppress stats/decoration; output only the agent's response. |
| `--output-format=text\|json` | `json` is JSONL — one object per turn/tool-call/response. |
| `--attachment <path>` | Attach a file (image or native document) to the initial prompt (`-p`/`--prompt` mode only). |
| `--model=<identifier>` | Choose the AI model. |
| `--agent=<name>` | Specify a custom agent to use for the session. |
| `--add-dir <path>` | Add a directory to agent context; rejects non-directory/inaccessible paths and aborts startup. |
| `--share [path]` | Export the session transcript to Markdown. |

## Approvals and permissions

| Flag | Grants |
|---|---|
| `--allow-all` (alias `--yolo`) | All permissions — tools and URL fetches. |
| `--allow-all-tools` | Every tool, without per-call confirmation (narrower than `--allow-all`: does not itself grant URL access). |
| `--allow-tool=<TOOL>` | One specific tool (comma-separated list for several). |
| `--allow-url=<URL>` | One specific URL/domain. |
| `--deny-tool=<TOOL>`, `--deny-url=<URL>` | Explicit denials. |

The official docs recommend minimal grants (`--allow-tool`/`--allow-url`) over `--allow-all` outside
a sandboxed environment. **Unanswered approval, documented behavior:** not explicitly documented for
a call that falls outside every allow flag in headless mode — do not rely on a graceful denial; pass
`--allow-all` (or the precise tool/URL grants the task needs) before running headless.

## Subcommands

Primarily invoked as `copilot -p "..."` with flags; slash commands (`/model`, `/agent`, `/mcp`,
etc.) are interactive-session only and not part of the non-interactive flag surface.

## Configuration and paths

- `.github/copilot-instructions.md` — created by `copilot init`; project instructions.
- `.gitignore` and `.copilotignore` — path exclusions.
- Custom model providers: `COPILOT_PROVIDER_BASE_URL`, `COPILOT_PROVIDER_TYPE`,
  `COPILOT_PROVIDER_API_KEY`, `COPILOT_MODEL` environment variables.
- `COPILOT_SUBAGENT_MAX_DEPTH` (default 6) and `COPILOT_SUBAGENT_MAX_CONCURRENT` (default 32) —
  recursion/parallelism limits for custom agents.

## Documentation

- Official docs: <https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-programmatic-reference>,
  <https://docs.github.com/copilot/concepts/agents/about-copilot-cli>
- Vendor card in this skill: [SKILL.md](SKILL.md)

## Delegation Checklist

1. **Full Goal**: State the desired outcome clearly.
2. **Prior Decisions**: Explicitly mention tech stack, naming conventions, and patterns.
3. **Scope**: Define `@files` or directories to work in.
4. **Constraints**: Mention performance, security, or style requirements.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes directly," "Provide a report only," etc.
