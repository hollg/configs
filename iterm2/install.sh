#!/bin/bash

# iterm2/install.sh - Install iTerm2 via Homebrew

set -e

# Source common functions
source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing iTerm2 module dependencies..."

# Check if Homebrew is available
check_homebrew() {
    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please install Homebrew first."
        print_status "Visit https://brew.sh for installation instructions"
        exit 1
    fi
}

# Install iTerm2 via Homebrew cask
install_iterm2() {
    if brew list --cask iterm2 &>/dev/null; then
        print_success "iTerm2 already installed via Homebrew"
    else
        # Check if iTerm2 is installed manually in Applications
        if [[ -d "/Applications/iTerm.app" ]]; then
            print_warning "iTerm2 is already installed manually in /Applications/iTerm.app"
            print_status "Please remove the manual installation first:"
            print_status "  rm -rf '/Applications/iTerm.app'"
            print_status "  rm -rf ~/Library/Preferences/com.googlecode.iterm2.plist"
            print_status "  rm -rf ~/Library/Application\\ Support/iTerm2/"
            print_status "Then run this script again to install via Homebrew."
            exit 1
        fi
        
        print_status "Installing iTerm2 via Homebrew..."
        brew install --cask iterm2
        print_success "iTerm2 installed via Homebrew"
    fi
}

# Install color themes
install_themes() {
    local colors_dir="$(dirname "$0")/colors"
    
    if [[ ! -d "$colors_dir" ]]; then
        print_warning "No color themes found in $colors_dir"
        return
    fi
    
    print_status "Catppuccin color themes are available in: $colors_dir"
    print_status "These need to be imported manually through iTerm2 preferences"
    
    # List available themes
    for color_file in "$colors_dir"/*.itermcolors; do
        if [[ -f "$color_file" ]]; then
            local filename=$(basename "$color_file")
            print_success "Available theme: $filename"
        fi
    done
}

# Configure default theme (optional)
configure_default_theme() {
    print_status "Setting up default configuration..."
    print_status "You can manually import themes in iTerm2:"
    echo "  1. Open iTerm2 Preferences (⌘,)"
    echo "  2. Go to Profiles → Colors → Color Presets → Import"
    echo "  3. Select themes from: $(dirname "$0")/colors/"
    echo "  4. Choose your preferred Catppuccin variant"
}

# Verify installation
verify_installation() {
    if [[ -d "/Applications/iTerm.app" ]]; then
        print_success "iTerm2 installation verified"
    else
        print_error "iTerm2 installation failed"
        exit 1
    fi
}

# Main installation process
main() {
    echo "🖥️  Installing iTerm2..."
    
    check_homebrew
    install_iterm2
    install_themes
    verify_installation
    configure_default_theme
    
    echo
    print_success "iTerm2 module installation completed!"
    echo
    print_status "Next steps:"
    echo "  1. Run 'stow iterm2' from the configs root directory"
    echo "  2. Launch iTerm2 and import Catppuccin themes"
    echo "  3. Configure settings - changes auto-save to this repo!"
    echo "  4. Commit your configuration changes to git"
}

# Run main function
main "$@"
