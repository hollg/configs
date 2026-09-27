---
description: Investigate code and produce an implementation plan (no changes)
argument-hint: "<task to scout and plan>"
---

Scout and plan the following task. Do NOT make any changes — this is read-only.

$@

## Workflow
Call the `subagent` tool twice, sequentially:

1. **scout** — "Thoroughly investigate the relevant code for: $@. Return files with line ranges, key types/functions, architecture, and a 'Start Here' recommendation."
2. **planner** — Pass the scout's full output and "$@" and ask: "Produce a concrete implementation plan: goals, numbered steps, files to modify, new files, risks."

## Rules
- Feed the planner the scout's entire output — the planner has NOT seen the code
- Neither agent may edit files
- Present the final plan to the user for approval. Do not start implementation unless explicitly told