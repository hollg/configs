/**
 * Web research tools for Pi: web_search + web_fetch.
 *
 * Installed at ~/.pi/agent/extensions/web-research/index.ts (Stow-managed
 * from pi/.pi/agent/extensions/web-research/). Pi auto-loads extension
 * subdirectories with an index.ts entry point.
 *
 * web_search  — keyless search across developer-focused sources:
 *               Hacker News (Algolia), GitHub repos, Wikipedia,
 *               Stack Overflow (Stack Exchange), npm registry.
 * web_fetch   — fetch a URL and return its readable text content.
 *
 * Zero runtime dependencies: Node's global fetch, hand-rolled HTML extractor.
 * Output is truncated to the built-in pi limits; full output is written to a
 * temp file and its path returned so the model can read the rest.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AgentToolResult, Theme } from "@earendil-works/pi-coding-agent";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateHead,
	withFileMutationQueue,
	type TruncationResult,
} from "@earendil-works/pi-coding-agent";
import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Type } from "typebox";
import { Text } from "@earendil-works/pi-tui";

const TIMEOUT_MS = 20_000;
const MAX_RESPONSE_BYTES = 15 * 1024 * 1024; // 15MB
const MAX_RESULTS = 20;

const UA =
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36";

/** Merge an optional outer signal (user abort) with a hard timeout. */
function combinedSignal(signal: AbortSignal | undefined): AbortSignal {
	const timeout = AbortSignal.timeout(TIMEOUT_MS);
	return signal ? AbortSignal.any([signal, timeout]) : timeout;
}

/** Fetch response body as text, aborting if it exceeds MAX_RESPONSE_BYTES. */
async function readBodyCapped(res: Response): Promise<string> {
	if (!res.body) return res.text();
	const reader = res.body.getReader();
	const decoder = new TextDecoder();
	const chunks: Uint8Array[] = [];
	let total = 0;
	try {
		for (;;) {
			const { done, value } = await reader.read();
			if (done) break;
			total += value.byteLength;
			if (total > MAX_RESPONSE_BYTES) {
				throw new Error(`Response exceeds ${formatSize(MAX_RESPONSE_BYTES)} limit`);
			}
			chunks.push(value);
		}
	} finally {
		reader.releaseLock();
	}
	let text = "";
	for (const c of chunks) text += decoder.decode(c, { stream: true });
	return text + decoder.decode();
}

// ---------------------------------------------------------------------------
// HTML extraction (dependency-free)
// ---------------------------------------------------------------------------

const ENTITIES: Record<string, string> = {
	amp: "&",
	lt: "<",
	gt: ">",
	quot: '"',
	apos: "'",
	nbsp: " ",
	ensp: " ",
	emsp: " ",
	ndash: "–",
	mdash: "—",
	hellip: "…",
	lsquo: "'",
	rsquo: "'",
	ldquo: '"',
	rdquo: '"',
	copy: "©",
	reg: "®",
	trade: "™",
	times: "×",
	divide: "÷",
	frac12: "½",
};

function decodeEntities(s: string): string {
	return s
		.replace(/&#x([0-9a-fA-F]+);/g, (_m, h: string) => {
			const cp = parseInt(h, 16);
			return cp >= 0 && cp <= 0x10ffff && !(cp >= 0xd800 && cp <= 0xdfff) ? String.fromCodePoint(cp) : "";
		})
		.replace(/&#(\d+);/g, (_m, d: string) => {
			const cp = parseInt(d, 10);
			return cp >= 0 && cp <= 0x10ffff && !(cp >= 0xd800 && cp <= 0xdfff) ? String.fromCodePoint(cp) : "";
		})
		.replace(/&([a-zA-Z][a-zA-Z0-9]*);/g, (m, name: string) => (name in ENTITIES ? ENTITIES[name] : m));
}

function stripTags(s: string): string {
	return decodeEntities(s.replace(/<[^>]+>/g, " ")).replace(/\s+/g, " ").trim();
}

interface ExtractedPage {
	title: string;
	description: string;
	text: string;
}

