#!/bin/bash

# claude/install.sh - Prepare ~/.claude for stowing global skills & agents

set -e

# Source common functions
source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing Claude (global skills & agents) module..."

# Pre-create the real target directories so `stow claude` links individual
# entries INTO them rather than folding (symlinking) the whole directory.
#
# This matters because ~/.claude/agents (and possibly ~/.claude/skills) may
# already contain files that are NOT managed by this repo. Forcing per-file
# linking lets stow-managed and unmanaged definitions coexist in the same
# directory without stow trying to adopt or overwrite the unmanaged ones.
prepare_claude_dirs() {
    for dir in "$HOME/.claude/skills" "$HOME/.claude/agents"; do
        if [[ -L "$dir" ]]; then
            print_warning "$dir is a symlink; leaving as-is (run 'stow -D claude' to reset)"
        elif [[ -d "$dir" ]]; then
            print_success "$dir already exists"
        else
            print_status "Creating $dir"
            mkdir -p "$dir"
            print_success "Created $dir"
        fi
    done
}

main() {
    prepare_claude_dirs

    echo
    print_success "Claude module ready!"
    echo
    echo "📝 To apply the global skills & agents:"
    echo "  1. Run: stow claude"
    echo "     (individual files are symlinked into ~/.claude/{skills,agents};"
    echo "      any pre-existing unmanaged files there are left untouched)"
    echo
    echo "🧹 To uninstall:"
    echo "  Run: stow -D claude"
    echo "  This removes only the symlinks this repo created. Unmanaged files"
    echo "  in ~/.claude/{skills,agents} are not affected. The now-empty"
    echo "  directories can be removed manually if desired."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
