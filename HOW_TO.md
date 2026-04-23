# How to Create Subagent Skills

This guide provides a checklist for creating new programmatic delegation skills for additional CLI tools. 

The core philosophy is based on **[Cognition-style delegation](https://cognition.ai/blog/dont-build-multi-agents#applying-the-principles)**, where the main agent acts as a strategic orchestrator and offloads tactical execution to specialized subagents.

## Skill Creation Checklist

When creating a new skill (e.g., `tool-cli`), ensure the following components are addressed in your `SKILL.md` and `reference.md`:

### 1. Mandatory Programmatic Constraints
- [ ] **Force Non-Interactive Mode**: Use flags (like `-p`, `--prompt`, or `--headless`) to ensure the tool never hangs waiting for user input.
- [ ] **Silent Output**: Use flags (like `-s`, `--silent`, or `-o text`) to ensure only the agent's response is returned, avoiding terminal "noise" (spinners, banners, stats).
- [ ] **Auto-Approval (YOLO)**: Use flags (like `--yolo`, `-y`, or `--allow-all`) so the subagent can execute tools and edit files without interruption.

### 2. Context & Delegation Depth
- [ ] **Context Handoff**: Include a "Delegation and context (critical)" section. Emphasize that the subagent doesn't see the main history.
- [ ] **Handoff Table**: Provide a table of what to include in the prompt (Goal, Decisions, Scope, Constraints, Expected Output).
- [ ] **Post-Execution Reconciliation**: Instruct the agent on how to merge the subagent's results back into the main thread.

### 3. Dynamic Model Discovery
- [ ] **Avoid Stale Versions**: Do not hardcode a single model version as the only option.
- [ ] **Search Instruction**: Explicitly command the agent to search the web for the latest model names/aliases and pricing before executing.
- [ ] **Tiered Defaults**: Define a "Default (Simple)" model and a "Heavy Reasoning" model.

### 4. Specialized Capabilities
- [ ] **Identify Strengths**: Mention what the tool is best at (e.g., "Deep Research," "Code Mapping," "Security Audits").
- [ ] **Quick Prompts**: Provide 3-5 high-signal example prompts for common tasks.

### 5. Reference File (`reference.md`)
- [ ] **Essential Flags**: A concise table of flags needed for programmatic use.
- [ ] **Subagent/Agent List**: List of internal "specialists" available in that CLI (e.g., `@explore`).
- [ ] **Authentication**: Mention which environment variables are needed for the tool to function.

## Philosophy Reference
All skills in this repo are inspired by the delegation principles described by Cognition AI in:
[Don't Build Multi-Agents - Applying the Principles](https://cognition.ai/blog/dont-build-multi-agents#applying-the-principles)
