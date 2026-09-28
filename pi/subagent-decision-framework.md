# Subagent Decision Framework — Findings and Plan

Assessment of the current subagent instructions (`APPEND_SYSTEM.md`, agent definitions,
workflow prompts) and where each gap is best solved.

**Update (2025-03-15):** Fork tool removed entirely. `pi-fork` package uninstalled from
`settings.json`, all fork references stripped from `APPEND_SYSTEM.md`, and the decision
framework simplified to a three-way choice (inline, subagent, subagent chain).
The `fork` mechanism (session forking via `/fork` command) still exists for manual use.

## Current landscape

### Mechanisms available

| Layer | Location | What it controls |
|-------|----------|-----------------|
| System instructions | `APPEND_SYSTEM.md` | Decision rules, heuristics, cost awareness (loaded every session) |
| Agent definitions | `.pi/agent/agents/*.md` | Role contract: tools, model, output format (loaded per subagent spawn) |
| Workflow prompts | `.pi/agent/prompts/*.md` | Orchestration patterns accessible via `/` commands |
| Subagent extension | `.pi/agent/extensions/subagent/index.ts` | Plumbing: process spawn, output capture, streaming, error handling |
| Skills | `.pi/agent/skills/*/SKILL.md` | On-demand specialised instructions (loaded when task matches) |

### What's working

- Role separation is crisp: scout (fast model, read-only tools), planner (no bash),
  worker (full capabilities), reviewer (read-only with strict bash policy).
- Tool selection table maps common task types to concrete actions.
- Workflow prompts encode orchestration patterns (`/implement`, `/scout-and-plan`,
  `/implement-and-review`).

## Gaps

### 1. No cost guidance / when NOT to subagent

The tool selection table is all upside. There is no entry for "this task is too small,
just do it inline." A simple grep ("find callers of X") is faster and cheaper inline
than spawning a subagent.

Every subagent costs:
- Process spawn + resource discovery (hundreds of ms before first token)
- Fresh system prompt construction (tool definitions, agent instructions, skill descriptions)
- Full context window from scratch (no shared prompt cache with parent)
- Separate prompt-cache writes for each subagent of the same type

**Fix location:** `APPEND_SYSTEM.md` — expand the tool selection table with a cost column
and add a "too small for subagent" heuristic.

### 2. No task-sizing heuristic

I need to know whether "investigate X" means a 30-second grep or a 5-minute deep dive,
and whether the subagent overhead is justified. The scout definition has a
`thoroughness` parameter (quick/medium/thorough) but the decision table doesn't
reference it.

Without sizing, the default behaviour is either wasteful (using a subagent for a
one-line lookup) or insufficient (running a quick scout when the task needs full
tracing).

**Fix location:** `APPEND_SYSTEM.md` (decision table) + scout agent definition (output
format notes on expected output size per thoroughness level).

### 3. Context transfer strategy undefined (✅ Fixed)

Rule says "feed each agent in a chain the previous agent's full output." There is no
cap or summarisation step.

**Fix applied:** Each agent definition now includes a `## Handoff` section as the
last output section — a dense 3-5 line summary of exactly what the next agent needs.
This keeps the chain compact even if the full output is verbose.

The extension-level output capping (chain-mode truncation) remains a future
improvement.

### 4. No "inline vs delegate" decision rule

The table compares subagent vs fork, but not subagent vs "do it right here." Consider:
- Reading a file and understanding one function: one tool call, ~0 extra context tokens
- Spawning a scout: process startup + fresh system prompt + tool definitions + context
  window

The instructions need a rule of thumb for when the delegation overhead pays off.
Candidates: >2 files to read, >3 distinct search patterns, or "I've already been
going in circles and need a fresh perspective."

**Fix location:** `APPEND_SYSTEM.md` — add to the tool selection table or as a rule
below it.

### 5. Debugging is a natural subagent task but isn't one

The `debug.md` prompt runs in the current context. Debugging benefits from a fresh
context — the parent session may have accumulated confirmation bias from chasing the
wrong path. A "debugger" subagent that starts clean would be valuable.

Currently: prompt template only (inline). There is no agent definition for it and no
workflow prompt that delegates debugging as a subagent task.

**Fix location:** New `debug.md` agent definition + new workflow prompt
`/debug-agent` or similar.

### 6. State sync after subagent mutations isn't addressed

The worker can edit files via the subagent. If it does, the parent session has no
record of those edits in its context window. The next turn in the parent has stale
understanding of "what files look like now."

Currently no mechanism to re-sync: no instruction to re-read changed files, and no
extension tracking of which files were mutated.

**Fix location:** `APPEND_SYSTEM.md` (instruction rule: "after worker returns, re-read
changed files into context") + subagent extension (return list of mutated file paths
alongside the text output).

### 7. Model tiering economics not articulated

Agent definitions assign models (fast → scout, balanced → planner, powerful →
worker/reviewer). The cost gradients are clear per definition, but there is no guidance
on *when the savings are eaten by the overhead*.

Using Haiku for a 1-turn scout saves output tokens, but the startup overhead (process
spawn + system prompt construction) is a fixed cost regardless of model. A 1-turn
scout on Haiku that returns "found nothing" costs almost as much as the same scout
on Sonnet.

**Fix location:** `APPEND_SYSTEM.md` — note in or near the model assignment rules.

## Resolution mapping

| # | Gap | Primary fix | Supporting changes | Status |
|---|-----|-------------|-------------------|--------|
| 1 | Cost guidance / inline-or-subagent | `APPEND_SYSTEM.md` — expand tool selection table | — | ✅ Done |
| 2 | Task sizing | `APPEND_SYSTEM.md` (heuristic) + scout output format (size targets per thoroughness) | — | ✅ Done |
| 3 | Context transfer | Agent definitions — output contracts expanded with Handoff sections | Chain prompts reinforce handoff structure | ✅ Done |
| 4 | Inline vs delegate rule | `APPEND_SYSTEM.md` — add to decision table or as a rule | — | ✅ Done |
| 5 | Debug subagent | New `debugger.md` agent definition + new `debug-agent.md` workflow prompt | — | ✅ Done |
| 6 | State sync | `APPEND_SYSTEM.md` — instruction rule | Extension: track mutated files and return their paths | ❌ Pending |
| 7 | Model tiering economics | `APPEND_SYSTEM.md` — note next to model assignment rules | — | ✅ Done |

Items 1, 2, 4, 7 were bundled into one pass and applied to `APPEND_SYSTEM.md`.
The fork tool (`pi-fork` package) was removed entirely — uninstalled from
`settings.json` and all references stripped from `APPEND_SYSTEM.md`.

## Proposed order of work

1. **`APPEND_SYSTEM.md` bundle** — gaps 1, 2, 4, 7 together. Single file, highest
   leverage, no code changes. ✅ Done
2. **Debug subagent** — gap 5. New standalone agent, minimal risk. ✅ Done
3. **Context transfer discipline** — gap 3. Update workflow prompts + agent definitions
   with Handoff contracts. ✅ Done
4. **Extension changes** — gaps 3 (chain output cap) and 6 (mutation tracking).
   Requires TypeScript changes to `extensions/subagent/index.ts`.
5. **State sync rule** — gap 6 instruction component. Simple addition to
   `APPEND_SYSTEM.md` once the extension returns mutated file paths.