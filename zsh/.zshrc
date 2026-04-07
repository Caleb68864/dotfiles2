# =============================================================================
# Caleb's .zshrc -- Main Zsh Shell Configuration
# Managed by GNU Stow from ~/dotfiles/zsh/.zshrc
# =============================================================================
#
# This file runs every time you open a new terminal. It sets up your
# entire shell environment: how the prompt looks, what shortcuts exist,
# what tools are available, and how everything behaves.
#
# Think of it as the "startup checklist" for your terminal -- everything
# here gets loaded before you even type your first command.
# =============================================================================


# =============================================================================
# Oh-My-Zsh Configuration
# =============================================================================
# Oh-My-Zsh is a framework that adds tons of helpful features to Zsh:
# auto-completions, themes, plugins, and shortcuts. It is like installing
# a "starter pack" of useful tools for your terminal.

# Tell Oh-My-Zsh where it is installed on disk.
export ZSH="$HOME/.oh-my-zsh"

# --- HYPRLAND INSTANCE DETECTION ---
# Hyprland (the desktop window manager) creates a unique folder for each
# session it runs. This line finds the LATEST Hyprland session ID so that
# tools like hyprctl can talk to the right Hyprland instance.
# Without this, commands like "hyprctl reload" would not know which
# Hyprland session to control.
# Guarded so it only runs on machines with Hyprland installed.
if [ -d /run/user/1000/hypr ]; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(/usr/bin/ls -1 /run/user/1000/hypr/ | grep '^[a-f0-9]' | sort -t_ -k2 -n | tail -1)
fi

# --- THEME ---
# We use Starship prompt (set up at the bottom of this file) instead of
# Oh-My-Zsh built-in themes. If you ever want to switch to Powerlevel10k,
# uncomment the line below and comment out the Starship init at the bottom.
# ZSH_THEME="powerlevel10k/powerlevel10k"

# --- OH-MY-ZSH BEHAVIOR SETTINGS ---
CASE_SENSITIVE="false"             # Treat "Foo" and "foo" as the same when tab-completing
HYPHEN_INSENSITIVE="true"          # Treat hyphens (-) and underscores (_) as the same in completions
DISABLE_AUTO_UPDATE="false"        # Allow Oh-My-Zsh to check for updates automatically
DISABLE_UPDATE_PROMPT="false"      # Show a prompt asking before updating (do not just update silently)
export UPDATE_ZSH_DAYS=14          # Check for updates every 14 days
DISABLE_MAGIC_FUNCTIONS="false"    # Keep "magic functions" that fix pasting URLs with special characters
DISABLE_LS_COLORS="false"          # Keep colors when listing files (so directories, files, etc. are color-coded)
DISABLE_AUTO_TITLE="false"         # Let the terminal title update automatically (shows current directory/command)
ENABLE_CORRECTION="true"           # Suggest "did you mean...?" when you mistype a command
COMPLETION_WAITING_DOTS="true"     # Show "..." while waiting for tab-completion to load (so you know it is thinking)
DISABLE_UNTRACKED_FILES_DIRTY="false"  # Show untracked git files as "dirty" in the prompt (helps you notice new files)

# --- HISTORY SETTINGS ---
# Your command history is like a diary of every command you have ever typed.
# These settings control how many commands to remember and how to handle duplicates.
HISTSIZE=100000                         # Keep 100,000 commands in memory while the shell is running
SAVEHIST=100000                         # Save 100,000 commands to the history file on disk
HISTFILE=~/.zsh_history                 # Where the history file lives on disk
setopt EXTENDED_HISTORY                 # Save timestamps with each command (when you ran it, how long it took)
setopt INC_APPEND_HISTORY              # Save commands to the file RIGHT AWAY, not just when you close the terminal
setopt SHARE_HISTORY                   # All open terminals share the same history -- type in one, see it in another
setopt HIST_EXPIRE_DUPS_FIRST          # When history gets full, delete duplicates first before deleting unique commands
setopt HIST_IGNORE_DUPS                # Do not save a command if it is the exact same as the one you just ran
setopt HIST_IGNORE_ALL_DUPS            # If you run an old command again, remove the old copy and save the new one
setopt HIST_FIND_NO_DUPS               # When searching history, skip duplicates (only show each command once)
setopt HIST_IGNORE_SPACE               # Commands starting with a space are NOT saved (handy for secrets/passwords)
setopt HIST_SAVE_NO_DUPS               # Never write duplicate commands to the history file
setopt HIST_VERIFY                     # When you use ! history shortcuts, show the command first instead of running it immediately

