#!/bin/bash

# ~/.config/fonts/install.sh - Install fonts for terminal development environment

set -e

# Source common functions
source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing font dependencies..."

# Install fonts via Homebrew (cask)
install_nerd_fonts() {
    # Check if font-meslo-lg-nerd-font is already installed
    if brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
        print_success "MesloLGS Nerd Font already installed"
    else
        print_status "Installing MesloLGS Nerd Font (recommended for Powerlevel10k)..."
        brew install --cask font-meslo-lg-nerd-font
        print_success "MesloLGS Nerd Font installed"
    fi
}

# Main installation function for fonts module
main() {
    # Ensure Homebrew is available
    if ! command_exists brew; then
        print_error "Homebrew is required but not installed. Please run the main install script first."
        exit 1
    fi
    
    install_nerd_fonts
    
    print_success "Font module dependencies installed successfully!"
    echo
    echo "📝 Next steps:"
    echo "  1. Restart your terminal application"
    echo "  2. Configure your terminal to use 'MesloLGS NF' font"
    echo "  3. For iTerm2: Preferences → Profiles → Text → Font → MesloLGS NF"
    echo "  4. For Terminal.app: Terminal → Preferences → Profiles → Text → Font → MesloLGS NF"
    echo "  5. For VS Code terminal: Set 'terminal.integrated.fontFamily': 'MesloLGS NF'"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
