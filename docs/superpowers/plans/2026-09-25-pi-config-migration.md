# Pi configuration migration implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move reusable Pi configuration into a safe Stow module while retaining private provider and runtime data as local Pi state.

**Architecture:** The `pi` module owns only durable, non-sensitive files under `~/.pi/agent`. `settings.json` is the package and preference source of truth. `setup.sh` creates real target directories and removes only known legacy entries, so Stow creates per-file links and Pi continues to write private state outside the repository.

**Tech Stack:** Bash, GNU Stow 2.4.1, npm, Pi CLI, JSON, Python 3 for portable JSON assertions in the test script.

**Spec:** `docs/superpowers/specs/2026-09-25-pi-config-migration-design.md`

## Global constraints

- Do not add provider aliases, endpoint URLs, model IDs, credential names, tokens, authentication data, sessions, mission data, or cached model data to tracked files.
- `~/.pi/agent/models.json` remains a local real file. Setup must not create, modify, copy, compare, or link it.
- Do not stow `~/.pi` or `~/.pi/agent` as a whole-directory symlink. All commands use `stow --no-folding`.
- `install.sh` installs dependencies only. It must not call Stow or modify the user configuration.
- `setup.sh` is safe to rerun. It may remove only the named retired links and files that byte-match their tracked replacement.
- Keep all existing unrelated modifications in `zsh/.env.template` and `zsh/.zshenv` out of commits.
- Every new configuration file starts with a comment that states its symlink path where that format permits comments. JSON cannot contain comments.

## Review focus

- A pre-existing `~/.pi/agent/models.json` must survive setup byte-for-byte and remain a normal file, not a repository symlink. Task 2 fixture covers this.
- A modified local agent or RTK configuration must make setup stop before deleting it. Task 2 fixture covers this.
- A real file at a retired prompt or `mash` path must not be deleted. Task 2 fixture covers this.
- The model example must not be deployed into `~/.pi/agent/`. Task 1 Stow simulation covers this.
- A fresh target directory must not be tree-folded into a repository symlink. Task 2 fixture verifies real target directories before Stow and per-file links afterward.

---

### Task 1: Add the tracked Pi resources

**Files:**
- Create: `pi/.stow-local-ignore`
- Create: `pi/.pi/agent/settings.json`
- Create: `pi/.pi/agent/models.json.example`
- Create: `pi/.pi/agent/agents/planner.md`
- Create: `pi/.pi/agent/agents/reviewer.md`
- Create: `pi/.pi/agent/agents/scout.md`
- Create: `pi/.pi/agent/agents/worker.md`
- Create: `pi/.pi/agent/extensions/pi-rtk-optimizer/config.json`
- Create: `pi/test/stow-layout.sh`

**Interfaces:**
- Consumes: Current local files under `~/.pi/agent/` as the migration source.
- Produces: A Stow package whose resources resolve under `~/.pi/agent/`; Task 2 compares these source files with local state.

- [ ] **Step 1: Create the Stow layout test**

Create `pi/test/stow-layout.sh` with a temporary Stow target. It must use the repository root derived from the script location and clean its temporary directory with `trap`.

```bash
#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
target="$(mktemp -d)"
trap 'rm -rf "$target"' EXIT

mkdir -p "$target/.pi/agent/agents" "$target/.pi/agent/extensions/pi-rtk-optimizer"
stow --simulate --no-folding --dir "$repo_root" --target "$target" pi
stow --no-folding --dir "$repo_root" --target "$target" pi

test -L "$target/.pi/agent/settings.json"
test -L "$target/.pi/agent/agents/planner.md"
test -L "$target/.pi/agent/extensions/pi-rtk-optimizer/config.json"
test ! -e "$target/.pi/agent/models.json.example"
```

- [ ] **Step 2: Run the layout test to verify it fails**

Run: `bash pi/test/stow-layout.sh`

Expected: FAIL because the `pi` module does not exist yet.

