/**
 * /goal extension — Autonomous multi-turn work toward a completion condition
 *
 * Usage:
 *   /goal make all tests pass
 *   /goal deploy the staging environment
 *   /goal stop    cancel the active goal
 *
 * Keeps working across turns until Claude reports the goal is met.
 * If a turn errors out, retries with exponential backoff (30s → 1m → 2m → 5m
 * → 10m → 30m → 1h).
 * Shows status in the footer while active.
 */

import type { AgentMessage } from "@earendil-works/pi-agent-core";
import type { AgentActivityOutcome, ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

const GOAL_STATUS_KEY = "goal";

// ── backoff schedule (in ms) ─────────────────────────────────────────

const BACKOFF_SCHEDULE = [30_000, 60_000, 120_000, 300_000, 600_000, 1_800_000, 3_600_000];

function getBackoff(level: number): number {
	if (level >= BACKOFF_SCHEDULE.length) return BACKOFF_SCHEDULE[BACKOFF_SCHEDULE.length - 1];
	return BACKOFF_SCHEDULE[level];
}

// ── helpers ──────────────────────────────────────────────────────────

function hasGoalMetSignal(message: AgentMessage): boolean {
	for (const part of message.content) {
		if (part.type === "text" && part.text.includes("[GOAL_MET]")) {
			return true;
		}
	}
	return false;
}

function stripGoalMetSignal(text: string): string {
	return text.replace(/\n?\[GOAL_MET\]\s*$/m, "");
}

function formatElapsed(startedAt: number): string {
	const elapsed = Date.now() - startedAt;
	const mins = Math.floor(elapsed / 60_000);
	const secs = Math.floor((elapsed % 60_000) / 1_000);
	if (mins === 0) return `${secs}s`;
	return `${mins}m ${secs}s`;
}

function formatTurns(turns: number): string {
	if (turns === 1) return "1 turn";
	if (turns < 100) return `${turns} turns`;
	return `${turns} turns`;
}

// ── extension ────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// State
	let goal: string | null = null;
	let startedAt = 0;
	let turnCount = 0;
	let backoffLevel = 0;
	let isWaitingBackoff = false;
	let backoffTimer: ReturnType<typeof setTimeout> | null = null;
	let statusCtx: ExtensionCommandContext | null = null;

	// ── helpers ────────────────────────────────────────────────────

	function updateFooter() {
		if (!statusCtx) return;
		if (goal && !isWaitingBackoff) {
			const label = `🎯 ${turnCount > 0 ? `${formatTurns(turnCount)} · ${formatElapsed(startedAt)}` : ""}`;
			statusCtx.ui.setStatus(GOAL_STATUS_KEY, label);
		} else if (goal && isWaitingBackoff) {
			statusCtx.ui.setStatus(GOAL_STATUS_KEY, `🎯 ⏳ retry in ${formatElapsedOnBackoff()}`);
		} else {
			statusCtx.ui.setStatus(GOAL_STATUS_KEY, undefined);
		}
	}

	function formatElapsedOnBackoff(): string {
		if (!backoffTimer || startedAt === 0) return "";
		const elapsed = Date.now() - startedAt;
		const mins = Math.floor(elapsed / 60_000);
		const secs = Math.floor((elapsed % 60_000) / 1_000);
		if (mins === 0) return `${secs}s`;
		return `${mins}m ${secs}s`;
	}

	function clearGoal() {
		goal = null;
		startedAt = 0;
		turnCount = 0;
		backoffLevel = 0;
		isWaitingBackoff = false;
		if (backoffTimer) {
			clearTimeout(backoffTimer);
			backoffTimer = null;
		}
		if (statusCtx) {
			statusCtx.ui.setStatus(GOAL_STATUS_KEY, undefined);
		}
	}

	function scheduleRetry() {
		const delay = getBackoff(backoffLevel);
		backoffLevel = Math.min(backoffLevel + 1, BACKOFF_SCHEDULE.length);
		isWaitingBackoff = true;
		updateFooter();

		backoffTimer = setTimeout(() => {
			backoffTimer = null;
			isWaitingBackoff = false;
			updateFooter();

			// Resume: inject a continuation message
			if (goal) {
				try {
					pi.sendUserMessage(`Continue working toward the goal: ${goal}`);
				} catch (err) {
					console.error("[/goal] retry sendUserMessage failed:", err);
					clearGoal();
				}
			}
		}, delay);

		if (statusCtx) {
			const minText = delay >= 60_000 ? `${Math.round(delay / 60_000)}min` : `${Math.round(delay / 1_000)}s`;
			statusCtx.ui.notify(`Goal hit an error — retrying in ${minText}...`, "warning");
		}
	}

	// ── before_agent_start: inject goal into system prompt ─────────

	pi.on("before_agent_start", async (event, _ctx) => {
		if (!goal) return;

		// Prompt options are mutable, so this preserves Pi's structured prompt updates.
		event.systemPromptOptions.promptGuidelines.push(
			`Goal: You are working toward this goal: ${goal}`,
			"At the end of each turn, evaluate your progress.",
			"If the goal is fully met, end your response with exactly: [GOAL_MET]",
			"If it is not yet met, continue working. Do not include [GOAL_MET].",
		);
	});

	// ── turn_end: evaluate progress, continue or stop ──────────────

	pi.on("turn_end", (event, _ctx) => {
		if (!goal) return;

		// Skip evaluations while waiting for a backoff retry
		if (isWaitingBackoff) return;

		turnCount++;
		updateFooter();

		// Check outcome
		switch (event.outcome as AgentActivityOutcome) {
			case "error":
			case "aborted": {
				// Error — backoff and schedule a retry
				scheduleRetry();
				// Don't set continue:true — the retry will re-trigger via sendUserMessage
				return { continue: false };
			}
			case "completed": {
				// Check if the model signaled goal met
				if (hasGoalMetSignal(event.message)) {
					// Strip the signal from what's stored
					for (const part of event.message.content) {
						if (part.type === "text") {
							part.text = stripGoalMetSignal(part.text);
						}
					}
					if (statusCtx) {
						statusCtx.ui.notify(`✅ Goal met: ${goal}`, "info");
					}
					clearGoal();
					return { continue: false };
				}

				// Goal not met yet — reset backoff and continue
				backoffLevel = 0;
				return { continue: true };
			}
		}

		return;
	});

	// ── command ──────────────────────────────────────────────────────

	pi.registerCommand("goal", {
		description:
			"Work autonomously until a goal is met. Usage: /goal <description>. /goal stop cancels. Retries with backoff on errors.",
		handler: async (raw, ctx) => {
			statusCtx = ctx;
			const trimmed = raw.trim();

			if (!trimmed) {
				if (goal) {
					ctx.ui.notify(`Active goal: "${goal}" — ${formatTurns(turnCount)} in ${formatElapsed(startedAt)}`, "info");
				} else {
					ctx.ui.notify("No active goal. Usage: /goal <description of what to achieve>", "warning");
				}
				return;
			}

			if (trimmed === "stop" || trimmed === "cancel" || trimmed === "off") {
				if (goal) {
					const prev = goal;
					clearGoal();
					ctx.ui.notify(`Goal cancelled: "${prev}"`, "info");
				} else {
					ctx.ui.notify("No active goal to cancel.", "info");
				}
				return;
			}

			// Clear any existing goal
			clearGoal();

			goal = trimmed;
			startedAt = Date.now();
			turnCount = 0;
			backoffLevel = 0;

			updateFooter();
			ctx.ui.notify(`🎯 Goal set: "${goal.slice(0, 80)}${goal.length > 80 ? "…" : ""}"`, "info");

			// Inject the goal prompt as a user message to kick things off
			// The turn_end handler will drive subsequent turns via { continue: true }
			if (goal) {
				try {
					pi.sendUserMessage(`I have set a goal: ${goal}`);
				} catch (err) {
					console.error("[/goal] initial sendUserMessage failed:", err);
					clearGoal();
				}
			}
		},
	});

	// ── lifecycle cleanup ────────────────────────────────────────────

	pi.on("session_shutdown", async () => {
		if (backoffTimer) {
			clearTimeout(backoffTimer);
			backoffTimer = null;
		}
		clearGoal();
	});
}