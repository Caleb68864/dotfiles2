# Caleb's Zsh Functions
# Managed by GNU Stow from ~/dotfiles/zsh/.zsh/functions.zsh

# ============================================================================
# Directory Management
# ============================================================================

# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Shorthand directory traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ============================================================================
# fzf Integration
# ============================================================================

# Quick find and edit file with fzf + bat preview
fe() {
    local file
    file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# Quick cd into a subdirectory with fzf + eza preview
fdir() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m --preview 'eza --tree --level=1 --color=always --icons {}')
    [ -n "$dir" ] && cd "$dir"
}

# ============================================================================
# Git Helpers
# ============================================================================

# Git add, commit, and push
gacp() {
    git add .
    git commit -m "$1"
    git push
}