- [ ] **Step 3: Add the Stow ignore rules and static resources**

Create `pi/.stow-local-ignore` so it replaces the global ignore list without accidentally deploying module documentation, scripts, tests, or the model example:

```text
^/README\.md$
^/install\.sh$
^/setup\.sh$
^/test(?:/|$)
^/\.pi/agent/models\.json\.example$
```

Copy the four existing local agent definitions unchanged into `pi/.pi/agent/agents/`. Copy the current RTK optimizer `config.json` unchanged into `pi/.pi/agent/extensions/pi-rtk-optimizer/`.

Create `pi/.pi/agent/settings.json` from the current settings with these exact changes:

- remove `lastChangelogVersion` because Pi owns that mutable update marker;
- remove the missing local `ai-workflow` package declaration;
- retain the nine public npm or Git package declarations;
- retain `theme`, `tuiMode`, `compaction.enabled`, and `hideThinkingBlock`.

Create `pi/.pi/agent/models.json.example` as valid JSON with one `providers.example` configuration. Use only these generic placeholder values:

```json
{
  "providers": {
    "example": {
      "baseUrl": "https://example.invalid/v1",
      "api": "openai-completions",
      "apiKey": "$PI_PROVIDER_API_KEY",
      "models": [
        {
          "id": "replace-with-approved-model-id",
          "name": "Replace with approved model name"
        }
      ]
    }
  }
}
```

Do not copy any value from the local `models.json`.

- [ ] **Step 4: Run static checks and the layout test**

Run:

```bash
python3 -m json.tool pi/.pi/agent/settings.json >/dev/null
python3 -m json.tool pi/.pi/agent/models.json.example >/dev/null
bash pi/test/stow-layout.sh
```

Expected: all commands exit 0. The test proves that Stow links the three managed file classes and excludes the model example.

- [ ] **Step 5: Commit the static module resources**

```bash
git add pi/.stow-local-ignore pi/.pi pi/test/stow-layout.sh
git commit -m "feat: add tracked Pi resources"
```

### Task 2: Add safe one-time migration setup

**Files:**
- Create: `pi/setup.sh`
- Create: `pi/test/setup.sh`

**Interfaces:**
- Consumes: `$HOME/.pi/agent/`, the static source files from Task 1, and an optional old `settings.json`.
- Produces: Real target directories, a backup named `settings.json.pre-pi-module`, and target paths ready for `stow --no-folding pi`.

- [ ] **Step 1: Create the setup fixture test**

Create `pi/test/setup.sh`. Use a temporary `HOME`, seed a local `models.json` with a unique marker, copy the source `settings.json`, agent, and RTK files into the fixture, and create the four retired entries as symbolic links. Run the real script with `HOME="$home" bash "$repo_root/pi/setup.sh"`.

The assertions must include:

```bash
test -f "$home/.pi/agent/models.json"
grep -qx 'local-model-marker' "$home/.pi/agent/models.json"
test ! -e "$home/.pi/agent/prompts/feature.md" && test ! -L "$home/.pi/agent/prompts/feature.md"
test ! -e "$home/.pi/agent/prompts/implement.md" && test ! -L "$home/.pi/agent/prompts/implement.md"
test ! -e "$home/.pi/agent/prompts/scout-and-plan.md" && test ! -L "$home/.pi/agent/prompts/scout-and-plan.md"
test ! -e "$home/.pi/agent/prompts/implement-and-review.md" && test ! -L "$home/.pi/agent/prompts/implement-and-review.md"
test ! -e "$home/.pi/agent/extensions/mash" && test ! -L "$home/.pi/agent/extensions/mash"
test -f "$home/.pi/agent/settings.json.pre-pi-module"
test ! -e "$home/.pi/agent/settings.json"
test ! -e "$home/.pi/agent/agents/planner.md"
test ! -e "$home/.pi/agent/extensions/pi-rtk-optimizer/config.json"
```

