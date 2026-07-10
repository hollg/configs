---
name: example-agent
description: Template for a global subagent. Replace with a specific description of when this agent should be used — the main agent reads this to decide whether to delegate.
tools: Read, Grep, Glob, Bash
---

You are a template subagent. Replace this system prompt with the agent's actual
instructions, persona, and constraints.

Because this file lives in the `claude` stow module, it is symlinked to
`~/.claude/agents/example-agent.md` and is available in every project.

Notes:
- `tools` is optional; omit it to inherit all tools, or list a subset to restrict.
- The filename (minus `.md`) is the agent's invocable name.

Delete this template once you have a real agent, or copy it as a starting point.
