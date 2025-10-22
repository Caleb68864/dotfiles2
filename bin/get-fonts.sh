#!/bin/bash

# Font downloader script for Nerd Fonts
# Downloads and installs JetBrainsMono Nerd Font

set -e

FONT_DIR="$HOME/.files/fonts/.local/share/fonts"
TEMP_DIR="/tmp/nerd-fonts-download"
FONT_NAME="JetBrainsMono"
FONT_VERSION="v3.1.1"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${FONT_NAME}.zip"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Nerd Fonts Installer                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Check if font directory exists
if [ ! -d "$FONT_DIR" ]; then
    echo -e "${BLUE}Creating font directory...${NC}"
    mkdir -p "$FONT_DIR"
fi

# Create temp directory
echo -e "${BLUE}Creating temporary directory...${NC}"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Download font
echo -e "${BLUE}Downloading ${FONT_NAME} Nerd Font...${NC}"
if command -v aria2c &> /dev/null; then
    aria2c -x 16 -s 16 "$FONT_URL" -o "${FONT_NAME}.zip"
elif command -v wget &> /dev/null; then
    wget "$FONT_URL" -O "${FONT_NAME}.zip"
elif command -v curl &> /dev/null; then
    curl -L "$FONT_URL" -o "${FONT_NAME}.zip"
else
    echo -e "${RED}Error: No download tool found (aria2c, wget, or curl)${NC}"
    exit 1
fi

# Extract font
echo -e "${BLUE}Extracting font files...${NC}"
unzip -o "${FONT_NAME}.zip" -d "${FONT_NAME}"

# Copy to font directory
echo -e "${BLUE}Installing font files...${NC}"
find "${FONT_NAME}" -name "*.ttf" -o -name "*.otf" | while read -r font; do
    cp "$font" "$FONT_DIR/"
done

# Cleanup
echo -e "${BLUE}Cleaning up...${NC}"
cd "$HOME"
rm -rf "$TEMP_DIR"

# Refresh font cache
echo -e "${BLUE}Refreshing font cache...${NC}"
fc-cache -rv "$FONT_DIR"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}${FONT_NAME} Nerd Font has been installed!${NC}"
echo ""
echo -e "${BLUE}Verify installation:${NC}"
echo "  fc-list | grep -i '${FONT_NAME}'"
echo ""
echo -e "${BLUE}To download more fonts:${NC}"
echo "  Visit: https://www.nerdfonts.com/font-downloads"
echo ""
