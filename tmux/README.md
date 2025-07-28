# tmux Configuration

This module installs and manages tmux (terminal multiplexer) with a comprehensive configuration, useful plugins, and Catppuccin theming.

## What's Included

- tmux terminal multiplexer installed via Homebrew
- TPM (Tmux Plugin Manager) for plugin management
- Comprehensive `.tmux.conf` with sensible defaults
- Catppuccin theme integration
- Session persistence with tmux-resurrect and tmux-continuum
- Enhanced copy/paste functionality

## Installation

Run the install script to set up tmux and TPM:

```bash
cd tmux
./install.sh
```

Or install as part of the full configs project:

```bash
# From the root of the configs project
./install.sh tmux
```

## Configuration Workflow

### Initial Setup
1. **Install tmux**: `./install.sh`
2. **Apply configuration**: `stow tmux` (from configs root)
3. **Start tmux**: `tmux`
4. **Install plugins**: `Ctrl-a + I` (prefix + I)

### Making Changes
1. **Edit settings** in tmux or modify `.tmux.conf`
2. **Reload config**: `Ctrl-a + r` (prefix + r)
3. **Auto-saved**: Changes are instantly reflected in this repo
4. **Commit to git** when you want to save a snapshot

### New Machine Setup
1. **Clone this repo**
2. **Install tmux**: `./install.sh tmux`
3. **Apply config**: `stow tmux`
4. **Start tmux and install plugins**: `tmux` then `Ctrl-a + I`
5. **Done!** All your settings and sessions are restored

## Key Features

### Enhanced Key Bindings
- **Prefix key**: `Ctrl-a` (instead of default `Ctrl-b`)
- **Split panes**: `prefix + |` (horizontal), `prefix + -` (vertical)
- **Navigate panes**: `Ctrl + h,j,k,l` (no prefix needed, consistent with Neovim)
- **Navigate panes (alt)**: `Alt + arrow keys` (alternative method)
- **Switch windows**: `Alt + 1-5` (no prefix needed)
- **Reload config**: `prefix + r`

### Session Management
- **Auto-save**: Sessions saved every 15 minutes
- **Auto-restore**: Sessions restored on tmux start
- **Persistence**: Sessions survive system restarts

### Visual Enhancements
- **256 colors**: Full color support
- **Catppuccin theme**: Beautiful, consistent theming
- **Mouse support**: Click to switch panes and windows
- **Activity monitoring**: Visual alerts for window activity

## Plugins

The configuration includes these essential plugins:

### Core Functionality
- **tmux-sensible**: Sensible default settings
- **tmux-yank**: Enhanced copy/paste with system clipboard integration

### Session Persistence
- **tmux-resurrect**: Save and restore tmux sessions
- **tmux-continuum**: Automatic session saving and restoring

### Theming
- **catppuccin/tmux**: Beautiful Catppuccin color scheme

## Plugin Management

### Install Plugins
```bash
# In tmux session
prefix + I  # Install new plugins
```

### Update Plugins
```bash
# In tmux session
prefix + U  # Update all plugins
```

### Remove Plugins
```bash
# In tmux session
prefix + alt + u  # Remove plugins not in config
```

## Common Commands

### Session Management
```bash
tmux                    # Start new session
tmux new -s work        # Start named session
tmux attach -t work     # Attach to session
tmux list-sessions      # List all sessions
tmux kill-session -t work  # Kill specific session
```

### Inside tmux (prefix = Ctrl-a)
```bash
prefix + |              # Split window horizontally
prefix + -              # Split window vertically
prefix + c              # Create new window
prefix + ,              # Rename current window
prefix + &              # Kill current window
prefix + x              # Kill current pane
prefix + z              # Toggle pane zoom
prefix + [              # Enter copy mode
prefix + ]              # Paste buffer
```

### Navigation (no prefix needed)
```bash
Ctrl + h,j,k,l          # Switch between panes (Neovim-consistent)
Alt + arrow keys        # Switch between panes (alternative)
Alt + 1-5              # Switch to window 1-5
```

## Customization

### Theme Variants
Change the Catppuccin flavor in `.tmux.conf`:
```bash
set -g @catppuccin_flavour 'mocha'    # Dark (default)
set -g @catppuccin_flavour 'latte'    # Light
set -g @catppuccin_flavour 'frappe'   # Dark variant
set -g @catppuccin_flavour 'macchiato' # Dark variant
```

### Prefix Key
To change the prefix key, modify these lines in `.tmux.conf`:
```bash
unbind C-b
set -g prefix C-a       # Change C-a to your preferred key
bind C-a send-prefix
```

### Mouse Support
To disable mouse support:
```bash
set -g mouse off        # Change 'on' to 'off'
```

## Troubleshooting

### Colors not displaying correctly
1. Ensure your terminal supports 256 colors
2. For iTerm2: Preferences → Profiles → Terminal → Report Terminal Type → xterm-256color
3. Add to your shell config: `export TERM=screen-256color`

### Plugins not installing
1. Ensure TPM is installed: `ls ~/.tmux/plugins/tpm`
2. Reload tmux config: `prefix + r`
3. Try installing again: `prefix + I`

### Sessions not restoring
1. Check if tmux-continuum is working: `tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH`
2. Manually save session: `prefix + Ctrl-s`
3. Manually restore session: `prefix + Ctrl-r`

## Scripts

- `install.sh` - Install tmux and TPM
- `setup.sh` - Show configuration workflow and status

## Integration

This tmux configuration works seamlessly with:
- **zsh**: Inherits your shell configuration
- **nvim**: Session strategy for vim/nvim restoration + consistent `Ctrl+hjkl` navigation
- **Catppuccin themes**: Consistent theming across tools

### Neovim Integration
The tmux configuration uses `Ctrl+h,j,k,l` for pane navigation, which matches the standard Neovim window navigation keys. This creates a seamless experience when moving between tmux panes and Neovim splits.
