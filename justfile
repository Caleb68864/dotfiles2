# =============================================================================
# Caleb's Dotfiles — Task Runner
# =============================================================================
# Requires: just (https://github.com/casey/just)
# Install:  yay -S just
#
# Usage:
#   just              -- List available commands
#   just install      -- Full installation (packages + stow + plugins)
#   just stow nvim    -- Deploy a single package
#   just unstow nvim  -- Remove a single package
#   just update       -- Git pull + re-stow everything
#   just status       -- Show symlink status for all packages
# =============================================================================

# Default: list available recipes
default:
    @just --list

# Dotfiles root (auto-detected)
dotfiles := justfile_directory()

# --- Package → Stow target mapping ---
# Packages not listed here default to $HOME

# Stow a single package to its correct target
stow package:
    #!/bin/bash
    declare -A TARGETS=( \
        ["nvim"]="$HOME/.config/nvim" \
        ["kitty"]="$HOME/.config/kitty" \
        ["hypr"]="$HOME/.config/hypr" \
        ["waybar"]="$HOME/.config/waybar" \
        ["swaync"]="$HOME/.config/swaync" \
        ["yazi"]="$HOME/.config/yazi" \
        ["atuin"]="$HOME/.config/atuin" \
        ["themes"]="$HOME/.config/themes" \
        ["aerc"]="$HOME/.config/aerc" \
        ["basalt"]="$HOME/.config/basalt" \
        ["newsboat"]="$HOME/.config/newsboat" \
        ["fonts"]="$HOME/.local/share/fonts" \
    )
    TARGET="${TARGETS[{{package}}]:-$HOME}"
    mkdir -p "$TARGET"
    cd "{{dotfiles}}" && stow -Rv -t "$TARGET" "{{package}}"

# Unstow (remove) a single package
unstow package:
    #!/bin/bash
    declare -A TARGETS=( \
        ["nvim"]="$HOME/.config/nvim" \
        ["kitty"]="$HOME/.config/kitty" \
        ["hypr"]="$HOME/.config/hypr" \
        ["waybar"]="$HOME/.config/waybar" \
        ["swaync"]="$HOME/.config/swaync" \
        ["yazi"]="$HOME/.config/yazi" \
        ["atuin"]="$HOME/.config/atuin" \
        ["themes"]="$HOME/.config/themes" \
        ["aerc"]="$HOME/.config/aerc" \
        ["basalt"]="$HOME/.config/basalt" \
        ["newsboat"]="$HOME/.config/newsboat" \
        ["fonts"]="$HOME/.local/share/fonts" \
    )
    TARGET="${TARGETS[{{package}}]:-$HOME}"
    cd "{{dotfiles}}" && stow -Dv -t "$TARGET" "{{package}}"

# Dry-run stow (preview without making changes)
dry-run package:
    #!/bin/bash
    declare -A TARGETS=( \
        ["nvim"]="$HOME/.config/nvim" \
        ["kitty"]="$HOME/.config/kitty" \
        ["hypr"]="$HOME/.config/hypr" \
        ["waybar"]="$HOME/.config/waybar" \
        ["swaync"]="$HOME/.config/swaync" \
        ["yazi"]="$HOME/.config/yazi" \
        ["atuin"]="$HOME/.config/atuin" \
        ["themes"]="$HOME/.config/themes" \
        ["aerc"]="$HOME/.config/aerc" \
        ["basalt"]="$HOME/.config/basalt" \
        ["newsboat"]="$HOME/.config/newsboat" \
        ["fonts"]="$HOME/.local/share/fonts" \
    )
    TARGET="${TARGETS[{{package}}]:-$HOME}"
    cd "{{dotfiles}}" && stow -nv -t "$TARGET" "{{package}}"

# Deploy all packages
stow-all:
    #!/bin/bash
    cd "{{dotfiles}}" && bash bin/bin/deploy-all

