#!/bin/bash

# scripts/common.sh - Common functions and utilities for configs project

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if not present
install_homebrew() {
    if command_exists brew; then
        print_success "Homebrew already installed"
    else
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed"
    fi
}

# Install GNU Stow
install_stow() {
    if command_exists stow; then
        print_success "GNU Stow already installed"
    else
        print_status "Installing GNU Stow..."
        brew install stow
        print_success "GNU Stow installed"
    fi
}

# Install zoxide
install_zoxide() {
    if command_exists zoxide; then
        print_success "zoxide already installed"
    else
        print_status "Installing zoxide..."
        brew install zoxide
        print_success "zoxide installed"
    fi
}

# Install uv (Python package manager)
install_uv() {
    if command_exists uv; then
        print_success "uv already installed"
    else
        print_status "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        print_success "uv installed"
    fi
}

# Get list of available modules
get_modules() {
    local modules=()
    for dir in */; do
        if [[ -d "$dir" && "$dir" != ".github/" && "$dir" != "scripts/" ]]; then
            modules+=("${dir%/}")
        fi
    done
    printf '%s\n' "${modules[@]}"
}

# Check if a module has an install script
module_has_install_script() {
    local module="$1"
    [[ -f "$module/install.sh" ]]
}

# Run install script for a specific module
install_module() {
    local module="$1"
    
    if [[ ! -d "$module" ]]; then
        print_error "Module '$module' does not exist"
        return 1
    fi
    
    if module_has_install_script "$module"; then
        print_status "Installing $module module..."
        (cd "$module" && bash install.sh)
    else
        print_warning "Module '$module' has no install script, skipping..."
    fi
}
