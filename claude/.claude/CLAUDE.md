<!-- ~/.claude/CLAUDE.md — global Claude Code memory (symlinked by the `claude` stow module) -->

# Global Claude Code memory

Claude Code does not read `AGENTS.md`, so this file imports the shared, machine-wide
agent instructions that every other agent reads directly from `~/AGENTS.md`. Keep the
actual instructions in `~/AGENTS.md` (the `agents` module) so all agents share one
source of truth; add Claude-only guidance below the import.

@~/AGENTS.md
