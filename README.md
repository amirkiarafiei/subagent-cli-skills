# Subagent CLI Skills

A collection of Skills for cross-agent task delegation. Let Claude Code use Gemini CLI as a subagent to reduce your context usage and costs.

## How It Works

Your primary agent can delegate tasks to other agents that support programmatic usage through the terminal (headless mode). This offloads context-heavy work, ensuring the main orchestrator stays lean and efficient.

<p align="center">
  <img src="./assets/diagram.png" width="320" alt="Delegation Flow Diagram">
</p>

By treating CLI tools as specialized subagents, you can bypass context window limitations and significantly reduce token costs. The primary agent remains the high-level decision maker, while the subagents handle the tactical implementation, research, and codebase exploration.

## Installation

1. Identify your agent's skill directory.
2. Copy the desired skill folder from this repository to that directory.
3. Restart your agent or refresh skills.

## Usage

Activate the necessary skills using the `/` command (e.g., `/copilot-cli` or `/gemini-cli`) supported in many tools. Once activated, simply ask the primary agent to delegate:

> *"Use Gemini CLI to search for the latest documentation of [library] and summarize breaking changes."*

The agent will use the skill to construct a programmatic CLI call, execute the task, and return the summary to the main thread.


## Delegation Technique

The delegation technique and philosophy used in this project are inspired by the principles outlined in **[Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents#applying-the-principles)** by Cognition AI:

We implement a stateless delegation pattern that offloads tactical work to CLI subagents by injecting a comprehensive "shared state" into every atomic command to prevent
  context fragmentation.

   * **Shared State Handoff**: Inject the original goal, prior architectural decisions, and explicit codebase scope into the prompt to bridge the subagent's lack of session
     history.
   * **Contextual Preservation**: Execute high-volume tasks in isolated headless environments to save orchestrator tokens and avoid "split story" failures caused by missing
     history.
   * **Result Reconciliation**: Pull new technical assumptions and filesystem changes back into the main thread after every delegation to maintain a single source of truth.

This methodology is further refined by lessons from **[Superpowers](https://github.com/obra/superpowers)** and **[Claude Code](https://github.com/anthropics/claude-code)**, incorporating rigorous verification loops and context hygiene to ensure subagents remain aligned with the primary orchestrator.


## Support

- [x] **Gemini CLI** (Programmatic)
- [x] **Copilot CLI** (Programmatic)
- [x] **Qwen-Code CLI** (Programmatic)
- [x] **Codex CLI** (Programmatic)
- [x] **Junie CLI** (Programmatic)
- [x] **Kiro CLI** (Programmatic)
- [x] **Cursor CLI** (Programmatic)
- [x] **OpenHands CLI** (Programmatic)
- [x] **OpenCode CLI** (Programmatic)
