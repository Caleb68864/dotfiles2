# Caleb's Zsh Keybindings
# Managed by GNU Stow from ~/.files/zsh/.zsh/keybindings.zsh

# ============================================================================
# Vi Mode
# ============================================================================
bindkey -v  # Vi mode

# ============================================================================
# Basic Navigation
# ============================================================================
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ============================================================================
# fzf Integration
# ============================================================================
bindkey '^r' fzf-history-widget
bindkey '^f' fzf-file-widget
bindkey '^t' fzf-completion

# ============================================================================
# Vi Mode Settings
# ============================================================================
# Reduce ESC delay in vi mode
export KEYTIMEOUT=1

# Change cursor shape for different vi modes
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
    fi
}
zle -N zle-keymap-select

# Initialize cursor to beam
echo -ne '\e[5 q'

# Restore beam cursor after each command
preexec() {
    echo -ne '\e[5 q'
}