# --- PLUGINS ---
# These are Oh-My-Zsh plugins -- each one adds specific features.
plugins=(
    git                      # Adds tons of git aliases and functions (gst, gco, etc.)
    zsh-autosuggestions      # Shows gray "ghost text" suggestions as you type, based on history
    zsh-syntax-highlighting  # Colors your commands as you type: green = valid, red = typo
    vi-mode                  # Lets you edit the command line using Vim keys (press Escape to enter normal mode)
    fzf                      # Integrates fzf (fuzzy finder) for searching files, history, etc.
    fzf-tab                  # Replaces the boring tab-completion menu with an fzf-powered fuzzy search
    command-not-found        # When you mistype a command, tells you which package to install to get it
    extract                  # Type "extract file.tar.gz" to unpack ANY archive format automatically
    sudo                     # Press Escape twice to add "sudo" to the beginning of your current command
    you-should-use           # Reminds you when you type a command that has an alias you forgot about
    zsh-autopair             # Auto-closes brackets, quotes, and backticks as you type
)

# Load Oh-My-Zsh -- this activates all the plugins and settings above.
source $ZSH/oh-my-zsh.sh


# =============================================================================
# Environment Variables
# =============================================================================
# Environment variables are like global settings that all programs can read.
# They tell programs things like "what text editor do you prefer?" or
# "what language should menus be in?"

# --- DEFAULT EDITOR ---
# When a program needs to open a text editor (like git commit), use Neovim.
export EDITOR='nvim'    # For terminal-based editing
export VISUAL='nvim'    # For GUI-based editing (also uses Neovim here)

# --- COMPILATION FLAGS ---
# Tells compilers to build for the x86_64 (64-bit Intel/AMD) architecture.
# Only matters when compiling software from source code.
export ARCHFLAGS="-arch x86_64"

# --- LANGUAGE ---
# Set the language and character encoding to US English with UTF-8.
# UTF-8 supports every character in every language (plus emojis).
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# --- XDG BASE DIRECTORIES ---
# These tell programs WHERE to put their stuff, following a standard convention:
#   CONFIG_HOME = settings/config files (like this .zshrc)
#   DATA_HOME   = persistent data (like fonts, databases)
#   CACHE_HOME  = temporary data that can be deleted without losing anything
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# --- OBSIDIAN VAULT ---
# Default vault path for scripts that interact with Obsidian notes
# (e.g., tmux-daily-note, mail-to-obsidian).
export OBSIDIAN_VAULT="$HOME/Documents/Notes/Logic"

# --- PATH ---
# PATH is the list of directories where the shell looks for programs.
# Adding ~/.local/bin and ~/bin means you can put your own scripts there
# and run them by name without typing the full path.
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# --- PYTHON SETTINGS ---
# Do not create __pycache__ folders full of .pyc files everywhere.
# They are compiled bytecode files that speed up Python slightly but clutter
# your project directories. Cleaner without them.
export PYTHONDONTWRITEBYTECODE=1
# Do not buffer Python output -- print statements appear immediately
# instead of being held in a buffer. Important for seeing live output
# from scripts and avoiding "why is my print() not showing up?" confusion.
export PYTHONUNBUFFERED=1

# --- .NET SETTINGS ---
# Tell Microsoft .NET tools not to send usage data back to Microsoft.
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# --- LOAD TOKYO NIGHT COLOR PALETTE ---
# Source the theme file which defines color variables (like THEME_BLUE, THEME_BG0, etc.)
# These variables are used below to color fzf and other tools consistently.
# The "[ -f ... ] &&" pattern means "only do this if the file exists" -- a safety check.
[ -f ~/.config/themes/tokyo-night.conf ] && source ~/.config/themes/tokyo-night.conf

# --- FZF CONFIGURATION ---
# fzf is a "fuzzy finder" -- a fast search tool you can use to find files,
# search command history, pick git branches, etc. It shows a nice interactive
# list you can type in to filter down.

# Default command: Use ripgrep (rg) to find files. It is much faster than
# the built-in "find" command and respects .gitignore by default.
# --hidden = include hidden files (dotfiles), --follow = follow symlinks
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vsc 2>/dev/null'