Then rerun setup to prove it is idempotent. Add a second fixture with a changed `planner.md`; assert that setup exits nonzero and leaves that file in place. Add a third fixture with a real `prompts/implement.md`; assert setup exits nonzero and leaves it in place.

- [ ] **Step 2: Run the setup test to verify it fails**

Run: `bash pi/test/setup.sh`

Expected: FAIL because `pi/setup.sh` does not exist.

- [ ] **Step 3: Implement `pi/setup.sh`**

Start the script with:

```bash
#!/bin/bash
# pi/setup.sh
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/common.sh"
agent_dir="$HOME/.pi/agent"
source_agent_dir="$script_dir/.pi/agent"
```

Implement these small functions:

```bash
require_real_dir() {
    local dir="$1"
    if [[ -L "$dir" ]]; then
        print_error "$dir is a symlink; run stow -D pi before setup"
        exit 1
    fi
    mkdir -p "$dir"
}

remove_retired_link() {
    local path="$1"
    [[ ! -e "$path" && ! -L "$path" ]] && return
    if [[ ! -L "$path" ]]; then
        print_error "$path is not a symlink; refusing to remove it"
        exit 1
    fi
    rm "$path"
}

remove_matching_file() {
    local source="$1"
    local target="$2"
    [[ ! -e "$target" && ! -L "$target" ]] && return
    if [[ -L "$target" ]]; then
        print_error "$target is already a symlink; run stow -D pi before setup"
        exit 1
    fi
    if ! cmp -s "$source" "$target"; then
        print_error "$target differs from $source; refusing to remove it"
        exit 1
    fi
    rm "$target"
}
```

Call `require_real_dir` for `~/.pi`, the agent directory, `agents`, `extensions`, `extensions/pi-rtk-optimizer`, and `prompts`.

If `settings.json` exists, it must be a regular file. Abort if `settings.json.pre-pi-module` already exists. Move it to that backup path. Do not inspect or touch `models.json`.

Call `remove_retired_link` for these exact paths:

```text
~/.pi/agent/prompts/feature.md
~/.pi/agent/prompts/implement.md
~/.pi/agent/prompts/scout-and-plan.md
~/.pi/agent/prompts/implement-and-review.md
~/.pi/agent/extensions/mash
```

Call `remove_matching_file` for each tracked agent source and its target, plus the RTK optimizer config source and target. End with the exact next command:

```text
Run: stow --no-folding pi
```

The script must not call `stow`, `pi`, `npm`, or modify paths other than the named migration targets.

- [ ] **Step 4: Run the setup test and shell checks**

Run:

```bash
bash -n pi/setup.sh pi/test/setup.sh
bash pi/test/setup.sh
```

Expected: both commands exit 0.

- [ ] **Step 5: Commit the safe migration setup**

```bash
git add pi/setup.sh pi/test/setup.sh
git commit -m "feat: add safe Pi migration setup"
```

### Task 3: Add installation and user documentation

**Files:**
- Create: `pi/install.sh`
- Create: `pi/README.md`

**Interfaces:**
- Consumes: Node and npm on `PATH`; setup output from Task 2.
- Produces: An installed Pi CLI and documented commands to apply, refresh, configure, and remove the module.

- [ ] **Step 1: Write the installation script**

Create `pi/install.sh` following the `claude/install.sh` structure. It must source `../scripts/common.sh`, check `command_exists npm`, and exit with `print_error` if npm is unavailable. If `pi` already exists, print its installed version and return without changing it. Otherwise run:

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Do not use `pi install`, `pi update`, or Stow in this script.

- [ ] **Step 2: Write the README**

Document these sections:

1. Purpose and Stow layout, including which tracked resources Pi receives.
2. Private local state. State that `models.json`, credentials, sessions, trust data, caches, and package installations remain outside Git.
3. First install, with these commands in order:

   ```bash
   ./install.sh pi
   ./pi/setup.sh
   stow --no-folding pi
   pi update --extensions
   ```

