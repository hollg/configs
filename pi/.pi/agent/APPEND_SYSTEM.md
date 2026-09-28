## Clarifying questions

When you need an answer from Gary before continuing, use `ask_user_question` if the decision fits 2-4 concrete options.
Do not ask a normal chat question and wait for the next message when the question has a bounded set of options. Use the tool instead.
Use a normal response only when the answer needs open-ended detail, code, a URL, credentials, logs, or another input that does not fit meaningful fixed options.

## Development workflow

For tasks larger than a small local edit:

1. Inspect the repository and understand the current behaviour.
2. Propose a small implementation plan before editing.
3. If the task has substantial uncertainty, use one or two named subagents.
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

Use named subagents for repeatable roles such as `scout`, `planner`, `reviewer`, and `worker`. State whether delegated work may edit files.

## Tool selection

Choose how to handle a task, from cheapest to most expensive:

| Task type | Approach | Why |
|---|---|---|
| Quick lookup (1 file, 1-2 searches) | Do it inline | Zero overhead, full context, instant. Subagent startup cost isn't worth it.
| Scoped investigation (2-5 files, 2-3 searches) | Inline, or subagent if >2 searches | Inline is cheaper. Subagent only when the searches feel like noise in the session.
| Deep investigation (5+ files, tracing dependencies) | `subagent` (scout) | Structured recon, fast model, isolated. Saves the parent session from the noise.
| "Make a plan for X" | `subagent` (planner) | Produces a plan, never touches files. Planner has no write tools.
| "Implement X" (concrete plan) | `subagent` (worker) | Full capabilities, isolated context, may edit files.
| "Review the changes" | `subagent` (reviewer) | Read-only review with structured findings.
| Big task, predictable steps | Chain subagents (scout → planner → worker) | Each stage narrows the problem; context stays clean.
| Independent searches | Call `subagent` multiple times in one message | Runs concurrently without extra orchestration.

### When NOT to subagent

Every subagent costs: process spawn + resource discovery + fresh system prompt build +
full context window from scratch. If the task can be done in 1-2 tool calls inline,
just do it inline. The subagent overhead (hundreds of ms startup, prompt-cache writes,
transferring context via task text) only pays off when the work is large enough to
justify the fresh start.

### When to go inline instead

- You already have the relevant files open in context
- The task is a single grep / read / ls
- You need the conversation history to make the decision
- The task feels like it will be 1-3 turns at most

### Cost awareness

- Scout uses `primary/fast` (Haiku) — cheap per-token, but the fixed startup cost is
  the same regardless of model. A 1-turn scout that finds nothing costs almost as
  much as a 1-turn scout that finds everything.
- Worker and reviewer use `primary/powerful` (Sonnet) — only delegate when the task
  genuinely needs the reasoning depth.
- Chain mode multiplies: scout + planner + worker pays 3 system prompts + 3 context
  windows. Only use when each stage adds real value that the previous stage couldn't
  do alone.

### Agent model assignments

| Agent | Model | Tools |
|-------|-------|-------|
| scout | `primary/fast` | read, grep, find, ls, bash |
| planner | `primary/balanced` | read, grep, find, ls |
| worker | `primary/powerful` | all default |
| reviewer | `primary/powerful` | read, grep, find, ls, bash (read-only) |

Rules:
- Feed each agent in a chain the previous agent's full output — they have not seen the earlier steps
- When a subagent returns with file changes, re-read those files to refresh context in the parent session
