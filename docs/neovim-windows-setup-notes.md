# Neovim Setup Notes — What to Add on Windows / WSL

This document captures plugins and tools added to the Linux (EndeavourOS/Hyprland) Neovim setup
that are worth replicating on Windows or Ubuntu under WSL. Includes the why and how for each.

---

## Neovim Plugins (replicate on Windows / WSL)

### 1. `sindrets/diffview.nvim` — Git Diff Viewer

**Why:** The base setup has `gitsigns` for hunk indicators in the gutter, but no way to see
all changed files at once, browse git history, or resolve merge conflicts with a UI.
Diffview fills all three gaps.

**What it gives you:**
- `:DiffviewOpen` — tabbed view of every changed file in the working tree
- `:DiffviewFileHistory %` — git log for the current file with diffs
- `:DiffviewFileHistory` — git log for the entire repo
- Merge conflict resolution UI (3-pane view: ours / base / theirs)

**Keybinds:**
| Key | Action |
|-----|--------|
| `<leader>gd` | Open diffview (current changes) |
| `<leader>gc` | Close diffview |
| `<leader>gh` | File history (current file) |
| `<leader>gH` | Repo history |

**Lazy.nvim config:**
```lua
{
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("diffview").setup()
  end,
}
```

---

### 2. `ThePrimeagen/harpoon` (branch: `harpoon2`) — File Bookmarks

**Why:** Telescope is great for finding files you don't know. Harpoon is for the 3-5 files
you're actively working in during a session — switch between them instantly with a single keypress
instead of fuzzy-finding every time.

**Keybinds:**
| Key | Action |
|-----|--------|
| `<leader>ha` | Add current file to Harpoon list |
| `<leader>hl` | Toggle Harpoon list menu |
| `<leader>1` | Jump to Harpoon file 1 |
| `<leader>2` | Jump to Harpoon file 2 |
| `<leader>3` | Jump to Harpoon file 3 |
| `<leader>4` | Jump to Harpoon file 4 |

**Lazy.nvim config:**
```lua
{
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()
    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "[h]arpoon [a]dd file" })
    vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "[h]arpoon [l]ist" })
    vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
    vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
    vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
    vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
  end,
}
```

---

### 3. `kdheepak/lazygit.nvim` — Lazygit TUI inside Neovim

**Why:** Full-featured git TUI that floats inside Neovim. Stage hunks, write commits, rebase
interactively, push/pull — all without leaving Neovim. Works alongside diffview (use diffview
for browsing history/diffs, lazygit for making commits and managing branches).

**Requirement:** Install `lazygit` separately:
- Windows: `winget install JesseDuffield.lazygit` or `scoop install lazygit`
- Ubuntu/WSL: `sudo apt install lazygit` or build from source
- Arch: `yay -S lazygit`

**Keybinds:**
| Key | Action |
|-----|--------|
| `<leader>lg` | Open/close lazygit |

**Lazy.nvim config:**
```lua
{
  "kdheepak/lazygit.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>lg", "<cmd>LazyGit<CR>", desc = "[l]azy[g]it" },
  },
}
```

---

### 4. `mikavilpas/yazi.nvim` — Yazi File Manager Integration

**Why:** Yazi is a terminal file manager (like Ranger but faster, written in Rust). This plugin
lets you open it in a floating window inside Neovim and jump to files from it.

