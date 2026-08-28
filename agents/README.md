# agents

A single, machine-wide **`AGENTS.md`** of instructions for AI coding agents, symlinked
to your home directory so agents discover it from anywhere you work under `$HOME`.

## Layout

```
agents/
└── AGENTS.md            → ~/AGENTS.md
```

Stow's target is `~`, so a file at the module root lands at `~/AGENTS.md`. Following the
repo convention, `install.sh` and `README.md` are excluded from stowing (see `.stowrc`)
and are never linked into `~`.

## Why home root

Most agents that support `AGENTS.md` search for it by walking up the directory tree from
the current working directory. Placing the canonical file at `~/AGENTS.md` means it's
found whenever you're working anywhere beneath your home directory — one file, picked up
by every such agent.

## Claude Code

Claude Code does **not** read `AGENTS.md`. Instead, the global
[`claude`](../claude/README.md) module ships `~/.claude/CLAUDE.md`, which imports this
file via `@~/AGENTS.md`. So the instructions live in one place (`~/AGENTS.md`) and both
Claude and other agents honor them.

## Install & apply

```bash
./install.sh agents    # no dependencies; just prints guidance
stow agents            # symlink AGENTS.md → ~/AGENTS.md
stow claude            # so Claude picks it up via ~/.claude/CLAUDE.md
```

## Uninstall

```bash
stow -D agents
```

Removes the `~/AGENTS.md` symlink this repo created. There are no dependencies to remove.
If you also want Claude to stop importing it, remove the import line from
`claude/.claude/CLAUDE.md` (or `stow -D claude`).
