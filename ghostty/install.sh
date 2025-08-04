#!/bin/bash

source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing Ghostty module..."

# Check if Homebrew is available
check_homebrew() {
    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please install Homebrew first."
        print_status "Visit https://brew.sh for installation instructions"
        exit 1
    fi
}

# Install Ghostty via Homebrew
install_ghostty() {
    if command_exists ghostty; then
        print_success "Ghostty already installed"
        print_status "Version: $(ghostty --version 2>&1 | head -n1)"
    else
        print_status "Installing Ghostty via Homebrew..."
        brew install ghostty
        print_success "Ghostty installed"
    fi
}

# Verify installation
verify_installation() {
    if command_exists ghostty; then
        print_success "Ghostty installation verified"
        print_status "Version: $(ghostty --version 2>&1 | head -n1)"
    else
        print_error "Ghostty installation failed"
        exit 1
    fi
}

main() {
    echo "📝 Installing Ghostty..."
    check_homebrew
    install_ghostty
    verify_installation

    echo
    print_success "Ghostty module installation completed!"
    echo
    print_status "Next steps:"
    print_status "  1. Run 'stow ghostty' to symlink configuration files"
    print_status "  2. Start Ghostty with 'ghostty'"
    echo
    print_status "To uninstall:"
    print_status "  brew uninstall ghostty"
}

main "$@"