**Requirement:** Install `yazi` separately:
- Windows: `scoop install yazi` or `winget install sxyazi.yazi`
- Ubuntu/WSL: download binary from [yazi releases](https://github.com/sxyazi/yazi/releases)
- Arch: `yay -S yazi`

**Note on yazi config:** The Linux dotfiles include `~/.config/yazi/` with keymap, theme
(Tokyo Night), and preview settings. Copy that directory across — just skip or stub out the
`ripdrag` keybind (Alt+D) since ripdrag is Wayland-only and won't work on Windows/WSL.

**Yazi keymap syntax (v26.x):** Use `[[mgr.prepend_keymap]]`, NOT `[[manager.prepend_keymap]]`.
The old section name is silently ignored in newer versions.

**Keybinds:**
| Key | Action |
|-----|--------|
| `<leader>y` | Open yazi (current file's directory) |
| `<leader>Y` | Open yazi (working directory) |

**Lazy.nvim config:**
```lua
{
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>y", "<cmd>Yazi<CR>", desc = "[y]azi (current file)" },
    { "<leader>Y", "<cmd>Yazi cwd<CR>", desc = "[Y]azi (working dir)" },
  },
  opts = {
    open_for_directories = true,
  },
}
```

---

### 5. Ruff instead of isort + black (Python formatter)

**Why:** Ruff is a drop-in replacement for both `isort` and `black`, written in Rust.
10-100x faster and actively maintained.

**Requirement:**
- Windows: `pip install ruff` or `winget install Astral.Ruff`
- Ubuntu/WSL: `pip install ruff`
- Arch: `yay -S ruff`

**conform.nvim change (in init.lua):**
```lua
-- OLD:
python = { "isort", "black" },

-- NEW:
python = { "ruff_organize_imports", "ruff_format" },
```

---

## Shell Tools (Linux / WSL Ubuntu)

### Atuin — Shell History Replacement

**Why:** Replaces `Ctrl+R` history search. Stores history with context (directory, exit code,
duration), deduplicates across sessions, fuzzy search UI. Optionally syncs history across machines.

**Install:**
- Ubuntu/WSL: `curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh`
- Arch: `yay -S atuin`

**Shell init (add to `.zshrc` / `.bashrc`):**
```bash
eval "$(atuin init zsh)"   # or bash
```

**Config file** (`~/.config/atuin/config.toml`) — copy from dotfiles or create:
```toml
search_mode = "fuzzy"
filter_mode = "global"
style = "compact"
inline_height = 20
show_preview = true
enter_accept = true
exit_mode = "return-original"
secrets_filter = true

[stats]
common_subcommands = ["cargo", "docker", "git", "go", "kubectl", "npm", "systemctl", "tmux"]

[sync]
records = true
```

**Usage:** `Ctrl+R` — atuin's UI replaces the default reverse search.

---

### fzf — Fuzzy Finder with Tokyo Night Colors

**Install:**
- Ubuntu/WSL: `sudo apt install fzf` or `git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install`
- Arch: `yay -S fzf`

**Shell init (add to `.zshrc`):**
```bash
# Source Tokyo Night palette
[ -f ~/.config/themes/tokyo-night.conf ] && source ~/.config/themes/tokyo-night.conf

export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --color=fg:${THEME_FG0},bg:${THEME_BG0},hl:${THEME_YELLOW}
  --color=fg+:${THEME_FG0},bg+:${THEME_BG2},hl+:${THEME_BLUE}
  --color=info:${THEME_FG4},prompt:${THEME_BLUE},pointer:${THEME_PURPLE}
  --color=marker:${THEME_GREEN},spinner:${THEME_CYAN},header:${THEME_FG2}
  --color=border:${THEME_BG3},gutter:${THEME_BG0}
"
```

Copy `themes/tokyo-night.conf` from dotfiles to `~/.config/themes/tokyo-night.conf`.

---

### Yazi — Terminal File Manager

**Why:** Faster than Ranger, image previews in terminal, bulk rename/move, strong plugin ecosystem.

**Install:**
- Ubuntu/WSL: download binary from [yazi releases](https://github.com/sxyazi/yazi/releases)
- Arch: `yay -S yazi`

**Image previews in WSL:** Use `chafa` for image preview in WSL (ueberzugpp may not work):
```bash
sudo apt install chafa
```

**ripdrag (drag-and-drop):** Linux/Wayland only — skip this on Windows/WSL. Remove or
comment out the `Alt+D` ripdrag binding from `~/.config/yazi/keymap.toml`.

---

## Tmux (Linux / WSL — not applicable on native Windows)

### tmux-resurrect + tmux-continuum

**Why:** Without these, every tmux session layout is lost on reboot. resurrect saves/restores
session layouts; continuum auto-saves every 15 minutes.

**Setup:**
```bash
# Install TPM first:
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Add to .tmux.conf:
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-capture-pane-contents 'on'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'
run '~/.tmux/plugins/tpm/tpm'

# Then inside tmux: prefix + I to install plugins
```

**Key binds (after install):**
- `prefix + Ctrl+s` — save session manually
- `prefix + Ctrl+r` — restore session manually

---

## What Doesn't Port to Windows / WSL

| Feature | Why |
|---------|-----|
| Hyprland, Waybar, Hyprlock, etc. | Wayland compositor — Linux only |
| hyprpaper / random wallpaper | Hyprland-specific |
| ripdrag (Yazi Alt+D) | Wayland drag-and-drop — Linux only |
| swaync | Wayland notification daemon — Linux only |
| hypridle / hyprshot / hyprpicker | Hyprland ecosystem — Linux only |
| GDK_SCALE=2 env var | HiDPI Wayland workaround — not needed on Windows |
