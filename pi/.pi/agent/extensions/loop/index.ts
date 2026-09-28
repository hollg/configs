/**
 * /loop extension — Repeat a prompt on a recurring interval
 *
 * Usage:
 *   /loop 30s    check deploy status
 *   /loop 5m     run tests and summarise
 *   /loop 1h     check for new releases
 *   /loop stop   cancel the active loop
 *
 * Parses suffixes: s (seconds), m (minutes), h (hours).
 * Cleans up on session shutdown.
 */

import type { ExtensionAPI, ExtensionCommandContext, ExtensionContext } from "@earendil-works/pi-coding-agent";

const LOOP_STATUS_KEY = "loop";

// ── helpers ──────────────────────────────────────────────────────────

function parseInterval(raw: string): number | null {
	const match = raw.match(/^(\d+)\s*(s|m|h)?$/);
	if (!match) return null;

	const val = parseInt(match[1], 10);
	const unit = match[2] || "s";

	switch (unit) {
		case "s": return val * 1_000;
		case "m": return val * 60_000;
		case "h": return val * 3_600_000;
		default: return null;
	}
}

function formatInterval(ms: number): string {
	if (ms < 60_000) return `${Math.round(ms / 1_000)}s`;
	if (ms < 3_600_000) return `${Math.round(ms / 60_000)}m`;
	return `${(ms / 3_600_000).toFixed(1)}h`;
}

// ── extension ────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// State stored in the module closure
	let timer: ReturnType<typeof setInterval> | null = null;
	let intervalMs = 0;
	let prompt = "";
	let statusCtx: ExtensionCommandContext | null = null;

	function clearLoop() {
		if (timer) {
			clearInterval(timer);
			timer = null;
		}
		intervalMs = 0;
		prompt = "";
		if (statusCtx) {
			statusCtx.ui.setStatus(LOOP_STATUS_KEY, undefined);
		}
	}

	// ── command ──────────────────────────────────────────────────────

	pi.registerCommand("loop", {
		description:
			"Repeat a prompt on a recurring interval. Usage: /loop <interval> <prompt> — interval supports s/m/h suffixes (e.g. 30s, 5m, 1h). /loop stop cancels.",
		handler: async (raw, ctx) => {
			statusCtx = ctx;
			const trimmed = raw.trim();

			if (!trimmed) {
				if (timer) {
					ctx.ui.notify(`Loop active: every ${formatInterval(intervalMs)}`, "info");
				} else {
					ctx.ui.notify("No active loop. Usage: /loop <interval> <prompt>", "warning");
				}
				return;
			}

			if (trimmed === "stop" || trimmed === "cancel" || trimmed === "off") {
				if (timer) {
					clearLoop();
					ctx.ui.notify("Loop cancelled.", "info");
				} else {
					ctx.ui.notify("No active loop to cancel.", "info");
				}
				return;
			}

			// Parse: first token is interval, rest is prompt
			const spaceIdx = trimmed.indexOf(" ");
			if (spaceIdx === -1) {
				ctx.ui.notify(
					"Usage: /loop <interval> <prompt> — e.g. /loop 5m check deploy",
					"warning",
				);
				return;
			}

			const intervalRaw = trimmed.slice(0, spaceIdx);
			const promptText = trimmed.slice(spaceIdx + 1).trim();

			const parsed = parseInterval(intervalRaw);
			if (!parsed) {
				ctx.ui.notify(
					`Invalid interval "${intervalRaw}". Use a number with s/m/h suffix (e.g. 30s, 5m, 1h).`,
					"warning",
				);
				return;
			}

			if (!promptText) {
				ctx.ui.notify("No prompt provided after interval.", "warning");
				return;
			}

			if (parsed < 5_000) {
				ctx.ui.notify("Minimum interval is 5 seconds.", "warning");
				return;
			}

			// Clear existing loop
			clearLoop();

			intervalMs = parsed;
			prompt = promptText;

			// Fire the first tick immediately
			pi.sendUserMessage(prompt).catch((err) => {
				console.error("[/loop] sendUserMessage failed:", err);
				clearLoop();
			});

			timer = setInterval(() => {
				pi.sendUserMessage(prompt).catch((err) => {
					console.error("[/loop] sendUserMessage failed:", err);
					clearLoop();
				});
			}, intervalMs);

			ctx.ui.setStatus(LOOP_STATUS_KEY, `🔁 ${formatInterval(intervalMs)}`);
			ctx.ui.notify(
				`Loop started: every ${formatInterval(intervalMs)} — "${prompt.slice(0, 60)}${prompt.length > 60 ? "…" : ""}"`,
				"info",
			);
		},
	});

	// ── lifecycle cleanup ────────────────────────────────────────────

	pi.on("session_shutdown", async () => {
		if (timer) {
			clearInterval(timer);
			timer = null;
		}
		intervalMs = 0;
		prompt = "";
	});
}