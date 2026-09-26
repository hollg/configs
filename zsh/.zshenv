# ~/.zshenv
# Environment variables for zsh

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# PATH configuration
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"   # Local binaries

# Language settings
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# Load environment variables (secrets) - available to all zsh sessions
[[ -r "$HOME/configs/zsh/.env" ]] && source "$HOME/configs/zsh/.env"
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
