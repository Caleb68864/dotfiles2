#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                       ║${NC}"
echo -e "${BLUE}║       Caleb's Dotfiles Installation Script           ║${NC}"
echo -e "${BLUE}║       Stow + Starship + Hyprland + Neovim            ║${NC}"
echo -e "${BLUE}║                                                       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status messages
status() {
    echo -e "${BLUE}==>${NC} ${1}"
}

success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

warning() {
    echo -e "${YELLOW}!${NC} ${1}"
}

error() {
    echo -e "${RED}✗${NC} ${1}"
}

# Check if running on Arch-based system
if ! command -v pacman &> /dev/null; then
    error "This script is designed for Arch-based systems (EndeavourOS, Arch Linux, Manjaro)"
    exit 1
fi

# Install yay if not present
if ! command -v yay &> /dev/null; then
    status "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm base-devel git
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    success "yay installed successfully"
else
    success "yay already installed"
fi

# Install packages from packages.txt
status "Installing packages from packages.txt..."
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    # Remove comments and empty lines, then install
    grep -v '^#' "$DOTFILES_DIR/packages.txt" | grep -v '^$' | xargs yay -Syu --needed --noconfirm
    success "Packages installed successfully"
else
    warning "packages.txt not found, skipping package installation"
fi

# Install Oh-My-Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    status "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh-My-Zsh installed"
else
    success "Oh-My-Zsh already installed"
fi

# Install Oh-My-Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

status "Installing Oh-My-Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    success "zsh-autosuggestions installed"
else
    success "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    success "zsh-syntax-highlighting installed"
else
    success "zsh-syntax-highlighting already installed"
fi

# fzf-tab
if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
    success "fzf-tab installed"
else
    success "fzf-tab already installed"
fi

# Optional: powerlevel10k (commented by default, using Starship instead)
# if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
#     git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
#     success "powerlevel10k installed"
# else
#     success "powerlevel10k already installed"
# fi

# Create necessary directories
status "Creating necessary directories..."
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.config"
success "Directories created"

# Backup existing dotfiles
status "Backing up existing dotfiles..."
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# List of files and directories that might conflict
CONFLICT_ITEMS=(
    "$HOME/.zshrc"
    "$HOME/.zsh"
    "$HOME/.tmux.conf"
    "$HOME/.gitconfig"
    "$HOME/.config/starship.toml"
    "$HOME/.config/nvim"
    "$HOME/.config/hypr"
    "$HOME/.config/waybar"
    "$HOME/.config/swaync"
    "$HOME/.config/atuin"
    "$HOME/.local/share/fonts"
)

for item in "${CONFLICT_ITEMS[@]}"; do
    if [ -e "$item" ] && [ ! -L "$item" ]; then
        # Create parent directory structure in backup
        parent_dir="$BACKUP_DIR/$(dirname ${item#$HOME/})"
        mkdir -p "$parent_dir"

        status "Backing up ${item#$HOME/}..."
        mv "$item" "$parent_dir/"
        success "${item#$HOME/} backed up"
    fi
done

if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    success "Backup completed: $BACKUP_DIR"
else
    rm -rf "$BACKUP_DIR"
fi

# Deploy dotfiles using Stow
status "Deploying dotfiles with GNU Stow..."

cd "$DOTFILES_DIR"

# List of packages to stow
PACKAGES=(
    "zsh"
    "tmux"
    "nvim"
    "kitty"
    "hypr"
    "waybar"
    "swaync"
    "yazi"
    "atuin"
    "git"
    "fonts"
    "scripts"
    "bin"
    "themes"
)

declare -A STOW_TARGETS=(
    ["hypr"]="$HOME/.config/hypr"
    ["waybar"]="$HOME/.config/waybar"
    ["nvim"]="$HOME/.config/nvim"
    ["kitty"]="$HOME/.config/kitty"
    ["swaync"]="$HOME/.config/swaync"
    ["yazi"]="$HOME/.config/yazi"
    ["atuin"]="$HOME/.config/atuin"
    ["fonts"]="$HOME/.local/share/fonts"
)

for package in "${PACKAGES[@]}"; do
    if [ -d "$package" ]; then
        status "Stowing $package..."
        target="${STOW_TARGETS[$package]:-$HOME}"
        mkdir -p "$target"
        stow -Rv -t "$target" "$package"
        success "$package stowed"
    else
        warning "$package directory not found, skipping"
    fi
done

# Refresh font cache
if [ -d "$HOME/.local/share/fonts" ]; then
    status "Refreshing font cache..."
    fc-cache -rv "$HOME/.local/share/fonts"
    success "Font cache refreshed"
fi

# Install lazy.nvim for Neovim
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
    status "Installing lazy.nvim..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable \
        "$HOME/.local/share/nvim/lazy/lazy.nvim"
    success "lazy.nvim installed"
else
    success "lazy.nvim already installed"
fi

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    warning "Current shell is not zsh"
    read -p "Would you like to change your default shell to zsh? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s "$(which zsh)"
        success "Default shell changed to zsh (restart session to apply)"
    fi
else
    success "Default shell is already zsh"
fi

# Print completion message
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}║           Installation Complete!                      ║${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR)" ]; then
    echo -e "${YELLOW}⚠ Existing dotfiles backed up to: $BACKUP_DIR${NC}"
    echo ""
fi
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Restart your terminal or run: ${YELLOW}exec zsh${NC}"
echo -e "  2. Open Neovim and run: ${YELLOW}:Lazy${NC} and ${YELLOW}:Mason${NC}"
echo -e "  3. Run: ${YELLOW}:checkhealth${NC} in Neovim to verify setup"
echo -e "  4. Configure your Hyprland monitors in ${YELLOW}~/.config/hypr/hyprland.conf${NC}"
echo ""
echo -e "${BLUE}Stow usage:${NC}"
echo -e "  Deploy a package:   ${YELLOW}stow -vRt \$HOME <package>${NC}"
echo -e "  Remove a package:   ${YELLOW}stow -DvRt \$HOME <package>${NC}"
echo -e "  Dry run:            ${YELLOW}stow -nvt \$HOME <package>${NC}"
echo ""
echo -e "${BLUE}Available packages:${NC} ${PACKAGES[*]}"
echo ""
echo -e "For more information, see: ${YELLOW}$DOTFILES_DIR/README.md${NC}"
echo ""
