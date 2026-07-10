# claude

Global Claude Code **skills** and **agents** — the ones you want available in *every*
project, regardless of which directory you're working in.

## Layout

```
claude/
└── .claude/
    ├── skills/            → ~/.claude/skills/     (each subdir is one skill)
    │   └── example-skill/
    │       └── SKILL.md
    └── agents/            → ~/.claude/agents/     (each .md file is one agent)
        └── example-agent.md
```

Following the repo convention, the in-module tree mirrors `$HOME`: everything under
`claude/.claude/` is symlinked beneath `~/.claude/`.

## Install & apply

```bash
./install.sh claude    # from repo root: prepares ~/.claude/skills & ~/.claude/agents
stow claude            # symlink the global skills & agents into place
```

`install.sh` pre-creates `~/.claude/skills` and `~/.claude/agents` as **real
directories** before you stow. This is deliberate: it forces Stow to link
*individual* files/subdirs into those directories instead of folding (symlinking)
the whole directory. As a result, skills and agents managed by this repo coexist
with any unmanaged ones already in `~/.claude/` — stow never adopts or overwrites
them.

## Adding a skill or agent

- **Skill:** create `claude/.claude/skills/<name>/SKILL.md` (with `name` +
  `description` frontmatter), then `stow -R claude`.
- **Agent:** create `claude/.claude/agents/<name>.md` (with `name` + `description`
  frontmatter), then `stow -R claude`.

Use `stow -R claude` (restow) after adding files so the new symlinks are created.

## Global vs. project-specific

This module is **only** for globally-available definitions. Definitions specific to a
single project belong in that project's own `.claude/` directory (for this repo, see
the root `.claude/skills/` and `.claude/agents/`, which are read directly and are
**not** stowed).

If a project-level skill/agent shares a name with a global one, Claude Code uses the
project-level definition — the project scope shadows the global one. They live at
different paths and never collide on the filesystem.

## Uninstall

```bash
stow -D claude
```

Removes only the symlinks this repo created. Unmanaged files in
`~/.claude/{skills,agents}` are untouched. Remove the now-empty directories manually
if you want them gone.
