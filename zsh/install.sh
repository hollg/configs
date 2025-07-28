#!/bin/bash

# ~/.config/zsh/install.sh - Install dependencies for zsh configuration

set -e

# Source common functions
source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing zsh module dependencies..."

# Install oh-my-zsh
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "oh-my-zsh already installed"
    else
        print_status "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "oh-my-zsh installed"
    fi
}

# Install zsh plugins
install_zsh_plugins() {
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [[ -d "$custom_dir/plugins/zsh-autosuggestions" ]]; then
        print_success "zsh-autosuggestions already installed"
    else
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    fi
    
    # zsh-syntax-highlighting
    if [[ -d "$custom_dir/plugins/zsh-syntax-highlighting" ]]; then
        print_success "zsh-syntax-highlighting already installed"
    else
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    fi
    
    # zsh-nvm
    if [[ -d "$custom_dir/plugins/zsh-nvm" ]]; then
        print_success "zsh-nvm already installed"
    else
        print_status "Installing zsh-nvm..."
        git clone https://github.com/lukechilds/zsh-nvm "$custom_dir/plugins/zsh-nvm"
        print_success "zsh-nvm installed"
    fi
    
    # Powerlevel10k theme
    if [[ -d "$custom_dir/themes/powerlevel10k" ]]; then
        print_success "Powerlevel10k already installed"
    else
        print_status "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
        print_success "Powerlevel10k installed"
    fi
}

# Main installation function for zsh module
main() {
    local script_dir="$(dirname "$0")"
    
    install_oh_my_zsh
    install_zsh_plugins
    
    # Check for environment variables setup
    if [[ ! -f "$script_dir/.env" ]]; then
        print_warning "Environment variables not configured"
        print_status "Copy .env.template to .env and configure your secrets:"
        echo "  cp $script_dir/.env.template $script_dir/.env"
        echo "  vim $script_dir/.env"
    fi
    
    print_success "zsh module dependencies installed successfully!"
    echo
    echo "📝 To apply zsh configuration:"
    echo "  1. Run: stow zsh"
    echo "  2. Restart your terminal or run: source ~/.zshrc"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
