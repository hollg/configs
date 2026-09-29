/**
 * /clear extension — Clear conversation context and start a fresh session
 *
 * Like Claude Code's /clear. Wipes the current conversation and starts
 * a blank session with a notification showing how many messages were removed.
 *
 * Usage:
 *   /clear
 */

import type { ExtensionAPI, SessionEntry } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("clear", {
		description: "Clear the conversation and start a fresh session",
		handler: async (_args, ctx) => {
			// Count messages on the current branch for the feedback notification
			const branch: SessionEntry[] = ctx.sessionManager.getBranch();
			const msgCount = branch.filter((e) => e.type === "message").length;
			const compactCount = branch.filter((e) => e.type === "compaction").length;

			const currentSessionFile = ctx.sessionManager.getSessionFile();

			const result = await ctx.newSession({
				parentSession: currentSessionFile,
				withSession: async (replacementCtx) => {
					const parts: string[] = [];
					if (msgCount > 0) parts.push(`${msgCount} messages`);
					if (compactCount > 0) parts.push(`${compactCount} compactions`);
					const summary = parts.length > 0 ? parts.join(", ") : "empty session";
					replacementCtx.ui.notify(`Cleared ${summary}. Fresh session ready.`, "info");
				},
			});

			if (result.cancelled) {
				// newSession was cancelled (e.g. session_shutdown during replacement)
				ctx.ui.notify("Clear cancelled", "info");
			}
		},
	});
}