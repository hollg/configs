# web-research

Pi extension adding two tools for internet research during planning and implementation:

- **`web_search(query, sources?, maxResults?)`** — keyless search across developer-focused sources, queried in parallel and merged:
  - Hacker News (Algolia)
  - GitHub repositories
  - Wikipedia
  - Stack Overflow (Stack Exchange)
  - npm registry
- **`web_fetch(url)`** — fetch a page and return its readable text (title, meta description, body text with scripts/styles/navigation stripped).

## Why keyless dev search?

General web search engines (DuckDuckGo, Bing, Mojeek, SearXNG) bot-block this machine's datacenter egress IP, so this extension uses keyless REST APIs instead — they tolerate datacenter IPs and cover the sources most useful for planning development work. If general web search is ever needed, `web_search` currently can't provide it; see "Limitations".

## Install

This directory is Stow-managed from `pi/.pi/agent/extensions/web-research/` in the dotfiles repo. Apply with:

```bash
stow --no-folding pi
```

Pi auto-loads extension subdirectories with an `index.ts` entry point; the tools appear on the next `pi` start (no settings change needed).

## Usage (inside pi)

Ask for research in the normal way; the model picks the tools. For example:

> "Search for recent Hacker News discussion about pi coding agent, then fetch the top result and summarize it."

For direct tool use:
- `web_search("pi coding agent extensions", maxResults: 10)`
- `web_search("pathfinding", sources: ["wikipedia", "stackoverflow"])` — restrict sources: `hn`, `github`, `wikipedia`, `stackoverflow`, `npm`
- `web_fetch("https://example.org/docs")`

Results are grouped by source and numbered. Output is capped at pi's built-in limits (50KB / 2000 lines); when a fetch is truncated the full text is written to a temp file whose path is included in the result.

## Limitations

- **No JavaScript rendering** — SPAs (React/Vue apps) return little or no readable text; `web_fetch` reports the `<title>` when extraction is empty. Prefer server-rendered pages.
- **No general-news search** — coverage is HN, GitHub, Wikipedia, Stack Overflow, npm.
- **GitHub rate limit** — keyless GitHub search allows ~10 requests/minute; the tool degrades gracefully and reports the failed source.
- **Stack Exchange quota** — keyless allows ~300 requests/day per IP.
- **Timeout** — each request aborts after 20s; pages over 15MB are rejected.
- **Binary content** — PDFs/images are rejected with an error (use `bash` + a download tool for those).

## Uninstall

Remove the extension directory from the repo, then re-apply stow on a fresh checkout:

```bash
git rm -r pi/.pi/agent/extensions/web-research
stow -R --no-folding pi
```

The tools stop loading on the next `pi` start. Nothing else is installed (no npm packages, no settings changes), so there is nothing further to clean up.