# Default look and feel for fzf -- colors come from Tokyo Night theme variables.
# --height=40%    = fzf takes up 40% of the terminal, not the whole screen
# --layout=reverse = newest results at the top (more natural for most uses)
# --border         = draw a box around fzf
# --margin/padding = spacing so it does not feel cramped
# --color=...      = map Tokyo Night colors to fzf color slots (bg, fg, highlights, etc.)
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --margin=1
  --padding=1
  --color=fg:${THEME_FG0},bg:${THEME_BG0},hl:${THEME_YELLOW}
  --color=fg+:${THEME_FG0},bg+:${THEME_BG2},hl+:${THEME_BLUE}
  --color=info:${THEME_FG4},prompt:${THEME_BLUE},pointer:${THEME_PURPLE}
  --color=marker:${THEME_GREEN},spinner:${THEME_CYAN},header:${THEME_FG2}
  --color=border:${THEME_BG3},gutter:${THEME_BG0}
"
# Ctrl+T: Search for files -- uses the same ripgrep command as above.
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Ctrl+T preview: When hovering over a file in the list, show a syntax-highlighted
# preview of the first 500 lines using "bat" (a fancy version of "cat").
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
# Alt+C preview: When browsing directories, show a tree view of what is inside
# using "eza" (a fancy version of "ls").
export FZF_ALT_C_OPTS='--preview "eza --tree --level=1 --color=always --icons {}"'


# =============================================================================
# WSL Detection
# =============================================================================
# WSL = Windows Subsystem for Linux. If we are running inside WSL (Linux running
# inside Windows), we need some special settings to bridge the two worlds.

if grep -qi microsoft /proc/version 2>/dev/null; then
    # We ARE inside WSL -- set up Windows integration
    export WSL=1

    # --- CLIPBOARD ---
    # Use Windows clip.exe to copy text to the Windows clipboard.
    # "pbcopy" is what macOS calls its clipboard command -- this alias makes
    # it work the same way on WSL.
    if command -v clip.exe &> /dev/null; then
        alias pbcopy='clip.exe'
    fi

    # --- WINDOWS APPS ---
    # Let you open Windows Explorer or VS Code from the Linux terminal.
    alias explorer='explorer.exe'
    alias code='code.exe'

    # --- DISPLAY ---
    # Some graphical Linux apps running in WSL need this to find a display server.
    export DISPLAY=:0
fi


# =============================================================================
# Auto-complete Settings
# =============================================================================
# Tab-completion is when you press Tab and the shell finishes what you are typing.
# These settings make it smarter and prettier.

# Show a menu of choices you can arrow through when there are multiple completions.
zstyle ':completion:*' menu select

# Make tab-completion case-insensitive: typing "documents" will match "Documents".
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Color the completion list using the same colors as "ls" (directories blue, etc.).
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- FZF-TAB PREVIEWS ---
# When tab-completing "cd <something>", show a preview of what is inside
# each directory in the fzf popup. Same for zoxide "z" command.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'


# =============================================================================
# Load Modular Configurations
# =============================================================================
# Instead of cramming everything into this one file, aliases, functions,
# and keybindings live in separate files for organization. Each file is
# loaded here if it exists. This keeps .zshrc cleaner and easier to navigate.

# Load alias modules (aliases-editor.zsh, aliases-git.zsh, etc.)
# Adding a new aliases-*.zsh file to ~/.zsh/ auto-loads it — no .zshrc edit needed.
for f in ~/.zsh/aliases-*.zsh(N); do source "$f"; done

# Load helper functions (like "mkcd" to create and enter a directory)
[ -f ~/.zsh/functions.zsh ] && source ~/.zsh/functions.zsh

# Load keybinding customizations (must come AFTER Oh-My-Zsh so they override its defaults)
[ -f ~/.zsh/keybindings.zsh ] && source ~/.zsh/keybindings.zsh


# =============================================================================
# Auto-ls After cd (and zoxide 'z')
# =============================================================================
# Every time you change directories (cd, z, pushd, etc.), automatically
# show the contents of the new directory. Saves you from always typing
# "ls" after "cd" -- the files just appear automatically.
chpwd() { ls }


# =============================================================================
# Keybindings
# =============================================================================

# Press Alt+K to go up one directory (same as typing "cd .." and pressing Enter).
# We use Alt+K instead of Ctrl+K because Ctrl+K is already used by
# vim-tmux-navigator to switch tmux panes.
# The "\n" at the end simulates pressing Enter so the command runs immediately.
bindkey -s '^[k' 'cd ..\n'


