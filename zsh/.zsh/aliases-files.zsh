# =============================================================================
# File Management Aliases
# =============================================================================

# --- LS REPLACEMENT: EZA ---
# Eza is a modern replacement for "ls" (the command that lists files).
# It adds icons (little pictures next to file names), colors, and puts
# directories at the top of the list. If eza isn't installed, fall back
# to plain ls with reasonable flags.
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'          # Basic file listing with icons
    alias ll='eza -l --icons --group-directories-first'       # Long format (shows size, date, permissions)
    alias la='eza -la --icons --group-directories-first'      # Long format + hidden files (dotfiles)
    alias lt='eza --tree --icons --group-directories-first'   # Tree view (shows folders inside folders)
    alias l='eza -lah --icons --group-directories-first'      # Long + all + human-readable sizes (the "show me everything" option)
else
    # Fallback: plain ls with human-readable sizes
    alias ll='ls -lh'
    alias la='ls -lah'
    alias l='ls -lah'
fi

# --- CAT REPLACEMENT: BAT ---
# Bat is a modern replacement for "cat" (the command that prints file contents).
# It adds syntax highlighting (code is colorized), line numbers, and
# git change markers. If bat isn't installed, regular cat is used automatically.
if command -v bat &> /dev/null; then
    alias cat='bat --style=auto'       # Use bat with automatic formatting
    alias catt='/usr/bin/cat'          # Escape hatch: "catt" runs the REAL cat
                                       # (useful when you need plain unformatted output,
                                       # like piping to another program)
fi
