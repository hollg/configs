## Clarifying questions

When you need an answer from Gary before continuing, use `ask_user_question` if the decision fits 2-4 concrete options.
Do not ask a normal chat question and wait for the next message when the question has a bounded set of options. Use the tool instead.
Use a normal response only when the answer needs open-ended detail, code, a URL, credentials, logs, or another input that does not fit meaningful fixed options.

## Development workflow

For tasks larger than a small local edit:

1. Inspect the repository and understand the current behaviour.
2. Propose a small implementation plan before editing.
3. If the task has substantial uncertainty, use one or two read-only forks or named subagents.
4. Keep implementation ownership in the current session.
5. Do not run parallel agents that edit overlapping files.
6. After editing, run the narrowest relevant tests and format changed files.
7. Review the final diff for unrelated changes.

## Read-only policy

You must not write, edit, or run destructive commands (rm, git push --force, etc.)
unless the user EXPLICITLY instructs you to make changes. "Thoughts?", "What do you
think?", "Any ideas?" are not change instructions — they are analysis requests.
Only proceed with changes when the user says something like "do it", "implement",
"make the change", or gives a concrete task that implies modification.

When the user says "I got this error" or reports an error without asking for a
fix, explain the error. Investigate first when needed, but do not modify files
until the user explicitly asks to fix it.

When unsure, ask: "Should I proceed with implementing this, or do you want to
review the plan first?"

Use `fork` for one-off investigation, review, testing, or option analysis.
Use named subagents for repeatable roles such as `scout`, `planner`, `reviewer`, and `worker`.
State whether delegated work may edit files. Read-only investigations should return findings with file references and no edits.

## Tool selection

Choose the right delegation mechanism based on the task type:

| Task type | Tool | Why |
|---|---|---|
| "Find all the X code and explain how it works" | `subagent` (scout) | Structured recon, cheap model, returns compressed context |
| "Make a plan for X" | `subagent` (planner) | Produces a plan, never touches files |
| "Implement X" (concrete plan) | `subagent` (worker) | Full capabilities, isolated context, may edit files |
| "Review the changes" | `subagent` (reviewer) | Read-only review with structured findings |
| "Not sure what's wrong / explore options" | `fork` | Needs full context and open-ended judgment |
| "Should I use approach A or B?" | `fork` | Exploratory option analysis |
| Big task, predictable steps | Chain subagents (scout → planner → worker) | Each stage narrows the problem; context stays clean |
| Independent searches | Call `subagent` multiple times in one message | Runs concurrently without extra orchestration |

Rules:
- Worker and reviewer run on `primary/powerful`; scout on `primary/fast`; planner on `primary/balanced`
- Feed each agent in a chain the previous agent's full output — they have not seen the earlier steps
- Do NOT fork for tasks that map cleanly to a named subagent role
- Read-only investigations must return findings with file references and no edits
