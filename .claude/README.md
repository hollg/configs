# Project-specific Claude Code config (this repo only)

This `.claude/` directory holds skills, agents, and settings scoped to the **configs
repo itself**. Claude Code reads it directly when the working directory is this repo —
it is **not** managed by GNU Stow and is never symlinked into `~/.claude`.

- `skills/` — skills relevant only to working on this dotfiles repo.
- `agents/` — subagents relevant only to this repo.
- `settings.local.json` — local settings (gitignored).

## Not to be confused with the `claude` stow module

Globally-available skills and agents — the ones you want in *every* project — live in
the top-level `claude/` module and are stowed to `~/.claude/`. See `claude/README.md`.

| Scope   | Path                        | Stowed? | Available where     |
|---------|-----------------------------|---------|---------------------|
| Global  | `claude/.claude/{skills,agents}` | Yes | Every project       |
| Project | `.claude/{skills,agents}` (here) | No  | This repo only      |

If a name exists in both scopes, the project-level definition wins here.
