#!/bin/bash

# agents/install.sh - Global AGENTS.md module (no dependencies)

set -e

# Source common functions
source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing agents (global AGENTS.md) module..."

main() {
    print_success "No dependencies to install for the agents module."
    echo
    echo "📝 To apply the global agent instructions:"
    echo "  Run: stow agents      # symlinks AGENTS.md → ~/AGENTS.md"
    echo
    echo "  Claude Code picks these up via ~/.claude/CLAUDE.md, which imports"
    echo "  ~/AGENTS.md. Apply that with: stow claude"
    echo
    echo "🧹 To uninstall:"
    echo "  Run: stow -D agents"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