4. Model setup. Copy `pi/.pi/agent/models.json.example` to `~/.pi/agent/models.json`, then fill it from the approved internal source. Do not put provider details in this repository.
5. Updating managed files with `stow -R --no-folding pi` and refreshing package code with `pi update --extensions`.
6. Uninstallation:

   ```bash
   stow -D pi
   npm uninstall -g @earendil-works/pi-coding-agent
   rm -rf ~/.pi/agent/npm
   ```

   State that the last two commands are optional and that removing `~/.pi/agent/npm` removes installed package code but not private sessions, authentication, or models.

- [ ] **Step 3: Run script and documentation checks**

Run:

```bash
bash -n pi/install.sh pi/setup.sh
rg -n 'Uninstall|models\.json|stow --no-folding|pi update --extensions' pi/README.md
./install.sh --list | rg '^  .*pi'
```

Expected: scripts parse, README contains all required lifecycle commands, and the root installer discovers the `pi` module.

- [ ] **Step 4: Commit the install and documentation surface**

```bash
git add pi/install.sh pi/README.md
git commit -m "docs: add Pi module setup"
```

### Task 4: Apply the migration and verify the real Pi configuration

**Files:**
- Modify: `~/.pi/agent/` local state only, through `pi/setup.sh` and GNU Stow.

**Interfaces:**
- Consumes: The committed module from Tasks 1-3 and the current local Pi state.
- Produces: Per-file Stow links for managed resources and preserved local model/runtime state.

- [ ] **Step 1: Record the pre-migration private model file identity**

Run:

```bash
shasum -a 256 ~/.pi/agent/models.json
stat -f '%HT %N' ~/.pi/agent/models.json
```

Record the hash and confirm the type is `Regular File`. Do not print file contents.

- [ ] **Step 2: Run the safe setup and Stow simulation**

Run:

```bash
./pi/setup.sh
stow --simulate --verbose --no-folding pi
```

Expected: setup reports the settings backup and removal of only the named retired links and matching managed files. The Stow simulation reports only Pi module links.

- [ ] **Step 3: Apply Stow and reconcile packages**

Run:

```bash
stow --no-folding pi
pi update --extensions
```

Expected: Stow succeeds and Pi refreshes package installations from the tracked settings file.

- [ ] **Step 4: Verify target ownership and retained private state**

Run:

```bash
test -L ~/.pi/agent/settings.json
test -L ~/.pi/agent/agents/planner.md
test -L ~/.pi/agent/extensions/pi-rtk-optimizer/config.json
test ! -e ~/.pi/agent/prompts/feature.md && test ! -L ~/.pi/agent/prompts/feature.md
test ! -e ~/.pi/agent/prompts/implement.md && test ! -L ~/.pi/agent/prompts/implement.md
test ! -e ~/.pi/agent/prompts/scout-and-plan.md && test ! -L ~/.pi/agent/prompts/scout-and-plan.md
test ! -e ~/.pi/agent/prompts/implement-and-review.md && test ! -L ~/.pi/agent/prompts/implement-and-review.md
test ! -e ~/.pi/agent/extensions/mash && test ! -L ~/.pi/agent/extensions/mash
shasum -a 256 ~/.pi/agent/models.json
stat -f '%HT %N' ~/.pi/agent/models.json
pi list
```

Expected: all managed files are links, all retired links are absent, the model hash matches Step 1, the model file remains a regular file, and Pi lists the package configuration without errors.

- [ ] **Step 5: Verify the repository contains no private runtime state**

Run:

```bash
if git ls-files pi | rg '(^|/)(auth\.json|models\.json|models-store\.json|sessions|missions|npm|git)(/|$)'; then
  exit 1
fi
git diff --check
git status --short
```

Expected: the tracked-file scan has no matches, whitespace validation exits 0, and only intended Pi module files are staged or modified alongside the pre-existing unrelated Zsh changes.

- [ ] **Step 6: Commit the final module state**

```bash
git add pi
git commit -m "feat: migrate Pi configuration"
```
