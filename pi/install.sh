#!/bin/bash
# pi/install.sh

set -euo pipefail

source "$(dirname "$0")/../scripts/common.sh"

install_pi() {
    if ! command_exists npm; then
        print_error "npm is required to install Pi"
        exit 1
    fi

    if command_exists pi; then
        print_success "Pi already installed: $(pi --version)"
        return
    fi

    print_status "Installing Pi..."
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    print_success "Pi installed"
}

main() {
    install_pi
    echo
    print_success "Pi module dependencies are ready"
    echo "Run ./pi/setup.sh, then stow --no-folding pi"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
