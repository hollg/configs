#!/bin/bash

source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing Neovim module..."

# Check if Homebrew is available
check_homebrew() {
    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please install Homebrew first."
        print_status "Visit https://brew.sh for installation instructions"
        exit 1
    fi
}

# Install Neovim via Homebrew
install_neovim() {
    if command_exists nvim; then
        print_success "Neovim already installed"
        print_status "Version: $(nvim --version | head -n1)"
    else
        print_status "Installing Neovim via Homebrew..."
        brew install neovim
        print_success "Neovim installed"
    fi
}

# Install ripgrep (rg) for fast file searching
install_ripgrep() {
    if command_exists rg; then
        print_success "ripgrep already installed"
        print_status "Version: $(rg --version | head -n1)"
    else
        print_status "Installing ripgrep via Homebrew..."
        brew install ripgrep
        print_success "ripgrep installed"
    fi
}

# Install fd (fdfind) for fast file finding
install_fd() {
    if command_exists fd; then
        print_success "fd already installed"
        print_status "Version: $(fd --version)"
    else
        print_status "Installing fd via Homebrew..."
        brew install fd
        print_success "fd installed"
    fi
}

# Verify installation
verify_installation() {
    local failed=false
    
    if command_exists nvim; then
        print_success "Neovim installation verified"
        print_status "Version: $(nvim --version | head -n1)"
    else
        print_error "Neovim installation failed"
        failed=true
    fi
    
    if command_exists rg; then
        print_success "ripgrep installation verified"
        print_status "Version: $(rg --version | head -n1)"
    else
        print_error "ripgrep installation failed"
        failed=true
    fi
    
    if command_exists fd; then
        print_success "fd installation verified"
        print_status "Version: $(fd --version)"
    else
        print_error "fd installation failed"
        failed=true
    fi
    
    if [[ "$failed" == "true" ]]; then
        exit 1
    fi
}

# Main installation process
main() {
    echo "📝 Installing Neovim and dependencies..."
    
    check_homebrew
    install_neovim
    install_ripgrep
    install_fd
    verify_installation
    
    echo
    print_success "Neovim module installation completed!"
    echo
    print_status "Installed tools:"
    print_status "  • Neovim - Modern text editor"
    print_status "  • ripgrep - Fast file content searching"
    print_status "  • fd - Fast file and directory finding"
    echo
    print_status "Next steps:"
    print_status "  1. Run 'stow nvim' to symlink configuration files"
    print_status "  2. Start Neovim with 'nvim'"
    print_status "  3. Configuration will be managed in ~/.config/nvim/"
    echo
    print_status "To uninstall:"
    print_status "  brew uninstall neovim ripgrep fd"
}

# Run main function
main "$@"