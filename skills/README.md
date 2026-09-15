<h3 align="center">Let your Claude Code prompt Codex and Antigravity as Subagent</h3>

<p align="center">
  <img src="../assets/diagram.png" width="320" alt="Delegation Flow Diagram">
</p>

Each folder here is one skill. A skill teaches your main agent to send a task to a different CLI
agent. The other agent does the work in the background. It returns only a summary. Your main agent
keeps a small context and a low cost.

## Usage examples

Type the slash command first. Then write the task.

**1. Send a documentation task to one agent**

```
/antigravity-cli Read the latest docs for the Stripe API. List the breaking changes.
```

**2. Send a code review to two agents**

```
/codex-cli /opencode-cli Review the changes in src/auth/. Report each bug with a file name and a line number.
```

**3. Build two features at the same time**

```
/codex-cli /opencode-cli Build the login form in src/auth/ with Codex. Build the signup form in src/signup/ with OpenCode. Run npm test after each build.
```

## Available skills

19 CLI agents: Antigravity (`agy`), Claude Code, Codex, Copilot, Cursor, Devin, Gemini, Grok,
Hermes, Junie, Kimi Code, Kiro, Mistral Vibe, Oh My Pi, OpenCode, OpenHands, Pi, Qoder, Qwen Code.

Every skill holds two files: `SKILL.md` for the behaviour, and `reference.md` for the flags, models
and authentication.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main/install.sh | bash
```

Or ask your agent to do it — see [AGENTIC_INSTALLATION.md](../AGENTIC_INSTALLATION.md).

More detail: [main README](../README.md)
