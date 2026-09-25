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
