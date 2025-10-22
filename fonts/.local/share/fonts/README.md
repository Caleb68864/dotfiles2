# Fonts Directory

This directory contains custom fonts that will be symlinked to `~/.local/share/fonts` via GNU Stow.

## Installation

1. Add your `.ttf`, `.otf`, or other font files to this directory
2. Run `stow -vRt "$HOME" fonts` from the dotfiles root
3. Refresh the font cache: `fc-cache -rv`

## Recommended Fonts

- **JetBrainsMono Nerd Font** - Great for terminal and coding
- **FiraCode Nerd Font** - Popular monospace font with ligatures
- **Hack Nerd Font** - Clean monospace font

## Automatic Download

Use the helper script to download recommended Nerd Fonts:

```bash
bash ~/dotfiles/bin/get-fonts.sh
```

This will download and install JetBrainsMono Nerd Font automatically.

## Manual Download

Visit [Nerd Fonts](https://www.nerdfonts.com/font-downloads) to download fonts manually.

Extract the downloaded fonts to this directory, then run:

```bash
fc-cache -rv ~/.local/share/fonts
```

## Verify Installation

List all available fonts:

```bash
fc-list | grep -i "JetBrains"
```
