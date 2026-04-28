# How to let agents from any provider act as subagent (Subagent CLI Skills)
## Let Claude Code use Gemini CLI as subagent to reduce costs

When you're using a top-tier tool like Claude Code with an expensive model like Claude Opus 4.7, every time it runs a massive grep search or reads through a 500-line log file, that data stays in the session. Pretty soon, the agent starts getting "confused," loses the big picture, and every message costs more than the last one. (This is often called "Context Rot" ot "Context Pollution")


### The Solution: Using other agents' CLI tools as subagents
Instead of letting Claude handle the messy, tactical work, I started treating other agents' CLI tools (such as Gemini CLI, Codex CLI, etc.) as subagents for Claude Code. 

You can create **Skills** for each CLI Agent so your orchestrator (main) agent can use it as a subagent.

If I need a deep web search or a documentation sweep, I don't let Claude do it. I tell Claude to call the Gemini CLI. Gemini handles the heavy lifting in its own isolated process, finds what I need, and hands back a clean summary. Claude stays "lean," focused only on the high-level architecture.

Here, you can find a collection of such skills that I've already built and tested: [amirkiarafiei/subagent-cli-skills](https://github.com/amirkiarafiei/subagent-cli-skills)

### Delegation Approach
The biggest worry with delegation is that the subagent with completely isolated context,  will do the task blindly without having the right background or context of the ongoing conversation between Human and AI Agent. To fix this, I use a simple "Handoff Table" in my prompts. Every time I delegate, I make sure the orchestrator passes these five things:

1. GOAL: What are we actually trying to achieve?
2. DECISIONS: What have we already decided? (e.g., "Use Tailwind," "No new libraries").
3. SCOPE: Which files are we touching?
4. CONSTRAINTS: Any specific rules to follow.
5. VERIFICATION: What command must pass (like npm test) before the subagent can say it's done.

This delegation approach is a combination of Claude Code's and Superpowers' approach, with Cognition AI's principles of "shared state" and "implicit decisions", written in this article: Don't build multi-agents.

### Why this works
By externalizing the tactical work to CLI tools, you decouple the "brain" from the "hands." You can use Codex for heavy logic, Gemini for research, and Copilot for boilerplate—all in one workflow.

### Skills Collection
To make this easy to implement, I've created a collection of these skills for various tools like Gemini, Copilot, Cursor, and more. You can find the full collection and an interactive installer here:

**GitHub Repo:** [amirkiarafiei/subagent-cli-skills](https://github.com/amirkiarafiei/subagent-cli-skills)

### Read more
- [Context Rot: How Increasing Input Tokens Impacts LLM Performance by Chroma](https://www.trychroma.com/research/context-rot?ref=blog.langchain.com)
- [Don't build multi-agents by Cognition AI](https://cognition.ai/blog/dont-build-multi-agents)
- [Langchain's Article on Context Management for DeepAgents](https://www.langchain.com/blog/context-management-for-deepagents)
- [Superpowers](https://github.com/obra/superpowers)
- [Claude Code](https://github.com/anthropics/claude-code)

---
