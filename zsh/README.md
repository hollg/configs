# Zsh Configuration

This directory contains configuration files for zsh with oh-my-zsh.

## Files

- `.zshrc` - Main zsh configuration file with oh-my-zsh setup, plugins, aliases, and functions
- `.zshenv` - Environment variables available to all zsh sessions
- `.zprofile` - Configuration for login shells, including development tool initialization
- `.p10k.zsh` - Powerlevel10k theme configuration
- `.env.template` - Template for environment variables (tracked in git)
- `.env` - Actual environment variables with secrets (not tracked in git)
- `install.sh` - Installs zsh-specific dependencies

## Prerequisites

Before using this configuration, ensure you have:

1. **Homebrew** - Package manager for macOS
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **oh-my-zsh** - Framework for managing zsh configuration
   ```bash
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

3. **Powerlevel10k** theme
   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
   ```

4. **zsh-autosuggestions** plugin
   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   ```

5. **zsh-syntax-highlighting** plugin
   ```bash
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   ```

## Installation

1. **Install dependencies** (automatically handled by root install script):
   ```bash
   # From the root of the configs repo
   ./install.sh zsh
   ```

2. **Apply configuration with Stow**:
   ```bash
   stow zsh
   ```

3. **Configure Powerlevel10k** (first time only):
   When you first open a terminal, Powerlevel10k will automatically run its configuration wizard. The config will be saved directly to your repo via the symlink:
   ```bash
   # After completing the wizard, just commit the changes
   git add .p10k.zsh
   git commit -m "Add Powerlevel10k configuration"
   ```

This will create symlinks in your home directory:
- `~/.zshrc` → `configs/zsh/.zshrc`
- `~/.zshenv` → `configs/zsh/.zshenv`
- `~/.zprofile` → `configs/zsh/.zprofile`
- `~/.p10k.zsh` → `configs/zsh/.p10k.zsh`

## Features

- **oh-my-zsh** framework with useful plugins
- **Powerlevel10k** theme for a beautiful and informative prompt
- **Auto-suggestions** and **syntax highlighting**
- Convenient aliases for common commands
- Custom `proj` function for quick project navigation
- Enhanced history management
- Case-insensitive tab completion
- Support for various development tools (Node.js, Python, Ruby, Docker, etc.)

## Customization

Create a `~/.zshrc.local` file for any local customizations that shouldn't be version controlled.

## Uninstallation

To completely remove the zsh configuration:

1. **Remove symlinks**:
   ```bash
   stow -D zsh
   ```

2. **Remove oh-my-zsh and plugins** (optional - only if you don't want them for other configs):
   ```bash
   rm -rf ~/.oh-my-zsh
   ```

3. **Reset to system default zsh**:
   ```bash
   # Remove any remaining zsh config files
   rm -f ~/.zshrc ~/.zshenv ~/.zprofile ~/.p10k.zsh ~/.zshrc.local
   
   # Your shell will now use system defaults
   ```

**Note**: This will restore your shell to the macOS default zsh configuration.
