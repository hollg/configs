---
description: Scout, plan, then implement a change
argument-hint: "<description of the change>"
---

Implement the following task using the scout → planner → worker chain:

$@

## Workflow
Call the `subagent` tool three times, sequentially:

1. **scout** — "Thoroughly investigate the relevant code for: $@. Return files, key types/functions, and how the pieces connect."
2. **planner** — Pass the scout's findings and "$@" and ask for a concrete implementation plan (steps, files to modify, risks).
3. **worker** — Pass the plan and "$@" and instruct: "Execute this plan exactly. Confirm when done."

## Rules
- Feed each agent the previous agent's full output — they have NOT seen the earlier steps
- The worker may edit files; scout and planner are read-only
- After the worker finishes, verify the change yourself: run the relevant tests
- Report the final result with files changed and test outcome