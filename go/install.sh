#!/bin/bash

# install.sh - Install Go toolchain

set -e

source "$(dirname "$0")/../scripts/common.sh"

print_status "Installing Go toolchain..."

if command_exists go; then
    print_success "Go already installed"
else
    print_status "Installing Go via Homebrew..."
    brew install go
    print_success "Go installed"
fi
