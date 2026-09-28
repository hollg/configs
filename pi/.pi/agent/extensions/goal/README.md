# `/goal` extension

Work autonomously across multiple turns until a completion condition is met, with automatic retry and backoff on errors.

## Usage

```
/goal <description of what to achieve>
/goal stop
```

| Example | Effect |
|---|---|
| `/goal make all tests pass` | Keeps fixing and running tests until they all pass |
| `/goal deploy staging and verify health` | Deploys and confirms health checks pass |
| `/goal stop` | Cancels the active goal |

## How it works

1. **`/goal`** sets the target and injects a continuation prompt as a user message.
2. On each turn, a system-prompt guideline reminds the model of the goal, asks it to call `ask_user_question` when it needs your input, and asks it to end with `[GOAL_MET]` when achieved.
3. After each turn, the extension checks the model's response:
   - Contains `[GOAL_MET]` → goal achieved, loop stops, notification shown.
   - The model needs your input → it calls `ask_user_question`; Pi adds the answer to the tool result and continues normally.
   - Turn completed but goal not yet met → the extension adds an internal continuation message, then starts the next turn.
   - Turn errored or aborted → backoff and schedule a retry.
4. A footer indicator (🎯) shows active turns and elapsed time.

## Backoff on errors

When a turn errors out, the extension retries with exponential backoff:

| Attempt | Delay |
|---|---|
| 1st retry | 30 seconds |
| 2nd retry | 1 minute |
| 3rd retry | 2 minutes |
| 4th retry | 5 minutes |
| 5th retry | 10 minutes |
| 6th retry | 30 minutes |
| 7th+ retry | 1 hour (capped) |

Backoff resets to 30s after a successful turn (even if the goal isn't met yet). A notification shows each retry attempt.

## Goal evaluation

The model self-evaluates progress each turn based on system-prompt guidelines:
> "At the end of each turn, evaluate your progress. If the goal is fully met, end your response with: [GOAL_MET]"

The `[GOAL_MET]` marker is stripped from the stored message content so it never appears in the visible transcript.

## Cancelling

Use `/goal stop`, `/goal cancel`, or `/goal off`. The loop also stops on session shutdown.

## Uninstallation

```bash
rm -rf ~/.pi/agent/extensions/goal
```