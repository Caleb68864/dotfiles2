# =============================================================================
# Caleb's Zsh Aliases
# Managed by GNU Stow from ~/dotfiles/zsh/.zsh/aliases.zsh
# =============================================================================
#
# Aliases are shortcuts — instead of typing a long command, you type a
# short nickname and the shell expands it to the full command for you.
# For example, typing "gs" is the same as typing "git status".
#
# WHY USE ALIASES?
#   - Saves typing (less wear on your fingers)
#   - Harder to make typos in short commands
#   - Can set preferred default flags so you don't forget them
# =============================================================================


# =============================================================================
# Editor Aliases
# =============================================================================
# All three of these open Neovim (nvim). This way, no matter which
# old habit you have — typing "vim", "vi", or just "v" — you always
# get Neovim. Neovim is the modern, improved version of Vim.
alias vim='nvim'
alias vi='nvim'
alias v='nvim'


# =============================================================================
# File Management
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


# =============================================================================
# Git Aliases
# =============================================================================
# Git is the version control system that tracks changes to your code.
# These aliases make common git commands faster to type.
# (Oh-My-Zsh's git plugin adds many more, but these are personal favorites.)

alias gs='git status'                 # Show which files are changed, staged, or untracked
alias ga='git add'                    # Stage files to be included in the next commit
alias gc='git commit'                 # Save staged changes as a new commit (snapshot)
alias gp='git push'                   # Upload your commits to the remote server (GitHub)
alias gl='git pull'                   # Download new commits from the remote server
alias gd='git diff'                   # Show what changed in files (line by line)
alias gco='git checkout'              # Switch to a different branch or restore files
alias gb='git branch'                 # List, create, or delete branches
alias glog='git log --oneline --graph --decorate --all'  # Show a pretty visual tree of all branches and commits
alias lg='lazygit'                    # Open LazyGit — a beautiful terminal UI for git
                                      # (much easier than remembering all git commands)


# =============================================================================
# System Aliases (Arch Linux / EndeavourOS)
# =============================================================================
# These use "yay" — an AUR helper that can install packages from both
# the official Arch repos AND the AUR (Arch User Repository, where
# community members share their own packages).

alias update='yay -Syu'              # Update ALL installed packages to their latest versions
alias cleanup='yay -Sc --noconfirm && yay -Yc --noconfirm'
                                      # Clean up: remove cached old package files (Sc) AND
                                      # remove unneeded dependencies (Yc) to free disk space
alias orphans='yay -Qtdq'            # List "orphan" packages — packages that were installed as
                                      # dependencies but are no longer needed by anything
alias remove-orphans='yay -Rns $(yay -Qtdq)'
                                      # Remove all orphan packages AND their config files (-n)
                                      # AND their now-unneeded dependencies (-s). Full cleanup.


# =============================================================================
# Python Aliases
# =============================================================================
# Python is a programming language. These aliases save typing for common
# Python development tasks.

alias py='python'                     # Short way to run the Python interpreter
alias pip='python -m pip'             # Install Python packages (using "python -m pip" is safer
                                      # than bare "pip" because it ensures you're using the
                                      # right Python version's pip)
alias venv='python -m venv'           # Create a virtual environment (an isolated sandbox for
                                      # a project's dependencies so they don't clash with others)
alias activate='source venv/bin/activate'  # Activate the virtual environment in the current folder
                                           # (after this, "python" and "pip" only affect this project)


# =============================================================================
# Docker Aliases
# =============================================================================
# Docker lets you run applications in "containers" — lightweight isolated
# environments (like mini virtual machines). These aliases only load if
# Docker is actually installed on this machine.

if command -v docker &> /dev/null; then
    alias d='docker'                  # The main Docker command
    alias dc='docker compose'         # Docker Compose: manage multi-container apps defined in docker-compose.yml
    alias dps='docker ps'             # List running containers (like "task manager" for Docker)
    alias di='docker images'          # List downloaded container images (the "blueprints" for containers)
    alias dex='docker exec -it'       # Run a command inside a running container interactively
                                      # (e.g., "dex mycontainer bash" opens a shell inside it)
fi


# =============================================================================
# Hyprland Aliases
# =============================================================================
# Hyprland is the desktop window manager (the thing that draws windows,
# handles keyboard shortcuts, manages workspaces, etc.). These aliases
# only load when Hyprland is actually running.

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    alias reload-hypr='hyprctl reload'                     # Reload Hyprland's config without restarting it
    alias hypr-edit='nvim ~/.config/hypr/hyprland.conf'    # Quickly open the Hyprland config file for editing
fi


# =============================================================================
# Email (aerc)
# =============================================================================
# aerc is the terminal email client. It handles IMAP/SMTP directly (no mbsync needed).
if command -v aerc &> /dev/null; then
    alias mail='aerc'                 # Quick way to open your email
fi

# =============================================================================
# System & TUI Tools (launch on demand, not auto-started)
# =============================================================================
# These are tools you launch when you need them, then quit.
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

# =============================================================================
# Pi Coding Agent
# =============================================================================
# Pi is an AI coding assistant (similar to Claude Code). These aliases
# provide quick access to its different modes.

alias pa='pi'           # Run Pi in normal interactive mode
alias pac='pi -c'       # Run Pi in "compact" mode (less verbose output)
alias par='pi -r'       # Run Pi in "resume" mode (continue a previous conversation)
alias paf='pi --fork'   # Fork a new conversation from the current one