function htmlToText(html: string): ExtractedPage {
	const title = stripTags(html.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1] ?? "");

	const descMatch =
		html.match(/<meta[^>]+name=["']description["'][^>]+content=["']([^"']*)["']/i) ??
		html.match(/<meta[^>]+content=["']([^"']*)["'][^>]+name=["']description["']/i);
	const description = descMatch ? decodeEntities(descMatch[1]).trim() : "";

	let doc = html
		.replace(/<script[\s\S]*?<\/script>/gi, " ")
		.replace(/<style[\s\S]*?<\/style>/gi, " ")
		.replace(/<noscript[\s\S]*?<\/noscript>/gi, " ")
		.replace(/<svg[\s\S]*?<\/svg>/gi, " ")
		.replace(/<!--[\s\S]*?-->/g, " ");

	doc = doc
		.replace(/<\/(?:p|div|section|article|li|tr|table|blockquote|pre|h[1-6])[^>]*>/gi, "\n")
		.replace(/<(?:br|hr|li|tr)[^>]*>/gi, "\n")
		.replace(/<h([1-6])[^>]*>/gi, (_m, n: string) => "\n" + "#".repeat(Number(n)) + " ");

	doc = decodeEntities(doc.replace(/<[^>]+>/g, " "));

	const out: string[] = [];
	let blank = 0;
	for (const raw of doc.split("\n")) {
		const line = raw.replace(/\s+/g, " ").trim();
		if (!line) {
			blank++;
			if (blank === 1) out.push("");
			continue;
		}
		blank = 0;
		out.push(line);
	}
	return { title, description, text: out.join("\n").trim() };
}

// ---------------------------------------------------------------------------
// web_fetch
// ---------------------------------------------------------------------------

async function fetchPage(url: string, signal: AbortSignal): Promise<{ finalUrl: string; text: string }> {
	const res = await fetch(url, {
		headers: { "User-Agent": UA, Accept: "text/html,application/xhtml+xml,text/plain,*/*;q=0.8" },
		redirect: "follow",
		signal,
	});
	if (!res.ok) throw new Error(`HTTP ${res.status} ${res.statusText} for ${url}`);
	const text = await readBodyCapped(res);
	// Reject clearly binary bodies (PDFs, images, zips) instead of returning garbage.
	if (text.includes("\u0000")) throw new Error(`Binary content is not supported (${url})`);
	return { finalUrl: res.url, text };
}

function assertHttpUrl(raw: string): URL {
	let u: URL;
	try {
		u = new URL(raw);
	} catch {
		throw new Error(`Invalid URL: ${raw}`);
	}
	if (u.protocol !== "http:" && u.protocol !== "https:") {
		throw new Error(`Only http/https URLs are supported: ${raw}`);
	}
	return u;
}

// ---------------------------------------------------------------------------
// web_search — keyless developer-focused backends
// ---------------------------------------------------------------------------

interface SearchResult {
	source: string;
	title: string;
	url: string;
	snippet: string;
}

const SOURCE_DEFS: Record<string, { label: string; query: (q: string, n: number, signal: AbortSignal) => Promise<SearchResult[]> }> = {
	hn: {
		label: "Hacker News",
		query: async (q, n, signal) => {
			const res = await fetch(
				`https://hn.algolia.com/api/v1/search?query=${encodeURIComponent(q)}&hitsPerPage=${n}`,
				{ headers: { "User-Agent": UA }, signal },
			);
			if (!res.ok) throw new Error(`HN API HTTP ${res.status}`);
			const data = (await res.json()) as {
				hits: { title?: string; url?: string | null; objectID?: string; story_text?: string | null }[];
			};
			return (data.hits ?? []).map((h) => ({
				source: "hn",
				title: decodeEntities(h.title ?? "(no title)"),
				url: h.url || `https://news.ycombinator.com/item?id=${h.objectID}`,
				snippet: stripTags(h.story_text ?? "").slice(0, 250),
			}));
		},
	},
	github: {
		label: "GitHub",
		query: async (q, n, signal) => {
			const res = await fetch(`https://api.github.com/search/repositories?q=${encodeURIComponent(q)}&per_page=${n}`, {
				headers: { "User-Agent": UA, Accept: "application/vnd.github+json" },
				signal,
			});
			if (res.status === 403 || res.status === 429) {
				throw new Error("GitHub API rate limit exceeded (unauthenticated: 10 req/min)");
			}
			if (!res.ok) throw new Error(`GitHub API HTTP ${res.status}`);
			const data = (await res.json()) as {
				items?: { full_name?: string; html_url?: string; description?: string | null; stargazers_count?: number; language?: string | null }[];
			};
			return (data.items ?? []).map((r) => {
				const meta = [`${r.stargazers_count ?? 0}★`, r.language].filter(Boolean).join(" · ");
				return {
					source: "github",
					title: r.full_name ?? "(no name)",
					url: r.html_url ?? "",
					snippet: `${meta} — ${r.description ?? ""}`.slice(0, 250),
				};
			});
		},
	},
	wikipedia: {
		label: "Wikipedia",
		query: async (q, n, signal) => {
			const res = await fetch(
				`https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=${encodeURIComponent(q)}&format=json&srlimit=${n}&srprop=snippet`,
				{ headers: { "User-Agent": UA }, signal },
			);
			if (!res.ok) throw new Error(`Wikipedia API HTTP ${res.status}`);
			const data = (await res.json()) as {
				query?: { search?: { title?: string; snippet?: string }[] };
			};
			return (data.query?.search ?? []).map((s) => ({
				source: "wikipedia",
				title: decodeEntities(s.title ?? "(no title)"),
				url: `https://en.wikipedia.org/wiki/${encodeURIComponent((s.title ?? "").replace(/ /g, "_"))}`,
				snippet: stripTags(s.snippet ?? "").slice(0, 250),
			}));
		},
	},
	stackoverflow: {
		label: "Stack Overflow",
		query: async (q, n, signal) => {
			const res = await fetch(
				`https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=relevance&q=${encodeURIComponent(q)}&site=stackoverflow&pagesize=${n}`,
				{ headers: { "User-Agent": UA }, signal },
			);
			if (!res.ok) throw new Error(`Stack Exchange API HTTP ${res.status}`);
			const data = (await res.json()) as {
				items?: { title?: string; link?: string; tags?: string[]; score?: number; answer_count?: number }[];
			};
			return (data.items ?? []).map((i) => ({
				source: "stackoverflow",
				title: decodeEntities(i.title ?? "(no title)"),
				url: i.link ?? "",
				snippet: `[${(i.tags ?? []).join(", ")}] score ${i.score ?? 0} · ${i.answer_count ?? 0} answers`,
			}));
		},
	},
	npm: {
		label: "npm",
		query: async (q, n, signal) => {
			const res = await fetch(
				`https://registry.npmjs.org/-/v1/search?text=${encodeURIComponent(q)}&size=${n}`,
				{ headers: { "User-Agent": UA }, signal },
			);
			if (!res.ok) throw new Error(`npm registry HTTP ${res.status}`);
			const data = (await res.json()) as {
				objects?: { package?: { name?: string; description?: string; version?: string; links?: { npm?: string } } }[];
			};
			return (data.objects ?? []).map((o) => ({
				source: "npm",
				title: o.package?.name ?? "(no name)",
				url: o.package?.links?.npm ?? `https://www.npmjs.com/package/${o.package?.name ?? ""}`,
				snippet: `v${o.package?.version ?? "?"} — ${o.package?.description ?? ""}`.slice(0, 250),
			}));
		},
	},
};

const SOURCE_NAMES = Object.keys(SOURCE_DEFS) as SearchSource[];

type SearchSource = keyof typeof SOURCE_DEFS;

function formatSearchResults(query: string, results: SearchResult[]): string {
	const perSource = new Map<string, SearchResult[]>();
	for (const r of results) {
		const list = perSource.get(r.source) ?? [];
		list.push(r);
		perSource.set(r.source, list);
	}
	const parts = [`Search results for "${query}" — ${results.length} total`];
	for (const name of SOURCE_NAMES) {
		const list = perSource.get(name);
		if (!list?.length) continue;
		parts.push("");
		parts.push(`[${SOURCE_DEFS[name].label}] (${list.length})`);
		list.forEach((r, i) => {
			parts.push(`${i + 1}. ${r.title}`);
			parts.push(`   ${r.url}`);
			if (r.snippet) parts.push(`   ${r.snippet}`);
		});
	}
	return parts.join("\n");
}

// ---------------------------------------------------------------------------
// Extension registration
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "web_search",
		label: "Web search",
		description: `Search the web across developer-focused sources: Hacker News, GitHub repositories, Wikipedia, Stack Overflow, and npm. All sources are queried in parallel and merged into one result list. Keyless — no API key required. Output is truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)}; if truncated, full output is saved to a temp file.`,
		promptSnippet: "web_search(query, sources?, maxResults?) — keyless dev-focused search (HN, GitHub, Wikipedia, Stack Overflow, npm)",
		promptGuidelines: [
			"Prefer web_search + web_fetch to answer questions about current tools, libraries, and best practices.",
			"Verify claims against the fetched page content rather than relying on search snippets alone.",
			"web_search cannot do general-news web search; it covers Hacker News, GitHub, Wikipedia, Stack Overflow, and npm.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "Search query" }),
			maxResults: Type.Optional(
				Type.Integer({ default: 8, minimum: 1, maximum: MAX_RESULTS, description: "Maximum total results (default 8, max 20)" }),
			),
			sources: Type.Optional(
				Type.Array(
					Type.Union([
						Type.Literal("hn"),
						Type.Literal("github"),
						Type.Literal("wikipedia"),
						Type.Literal("stackoverflow"),
						Type.Literal("npm"),
					]),
					{ description: "Restrict to specific sources (default: all five)" },
				),
			),
		}),

		async execute(_toolCallId, params, signal, _onUpdate) {
			const sig = combinedSignal(signal);
			const maxResults = Math.min(params.maxResults ?? 8, MAX_RESULTS);
			const sources = (params.sources && params.sources.length ? params.sources : SOURCE_NAMES) as SearchSource[];
			const perSource = Math.max(1, Math.ceil(maxResults / sources.length));

			const settled = await Promise.allSettled(
				sources.map((s) => SOURCE_DEFS[s].query(params.query, perSource, sig)),
			);

			const results: SearchResult[] = [];
			const failed: string[] = [];
			settled.forEach((r, i) => {
				if (r.status === "fulfilled") results.push(...r.value);
				else failed.push(SOURCE_DEFS[sources[i]].label);
			});
			results.splice(maxResults);

			if (results.length === 0) {
				const note = failed.length ? ` Sources that failed: ${failed.join(", ")}.` : "";
				return {
					content: [{ type: "text", text: `No results found for "${params.query}".${note}` }],
					details: { query: params.query, count: 0, failed } as SearchDetails,
				};
			}

			let text = formatSearchResults(params.query, results);
			if (failed.length) text += `\n\n(Sources that failed: ${failed.join(", ")})`;

			return {
				content: [{ type: "text", text }],
				details: { query: params.query, count: results.length, failed, results } as SearchDetails,
			};
		},

		renderCall(args, theme) {
			let text = theme.fg("toolTitle", theme.bold("web_search "));
			text += theme.fg("accent", `"${args.query}"`);
			if (args.sources?.length) text += theme.fg("muted", ` [${args.sources.join(",")}]`);
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded }, theme) {
			const d = result.details as SearchDetails | undefined;
			let text = theme.fg("success", `${d?.count ?? 0} results`);
			if (d?.failed?.length) text += theme.fg("warning", ` (${d.failed.length} source(s) failed)`);
			if (expanded && result.content[0]?.type === "text") {
				for (const line of result.content[0].text.split("\n").slice(0, 24)) {
					text += `\n${theme.fg("dim", line)}`;
				}
			}
			return new Text(text, 0, 0);
		},
	});

	pi.registerTool({
		name: "web_fetch",
		label: "Fetch web page",
		description: `Fetch a URL and return its readable text content: page title, meta description, and extracted article/body text (scripts, styles, and navigation removed). Accepts http/https URLs, follows redirects, 20s timeout. Output is truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)}; if truncated, full output is saved to a temp file whose path is included in the output. Use web_search to find URLs first.`,
		promptSnippet: "web_fetch(url) — fetch a web page and return its readable text content",
		promptGuidelines: [
			"Use web_fetch to read a page found via web_search before trusting it as a source.",
			"JavaScript-rendered pages may return little or no text; prefer server-rendered pages or look for an alternative URL.",
		],
		parameters: Type.Object({
			url: Type.String({ description: "http(s) URL to fetch" }),
		}),

		async execute(_toolCallId, params, signal, _onUpdate) {
			assertHttpUrl(params.url);
			const sig = combinedSignal(signal);
			const { finalUrl, text } = await fetchPage(params.url, sig);
			const { title, description, extracted } = preparePage(finalUrl, text);

			if (!extracted) {
				return {
					content: [
						{
							type: "text",
							text: `Fetched ${finalUrl} but extracted no readable text — the page is likely JavaScript-rendered (SPA). Its <title> was ${title ? `"${title}"` : "empty"}.`,
						},
					],
					details: { url: finalUrl, textLength: 0 } as FetchDetails,
				};
			}

			const truncation = truncateHead(extracted, {
				maxLines: DEFAULT_MAX_LINES,
				maxBytes: DEFAULT_MAX_BYTES,
			});

			let resultText = truncation.content;
			let fullOutputPath: string | undefined;
			if (truncation.truncated) {
				const dir = await mkdtemp(join(tmpdir(), "pi-web-fetch-"));
				fullOutputPath = join(dir, "page.txt");
				const target = fullOutputPath;
				await withFileMutationQueue(target, async () => {
					await writeFile(target, extracted, "utf8");
				});
				const omittedLines = truncation.totalLines - truncation.outputLines;
				const omittedBytes = truncation.totalBytes - truncation.outputBytes;
				resultText += `\n\n[Output truncated: showing ${truncation.outputLines} lines (${formatSize(truncation.outputBytes)}) of ${truncation.totalLines} (${formatSize(truncation.totalBytes)}). ${omittedLines} lines (${formatSize(omittedBytes)}) omitted. Full output saved to: ${fullOutputPath}]`;
			}

			return {
				content: [{ type: "text", text: resultText }],
				details: {
					url: finalUrl,
					title,
					description,
					truncated: truncation.truncated,
					fullOutputPath,
				} as FetchDetails,
			};
		},

		renderCall(args, theme) {
			let text = theme.fg("toolTitle", theme.bold("web_fetch "));
			text += theme.fg("accent", args.url);
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded }, theme) {
			const d = result.details as FetchDetails | undefined;
			let text = theme.fg("success", d?.title || "fetched");
			if (d?.truncated) text += theme.fg("warning", " (truncated)");
			if (expanded && result.content[0]?.type === "text") {
				for (const line of result.content[0].text.split("\n").slice(0, 24)) {
					text += `\n${theme.fg("dim", line)}`;
				}
			}
			return new Text(text, 0, 0);
		},
	});
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface SearchDetails {
	query: string;
	count: number;
	failed: string[];
	results?: SearchResult[];
}

interface FetchDetails {
	url: string;
	title: string;
	description: string;
	textLength?: number;
	truncated?: boolean;
	fullOutputPath?: string;
	truncation?: TruncationResult;
}

function preparePage(finalUrl: string, text: string): { title: string; description: string; extracted: string | null } {
	const { title, description, text: body } = htmlToText(text);
	if (!body) {
		return { title, description, extracted: null };
	}
	const header = `URL: ${finalUrl}\nTitle: ${title || "(no title)"}${description ? `\nDescription: ${description}` : ""}\n\n`;
	return { title, description, extracted: header + body };
}