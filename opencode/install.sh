#!/bin/bash

source "$(dirname "$0")/../scripts/common.sh"

OPENCODE_BREW="sst/tap/opencode"

print_status "Installing Opencode module..."

check_homebrew() {
    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please install Homebrew first."
        print_status "Visit https://brew.sh for installation instructions"
        exit 1
    fi
}

install_opencode() {
    if command_exists opencode; then
        print_success "Opencode already installed"
        print_status "Version: $(opencode --version 2>/dev/null || echo 'unknown')"
    else
        print_status "Installing Opencode via Homebrew..."
        brew install "$OPENCODE_BREW"
        print_success "Opencode installed"
    fi
}

uninstall_opencode() {
    print_status "Uninstalling Opencode via Homebrew..."
    brew uninstall "$OPENCODE_BREW"
    print_success "Opencode uninstalled"
}

update_opencode() {
    print_status "Upgrading Opencode via Homebrew..."
    brew upgrade "$OPENCODE_BREW"
    print_success "Opencode upgraded"
}

verify_installation() {
    if command_exists opencode; then
        print_success "Opencode installation verified"
        print_status "Version: $(opencode --version 2>/dev/null || echo 'unknown')"
    else
        print_error "Opencode installation failed"
        exit 1
    fi
}

main() {
    if [[ "$1" == "uninstall" ]]; then
        check_homebrew
        uninstall_opencode
    elif [[ "$1" == "update" ]]; then
        check_homebrew
        update_opencode
        verify_installation
    else
        check_homebrew
        install_opencode
        verify_installation
        echo
        print_success "Opencode module installation completed!"
        echo
        print_status "Installed tool:"
        print_status "  • Opencode - AI coding agent for the terminal"
        echo
        print_status "Next steps:"
        print_status "  1. Run 'stow opencode' to symlink configuration files (if any)"
        print_status "  2. Start Opencode with 'opencode'"
        print_status "  3. Configuration managed in ~/.opencode/"
        echo
        print_status "To uninstall:"
        print_status "  ./install.sh uninstall"
    fi
}

main "$@"

