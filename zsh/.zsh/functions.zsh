# Caleb's Zsh Functions
# Managed by GNU Stow from ~/.files/zsh/.zsh/functions.zsh

# ============================================================================
# Directory Management
# ============================================================================

# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# ============================================================================
# Archive Extraction
# ============================================================================

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ============================================================================
# fzf Integration
# ============================================================================

# Quick find and edit
fe() {
    local file
    file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# Quick cd with fzf
fd() {
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
