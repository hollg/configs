# Pi configuration migration design

## Goal

Manage Gary's reusable Pi configuration in this repository without storing provider details, credentials, sessions, or other private Pi runtime state in Git.

## Scope

Add a `pi` Stow module. It manages durable, non-sensitive Pi preferences and resources under `~/.pi/agent/`.

The migration removes stale prompt links, a missing local package declaration, and the temporary `mash` extension link.

## Managed files

```text
pi/
├── .stow-local-ignore
├── .pi/
│   └── agent/
│       ├── agents/
│       │   ├── planner.md
│       │   ├── reviewer.md
│       │   ├── scout.md
│       │   └── worker.md
│       ├── extensions/
│       │   └── pi-rtk-optimizer/
│       │       └── config.json
│       ├── models.json.example
│       └── settings.json
├── install.sh
├── setup.sh
└── README.md
```

`settings.json` is the source of truth for Pi's public package declarations, Catppuccin Mocha theme, fullscreen interface, and current compaction preferences. The missing `ai-workflow` local package declaration is removed. The nine remaining package declarations use public npm or Git sources.

The four existing agent definitions move unchanged. The RTK optimizer configuration moves unchanged. Their supporting packages are restored from the package declarations in `settings.json`.

`models.json.example` is valid generic Pi compatible-endpoint JSON. It uses placeholders only. It must not identify internal providers, endpoint URLs, model IDs, or credential environment variables.

## Private local state

These paths remain real local files or directories under `~/.pi/agent/` and must never be created, symlinked, copied, or read by the module migration:

- `models.json`
- `auth.json`
- `trust.json`
- `models-store.json`
- `models.json.bak`
- `sessions/`
- `missions/`
- `npm/`
- `git/`

The module-local `.stow-local-ignore` excludes `models.json.example` from deployment. It also ensures no private runtime path can be added to the module accidentally.

On a new machine, the README instructs the user to copy the tracked example to `~/.pi/agent/models.json`, then fill it from the approved internal source. `setup.sh` never creates or modifies that file.

## Installation and package restoration

`pi/install.sh` installs the official Pi CLI with npm when it is absent. It does not stow configuration.

`pi/setup.sh` creates real target directories before Stow runs. This prevents Stow from folding `~/.pi` or `~/.pi/agent` into repository symlinks. Pi can then write its private runtime state locally.

After setup and `stow --no-folding pi`, `pi update --extensions` reconciles the package installations declared in the tracked `settings.json`.

Pi can update `lastChangelogVersion` in the tracked settings file after a Pi upgrade. This is an expected configuration diff, not a generated manifest drift.

## One-time migration

The setup script performs only bounded cleanup:

1. Back up the old local `settings.json` before it is replaced by the tracked version.
2. Remove the dangling `feature.md` prompt link.
3. Remove the three prompt links that point into the version-specific Pi npm installation.
4. Remove the `mash` extension link.
5. For each agent definition and RTK optimizer configuration file, compare the local file with the tracked source. Remove it only when the contents match. Otherwise stop with an actionable message.

The script refuses to overwrite unknown files or links. It does not run Stow, in line with this repository's installation convention.

## User-facing commands

```sh
./install.sh pi
./pi/setup.sh
stow --no-folding pi
pi update --extensions
```

To remove the module:

```sh
stow -D pi
```

This removes only managed links. It leaves the private local state, installed Pi CLI, and installed Pi packages intact. The README includes separate commands to remove those dependencies if wanted.

## Verification

The implementation verifies:

1. `stow --simulate --no-folding pi` succeeds after setup.
2. Managed target paths are symlinks into the repository.
3. `~/.pi/agent/models.json` remains a real local file and contains no repository link.
4. The four retired prompt links and `mash` link are absent.
5. `settings.json` has no missing local package declaration.
6. `pi update --extensions` completes and Pi starts with the tracked resources available.
7. `git diff --check` passes and no private Pi runtime path is tracked.
