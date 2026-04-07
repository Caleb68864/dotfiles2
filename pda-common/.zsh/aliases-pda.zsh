# =============================================================================
# PDA Aliases & Environment
# =============================================================================
# PDA-specific environment variables, aliases, and shortcuts.
# Sourced by .zshrc when running on a PDA (small-screen Linux handheld).
# These override or supplement the desktop aliases for a keyboard-driven,
# no-Wayland workflow optimized for reading, writing, and quick capture.

# =============================================================================
# Environment Variables
# =============================================================================

# --- PDA MODE FLAG ---
# Scripts and configs can check this to adapt behavior for small screens.
# Example: tmux session builders use this to pick a PDA-friendly layout.
export PDA_MODE=1

# --- SESSION BUILDER ---
# Points to the PDA-specific tmux session script instead of the desktop one.
# The session builder creates the default tmux layout when a new session starts.
export TMUX_SESSION_BUILDER="$HOME/bin/tmux-pda-session"

# --- BROWSER ---
# Use w3m (terminal web browser) instead of a GUI browser.
# PDA devices typically have no Wayland/X11 compositor running.
export BROWSER=w3m

# --- OBSIDIAN VAULT ---
# Path to the Obsidian-compatible markdown vault on the PDA.
# Shorter path than desktop (~/.../Logic) since the PDA is single-purpose.
export OBSIDIAN_VAULT="$HOME/Notes"

# =============================================================================
# Aliases
# =============================================================================

# --- Quick Capture & Notes ---
# These aliases make it fast to jot down ideas or review notes from anywhere.
alias note='pda-note'                                                                      # Quick-capture a note to the vault inbox
alias today='nvim "$OBSIDIAN_VAULT/Calendar Notes/Daily Notes/$(date +%Y-%m-%d).md"'       # Open today's daily note in Neovim
alias inbox='nvim "$OBSIDIAN_VAULT/Inbox/"'                                                # Browse the vault inbox folder

# --- Information & Reading ---
alias feeds='newsboat'                  # RSS feed reader
alias agenda='khal list today 7d'       # Show agenda for the next 7 days

# --- E-Book Reader ---
# Detect which reader is installed and alias accordingly.
# bookratt is preferred (richer TUI); epy is a lighter fallback.
if command -v bookratt &> /dev/null; then
    alias books='bookratt'
elif command -v epy &> /dev/null; then
    alias books='epy'
fi

# --- SSH Shortcuts ---
# Placeholder aliases — edit these with your actual host addresses.
# Example: alias ssh-home='ssh user@192.168.1.100'
alias ssh-home='echo "Configure ssh-home in aliases-pda.zsh with your home PC address"'
alias ssh-server='echo "Configure ssh-server in aliases-pda.zsh with your server address"'
