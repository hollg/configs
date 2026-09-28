---
description: Full implementation workflow - scout gathers context, planner creates plan, worker implements
---
Execute this as a sequential workflow using `Agent` calls:

1. First, call `Agent({subagent_type: "scout", prompt: "Find all code relevant to: $@", description: "Scout codebase", run_in_background: false})` to gather context.
2. Then, call `Agent({subagent_type: "planner", prompt: "Create an implementation plan for $@ using this context: [scout's full output]", description: "Create plan", run_in_background: false})` to plan.
3. Finally, call `Agent({subagent_type: "worker", prompt: "Implement the plan. Context so far: [scout output] [planner output]", description: "Implement plan", run_in_background: false})` to implement.

Feed each agent's full output into the next agent's prompt. All run in the foreground so results are available inline.
