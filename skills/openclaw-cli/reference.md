# OpenClaw — reference

> **Checked against `openclaw` 2026.9.5 (ec9c1a1) on 2026-09-20.** Provenance is stated per claim,
> because not all of it carries the same weight:
>
> - **From `--help`:** every flag and subcommand.
> - **From real runs:** the JSON envelope and its keys, the stdout/stderr split, exit code `1`, the
>   default approval policy printed by `exec-policy show`, the managed-skills layout from
>   `skills list --json`, and the Node engine requirement.
> - **From the installed package:** the skill limits (`dist/node-skill-constraints`) and the
>   frontmatter contract (the bundled `skill-creator` skill).
> - **From vendor docs only, not reproduced here:** exit codes `0` and `2`, and the full enumeration
>   of security and ask levels. These are marked in place.
>
> A successful delegation was **not** run, because that needs provider credentials. Nothing here was
> taken from documentation where the binary could answer instead — the docs already disagree with this
> build on where `--json` lives and on the description-length limit. `openclaw <command> --help` is the
> only authority. On an unrecognized flag, re-read `--help`, use what exists, and report that this file
> needs updating.

## Authentication

Credentials belong to the host, not to the call. Provider keys are configured through
`openclaw onboard`, `openclaw configure`, or `openclaw models auth`, and stored credentials are used
by default.

- `openclaw models status` — check provider auth health before delegating.
- `--auth-env-only` on `agent exec` — use provider keys from environment variables only, ignoring
  stored and external CLI logins. Useful for a reproducible or CI-style run.
- `--no-auth-env-only` — the inverse; allow stored and external CLI credential discovery.

A run with no usable credential still returns a well-formed JSON envelope and exits `1`:

```json
{ "ok": false, "status": "error", "final": "", "payloads": [],
  "error": { "message": "No route-compatible authentication source is configured for <provider>.",
             "kind": "exception" } }
```

Scripted setup exists as `openclaw onboard --non-interactive --accept-risk …` (add `--json` for a
machine-readable summary). `--accept-risk` is described by the binary as "Acknowledge that agents are
powerful and full system access is risky", and it is *required* for `--non-interactive`. That is a
host setup step for the user, not something a delegating agent should run on their behalf.

## Models

`openclaw models list --json` is the only authority for the identifiers this install accepts.

| Command | Purpose |
|---|---|
| `openclaw models list` | List configured models |
| `openclaw models list --json` | Same, machine-readable |
| `openclaw models list --all` | Full published catalogue |
| `openclaw models list --refresh` | Rediscover providers first |
| `openclaw models list --provider <id>` | Filter by provider |
| `openclaw models list --local` | Local endpoints only |
| `openclaw models status` | Configured model state and auth health |
| `openclaw models set` | Set the persistent default (check its `--help` for the argument) |

Per-run selection is `--model <provider/model>`. `--fallback <provider/model>` adds an ordered
fallback; it is repeatable and requires `--model`. Never hard-code a model identifier — ask the
binary.

## Essential Flags

`openclaw agent exec [options] [message]` — one isolated headless embedded turn, no Gateway.

| Flag | Meaning |
|---|---|
| *(positional)* | The prompt |
| `--message-file <path>` | Read the UTF-8 prompt from a file; `-` reads stdin |
| `--json` | Emit the stable agent-exec JSON envelope |
| `--timeout <seconds>` | Agent deadline; default `600` |
| `--cwd <dir>` | Set both the agent workspace and the tool working directory |
| `--model <provider/model>` | Explicit primary model |
| `--fallback <provider/model>` | Ordered fallback; repeatable; requires `--model` |
| `--thinking <level>` | `off\|minimal\|low\|medium\|high\|xhigh\|adaptive\|max\|ultra` |
| `--isolated` | Ignore the ambient config; run against exec defaults only |
| `--config <path>` | Run against an explicit config file |
| `--state-dir <dir>` | Use an existing state directory instead of a temporary one |
| `--code-mode <mode>` | Tool mode: `direct \| auto \| code` |
| `--local-model-lean` | Reduced local-model tool surface |
| `--auth-env-only` | Environment-variable provider keys only |

