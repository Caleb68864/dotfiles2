# =============================================================================
# Caleb's Zsh Functions
# Managed by GNU Stow from ~/dotfiles/zsh/.zsh/functions.zsh
# =============================================================================
#
# Functions are like aliases but more powerful — they can take arguments,
# run multiple commands, and contain logic. Think of them as tiny
# programs you write to automate things you do often.
# =============================================================================


# =============================================================================
# Directory Management
# =============================================================================

# --- MKCD: Create a directory and immediately enter it ---
# Normally you'd type "mkdir myfolder" then "cd myfolder" — two commands.
# This function does both in one step: "mkcd myfolder".
# The "-p" flag on mkdir means it will create parent directories too
# (e.g., "mkcd a/b/c" creates all three folders at once, no errors if they exist).
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# --- SHORTHAND DIRECTORY TRAVERSAL ---
# These let you go up multiple directories quickly:
#   ..   = go up 1 level  (same as "cd ..")
#   ...  = go up 2 levels (same as "cd ../..")
#   .... = go up 3 levels (same as "cd ../../..")
# Much faster than typing "cd ../../.." when you're deep in a folder tree.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'


# =============================================================================
# fzf Integration
# =============================================================================
# fzf is a "fuzzy finder" — you type a few letters and it instantly filters
# a huge list down to matching items. These functions combine fzf with
# other tools for powerful search-and-act workflows.

# --- FE: Fuzzy Find and Edit a file ---
# Type "fe" and a searchable list of all files appears. Start typing to
# filter. As you highlight a file, a syntax-highlighted preview of its
# contents appears on the right side (using bat). Press Enter to open
# the selected file in your editor (Neovim).
# If you press Escape without selecting anything, nothing happens.
fe() {
    local file
    file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# --- FDIR: Fuzzy Find and CD into a directory ---
# Type "fdir" and a searchable list of all subdirectories appears. As you
# highlight a directory, a tree preview shows what's inside it (using eza).
# Press Enter to cd into the selected directory.
# You can optionally pass a starting path: "fdir ~/projects" to search from there.
# The "${1:-.}" means "use the first argument if given, otherwise use . (current dir)".
fdir() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m --preview 'eza --tree --level=1 --color=always --icons {}')
    [ -n "$dir" ] && cd "$dir"
}


# =============================================================================
# Git Helpers
# =============================================================================

# --- GACP: Git Add, Commit, and Push in one command ---
# Instead of running three separate commands:
#   git add .          (stage ALL changes)
#   git commit -m "message"  (save a snapshot with a description)
#   git push           (upload to GitHub)
# You just type: gacp "my commit message"
# WARNING: This uses "git add ." which stages EVERYTHING — be careful
# not to accidentally commit files you didn't mean to (like secrets or large files).
gacp() {
    git add .
    git commit -m "$1"
    git push
}


# =============================================================================
# AI Coding Pane Launchers
# =============================================================================
# These functions split your current tmux pane and launch an AI coding agent
# right next to what you're working on. Perfect for monitoring multiple
# sessions side by side without switching windows.
#
# Usage:
#   spi              -- Split right and open Pi in current directory
#   spi ~/project    -- Split right and open Pi in ~/project
#   sclaude          -- Split right and open Claude Code in current directory
#   sclaude ~/proj   -- Split right and open Claude Code in ~/project
#   snvim            -- Split right and open Neovim in current directory

# --- SPI: Split pane and launch Pi ---
# Opens Pi in a new tmux pane to the RIGHT of your current pane (40% width).
# Optionally pass a directory; defaults to your current working directory.
spi() {
    local dir="${1:-$(pwd)}"
    tmux split-window -h -l 40% -c "$dir" pi
}

# --- SCLAUDE: Split pane and launch Claude Code ---
# Same as spi but launches Claude Code instead.
sclaude() {
    local dir="${1:-$(pwd)}"
    tmux split-window -h -l 40% -c "$dir" claude
}

# --- SNVIM: Split pane and launch Neovim ---
# Opens Neovim in a new pane to the RIGHT (60% width, since editor needs more space).
snvim() {
    local dir="${1:-$(pwd)}"
    tmux split-window -h -l 60% -c "$dir" nvim
}
