# =============================================================================
# Desktop & TUI Aliases
# =============================================================================
# Desktop environment shortcuts and TUI (Terminal User Interface) tools.
# Guarded by command checks so they only load when the tools are installed.

# --- Hyprland ---
# These only load when Hyprland is the active desktop environment.
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    alias reload-hypr='hyprctl reload'                     # Reload Hyprland's config without restarting it
    alias hypr-edit='nvim ~/.config/hypr/hyprland.conf'    # Quickly open the Hyprland config file for editing
fi

# --- Email (aerc) ---
if command -v aerc &> /dev/null; then
    alias mail='aerc'                 # Quick way to open your email
fi

# --- System & TUI Tools ---
# Tools you launch on demand, then quit.
# The always-running TUI apps live in tmux windows (see tmux-command-center).
if command -v pulsemixer &> /dev/null; then
    alias audio='pulsemixer'          # TUI audio mixer (volume, inputs, outputs)
fi
if command -v bluetuith &> /dev/null; then
    alias bt='bluetuith'              # TUI bluetooth manager (pair, connect, disconnect)
fi
if command -v khal &> /dev/null; then
    alias agenda='khal list today 7d' # Show agenda for the next 7 days
fi
if command -v btop &> /dev/null; then
    alias top='btop'                  # System monitor (replaces htop/top)
fi
alias notes='basalt'                  # Obsidian vault browser TUI (also Alt+4 in tmux)
alias tmux-reset='rm -f ~/.local/share/tmux/resurrect/last && tmux kill-server'
                                      # Nuke resurrect state and restart tmux fresh
                                      # (use after changing window names/layout in config)

# --- Pi Coding Agent ---
alias pa='pi'           # Run Pi in normal interactive mode
alias pac='pi -c'       # Run Pi in "compact" mode (less verbose output)
alias par='pi -r'       # Run Pi in "resume" mode (continue a previous conversation)
alias paf='pi --fork'   # Fork a new conversation from the current one
