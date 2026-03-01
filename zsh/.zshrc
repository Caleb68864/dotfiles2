# Caleb's .zshrc
# Managed by GNU Stow from ~/dotfiles/zsh/.zshrc

# ============================================================================
# Oh-My-Zsh Configuration
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"

export HYPRLAND_INSTANCE_SIGNATURE=$(/usr/bin/ls -1 /run/user/1000/hypr/ | grep '^[a-f0-9]' | sort -t_ -k2 -n | tail -1)

# Theme - Using Starship instead of Oh-My-Zsh themes
# To use Powerlevel10k instead, uncomment the line below and comment out the Starship init at the bottom
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-My-Zsh settings
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="false"
DISABLE_UPDATE_PROMPT="false"
export UPDATE_ZSH_DAYS=14
DISABLE_MAGIC_FUNCTIONS="false"
DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"

# History settings
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# Oh-My-Zsh plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    vi-mode
    fzf
    fzf-tab
    command-not-found
    extract
    sudo
)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# Environment Variables
# ============================================================================

# Preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Python
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# .NET
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# fzf configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vsc 2>/dev/null'
export FZF_DEFAULT_OPTS='
  --height=40%
  --layout=reverse
  --border
  --margin=1
  --padding=1
  --color=fg:#ebdbb2,bg:#282828,hl:#fabd2f
  --color=fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color=info:#83a598,prompt:#bdae93,pointer:#fb4934
  --color=marker:#8ec07c,spinner:#fabd2f,header:#83a598
'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
export FZF_ALT_C_OPTS='--preview "eza --tree --level=1 --color=always --icons {}"'

# ============================================================================
# WSL Detection
# ============================================================================

if grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL detected
    export WSL=1

    # Windows clipboard integration
    if command -v clip.exe &> /dev/null; then
        alias pbcopy='clip.exe'
    fi

    # Open Windows apps
    alias explorer='explorer.exe'
    alias code='code.exe'

    # Fix for some display issues
    export DISPLAY=:0
fi

# ============================================================================
# Auto-complete Settings
# ============================================================================

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# fzf-tab configuration
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'

# ============================================================================
# Load Modular Configurations
# ============================================================================

# Load aliases
[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh

# Load functions
[ -f ~/.zsh/functions.zsh ] && source ~/.zsh/functions.zsh

# Load keybindings (must be loaded after Oh-My-Zsh)
[ -f ~/.zsh/keybindings.zsh ] && source ~/.zsh/keybindings.zsh

# ============================================================================
# Auto-ls After cd
# ============================================================================

# Automatically run ls after cd
function cd() {
    builtin cd "$@" && ls
}

# ============================================================================
# Keybindings
# ============================================================================

# Ctrl+K to go up a directory
bindkey -s '^K' 'cd ..\n'

# ============================================================================
# Tmux Auto-Start
# ============================================================================

# Auto-start or attach to tmux session "command-center"
# Works for both local and SSH sessions
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    # Check if session "command-center" exists
    if tmux has-session -t command-center 2>/dev/null; then
        # Session exists, attach to it
        exec tmux attach-session -t command-center
    else
        # Session doesn't exist, create it with first window named "tactical"
        exec tmux new-session -s command-center -n tactical
    fi
fi

# ============================================================================
# Prompt
# ============================================================================

# Initialize Atuin (enhanced shell history — replaces Ctrl+R)
eval "$(atuin init zsh)"

# Initialize Starship prompt (default)
eval "$(starship init zsh)"

# Optional: Initialize Powerlevel10k (if using P10k instead of Starship)
# To enable Powerlevel10k, uncomment the line below and comment out the Starship init above
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Local Customizations
# ============================================================================

# Load local customizations (not tracked by git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
