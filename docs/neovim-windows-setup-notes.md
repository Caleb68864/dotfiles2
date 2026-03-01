# Neovim Setup Notes — What to Add on Windows

This document captures the plugins and tools added to the Linux (EndeavourOS/Hyprland) Neovim setup
that are worth replicating on Windows. Includes the why and how for each.

---

## Plugins Added (Linux — replicate on Windows)

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

**What it gives you:**
- Mark files to a per-project list with `<leader>ha`
- Jump to marked files 1-4 with `<leader>1` through `<leader>4`
- Open the list with `<leader>hl` to reorder/remove

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
- Linux: `yay -S lazygit`

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
lets you open it in a floating window inside Neovim and jump to files from it. More powerful than
nvim-tree for bulk operations (rename, move, copy multiple files) while staying in Neovim.

**Requirement:** Install `yazi` separately:
- Windows: `scoop install yazi` or `winget install sxyazi.yazi`
- Linux: `yay -S yazi`

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

**Why:** Ruff is a drop-in replacement for both `isort` (import sorting) and `black` (formatting),
written in Rust. It's 10-100x faster, produces identical output, and is actively maintained.
No reason to run both isort and black when ruff does both in one pass.

**Requirement:** Install `ruff`:
- Windows: `pip install ruff` or `winget install Astral.Ruff`
- Linux: `yay -S ruff`

**conform.nvim change (in init.lua):**
```lua
-- OLD:
python = { "isort", "black" },

-- NEW:
python = { "ruff_organize_imports", "ruff_format" },
```

`ruff_organize_imports` = equivalent to isort
`ruff_format` = equivalent to black

---

## Shell Tools (Linux-specific, reference for WSL/Windows Terminal)

### Atuin — Shell History Replacement

**Why:** Replaces `Ctrl+R` history search. Stores history with context (directory, exit code,
duration), deduplicates across sessions, and gives a much better fuzzy search UI.
Optionally syncs history across machines.

**Setup (Linux/WSL):**
```bash
yay -S atuin
# Add to .zshrc / .bashrc:
eval "$(atuin init zsh)"
```

**Usage:** Press `Ctrl+R` — atuin's UI replaces the default reverse search.

### Yazi — Terminal File Manager

**Why:** Faster than Ranger, image previews in terminal, bulk rename/move, strong plugin ecosystem.
Pairs with yazi.nvim to jump to files from within Neovim.

---

## Tmux Tools (Linux — not applicable on Windows unless using WSL)

### tmux-resurrect + tmux-continuum

**Why:** Without these, every tmux session layout is lost on reboot. resurrect saves/restores
session layouts (windows, panes, working directories, even running programs). continuum
auto-saves every 15 minutes and auto-restores on tmux start.

**Setup:**
```bash
# Install TPM first:
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# In .tmux.conf (at the bottom):
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
