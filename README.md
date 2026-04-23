# Subagent CLI Skills

A collection of programmatic `SKILL.md` templates for **Claude Code**, **Gemini CLI**, **Copilot CLI**, and **Cursor**. These skills enable context-efficient **task delegation** between AI agents using CLI tools as subagents.

## Core Philosophy: Cognition-style Delegation

Primary agents (like Claude Code) are powerful but context-heavy. This project allows you to offload "heavy lifting" to local CLI subagents (Gemini, Copilot, etc.) through **programmatic terminal calls**.

The delegation technique and philosophy used in this project are inspired by the principles outlined in **[Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents#applying-the-principles)** by Cognition AI.

*   **Context Optimization**: Moves high-volume edits and exploration to an isolated process.
*   **Cost Efficiency**: Reduces the token burden on the main orchestrator.
*   **Specialized Execution**: Leverages tool-specific strengths (e.g., Gemini's Google Search, Copilot's codebase exploration).

## Roadmap & Support

- [x] **Gemini CLI** (Programmatic)
- [x] **Copilot CLI** (Programmatic)
- [ ] **Junie CLI**
- [ ] **Kiro CLI**
- [ ] **Cursor CLI**
- [ ] **Antigravity IDE**

## Installation

1. Copy the desired skill folder to your agent's skill directory:
    *   **Claude Code**: `~/.claude/skills/`
    *   **Gemini CLI**: `~/.gemini/skills/`
    *   **Copilot CLI**: `~/.copilot/skills/`
2. Restart your agent or refresh skills.

## Usage

Activate the necessary skills using the `/` command (e.g., `/activate_skill copilot-cli`) supported in many tools. Once activated, simply ask the primary agent to delegate:

> *"Use Gemini CLI to search for the latest documentation of [library] and summarize breaking changes."*

The agent will use the skill to construct a programmatic CLI call, execute the task, and return the summary to the main thread.
