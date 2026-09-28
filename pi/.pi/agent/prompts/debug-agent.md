---
description: Debug an error using a dedicated debugger subagent with a fresh context
argument-hint: "<error, bug, or symptom>"
---

Use the subagent tool with the "debugger" agent to debug: $@

The debugger starts with a clean context, free from any assumptions in the current
conversation. It will diagnose the root cause and propose a fix without implementing it.

If you want the fix applied, follow up after reviewing the diagnosis.