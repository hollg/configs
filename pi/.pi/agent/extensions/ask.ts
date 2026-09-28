/**
 * ask - Interactive question tool
 *
 * Full custom component with scrollable context area + interactive options panel.
 * No overlay — replaces the main content area so the asking experience has its
 * own focused layout. The agent passes self-contained context via the `context`
 * field; the user can scroll it with ↑↓ in context-focus mode, Tab to options,
 * then navigate/select with ↑↓/Space/Enter.
 *
 * Stows to ~/.pi/agent/extensions/ask.ts
 *
 * Tool parameters:
 *   question    — the question to ask
 *   options     — array of { label, value?, description? }
 *   multiSelect — allow multiple selections (default false)
 *   context     — self-contained info the user needs to decide (optional)
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	Editor,
	type EditorTheme,
	Key,
	matchesKey,
	Text,
	visibleWidth,
	wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

// ── Types ───────────────────────────────────────────────────────────────────

interface OptionDef {
	label: string;
	value?: string;
	description?: string;
}

type RenderOption = OptionDef & { isOther?: boolean };

interface Answer {
	value: string;
	label: string;
	index?: number;
	wasCustom: boolean;
}

interface AskDetails {
	question: string;
	options: OptionDef[];
	multiSelect: boolean;
	context?: string;
	answers: Answer[];
}

// ── Schema ──────────────────────────────────────────────────────────────────

const OptionSchema = Type.Object({
	label: Type.String({ description: "Display label for the option" }),
	value: Type.Optional(
		Type.String({ description: "Value returned when selected (defaults to label)" }),
	),
	description: Type.Optional(
		Type.String({ description: "Optional description shown below label" }),
	),
});

const AskParams = Type.Object({
	question: Type.String({
		description: "The question to ask the user. Must be self-contained — do not rely on conversation history for context.",
	}),
	options: Type.Array(OptionSchema, {
		description: "Available choices (2-4 recommended)",
	}),
	multiSelect: Type.Optional(
		Type.Boolean({ description: "Allow multiple selections (default: false)" }),
	),
	context: Type.Optional(
		Type.String({
			description:
				"Self-contained context the user needs to make the decision. Include essential info here — do NOT rely on conversation history. Be concise: enough to decide, no more.",
		}),
	),
});

// ── Extension ──────────────────────────────────────────────────────────────

export default function askExtension(pi: ExtensionAPI) {
	pi.registerTool({
		name: "ask",
		label: "Ask",
		description:
			"Ask the user a question with optional choices. Supports single-select, multi-select, and custom text input. " +
			"Use when you need user input to proceed — clarifying questions, preferences, or decisions.",
		parameters: AskParams,
		executionMode: "sequential",

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (ctx.mode !== "tui") {
				return {
					content: [{ type: "text", text: "Error: UI not available" }],
					details: {
						question: params.question,
						options: params.options,
						context: params.context,
						multiSelect: !!params.multiSelect,
						answers: [],
					} as AskDetails,
				};
			}

			if (params.options.length === 0) {
				return {
					content: [{ type: "text", text: "Error: No options provided" }],
					details: {
						question: params.question,
						options: [],
						context: params.context,
						multiSelect: !!params.multiSelect,
						answers: [],
					} as AskDetails,
				};
			}

			const multiSelect = params.multiSelect === true;
			const allOptions: RenderOption[] = [
				...params.options,
				{ label: "Type something.", isOther: true },
			];

			const result = await ctx.ui.custom<{ answers: Answer[] } | null>(
				(tui, theme, _kb, done) => {
					// ── State ──
					let optionIndex = 0;
					let editMode = false;
					let cachedLines: string[] | undefined;
					const selectedIndices = new Set<number>();
					let focusMode: "context" | "options" = "options";
					let contextScroll = 0;

					// ── Editor for "Type something" ──
					const editorTheme: EditorTheme = {
						borderColor: (s) => theme.fg("accent", s),
						selectList: {
							selectedPrefix: (t) => theme.fg("accent", t),
							selectedText: (t) => theme.fg("accent", t),
							description: (t) => theme.fg("muted", t),
							scrollInfo: (t) => theme.fg("dim", t),
							noMatch: (t) => theme.fg("warning", t),
						},
					};
					const editor = new Editor(tui, editorTheme);

					editor.onSubmit = (value) => {
						const trimmed = value.trim();
						if (trimmed) {
							done({ answers: [{ value: trimmed, label: trimmed, wasCustom: true }] });
						} else {
							editMode = false;
							editor.setText("");
							refresh();
						}
					};

					function refresh() {
						cachedLines = undefined;
						tui.requestRender();
					}

					// ── Build the context lines (split on newlines, wrapped) ──
					function buildContextLines(rw: number): string[] {
						if (!params.context) return [];
						const lines: string[] = [];
						const paragraphs = params.context.split("\n");
						for (let i = 0; i < paragraphs.length; i++) {
							if (i > 0) lines.push("");
							lines.push(...wrapTextWithAnsi(paragraphs[i], rw));
						}
						return lines;
					}

					// ── Resolve layout ──
					function resolveLayout(rw: number, totalHeight: number): {
						contextHeight: number;
						optionsHeight: number;
					} {
						// Measure the options panel height
						const optLines = estimateOptionsHeight(rw);
						let contextHeight = 0;
						if (params.context && focusMode === "context") {
							// Give context as much room as possible while keeping options visible
							const maxContext = totalHeight - optLines - 5; // 5 for separator + borders + breathing room
							const fullContext = buildContextLines(rw).length + 2; // +2 for header
							contextHeight = Math.min(fullContext, Math.max(maxContext, 5));
						}
						const optionsHeight = totalHeight - contextHeight;
						return { contextHeight, optionsHeight };
					}

					function estimateOptionsHeight(rw: number): number {
						// Estimate: question (wrapped) + options + help + border lines
						const qLines = wrapTextWithAnsi(params.question, rw - 2).length;
						const optLines = allOptions.reduce((sum, opt) => {
							let l = 1; // option label
							if (opt.description) l += 1; // description
							return sum + l;
						}, 0);
						const extra = editMode ? 4 : 2; // editor lines or padding
						const helped = 1;
						const borders = 2;
						return qLines + optLines + extra + helped + borders + 10;
					}

					// ── Confirm ──
					function confirmSelection() {
						if (multiSelect) {
							if (selectedIndices.size === 0) return;
							const answers = Array.from(selectedIndices)
								.sort((a, b) => a - b)
								.map((idx) => {
									const opt = allOptions[idx];
									return { value: opt.value ?? opt.label, label: opt.label, index: idx + 1, wasCustom: false };
								});
							done({ answers });
						} else {
							const selected = allOptions[optionIndex];
							if (selected.isOther) {
								editMode = true;
								refresh();
							} else {
								done({
									answers: [{ value: selected.value ?? selected.label, label: selected.label, index: optionIndex + 1, wasCustom: false }],
								});
							}
						}
					}

					// ── Handle input ──
					function handleInput(data: string) {
	if (editMode) {
		if (matchesKey(data, Key.escape)) {
			editMode = false;
			editor.setText("");
			refresh();
			return;
		}
		editor.handleInput(data);
		refresh();
		return;
	}

	// Tab/Shift+Tab toggle focus between context and options
	if (matchesKey(data, Key.tab) || matchesKey(data, "shift+tab")) {
		if (params.context) {
			focusMode = focusMode === "context" ? "options" : "context";
			refresh();
			return;
		}
	}

	if (focusMode === "context" && params.context) {
		if (matchesKey(data, Key.up)) {
			contextScroll = Math.max(0, contextScroll - 1);
			refresh();
			return;
		}
		if (matchesKey(data, Key.down)) {
			const ctxLines = buildContextLines(80).length + 2;
			contextScroll = Math.min(ctxLines - 1, contextScroll + 1);
			refresh();
			return;
		}
		// Space/Enter in context mode switch to options
		if (matchesKey(data, Key.enter) || matchesKey(data, Key.space)) {
			focusMode = "options";
			refresh();
			return;
		}
		if (matchesKey(data, Key.escape)) {
			done(null);
		}
		return;
	}

	// Options focus
	if (matchesKey(data, Key.up)) {
		optionIndex = Math.max(0, optionIndex - 1);
		refresh();
		return;
	}
	if (matchesKey(data, Key.down)) {
		optionIndex = Math.min(allOptions.length - 1, optionIndex + 1);
		refresh();
		return;
	}
	if (matchesKey(data, Key.enter)) {
		confirmSelection();
		return;
	}
	if (multiSelect && matchesKey(data, Key.space)) {
		const selected = allOptions[optionIndex];
		if (selected.isOther) {
			editMode = true;
			refresh();
		} else {
			if (selectedIndices.has(optionIndex)) {
				selectedIndices.delete(optionIndex);
			} else {
				selectedIndices.add(optionIndex);
			}
			refresh();
		}
		return;
	}
	if (matchesKey(data, Key.escape)) {
		done(null);
	}
}

					// ── Render ──
					function render(width: number): string[] {
	if (cachedLines) return cachedLines;

	const rw = Math.max(1, width);
	const lines: string[] = [];

	// Context section
	if (params.context) {
		const ctxLines = buildContextLines(rw - 2);
		lines.push(theme.fg("dim", "── Context ──────────────────────────────"));
		const start = contextScroll;
		const maxCtx = 40; // max context lines visible
		const end = Math.min(ctxLines.length, start + maxCtx);
		for (let i = start; i < end; i++) {
			lines.push(` ${ctxLines[i]}`);
		}
		if (ctxLines.length > maxCtx) {
			const pct = ctxLines.length <= maxCtx ? 100 : Math.round((start / Math.max(1, ctxLines.length - maxCtx)) * 100);
			lines.push(theme.fg("dim", `  [${focusMode === "context" ? "✦" : " "} ↑↓ scroll · Tab to options]`));
		} else {
			lines.push(theme.fg("dim", `  [${focusMode === "context" ? "✦" : " "} Tab to options]`));
		}
	}

	// Separator
	lines.push(theme.fg("accent", "─".repeat(rw)));

	// Question
	const qPrefix = focusMode === "options" ? theme.fg("accent", "> ") : "  ";
	const qWrapped = wrapTextWithAnsi(params.question, rw - visibleWidth(qPrefix));
	const qCp = " ".repeat(visibleWidth(qPrefix));
	for (let i = 0; i < qWrapped.length; i++) {
		lines.push(`${i === 0 ? qPrefix : qCp}${theme.fg("text", qWrapped[i])}`);
	}
	lines.push("");

	// Options

	for (let i = 0; i < allOptions.length; i++) {
		const opt = allOptions[i];
		const hl = i === optionIndex && focusMode === "options";
		const checked = multiSelect && selectedIndices.has(i);
		const isOther = opt.isOther === true;

		let prefix: string;
		if (multiSelect) {
			const cb = checked ? "[x]" : "[ ]";
			prefix = hl ? theme.fg("accent", `> ${cb} `) : `  ${cb} `;
		} else {
			prefix = hl ? theme.fg("accent", "> ") : "  ";
		}

		const color = hl ? "accent" : checked ? "success" : "text";
		const labelText = `${i + 1}. ${opt.label}${isOther && editMode ? " ✎" : ""}`;
		const pw = visibleWidth(prefix);
		const wrapped = wrapTextWithAnsi(labelText, rw - pw);
		const cp = " ".repeat(pw);
		for (let j = 0; j < wrapped.length; j++) {
			lines.push(`${j === 0 ? prefix : cp}${theme.fg(color, wrapped[j])}`);
		}

		if (opt.description) {
			const descWrapped = wrapTextWithAnsi(opt.description, rw - 5);
			for (const dl of descWrapped) {
				lines.push(`     ${theme.fg("muted", dl)}`);
			}
		}
	}

	// Inline editor
	if (editMode) {
		lines.push("");
		lines.push(` ${theme.fg("muted", "Your answer:")}`);
		for (const el of editor.render(Math.max(1, rw - 2))) {
			lines.push(` ${el}`);
		}
	}

	// Summary of selections (multi-select)
	if (multiSelect && selectedIndices.size > 0) {
		const selectedLabels = Array.from(selectedIndices)
			.sort((a, b) => a - b)
			.map((i) => allOptions[i].label);
		lines.push(` ${theme.fg("success", `Selected: ${selectedLabels.join(", ")}`)}`);
	}

	// Help text
	lines.push("");
	const helpParts: string[] = [];
	if (focusMode === "context" && params.context) {
		helpParts.push(theme.fg("accent", "✦ context"));
	} else if (focusMode === "options") {
		helpParts.push(theme.fg("accent", "✦ options"));
	}
	if (editMode) {
		helpParts.push("Enter to submit", "Esc to go back");
	} else {
		if (params.context) helpParts.push("Tab to switch focus");
		if (multiSelect) {
			if (focusMode === "options") helpParts.push("↑↓ navigate", "Space toggle", "Enter confirm");
		} else {
			if (focusMode === "options") helpParts.push("↑↓ navigate", "Enter select");
		}
		helpParts.push("Esc cancel");
	}
	lines.push(` ${theme.fg("dim", helpParts.join(" • "))}`);

	// Bottom border
	lines.push(theme.fg("accent", "─".repeat(rw)));

	cachedLines = lines;
	return lines;
}

					return { render, invalidate: () => { cachedLines = undefined; }, handleInput };
				},
			);

			const simpleOptions = params.options.map((o) => o.label);

			if (!result) {
				return {
					content: [{ type: "text", text: "[User cancelled]" }],
					details: { question: params.question, options: params.options, multiSelect, context: params.context, answers: [] } as AskDetails,
				};
			}

			const answerSummary = result.answers
				.map((a) => (a.wasCustom ? `(wrote) "${a.label}"` : a.index ? `${a.index}. ${a.label}` : a.label))
				.join(multiSelect ? "; " : "");

			return {
				content: [{ type: "text", text: `User answered: ${answerSummary}` }],
				details: { question: params.question, options: params.options, multiSelect, context: params.context, answers: result.answers } as AskDetails,
			};
		},

		// ── Inline rendering in chat ──
		renderCall(args, theme, _context) {
			let text = theme.fg("toolTitle", theme.bold("ask ")) + theme.fg("muted", args.question);
			const opts = Array.isArray(args.options) ? args.options : [];
			if (opts.length) {
				const labels = opts.map((o: OptionDef) => o.label);
				const numbered = [...labels, "Type something."].map((o, i) => `${i + 1}. ${o}`);
				text += `\n${theme.fg("dim", `  Options: ${numbered.join(", ")}`)}`;
			}
			if (args.context) {
				const truncated = args.context.length > 60 ? args.context.slice(0, 57) + "..." : args.context;
				text += `\n${theme.fg("dim", `  Context: ${truncated}`)}`;
			}
			return new Text(text, 0, 0);
		},

		renderResult(result, _options, theme, _context) {
			const details = result.details as AskDetails | undefined;
			if (!details) {
				const c = result.content[0];
				const t = typeof c === "string" ? c : (c as { text: string })?.text ?? "";
				return new Text(t, 0, 0);
			}
			if (details.answers.length === 0) {
				return new Text(theme.fg("warning", "Cancelled"), 0, 0);
			}
			const lines = details.answers.map((a) => {
				const prefix = a.wasCustom
					? `${theme.fg("success", "✓ ")}${theme.fg("muted", "(wrote) ")}`
					: theme.fg("success", "✓ ");
				const display = a.index ? `${a.index}. ${a.label}` : a.label;
				return prefix + theme.fg("accent", display);
			});
			return new Text(lines.join("\n"), 0, 0);
		},
	});
}
