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

Use `fork` for one-off investigation, review, testing, or option analysis.
Use named subagents for repeatable roles such as `scout`, `planner`, `reviewer`, and `worker`.
State whether delegated work may edit files. Read-only investigations should return findings with file references and no edits.
