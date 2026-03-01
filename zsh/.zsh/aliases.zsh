# Caleb's Zsh Aliases
# Managed by GNU Stow from ~/dotfiles/zsh/.zsh/aliases.zsh

# ============================================================================
# Editor Aliases
# ============================================================================
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# ============================================================================
# File Management
# ============================================================================
# ls -> eza
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias lt='eza --tree --icons --group-directories-first'
    alias l='eza -lah --icons --group-directories-first'
else
    alias ll='ls -lh'
    alias la='ls -lah'
    alias l='ls -lah'
fi

# cat -> bat
if command -v bat &> /dev/null; then
    alias cat='bat --style=auto'
    alias catt='/usr/bin/cat'  # original cat
fi

# ============================================================================
# Git Aliases
# ============================================================================
# (in addition to Oh-My-Zsh git plugin)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate --all'

# ============================================================================
# System Aliases
# ============================================================================
alias update='yay -Syu'
alias cleanup='yay -Sc --noconfirm && yay -Yc --noconfirm'
alias orphans='yay -Qtdq'
alias remove-orphans='yay -Rns $(yay -Qtdq)'

# ============================================================================
# Python Aliases
# ============================================================================
alias py='python'
alias pip='python -m pip'
alias venv='python -m venv'
alias activate='source venv/bin/activate'

# ============================================================================
# Docker Aliases
# ============================================================================
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dc='docker compose'
    alias dps='docker ps'
    alias di='docker images'
    alias dex='docker exec -it'
fi

# ============================================================================
# Hyprland Aliases
# ============================================================================
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    alias reload-hypr='hyprctl reload'
    alias hypr-edit='nvim ~/.config/hypr/hyprland.conf'
fi
