# pi

Reusable [Pi](https://github.com/badlogic/pi-mono) preferences, agent definitions, and extension configuration.

## Layout

The module mirrors Pi's user agent directory:

```text
pi/.pi/agent/
├── APPEND_SYSTEM.md                     → ~/.pi/agent/APPEND_SYSTEM.md
├── agents/                              → ~/.pi/agent/agents/
├── extensions/pi-rtk-optimizer/config.json
│                                         → ~/.pi/agent/extensions/pi-rtk-optimizer/config.json
├── models.json                          → ~/.pi/agent/models.json
├── models.json.example                  reference only
├── model-aliases.json.example           reference only
└── settings.json                        → ~/.pi/agent/settings.json
```

`APPEND_SYSTEM.md` adds Pi-only system instructions. `settings.json` declares Pi's public packages, Catppuccin Mocha theme, and interface preferences. `models.json` is a local, Git-ignored source file. `models.json.example` stays in the repository as a reference but Stow does not deploy it.

## Private local state

Pi keeps credentials, sessions, trust data, caches, and package installations as real local state. The module manages the model configuration only as a Git-ignored local file.

These paths are Git-ignored if they exist in the module:

- `pi/.pi/agent/models.json`
- `pi/.pi/agent/auth.json`
- `pi/.pi/agent/trust.json`
- `pi/.pi/agent/models-store.json`
- `pi/.pi/agent/sessions/`
- `pi/.pi/agent/missions/`
- `pi/.pi/agent/npm/`
- `pi/.pi/agent/git/`

Do not create or Stow the non-model runtime paths.

## Install and apply

From the repository root, run:

```bash
./install.sh pi
./pi/setup.sh
stow --no-folding pi
pi update --extensions
```

`setup.sh` moves an existing `~/.pi/agent/models.json` into the ignored module source, backs up the existing `settings.json`, removes only the retired Pi links, and verifies matching managed files before Stow replaces them. It does not modify credentials, sessions, or package code. After Stow applies the module, rerunning `setup.sh` reports that the module is already applied.

## Worktrees

Run Stow from the durable repository checkout, not a disposable Git worktree. Stow links point at the checkout that runs the command.

If you apply the module from a worktree, merge its branch first. Then, from the durable checkout, run:

```bash
stow -R --no-folding pi
```

Remove the worktree only after that command completes.

## Configure models

Copy the generic example into the ignored local source, then fill it from the approved internal source:

```bash
cp pi/.pi/agent/models.json.example pi/.pi/agent/models.json
stow -R --no-folding pi
```

Do not add provider details to Git.

## Configure model aliases

The shared extension at `.pi/agent/extensions/pi-model-aliases` provides stable
aliases for the main session and named subagents. Configure the aliases per machine in the ignored `.pi/agent/model-aliases.json` file:

```bash
cp pi/.pi/agent/model-aliases.json.example pi/.pi/agent/model-aliases.json
```

Then replace the placeholder provider and model IDs with local values. The example file contains no provider details.

`aliasProvider` is a local stable name. It lets each machine map `primary` to a
different provider without putting provider details in Git. The source provider
and model IDs stay in the ignored local files.

The named agents use `fast`, `balanced`, and `powerful`, so their model choices
follow the local alias configuration.

## Update

Apply a changed module layout with:

```bash
stow -R --no-folding pi
```

Refresh installed package code with:

```bash
pi update --extensions
```

## Uninstall

Remove the Stow-managed links:

```bash
stow -D pi
```

The Pi CLI and package code stay installed. Remove them only if you no longer want Pi on this machine:

```bash
npm uninstall -g @earendil-works/pi-coding-agent
rm -rf ~/.pi/agent/npm
```

Removing `~/.pi/agent/npm` removes installed package code. It does not remove local models, authentication, sessions, or trust data.
