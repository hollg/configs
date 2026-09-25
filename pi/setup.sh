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

is_managed_link() {
    local source="$1"
    local target="$2"

    [[ -L "$target" && "$source" -ef "$target" ]]
}

public_module_is_stowed() {
    local agent

    is_managed_link "$source_agent_dir/settings.json" "$agent_dir/settings.json" || return 1
    for agent in planner reviewer scout worker; do
        is_managed_link "$source_agent_dir/agents/$agent.md" "$agent_dir/agents/$agent.md" || return 1
    done
    is_managed_link \
        "$source_agent_dir/extensions/pi-rtk-optimizer/config.json" \
        "$agent_dir/extensions/pi-rtk-optimizer/config.json"
}

module_is_stowed() {
    local source_model="$source_agent_dir/models.json"
    local target_model="$agent_dir/models.json"

    public_module_is_stowed || return 1
    [[ ! -e "$source_model" && ! -L "$source_model" ]] || is_managed_link "$source_model" "$target_model"
}

migrate_model_config() {
    local source_model="$source_agent_dir/models.json"
    local target_model="$agent_dir/models.json"

    if [[ -e "$source_model" || -L "$source_model" ]]; then
        if [[ -L "$source_model" || ! -f "$source_model" ]]; then
            print_error "$source_model is not a regular file; refusing to replace it"
            exit 1
        fi
        if [[ -e "$target_model" || -L "$target_model" ]]; then
            if is_managed_link "$source_model" "$target_model"; then
                return
            fi
            print_error "$target_model already exists; refusing to overwrite it"
            exit 1
        fi
        return
    fi

    [[ ! -e "$target_model" && ! -L "$target_model" ]] && return
    if [[ -L "$target_model" || ! -f "$target_model" ]]; then
        print_error "$target_model is not a regular file; refusing to move it"
        exit 1
    fi

    mv "$target_model" "$source_model"
    print_success "Moved $target_model into the ignored Pi module source"
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

    migrate_model_config

    if module_is_stowed; then
        print_success "Pi module is already applied"
        return
    fi

    if public_module_is_stowed; then
        print_success "Pi model configuration is ready"
        echo "Run: stow -R --no-folding pi"
        return
    fi

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
