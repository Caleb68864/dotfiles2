# =============================================================================
# Caleb's Zsh Keybindings
# Managed by GNU Stow from ~/.files/zsh/.zsh/keybindings.zsh
# =============================================================================
#
# Keybindings tell the shell what to do when you press specific key
# combinations. This file sets up Vim-style editing and useful shortcuts.
#
# IMPORTANT: This file is loaded AFTER Oh-My-Zsh (in .zshrc) so that
# these settings override any defaults that Oh-My-Zsh sets.
# =============================================================================


# =============================================================================
# Vi Mode
# =============================================================================
# Enable Vim-style editing on the command line. This means:
#   - You start in "insert mode" (typing works normally)
#   - Press ESCAPE to enter "normal mode" (navigate with h/j/k/l, delete with d, etc.)
#   - Press 'i' to go back to insert mode
# This is great if you already know Vim — the same muscle memory works here.
bindkey -v


# =============================================================================
# Basic Navigation (History Search)
# =============================================================================
# These let you search your command history by what you've already typed.
# Example: type "git" then press Ctrl+P — it finds the most recent command
# that started with "git". Press Ctrl+P again to go further back.
# Ctrl+N goes forward (toward more recent commands).
# This is MUCH faster than pressing the Up arrow 50 times to find an old command.
bindkey '^p' history-search-backward   # Ctrl+P = search backward through history
bindkey '^n' history-search-forward    # Ctrl+N = search forward through history


# =============================================================================
# fzf Integration
# =============================================================================
# These keybindings connect fzf (fuzzy finder) to your shell for
# powerful interactive search.

# Ctrl+R = Search command history with fzf
# Instead of scrolling through history one line at a time, this opens a
# full fuzzy search of ALL your past commands. Type a few letters to filter.
# (Note: Atuin may override this with its own history search.)
bindkey '^r' fzf-history-widget

# Ctrl+F = Search for files with fzf
# Opens a fuzzy file finder. Start typing a filename and it narrows down instantly.
# Press Enter to insert the selected file path into your current command.
bindkey '^f' fzf-file-widget

# Ctrl+T = Trigger fzf-powered tab completion
# Like regular tab completion but uses fzf's fuzzy matching instead of
# the basic prefix matching. More forgiving of typos.
bindkey '^t' fzf-completion


# =============================================================================
# Vi Mode Settings
# =============================================================================

# --- REDUCE ESCAPE KEY DELAY ---
# When you press Escape in vi mode, the shell normally waits a moment to
# see if you're pressing a multi-key sequence (like Escape then a letter).
# KEYTIMEOUT=1 makes it only wait 10 milliseconds (1 = 10ms in Zsh).
# This makes switching from insert to normal mode feel instant.
export KEYTIMEOUT=1

# --- CURSOR SHAPE CHANGES ---
# Change the cursor shape to show which vi mode you're in:
#   NORMAL MODE (after pressing Escape) = block cursor (solid rectangle)
#   INSERT MODE (typing normally)       = beam cursor (thin vertical line)
# This gives you a clear visual indicator of which mode you're in,
# so you don't accidentally type vim commands as text or vice versa.
#
# '\e[1 q' = blinking block cursor (normal/command mode)
# '\e[5 q' = blinking beam/line cursor (insert mode)
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        # Switched to NORMAL mode — show block cursor
        echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        # Switched to INSERT mode — show beam cursor
        echo -ne '\e[5 q'
    fi
}
# Register this function as a Zsh "widget" so it runs every time the keymap changes.
zle -N zle-keymap-select

# --- INITIALIZE CURSOR ---
# Start with a beam cursor (insert mode) when the shell first opens.
# Without this, you might see a block cursor initially, which is confusing
# because you're actually in insert mode.
echo -ne '\e[5 q'

# --- RESTORE CURSOR AFTER EACH COMMAND ---
# After a command finishes running, reset the cursor back to beam (insert mode).
# Some programs change the cursor shape while they run, and without this,
# the cursor might stay as a block after you exit Vim or another program.
# "preexec" is a special Zsh hook that runs just before each command executes.
preexec() {
    echo -ne '\e[5 q'
}
