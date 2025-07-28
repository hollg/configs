#!/bin/bash

# tmux/install.sh - Install tmux and plugins

set -e

# Source common functions
source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing tmux module dependencies..."

# Install tmux via Homebrew
install_tmux() {
    if command_exists tmux; then
        print_success "tmux already installed"
        print_status "Current version: $(tmux -V)"
    else
        print_status "Installing tmux via Homebrew..."
        brew install tmux
        print_success "tmux installed"
    fi
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    if [[ -d "$tpm_dir" ]]; then
        print_success "TPM (Tmux Plugin Manager) already installed"
    else
        print_status "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        print_success "TPM installed"
    fi
}

# Verify installation
verify_installation() {
    if command_exists tmux; then
        print_success "tmux installation verified"
        print_status "Version: $(tmux -V)"
    else
        print_error "tmux installation failed"
        exit 1
    fi
    
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_success "TPM installation verified"
    else
        print_error "TPM installation failed"
        exit 1
    fi
}

# Main installation process
main() {
    echo "🖥️  Installing tmux..."
    
    install_tmux
    install_tpm
    verify_installation
    
    echo
    print_success "tmux module installation completed!"
    echo
    print_status "Next steps:"
    echo "  1. Run 'stow tmux' from the configs root directory"
    echo "  2. Launch tmux and install plugins with: prefix + I"
    echo "  3. Configure tmux settings - changes auto-save to this repo!"
    echo "  4. Commit your configuration changes to git"
    echo
    print_status "Key bindings (with default config):"
    echo "  - prefix key: Ctrl-b (customizable)"
    echo "  - Install plugins: prefix + I"
    echo "  - Update plugins: prefix + U"
    echo "  - Uninstall plugins: prefix + alt + u"
}

# Run main function
main "$@"
