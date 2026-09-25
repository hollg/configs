#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

assert_absent() {
    local path="$1"

    if [[ -e "$path" || -L "$path" ]]; then
        echo "expected $path to be absent" >&2
        exit 1
    fi
}

prepare_fixture() {
    local home="$1"
    local agent_dir="$home/.pi/agent"

    mkdir -p "$agent_dir/agents" "$agent_dir/extensions/pi-rtk-optimizer" "$agent_dir/prompts"
    printf '%s\n' 'local-model-marker' > "$agent_dir/models.json"
    cp "$repo_root/pi/.pi/agent/settings.json" "$agent_dir/settings.json"
    cp "$repo_root/pi/.pi/agent/agents/"*.md "$agent_dir/agents/"
    mv "$agent_dir/agents/planner.md" "$agent_dir/planner-link-target.md"
    ln -s "$agent_dir/planner-link-target.md" "$agent_dir/agents/planner.md"
    cp "$repo_root/pi/.pi/agent/extensions/pi-rtk-optimizer/config.json" "$agent_dir/extensions/pi-rtk-optimizer/config.json"
    ln -s /missing-feature "$agent_dir/prompts/feature.md"
    ln -s /missing-implement "$agent_dir/prompts/implement.md"
    ln -s /missing-scout "$agent_dir/prompts/scout-and-plan.md"
    ln -s /missing-review "$agent_dir/prompts/implement-and-review.md"
    ln -s /missing-mash "$agent_dir/extensions/mash"
}

assert_migrated() {
    local home="$1"

    test -f "$home/.pi/agent/models.json"
    grep -qx 'local-model-marker' "$home/.pi/agent/models.json"
    assert_absent "$home/.pi/agent/prompts/feature.md"
    assert_absent "$home/.pi/agent/prompts/implement.md"
    assert_absent "$home/.pi/agent/prompts/scout-and-plan.md"
    assert_absent "$home/.pi/agent/prompts/implement-and-review.md"
    assert_absent "$home/.pi/agent/extensions/mash"
    test -f "$home/.pi/agent/settings.json.pre-pi-module"
    test ! -e "$home/.pi/agent/settings.json"
    test ! -e "$home/.pi/agent/agents/planner.md"
    test ! -e "$home/.pi/agent/extensions/pi-rtk-optimizer/config.json"
}

home="$temp_root/matching"
prepare_fixture "$home"
HOME="$home" bash "$repo_root/pi/setup.sh"
assert_migrated "$home"
stow --no-folding --dir "$repo_root" --target "$home" pi
HOME="$home" bash "$repo_root/pi/setup.sh"
test -f "$home/.pi/agent/models.json"
grep -qx 'local-model-marker' "$home/.pi/agent/models.json"
assert_absent "$home/.pi/agent/prompts/feature.md"
assert_absent "$home/.pi/agent/prompts/implement.md"
assert_absent "$home/.pi/agent/prompts/scout-and-plan.md"
assert_absent "$home/.pi/agent/prompts/implement-and-review.md"
assert_absent "$home/.pi/agent/extensions/mash"
test -f "$home/.pi/agent/settings.json.pre-pi-module"
test -L "$home/.pi/agent/settings.json"
test -L "$home/.pi/agent/agents/planner.md"
test -L "$home/.pi/agent/extensions/pi-rtk-optimizer/config.json"

modified_home="$temp_root/modified"
prepare_fixture "$modified_home"
printf '%s\n' 'modified locally' >> "$modified_home/.pi/agent/agents/planner.md"
if HOME="$modified_home" bash "$repo_root/pi/setup.sh" >"$temp_root/modified.log" 2>&1; then
    echo "setup accepted a modified agent definition" >&2
    exit 1
fi
test -f "$modified_home/.pi/agent/agents/planner.md"

real_prompt_home="$temp_root/real-prompt"
prepare_fixture "$real_prompt_home"
rm "$real_prompt_home/.pi/agent/prompts/implement.md"
printf '%s\n' 'do not delete' > "$real_prompt_home/.pi/agent/prompts/implement.md"
if HOME="$real_prompt_home" bash "$repo_root/pi/setup.sh" >"$temp_root/real-prompt.log" 2>&1; then
    echo "setup removed a real retired prompt" >&2
    exit 1
fi
test -f "$real_prompt_home/.pi/agent/prompts/implement.md"
