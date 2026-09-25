#!/bin/bash
# pi/setup.sh

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/common.sh"
agent_dir="$HOME/.pi/agent"
source_agent_dir="$script_dir/.pi/agent"

require_real_dir() {
    local dir="$1"

    if [[ -L "$dir" ]]; then
        print_error "$dir is a symlink; run stow -D pi before setup"
        exit 1
    fi

    mkdir -p "$dir"
}

validate_retired_link() {
    local path="$1"

    [[ ! -e "$path" && ! -L "$path" ]] && return
    if [[ ! -L "$path" ]]; then
        print_error "$path is not a symlink; refusing to remove it"
        exit 1
    fi
}

remove_retired_link() {
    local path="$1"

    [[ ! -e "$path" && ! -L "$path" ]] && return
    rm "$path"
}

validate_matching_file() {
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
}

remove_matching_file() {
    local source="$1"
    local target="$2"

    [[ ! -e "$target" && ! -L "$target" ]] && return
    validate_matching_file "$source" "$target"
    rm "$target"
}

main() {
    local retired_links=(
        "$agent_dir/prompts/feature.md"
        "$agent_dir/prompts/implement.md"
        "$agent_dir/prompts/scout-and-plan.md"
        "$agent_dir/prompts/implement-and-review.md"
        "$agent_dir/extensions/mash"
    )
    local agent

    require_real_dir "$HOME/.pi"
    require_real_dir "$agent_dir"
    require_real_dir "$agent_dir/agents"
    require_real_dir "$agent_dir/extensions"
    require_real_dir "$agent_dir/extensions/pi-rtk-optimizer"
    require_real_dir "$agent_dir/prompts"

    if [[ -e "$agent_dir/settings.json" || -L "$agent_dir/settings.json" ]]; then
        if [[ -L "$agent_dir/settings.json" || ! -f "$agent_dir/settings.json" ]]; then
            print_error "$agent_dir/settings.json is not a regular file; refusing to move it"
            exit 1
        fi
        if [[ -e "$agent_dir/settings.json.pre-pi-module" || -L "$agent_dir/settings.json.pre-pi-module" ]]; then
            print_error "$agent_dir/settings.json.pre-pi-module already exists; refusing to overwrite it"
            exit 1
        fi
    fi

    for retired_link in "${retired_links[@]}"; do
        validate_retired_link "$retired_link"
    done
    for agent in planner reviewer scout worker; do
        validate_matching_file "$source_agent_dir/agents/$agent.md" "$agent_dir/agents/$agent.md"
    done
    validate_matching_file \
        "$source_agent_dir/extensions/pi-rtk-optimizer/config.json" \
        "$agent_dir/extensions/pi-rtk-optimizer/config.json"

    if [[ -e "$agent_dir/settings.json" ]]; then
        mv "$agent_dir/settings.json" "$agent_dir/settings.json.pre-pi-module"
        print_success "Backed up $agent_dir/settings.json"
    fi

    for retired_link in "${retired_links[@]}"; do
        remove_retired_link "$retired_link"
    done
    for agent in planner reviewer scout worker; do
        remove_matching_file "$source_agent_dir/agents/$agent.md" "$agent_dir/agents/$agent.md"
    done
    remove_matching_file \
        "$source_agent_dir/extensions/pi-rtk-optimizer/config.json" \
        "$agent_dir/extensions/pi-rtk-optimizer/config.json"

    print_success "Pi module target is ready"
    echo "Run: stow --no-folding pi"
}

main "$@"
