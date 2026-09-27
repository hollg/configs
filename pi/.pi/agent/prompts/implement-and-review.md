---
description: Implement a change, then review it for quality and security
argument-hint: "<description of the change>"
---

Implement the following change, then have it reviewed. You may make changes.

$@

## Workflow
Call the `subagent` tool sequentially:

1. **worker** — "Execute this task: $@. When done, report what you completed, files changed, and key functions/types touched."
2. **reviewer** — Pass the worker's output (files changed, functions touched) and ask: "Review the changes the worker made for $@. Use git diff and read the modified files. Report Critical, Warning, Suggestion findings with file:line references."

## Rules
- Feed the reviewer the worker's full report — the reviewer has NOT seen the worker's session
- The reviewer is strictly read-only
- After the review, fix any Critical findings yourself (or delegate back to worker for the fix), then re-verify
- Report: what was implemented, review findings, and what you fixed