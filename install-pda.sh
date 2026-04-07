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
echo -e "${BLUE}║       PDA (Personal Digital Assistant) Installer      ║${NC}"
echo -e "${BLUE}║   Raspberry Pi Zero 2 W — Terminal-First Workflow    ║${NC}"
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
    error "This script is designed for Arch-based systems (Arch Linux ARM, EndeavourOS, Manjaro)"
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

# Install packages from packages-pda.txt
status "Installing packages from packages-pda.txt..."
if [ -f "$DOTFILES_DIR/packages-pda.txt" ]; then
    # Remove comments and empty lines, then install
    grep -v '^#' "$DOTFILES_DIR/packages-pda.txt" | grep -v '^$' | xargs yay -Syu --needed --noconfirm
    success "Packages installed successfully"
else
    warning "packages-pda.txt not found, skipping package installation"
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

# zsh-you-should-use (reminds you of existing aliases)
if [ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use "$ZSH_CUSTOM/plugins/you-should-use"
    success "zsh-you-should-use installed"
else
    success "zsh-you-should-use already installed"
fi

# zsh-autopair (auto-close brackets, quotes, backticks)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ]; then
    git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair"
    success "zsh-autopair installed"
else
    success "zsh-autopair already installed"
fi

# Create PDA directories
status "Creating PDA directories..."
mkdir -p "$HOME/Notes/Inbox"
mkdir -p "$HOME/Notes/Calendar Notes/Daily Notes"
mkdir -p "$HOME/Media/Podcasts"
mkdir -p "$HOME/Media/Audiobooks"
mkdir -p "$HOME/Books"
mkdir -p "$HOME/.config/hypr"
touch "$HOME/.config/hypr/hyprland.local.conf"
success "PDA directories created"

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
    "$HOME/.config/atuin"
    "$HOME/.config/newsboat"
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
status "Deploying PDA dotfiles with GNU Stow..."

cd "$DOTFILES_DIR"

# List of packages to stow
PACKAGES=(
    "zsh"
    "tmux"
    "nvim"
    "git"
    "atuin"
    "themes"
    "bin"
    "scripts"
    "newsboat"
    "pda-common"
)

declare -A STOW_TARGETS=(
    ["nvim"]="$HOME/.config/nvim"
    ["atuin"]="$HOME/.config/atuin"
    ["themes"]="$HOME/.config/themes"
    ["newsboat"]="$HOME/.config/newsboat"
)
# All others (zsh, tmux, git, bin, scripts, pda-common) default to $HOME

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

# Set executable permissions on scripts
# (Git on Windows can't set the execute bit, so we fix it here on Linux)
status "Setting executable permissions on scripts..."
EXECUTABLE_SCRIPTS=(
    "$HOME/bin/tmux-pda-session"
    "$HOME/bin/pda-note"
    "$HOME/bin/tmux-command-center"
    "$HOME/bin/tmux-smart-window"
    "$HOME/bin/tmux-daily-note"
    "$HOME/bin/deploy-all"
    "$HOME/bin/undeploy"
    "$HOME/bin/get-fonts.sh"
    "$HOME/bin/switch-theme.sh"
    "$HOME/bin/yt2rss"
)
for script in "${EXECUTABLE_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        success "chmod +x $(basename $script)"
    fi
done

# Install lazy.nvim for Neovim
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
    status "Installing lazy.nvim..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable \
        "$HOME/.local/share/nvim/lazy/lazy.nvim"
    success "lazy.nvim installed"
else
    success "lazy.nvim already installed"
fi

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    status "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    success "TPM installed (press Ctrl+a then I inside tmux to install plugins)"
else
    success "TPM already installed"
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

# Print PDA completion message
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}║         PDA Installation Complete!                    ║${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    echo -e "${YELLOW}⚠ Existing dotfiles backed up to: $BACKUP_DIR${NC}"
    echo ""
fi
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Restart your terminal or run: ${YELLOW}exec zsh${NC}"
echo -e "     (Tmux PDA session will auto-start)"
echo -e "  2. Open Neovim and run: ${YELLOW}:Lazy${NC} and ${YELLOW}:Mason${NC}"
echo -e "  3. Run: ${YELLOW}:checkhealth${NC} in Neovim to verify setup"
echo -e "  4. Configure vdirsyncer for calendar sync: ${YELLOW}vdirsyncer discover${NC}"
echo ""
echo -e "${BLUE}PDA Aliases:${NC}"
echo -e "  ${YELLOW}pda${NC}              Start/attach PDA tmux session"
echo -e "  ${YELLOW}note${NC}             Quick note to ~/Notes/Inbox"
echo -e "  ${YELLOW}today${NC}            Open today's daily note"
echo -e "  ${YELLOW}feeds${NC}            Open newsboat RSS reader"
echo -e "  ${YELLOW}cal${NC}              Open khal calendar"
echo -e "  ${YELLOW}bt${NC}              Open bluetuith Bluetooth manager"
echo ""
echo -e "${BLUE}Tmux keybinds:${NC}"
echo -e "  ${YELLOW}Alt+1${NC}            Notes window"
echo -e "  ${YELLOW}Alt+2${NC}            RSS feeds window"
echo -e "  ${YELLOW}Alt+3${NC}            Calendar window"
echo -e "  ${YELLOW}Alt+4${NC}            Media window"
echo -e "  ${YELLOW}Alt+0${NC}            Scratch shell"
echo -e "  ${YELLOW}Ctrl+a, /${NC}        Cheat sheet popup"
echo ""
echo -e "${BLUE}Stow usage:${NC}"
echo -e "  Deploy a package:   ${YELLOW}stow -vRt \$HOME <package>${NC}"
echo -e "  Remove a package:   ${YELLOW}stow -DvRt \$HOME <package>${NC}"
echo -e "  Dry run:            ${YELLOW}stow -nvt \$HOME <package>${NC}"
echo ""
echo -e "${BLUE}Available packages:${NC} ${PACKAGES[*]}"
echo ""
echo -e "For more information, see: ${YELLOW}$DOTFILES_DIR/CLAUDE.md${NC}"
echo ""
