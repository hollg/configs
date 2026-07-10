# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A portable, opinionated dotfiles repository for a terminal-based development environment. Each tool's configuration lives in its own top-level directory (a "module"), and [GNU Stow](https://www.gnu.org/software/stow/) manages the symlinks from each module into the correct filesystem location. Nothing here is a compiled project — there is no build or test suite; "running" a module means symlinking its config and launching the underlying tool.

Modules: `zsh`, `fonts`, `ghostty`, `iterm2`, `tmux`, `nvim`, `opencode`, `npm`, `go`, `claude`.

## Commands

```bash
./install.sh                 # Install core deps + all modules' deps
./install.sh zsh nvim        # Install only specific modules' deps
./install.sh --list          # List modules and whether each has an install script
./install.sh --help

stow <module>                # Symlink a module's config into place (e.g. stow nvim)
stow -D <module>             # Remove a module's symlinks
stow -R <module>             # Re-apply (use after changing which files a module tracks)
```

`install.sh` only installs dependencies; it does **not** stow. Applying config is always an explicit `stow <module>` step.

## Architecture

**Stow layout is load-bearing.** Inside each module, the directory tree mirrors what will appear under `$HOME` (Stow's target is `~`, set in `.stowrc`). So `nvim/.config/nvim/init.lua` symlinks to `~/.config/nvim/init.lua`, and `zsh/.zshrc` symlinks to `~/.zshrc`. When adding a config file, place it at the path it needs to live at relative to home, not wherever is convenient.

**Files excluded from symlinking** are listed in `.stowrc` (`install.sh`, `setup.sh`, `README.md`, `colors`, `.git`, `.gitignore`). These stay in the repo and are never linked into `~`. This is why every module can keep its own `install.sh` and `README.md` alongside the config without polluting the home directory.

**Modular install architecture** — the design intent (see `.github/instructions/configs.md`) is that a user can install only the modules they want:
- Root `install.sh` installs core deps (Homebrew, Stow, zoxide, uv) via `scripts/common.sh`, then delegates to each module's own `install.sh`.
- Each `<module>/install.sh` sources `../scripts/common.sh` and installs only that module's dependencies. Keep module install scripts self-contained and idempotent (check `command_exists` / existing install before installing) — follow the pattern in `nvim/install.sh` and `zsh/install.sh`.
- `scripts/common.sh` is the shared library: colored `print_status/success/warning/error` helpers, `command_exists`, core-dependency installers, and module discovery (`get_modules`, `module_has_install_script`, `install_module`). Add shared install logic here, not duplicated per module.

## Conventions (from `.github/instructions/configs.md`)

- **Every config file starts with a comment showing the filesystem path it will be symlinked to** (e.g. `# ~/.config/nvim/init.lua`). Maintain this when adding files.
- **Catppuccin theme everywhere** it's supported (iTerm2 ships all four flavors in `iterm2/colors/`; nvim/tmux/ghostty themed to match).
- **Each module's `README.md` must include uninstallation instructions**, including how to remove the module's dependencies.
- **Assume no config exists outside this repo.** Don't document how to remove options or plugins added elsewhere — the repo is the single source of truth for these tools' configuration.
- New modules are auto-discovered by `get_modules()` (any top-level dir that isn't `.github/` or `scripts/`), so adding a module means: create the directory with the mirrored config tree, an `install.sh`, and a `README.md`.

## Claude Code skills & agents

Two distinct scopes, deliberately at different paths so they never collide:

- **Global** (`claude` module) — `claude/.claude/{skills,agents}` stows to `~/.claude/{skills,agents}`, making those skills/agents available in every project. `claude/install.sh` pre-creates the target dirs as real directories so Stow links *individual* files/subdirs in, coexisting with any unmanaged files already in `~/.claude/` (e.g. hand-placed agents). Use `stow -R claude` after adding definitions.
- **Project** (this repo only) — the repo-root `.claude/{skills,agents}` is read directly by Claude Code when cwd is this repo and is **not** stowed. If a name exists in both scopes, the project-level definition wins.

When adding here: skills are `skills/<name>/SKILL.md`, agents are `agents/<name>.md`, both with `name` + `description` frontmatter. See `claude/README.md`.

## Secrets

`zsh/.env` holds secrets and is gitignored. `zsh/.env.template` is the tracked template — copy it to `zsh/.env` and fill in real values. Never commit `zsh/.env`.

## nvim specifics

Neovim config uses `lazy.nvim`. `init.lua` imports two plugin groups: `plugins` (`lua/plugins/*.lua`) and `plugins.lsp` (`lua/plugins/lsp/*.lua`) — each file returns a lazy plugin spec. `basics.lua` holds core options/keymaps loaded before plugins. `lazy-lock.json` pins plugin versions; commit it when intentionally updating plugins. Requires Neovim ≥ 0.11 (enforced by `nvim/install.sh`).
