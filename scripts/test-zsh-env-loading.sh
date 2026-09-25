#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

copy_config() {
    local home="$1"

    mkdir -p "$home/configs" "$home/.cargo"
    : > "$home/.cargo/env"
    cp -R "$repo_root/zsh" "$home/configs/zsh"
}

empty_env_home="$temp_root/empty-env"
copy_config "$empty_env_home"
: > "$empty_env_home/configs/zsh/.env"
env -i HOME="$empty_env_home" PATH="$PATH" zsh -dfc '
    source "$HOME/configs/zsh/.zshenv"
    [[ -z ${ELASTIC_READ_ONLY+x} ]]
'

configured_home="$temp_root/configured-env"
copy_config "$configured_home"
env -i HOME="$configured_home" PATH="$PATH" zsh -dfc '
    source "$HOME/configs/zsh/.zshenv"
    [[ -n ${ELASTIC_READ_ONLY+x} ]]
'
