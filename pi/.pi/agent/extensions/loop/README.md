# `/loop` extension

Repeatedly runs a prompt on a recurring interval.

## Usage

```
/loop <interval> <prompt>
/loop stop
```

| Example | Effect |
|---|---|
| `/loop 30s check deploy status` | Checks deploy every 30 seconds |
| `/loop 5m run tests and summarise` | Runs tests every 5 minutes |
| `/loop 1h check for new releases` | Checks for releases every hour |
| `/loop stop` | Cancels the active loop |

## Interval format

A number followed by a single-letter unit suffix:

| Suffix | Unit | Example |
|---|---|---|
| `s` | seconds | `30s`, `10s` |
| `m` | minutes | `5m`, `1m` |
| `h` | hours | `1h`, `2h` |

Minimum interval is 5 seconds. No suffix defaults to seconds.

## How it works

- The first tick fires **immediately** when `/loop` is invoked.
- Subsequent ticks fire on the interval using `setInterval`.
- Each tick calls `pi.sendUserMessage()` to inject the prompt as if typed by the user.
- The footer shows a `🔁` indicator while the loop is active.
- The loop survives user messages — it runs alongside normal interaction.
- Stops on `/loop stop`, `/loop cancel`, `/loop off`, or session shutdown.

## Cancelling

The loop continues until explicitly cancelled or the session ends. Pressing **Esc** or **Ctrl+C** while the model is streaming does **not** cancel the loop — it only stops the current response. Use `/loop stop` to cancel.

## Uninstallation

```bash
rm -rf ~/.pi/agent/extensions/loop
```