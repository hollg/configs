# pi

Reusable [Pi](https://github.com/badlogic/pi-mono) preferences, agent definitions, and extension configuration.

## Layout

The module mirrors Pi's user agent directory:

```text
pi/.pi/agent/
├── agents/                              → ~/.pi/agent/agents/
├── extensions/pi-rtk-optimizer/config.json
│                                         → ~/.pi/agent/extensions/pi-rtk-optimizer/config.json
└── settings.json                        → ~/.pi/agent/settings.json
```

`settings.json` declares Pi's public packages, Catppuccin Mocha theme, and interface preferences. `models.json.example` stays in the repository as a reference but Stow does not deploy it.

## Private local state

Pi keeps provider models, credentials, sessions, trust data, caches, and package installations local. This module does not manage or read them.

Keep these paths outside Git:

- `~/.pi/agent/models.json`
- `~/.pi/agent/auth.json`
- `~/.pi/agent/trust.json`
- `~/.pi/agent/models-store.json`
- `~/.pi/agent/sessions/`
- `~/.pi/agent/missions/`
- `~/.pi/agent/npm/`
- `~/.pi/agent/git/`

## Install and apply

From the repository root, run:

```bash
./install.sh pi
./pi/setup.sh
stow --no-folding pi
pi update --extensions
```

`setup.sh` backs up the existing `settings.json`, removes only the retired Pi links, and verifies matching managed files before Stow replaces them. It does not modify models, credentials, sessions, or package code. After Stow applies the module, rerunning `setup.sh` reports that the module is already applied.

## Worktrees

Run Stow from the durable repository checkout, not a disposable Git worktree. Stow links point at the checkout that runs the command.

If you apply the module from a worktree, merge its branch first. Then, from the durable checkout, run:

```bash
stow -R --no-folding pi
```

Remove the worktree only after that command completes.

## Configure models

Copy the generic example, then fill it from the approved internal source:

```bash
cp pi/.pi/agent/models.json.example ~/.pi/agent/models.json
```

Do not add provider details to this repository.

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