The global flags on `openclaw` itself are `--container`, `--dev`, `--log-level`, `--no-color`,
`--profile`, `-V` and `-h`. **`--json` is not among them** — it belongs to the subcommand.

`openclaw agent` (the Gateway form) takes the prompt as `-m, --message <text>` or
`--message-file <path>`, plus `--local`, `--agent <id>`, `--session-id`, `--session-key`,
`-t, --to`, `--deliver`, `--channel`, `--model <id>`, `--timeout`, `--thinking`, `--json`.

**`-m` means `--message`, not `--model`.** `--model` has no short form on either command, and
`agent exec` has no `-m` at all.

### Output and exit codes

**Observed by running `agent exec --json`:** stdout carries the envelope alone and every diagnostic
goes to stderr, so the output parses without filtering. The envelope keys are `ok`, `status`, `final`,
`payloads`, `model`, `provider`, `sessionId`, and `error` (`message`, `kind`) on failure. Read the
answer from `.final`.

| Code | Meaning | Provenance |
|---|---|---|
| `0` | Completed turn | vendor docs — **not observed here** |
| `1` | Model or result error | **observed** on a run with no usable credential |
| `2` | Timeout | vendor docs — **not observed here** |

Only exit `1` was reproduced, because a successful turn and a timeout both need working provider
credentials. Treat `0` and `2` as documented rather than proven, and confirm them on first use.
Check `.ok` as well as the exit code: a failed run still prints a well-formed envelope.

## Approvals and permissions

Approvals are **host configuration, not a flag**. There is no per-run approve-all option on
`agent exec`, and none is needed on a default host.

Verified default on a clean install, from `openclaw exec-policy show`:

    tools.exec   requested: host=auto, security=full, ask=off     (all "OpenClaw default")
                 host:      security=full, ask=off, askFallback=deny
                 effective: security=full, ask=off

So OpenClaw ships auto-approving and a headless run does not stall. The effective policy is the host
approvals policy intersected with the requested `tools.exec` policy.

| Command | Purpose |
|---|---|
| `openclaw exec-policy show` | Config policy, host approvals, and the effective merge |
| `openclaw exec-policy preset <name>` | Apply `yolo`, `cautious`, or `deny-all` |
| `openclaw exec-policy set …` | Synchronize with explicit values |
| `openclaw approvals pending` | Pending exec, plugin and system-agent approvals |
| `openclaw approvals resolve` | Resolve one pending approval |
| `openclaw approvals grants` | Standing grants minted by allow-always |
| `openclaw approvals allowlist` | Edit the per-agent allowlist |

Per the vendor documentation, security levels are `deny`, `allowlist`, `full` and `ask` is `off`,
`on-miss`, or `always`; only the default combination above was observed here. Because the
default `askFallback` is `deny`, an **exec** request that falls through to asking on a headless host
is denied rather than queued, so a tightened host fails fast instead of hanging. Plugin and
system-agent approvals use a separate queue that `approvals pending` still reports.

A delegating agent should run `exec-policy show`, read the effective column, and — if the host has
been tightened — report it and let the user decide. Changing a host-wide approval policy is the
user's call, not the subagent caller's.

## Subcommands

`openclaw --help` lists a large surface. The ones that matter for delegation:

| Command | Purpose |
|---|---|
| `agent exec` | One isolated headless embedded turn (**use this**) |
| `agent` | One turn via the Gateway; `--local` runs it embedded instead |
| `models` | Discovery, scanning, configuration |
| `exec-policy` / `approvals` | Approval policy and pending requests |
| `skills` | List, check, inspect and install skills |
| `sessions` | List stored conversation sessions |
| `gateway` | Run, inspect and query the WebSocket Gateway |
| `doctor` | Health checks and quick fixes |
| `docs` | Search the live OpenClaw docs |

