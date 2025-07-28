# Neovim Configuration

This module installs and configures Neovim with modern development features and essential dependencies.

## Installation

Run the install script to set up Neovim and its dependencies:

```bash
cd nvim
./install.sh
```

## What's Installed

- **Neovim** - Modern Vim-based text editor via Homebrew
- **ripgrep** - Fast file content searching (used by telescope, grep operations)
- **fd** - Fast file and directory finding (used by file pickers, fuzzy finding)
- **Configuration structure** - Ready for advanced Neovim configuration

## Dependencies

These tools are essential for modern Neovim workflows:

- **ripgrep (`rg`)** - Enables fast project-wide searching in plugins like Telescope
- **fd** - Provides fast file finding for fuzzy file pickers and navigation
- **Homebrew** - Package manager for installing all dependencies

## Usage

After installation:

```bash
# Symlink configuration files
stow nvim

# Start Neovim
nvim

# Test dependencies
rg "search term" .    # Search file contents
fd filename          # Find files by name
```

## Configuration

Configuration files will be managed in `~/.config/nvim/` when added to this module.

## Uninstallation

```bash
# Remove all installed tools
brew uninstall neovim ripgrep fd

# Remove configuration symlinks
stow -D nvim
```

## Planned Features

- LSP (Language Server Protocol) configuration
- Plugin management with lazy.nvim
- Treesitter for syntax highlighting
- Telescope integration (using ripgrep and fd)
- AI integration with Avante
- Modern keybindings and UI enhancements
