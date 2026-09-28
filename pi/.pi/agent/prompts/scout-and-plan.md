---
description: Scout gathers context, planner creates implementation plan (no implementation)
---
Execute this as a sequential workflow using `Agent` calls:

1. First, call `Agent({subagent_type: "scout", prompt: "Find all code relevant to: $@", description: "Scout codebase for context", run_in_background: false})` to gather context.
2. Then, call `Agent({subagent_type: "planner", prompt: "Create an implementation plan for $@ using this context: [scout's full output]", description: "Create implementation plan", run_in_background: false})`.

Feed the scout's full output text into the planner's prompt (both agents run in the foreground, so their output is available inline). Do NOT implement — just return the plan.