# =============================================================================
# Tmux Auto-Start (Grouped Sessions)
# =============================================================================
# Automatically start or join the "command-center" tmux session every time
# you open a terminal. This means:
#   - All your work is preserved if the terminal closes
#   - You always land in the same organized workspace
#   - SSH sessions automatically get tmux too
#
# GROUPED SESSIONS: The key change here is using "tmux new-session -t"
# (without -s) for subsequent terminals. This creates a "grouped session"
# that SHARES all windows with the original session, but each terminal can
# independently view a DIFFERENT window. So terminal 1 can be on "tactical"
# while terminal 2 is on "mail" and terminal 3 is on "monitor".
#
# Without grouped sessions, every terminal would mirror the same view --
# switching windows in one would switch all of them.
#
# The "exec" replaces the current shell with tmux (no leftover shell
# sitting underneath -- cleaner and uses less memory).
# The "[ -z "$TMUX" ]" check prevents this from running if you are ALREADY
# inside tmux (which would cause infinite nesting).
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    if tmux has-session -t command-center 2>/dev/null; then
        # Session exists -- create a GROUPED session.
        # This shares all windows but lets this terminal look at a different
        # window independently from other terminals.
        exec tmux new-session -t command-center
    else
        # Session does not exist yet -- run the layout builder script which
        # creates the session with all TUI app windows (mail, monitor, etc.)
        # and then attaches to it.
        if [ -x "$HOME/bin/tmux-command-center" ]; then
            exec "$HOME/bin/tmux-command-center"
        else
            # Fallback: if the script isn't available, create a basic session
            exec tmux new-session -s command-center -n tactical
        fi
    fi
fi


# =============================================================================
# Tool Initialization (Prompt, History, Navigation)
# =============================================================================
# These tools need to be initialized LAST because they hook into the shell
# and some need to override things set up by Oh-My-Zsh or plugins above.
#
# Each tool's init output is cached in ~/.cache/zsh/ to avoid forking a
# subprocess on every shell startup. The cache auto-regenerates when the
# tool binary changes (e.g., after an update).

# --- CACHED EVAL HELPER ---
# Usage: cached_eval <command> <args...>
# Caches the output of "command args..." and sources it on subsequent shells.
# Invalidates when the binary's modification time changes.
cached_eval() {
    local cmd="$1"; shift
    local cache_dir="$HOME/.cache/zsh"
    local cache_file="$cache_dir/${cmd}-init.zsh"
    local bin_path="$(command -v "$cmd" 2>/dev/null)"

    # Skip if the tool isn't installed
    [[ -z "$bin_path" ]] && return

    mkdir -p "$cache_dir"

    # Regenerate cache if missing or binary is newer than cache
    if [[ ! -f "$cache_file" ]] || [[ "$bin_path" -nt "$cache_file" ]]; then
        "$cmd" "$@" > "$cache_file" 2>/dev/null
    fi

    source "$cache_file"
}

# --- ATUIN ---
# Atuin replaces the default Ctrl+R history search with a much better one.
# It stores your command history in a database, supports fuzzy search,
# and can even sync history across multiple machines.
cached_eval atuin init zsh

# --- ZOXIDE ---
# Zoxide is a smarter "cd" command. Type "z project" and it jumps to
# whichever directory named "project" you visit most often. It learns
# your habits over time (tracking "frecency" -- frequency + recency).
cached_eval zoxide init zsh

# --- DIRENV ---
# Direnv auto-loads .envrc files when you cd into a project directory.
# Use it to set per-project env vars (API keys, Python venvs, PATH tweaks)
# without polluting your global shell. Run "direnv allow" in a directory
# to trust its .envrc file.
cached_eval direnv hook zsh

# --- STARSHIP PROMPT ---
# Starship is the program that draws your command prompt (the text before
# your cursor). It shows useful info like the current directory, git branch,
# Python version, etc. -- all customized in ~/.config/starship.toml.
cached_eval starship init zsh

# Optional: Powerlevel10k is an alternative prompt. To use it instead of
# Starship, uncomment the line below and comment out the Starship init above.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# =============================================================================
# Local Customizations (Machine-Specific, Not in Git)
# =============================================================================
# If a file called ~/.zshrc.local exists, load it. This is where you put
# settings that are specific to THIS computer and should not be shared
# in the dotfiles repo (like API keys, work-specific paths, etc.).
# The file is NOT tracked by git, so it stays private.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
