# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ~/.zshrc
# Main zsh configuration file

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-nvm
    brew
    macos
    node
    npm
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# User configuration
POWERLEVEL9K_DISABLE_AUTO_TITLE=true
export EDITOR='nvim'
export VISUAL='nvim'

# Initialize zoxide (smarter cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Aliases
## Git
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias vim='nvim'
alias vi='nvim'

alias gl='git pull'
alias gp='git push'
alias gs='git status'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'

## AI
alias mcp='mcp-hub --port 8081 --config ~/.config/mcphub/servers.json'


# Case-insensitive completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Load any local configuration
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