## Agent Skills

OpenClaw is also a **host** for skills, so this repository's skills can be installed into it.

- `openclaw skills list --json` reports `workspaceDir` and `managedSkillsDir`.
- Verified layout: `managedSkillsDir` is `<state-dir>/skills`, so the default is
  `~/.openclaw/skills`; the workspace is `<state-dir>/workspace`.
- `openclaw skills install <ref> --global` installs into the shared managed directory. The ref is a
  ClawHub slug (`@owner/slug`), `git:<repo>`, or a local directory. `--as <slug>` renames,
  `--force` overwrites, `--version <version>` pins.
- `openclaw skills check` reports how many skills are eligible, visible to the model, and missing
  requirements.

`OPENCLAW_STATE_DIR` moves the whole state directory, and the managed skills directory moves with it.

Skill frontmatter, quoted from the `skill-creator` skill bundled inside the installed package:
"Required: `name`, `description`." and "OpenClaw also supports `metadata`, `homepage`, `license`,
`allowed-tools`, `user-invocable`, `disable-model-invocation`, `command-dispatch`, `command-tool`,
and `command-arg-mode`." So this repository's `allowed-tools` key is recognized, not ignored.

Limits, read from the shipped `node-skill-constraints` module rather than from documentation:

| Constant | Value |
|---|---|
| `MAX_DESCRIPTION_LENGTH` | 1024 characters |
| `MAX_CONTENT_BYTES` | 65536 bytes per skill file |
| `MAX_TOTAL_BYTES` | 524288 bytes |
| `MAX_SKILLS_IN_PROMPT` | 150 skills |
| `MAX_SKILLS_PROMPT_CHARS` | 18000 characters |

Every skill in this repository sits well inside all of these. Beware third-hand claims of a
160-character description limit — the shipped constant is 1024.

Bundled skills can declare `metadata.openclaw.requires` (`bins`, `anyBins`, `env`, `config`) and `os`
to gate themselves on what the machine actually has; `openclaw skills list --json` reports a
`missing` object with exactly those keys, and `skills check` summarises what is unmet.

## Configuration and paths

| Path | Contents |
|---|---|
| `~/.openclaw/` | Default state directory |
| `~/.openclaw/openclaw.json` | Config |
| `~/.openclaw/skills/` | Managed (global) skills |
| `~/.openclaw/workspace/` | Agent workspace, including workspace skills |
| `~/.openclaw/state/openclaw.sqlite` | State; `exec-policy show` names `#exec_approvals_config` here |
| `~/.openclaw-dev/` | `--dev` profile, gateway port 19001 |
| `~/.openclaw-<name>/` | `--profile <name>` |

`OPENCLAW_STATE_DIR` and `OPENCLAW_CONFIG_PATH` override these. The Gateway listens on port 18789 by
default and takes `--port`, `--auth <mode>`, `--token` and `--password`; the `--dev` profile shifts it
to 19001. None of this matters for `agent exec`, which runs without a Gateway.

`openclaw` requires Node `>=24.16.0 <25` or `>=26.1.0`; the installer refuses to run on older Node.

## Documentation

- CLI index: <https://docs.openclaw.ai/cli>
- `agent` and `agent exec`: <https://docs.openclaw.ai/cli/agent>
- Approvals: <https://docs.openclaw.ai/cli/approvals>
- Models: <https://docs.openclaw.ai/cli/models>
- Skills: <https://docs.openclaw.ai/cli/skills>
- `openclaw docs "<query>"` searches the live docs from the terminal.

## Delegation Checklist

1. **Full Goal**: Clearly state the final objective.
2. **Prior Decisions**: Explicitly mention tech stack and architectural choices.
3. **Scope**: Define the exact modules or directories to touch.
4. **Constraints**: Performance, security, or style guidelines.
5. **Verification**: Explicit command the subagent must pass before returning.
6. **Desired Shape**: "Apply changes," "Return JSON report," etc.
