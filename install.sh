#!/bin/bash

# install.sh - Install all dependencies for the configs project

set -e

echo "🚀 Installing dependencies for configs project..."

# Source common functions
source "$(dirname "$0")/scripts/common.sh"

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [MODULES...]"
    echo
    echo "Install dependencies for the configs project."
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List available modules"
    echo "  -a, --all      Install all modules (default)"
    echo
    echo "Examples:"
    echo "  $0              # Install all modules"
    echo "  $0 --all        # Install all modules"
    echo "  $0 zsh          # Install only zsh module"
    echo "  $0 zsh nvim     # Install zsh and nvim modules"
    echo "  $0 --list       # List available modules"
}

# List available modules
list_modules() {
    echo "🔍 Available modules:"
    local modules=()
    local all_modules
    all_modules=$(get_modules)
    
    if [[ -z "$all_modules" ]]; then
        echo "  No modules found"
        return
    fi
    
    while IFS= read -r module; do
        modules+=("$module")
    done <<< "$all_modules"
    
    for module in "${modules[@]}"; do
        if module_has_install_script "$module"; then
            echo "  ✅ $module (has install script)"
        else
            echo "  ⚠️  $module (no install script)"
        fi
    done
}

# Install core dependencies (Homebrew, Stow, zoxide, and uv)
install_core_dependencies() {
    print_status "Installing core dependencies..."
    install_homebrew
    install_stow
    install_zoxide
    install_uv
}

# Install specific modules
install_modules() {
    local modules=("$@")
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        # Install all modules if none specified
        local all_modules
        all_modules=$(get_modules)
        if [[ -n "$all_modules" ]]; then
            while IFS= read -r module; do
                modules+=("$module")
            done <<< "$all_modules"
        fi
    fi
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        print_warning "No modules found to install"
        return
    fi
    
    print_status "Installing modules: ${modules[*]}"
    echo
    
    for module in "${modules[@]}"; do
        install_module "$module"
    done
}

# Main installation process
main() {
    local install_all=true
    local modules=()
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                list_modules
                exit 0
                ;;
            -a|--all)
                install_all=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                modules+=("$1")
                install_all=false
                shift
                ;;
        esac
    done
    
    echo "🔧 Starting installation process..."
    echo
    
    # Install core dependencies first
    install_core_dependencies
    echo
    
    # Install modules
    if [[ "$install_all" == true ]]; then
        install_modules
    else
        install_modules "${modules[@]}"
    fi
    
    echo
    print_success "Installation completed successfully!"
    echo
    echo "📝 Next steps:"
    echo "  1. Use 'stow <module>' to apply configurations"
    echo "  2. Restart your terminal or source relevant config files"
    echo
    list_modules
}

# Run main function
main "$@"
