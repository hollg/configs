# Configs

This is a portable and opinionated config for a terminal-based development environment. It defines configs for all relevant tools within one git repository and uses GNU Stow to manage symlinks between each config and the filesystem location where it's required.

## Tools

- **zsh** - Shell configuration with oh-my-zsh, plugins, and useful aliases
- **fonts** - Nerd Fonts installation for optimal terminal display
- **ghostty** - GPU-accelerated terminal emulator configuration
- **iterm2** - Terminal emulator with Catppuccin themes and configuration management
- **tmux** - Terminal multiplexer with plugins, theming, and session persistence
- **nvim** - Neovim configuration with LSP, plugins, and AI integration
- **opencode** - AI coding assistant configuration
- **npm** - Node.js package manager configuration
- **go** - Go programming language toolchain
- **zoxide** - Smarter `cd`

## Dependencies

- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink manager
- [Homebrew](https://brew.sh/) - Package manager for macOS
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter `cd` command replacement
- [oh-my-zsh](https://ohmyz.sh/) - Framework for managing zsh configuration
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme with customizable prompt
- [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) - Nerd Font optimized for Powerlevel10k
- [Go](https://golang.org/) - Programming language and toolchain

## Quick Start

1. **Install all dependencies:**
   ```bash
   ./install.sh
   ```

2. **Configure secrets (if needed):**
   ```bash
   # Copy the environment template and add your actual values
   cp zsh/.env.template zsh/.env
   vim zsh/.env
   ```

3. **Apply configurations for specific tools:**
   ```bash
    stow zsh        # Apply zsh configuration
    stow iterm2     # Apply iTerm2 configuration
    stow tmux       # Apply tmux configuration
    stow go         # Apply Go configuration
    stow nvim       # Apply nvim configuration
    stow opencode   # Apply opencode configuration
    stow npm        # Apply npm configuration
    stow ghostty    # Apply ghostty configuration```
3. **Restart your terminal or reload your shell:**
   ```bash
   source ~/.zshrc
   ```
   
   After reloading, you'll have access to zoxide's `z` command for smarter navigation:
   ```bash
   z Documents    # Jump to ~/Documents
   z proj         # Jump to any directory containing "proj"
   zi             # Interactive directory selection
   ```

4. **Configure Powerlevel10k (first time only):**
   When you first open a terminal after stowing, Powerlevel10k will automatically run its configuration wizard. The config will be saved directly to your repo via the symlink. After completing the wizard:
   ```bash
   # Commit the generated config so other machines get your customized prompt
   git add zsh/.p10k.zsh
   git commit -m "Add Powerlevel10k configuration"
   ```

5. **Configure your terminal font:**
   For optimal display of icons and symbols, configure your terminal to use the installed Nerd Font:
   - **iTerm2**: Preferences → Profiles → Text → Font → "MesloLGS NF"
   - **Terminal.app**: Preferences → Profiles → Text → Font → "MesloLGS NF"
   - **VS Code**: Add `"terminal.integrated.fontFamily": "MesloLGS NF"` to settings.json

## Project Structure

Each tool has its own directory containing:
- Configuration files that will be symlinked to appropriate locations
- A README with tool-specific setup instructions
- Any additional assets or scripts needed for that tool

```
configs/
├── .github/
│   └── instructions/
│       └── configs.md
├── .mcphub/
│   └── servers.json
├── fonts/
│   ├── install.sh
│   └── README.md
├── ghostty/
│   ├── .config/
│   │   └── ghostty/
│   │       └── config
│   └── install.sh
├── go/
│   ├── install.sh
│   └── README.md
├── iterm2/
│   ├── colors/
│   │   ├── catppuccin-frappe.itermcolors
│   │   ├── catppuccin-latte.itermcolors
│   │   ├── catppuccin-macchiato.itermcolors
│   │   └── catppuccin-mocha.itermcolors
│   ├── com.googlecode.iterm2.plist
│   ├── install.sh
│   └── README.md
├── npm/
│   ├── .npmrc
│   └── README.md
├── nvim/
│   ├── .config/
│   │   ├── mcphub/
│   │   │   └── servers.json
│   │   └── nvim/
│   │       ├── lua/
│   │       │   ├── plugins/
│   │       │   │   ├── lsp/
│   │       │   │   │   ├── blink.lua
│   │       │   │   │   ├── conform.lua
│   │       │   │   │   ├── init.lua
│   │       │   │   │   └── lazydev.lua
│   │       │   │   ├── autopairs.lua
│   │       │   │   ├── codecompanion.lua
│   │       │   │   ├── dashboard.lua
│   │       │   │   ├── debug.lua
│   │       │   │   ├── diagnostic.lua
│   │       │   │   ├── finder.lua
│   │       │   │   ├── gitsigns.lua
│   │       │   │   ├── guess_indent.lua
│   │       │   │   ├── health.lua
│   │       │   │   ├── indent_line.lua
│   │       │   │   ├── lint.lua
│   │       │   │   ├── lualine.lua
│   │       │   │   ├── mini.lua
│   │       │   │   ├── neo-tree.lua
│   │       │   │   ├── noice.lua
│   │       │   │   ├── theme.lua
│   │       │   │   ├── tmux_navigation.lua
│   │       │   │   ├── todo_comments.lua
│   │       │   │   ├── toggleterm.lua
│   │       │   │   ├── treesitter.lua
│   │       │   │   ├── vim-tpipeline.lua
│   │       │   │   └── which_key.lua
│   │       │   └── basics.lua
│   │       ├── init.lua
│   │       └── lazy-lock.json
│   ├── install.sh
│   └── README.md
├── opencode/
│   ├── .config/
│   │   └── opencode/
│   │       ├── instructions/
│   │       │   └── vibecode.md
│   │       └── opencode.json
│   ├── install.sh
│   └── README.md
├── scripts/
│   └── common.sh
├── tmux/
│   ├── .config/
│   │   └── tmux/
│   │       └── tmux.conf
│   ├── install.sh
│   └── README.md
├── zsh/
│   ├── .env.template
│   ├── .p10k.zsh
│   ├── .zprofile
│   ├── .zshenv
│   ├── .zshrc
│   ├── install.sh
│   └── README.md
├── .gitignore
├── .stowrc
├── install.sh
└── README.md
```

## Installation Options

The install script supports both full installation and selective module installation:

```bash
# Install all modules (default)
./install.sh

# Install specific modules only
./install.sh zsh fonts
./install.sh zsh iterm2 tmux
./install.sh tmux

# List available modules
./install.sh --list

# Show help
./install.sh --help
```

## Usage

After running `./install.sh`, you can use GNU Stow to manage individual configurations:

```bash
# Apply tmux configuration
stow tmux

# Remove tmux configuration
stow -D tmux

# Re-apply tmux configuration (useful after updates)
stow -R tmux
```

## Uninstallation

To remove configurations and restore your system to its previous state:

### Quick Removal
Remove symlinks for specific modules:
```bash
# Remove specific module configurations
stow -D zsh
stow -D iterm2
stow -D tmux
stow -D fonts
stow -D go
stow -D nvim
stow -D opencode
stow -D npm
stow -D ghostty

# Verify no symlinks remain
ls -la ~/ | grep " -> .*configs"
```

### Complete Removal
For complete removal of all modules:

```bash
# Remove all active stow configurations
for module in zsh iterm2 tmux fonts go nvim opencode npm ghostty; do
    stow -D "$module" 2>/dev/null || true
done
```

### Module-Specific Uninstallation
For detailed uninstallation instructions including dependency removal:
- **Zsh**: See `zsh/README.md` for complete oh-my-zsh and plugin removal
- **iTerm2**: See `iterm2/README.md` for app removal and preference cleanup
- **tmux**: See `tmux/README.md` for tmux and TPM plugin removal
- **Fonts**: See `fonts/README.md` for font uninstallation and terminal reconfiguration
- **Go**: See `go/README.md` for Go toolchain uninstallation
- **Nvim**: See `nvim/README.md` for Neovim and plugin removal
- **Opencode**: See `opencode/README.md` for opencode configuration removal
- **Npm**: See `npm/README.md` for npm configuration removal
- **Ghostty**: See `ghostty/README.md` for ghostty configuration removal

**Warning**: Complete uninstallation will remove customizations and restore system defaults. Each module's README contains specific instructions for safely removing dependencies.