# Full installation (run on a fresh machine)
install:
    cd "{{dotfiles}}" && bash install.sh

# Git pull + re-stow everything
update:
    cd "{{dotfiles}}" && git pull && bash bin/bin/deploy-all

# Show which packages are currently stowed (check for broken symlinks)
status:
    #!/bin/bash
    echo "Checking dotfile symlinks..."
    echo ""
    CHECKS=(
        "$HOME/.zshrc:zsh"
        "$HOME/.tmux.conf:tmux"
        "$HOME/.gitconfig:git"
        "$HOME/.config/nvim/init.lua:nvim"
        "$HOME/.config/kitty/kitty.conf:kitty"
        "$HOME/.config/hypr/hyprland.conf:hypr"
        "$HOME/.config/waybar/config.jsonc:waybar"
        "$HOME/.config/swaync/config.json:swaync"
        "$HOME/.config/yazi/yazi.toml:yazi"
        "$HOME/.config/atuin/config.toml:atuin"
        "$HOME/.config/themes/tokyo-night.conf:themes"
        "$HOME/.config/aerc/aerc.conf:aerc"
        "$HOME/.config/basalt/config.toml:basalt"
        "$HOME/.config/newsboat/config:newsboat"
        "$HOME/.local/share/fonts:fonts"
    )
    for check in "${CHECKS[@]}"; do
        file="${check%%:*}"
        pkg="${check#*:}"
        if [ -L "$file" ]; then
            printf "  \033[0;32m✓\033[0m %-12s %s\n" "$pkg" "$file"
        elif [ -e "$file" ]; then
            printf "  \033[1;33m!\033[0m %-12s %s (exists but not a symlink)\n" "$pkg" "$file"
        else
            printf "  \033[0;31m✗\033[0m %-12s %s (missing)\n" "$pkg" "$file"
        fi
    done

# List all packages (directories that look like stow packages)
packages:
    @ls -d */ | grep -v -E '^(docs|\.)'  | sed 's/\///'

# Refresh font cache
fonts:
    fc-cache -rv "$HOME/.local/share/fonts"

# Clear cached shell init files (forces regeneration on next shell)
clear-cache:
    rm -rf "$HOME/.cache/zsh"
    @echo "Shell init cache cleared. Restart your shell to regenerate."

# Install PDA environment (run on a fresh Pi)
install-pda:
    cd "{{dotfiles}}" && bash install-pda.sh

# Stow only PDA-relevant packages
stow-pda:
    #!/bin/bash
    cd "{{dotfiles}}"
    declare -A TARGETS=( \
        ["nvim"]="$HOME/.config/nvim" \
        ["atuin"]="$HOME/.config/atuin" \
        ["themes"]="$HOME/.config/themes" \
        ["newsboat"]="$HOME/.config/newsboat" \
    )
    for pkg in zsh tmux nvim git atuin themes bin scripts newsboat pda-common; do
        TARGET="${TARGETS[$pkg]:-$HOME}"
        mkdir -p "$TARGET"
        stow -Rv -t "$TARGET" "$pkg"
    done

# Unstow PDA packages
unstow-pda:
    #!/bin/bash
    cd "{{dotfiles}}"
    declare -A TARGETS=( \
        ["nvim"]="$HOME/.config/nvim" \
        ["atuin"]="$HOME/.config/atuin" \
        ["themes"]="$HOME/.config/themes" \
        ["newsboat"]="$HOME/.config/newsboat" \
    )
    for pkg in pda-common zsh tmux nvim git atuin themes bin scripts newsboat; do
        TARGET="${TARGETS[$pkg]:-$HOME}"
        stow -Dv -t "$TARGET" "$pkg" 2>/dev/null
    done

# Run the Neovim Lua test suite headlessly
test-nvim:
    nvim --headless -u nvim/tests/minimal_init.lua \
      -c "PlenaryBustedDirectory nvim/tests/ {minimal_init='nvim/tests/minimal_init.lua'}"
