---
date: 2026-03-24
topic: "Obsidian Clipping Pipeline & Markdown-to-PDF for Terminal Workflow"
author: Caleb Bennett
status: shelved
tags:
  - design
  - obsidian
  - neomutt
  - newsboat
  - pdf
  - slingmd
---

# Obsidian Clipping Pipeline & Markdown-to-PDF -- Design

## Summary

Create a terminal-native content clipping pipeline that saves emails (neomutt), RSS articles (newsboat), and web pages to the Obsidian vault as markdown notes -- replicating SlingMD's patterns (same frontmatter, wikilinks, folder structure). Also replace the old wkhtmltopdf markdown-to-PDF workflow with modern tools (typst/weasyprint + entr + zathura).

## Status: Shelved

This design is ready to implement when needed. Prerequisites:
- Phase 2+ of the TUI email design (neomutt configured and working)
- newsboat configured with RSS feeds
- GPG key set up for credential encryption
- SlingMD frontmatter patterns finalized

## Architecture

### Content Clipping Pipeline

All sources funnel through a common vault-writing script:

```
newsboat bookmark-cmd ──→ save-to-obsidian.sh ──┐
newsboat pipe-to (|)  ──→ pipe-to-obsidian.sh ──┤
neomutt pipe-message  ──→ email-to-obsidian.py ──┤
terminal web clip     ──→ clip-web              ──┤
                                                  ▼
                                      sling-to-vault.sh
                                      (sanitize title, mkdir, write
                                       frontmatter + content to vault)
                                                  ▼
                              ~/Documents/Notes/Logic/Inbox/{Email,Web,RSS}/
```

### Markdown-to-PDF Pipeline

```
Neovim editing .md  ──→  BufWritePost autocmd  ──→  pandoc + typst (~150ms)
                                                          ▼
                                                     output.pdf
                                                          ▼
                                                  zathura (auto-reloads)
```

Alternative for themed PDFs:
```
Neovim editing .md  ──→  entr watcher  ──→  pandoc + weasyprint + tokyo-night.css
```

## Packages to Install

All packages are Arch-native (no pip install on Arch):

```bash
# Markdown-to-PDF
yay -S pandoc typst python-weasyprint zathura zathura-pdf-mupdf entr

# Web clipping & content extraction
yay -S python-trafilatura python-markdownify python-beautifulsoup4

# Obsidian vault tools
yay -S obsidian-export notesmd-cli

# Optional: alternate web clipper
npm install -g percollate
```

**Note:** `python-trafilatura` and `python-markdownify` may not have official Arch packages. Check AUR first (`yay -Ss python-trafilatura`). If unavailable, use `pipx install trafilatura` (pipx is the Arch-approved way to install Python CLI tools without polluting system Python).

```bash
# Fallback if AUR packages don't exist
yay -S python-pipx
pipx install trafilatura
pipx install markdownify
```

## Components

### 1. Common Vault Writer: `bin/sling-to-vault.sh`

Central script that all clipping sources call. Mirrors SlingMD's patterns:

```bash
#!/bin/bash
# sling-to-vault.sh -- Write content to Obsidian vault with frontmatter
# Usage: sling-to-vault.sh --type email|rss|web --title "..." --source "..." --content-file /path

VAULT="$HOME/Documents/Notes/Logic"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)

# Parse args...
# Sanitize title (remove /:*?"<>| characters, truncate to 100 chars)
# Determine folder: Inbox/Email, Inbox/Web, Inbox/RSS based on --type
# Write frontmatter matching SlingMD pattern:
#   title, source, from (wikilink), to (wikilink), date, type, tags
# Append content from --content-file or stdin
```

### 2. Frontmatter Templates (matching SlingMD)

SlingMD uses these frontmatter fields. The terminal scripts must produce identical output:

**Email note:**
```yaml
---
title: "Re: Project Update"
from: "[[Jane Smith]]"
to: "[[Caleb Bennett]]"
date: 2026-03-24
type: email
threadId: "AAMkAG..."
tags:
  - email/inbox
---
```

**RSS clip:**
```yaml
---
title: "How to Use Typst for PDF Generation"
source: "https://example.com/article"
feed: "Hacker News"
date: 2026-03-24
type: clip
tags:
  - clip/rss
---
```

**Web clip:**
```yaml
---
title: "Interesting Article"
source: "https://example.com/page"
author: "Author Name"
date: 2026-03-24
type: clip
tags:
  - clip/web
---
```

### 3. Neomutt Email-to-Obsidian Script

`neomutt/scripts/email-to-obsidian.py` -- Python script piped from neomutt:

- Parses raw email from stdin using `email` stdlib
- Extracts: subject, from, to, cc, date, message-id
- Converts HTML body to markdown via `markdownify`
- Wraps sender/recipient names in `[[wikilinks]]` (matching SlingMD's contact linking)
- Calls `sling-to-vault.sh` or writes directly to vault
- Saves to `~/Documents/Notes/Logic/Inbox/Email/`

Neomutt macro: `\cs` (Ctrl+S) pipes current message to the script.

### 4. Newsboat Article-to-Obsidian Script

Two integration points:

**bookmark-cmd** (`newsboat/scripts/save-to-obsidian.sh`):
- Receives: URL, title, description, feed_title
- Uses `trafilatura -u "$URL" --markdown --with-metadata` to fetch full article
- Falls back to description if trafilatura fails
- Writes to `~/Documents/Notes/Logic/Inbox/RSS/`

**pipe-to macro** (`newsboat/scripts/pipe-to-obsidian.sh`):
- Reads rendered article text from stdin
- Parses header lines (Title, Link, Feed, Author, Date)
- Writes body as-is (already text, no HTML conversion needed)

### 5. Web Clipper: `bin/clip-web`

Manual terminal web clipping:

```bash
# Usage: clip-web "https://example.com/article"
# Extracts article, saves to vault with frontmatter
clip-web() {
    local url="$1"
    local content=$(trafilatura -u "$url" --markdown --with-metadata)
    local title=$(echo "$content" | head -1 | sed 's/^# //')
    # ... write to vault via sling-to-vault.sh
}
```

### 6. Markdown-to-PDF Setup

#### Tool Comparison

| Engine | Speed (10-page doc) | Quality | Customization |
|--------|---------------------|---------|---------------|
| **pandoc + typst** | ~150ms | Very good | Typst templates |
| pandoc + pdflatex | ~3s | Excellent | LaTeX templates |
| pandoc + xelatex | ~4s | Excellent + system fonts | LaTeX templates |
| **pandoc + weasyprint** | ~1.5s | Good | CSS stylesheets |
| pandoc + wkhtmltopdf | ~2s | Decent | CSS (DEPRECATED, don't use) |
| pandoc + groff | ~50ms | Clean | groff macros |

**Recommended: pandoc + typst** for speed. **pandoc + weasyprint** for themed PDFs.

#### Live Preview Workflow

```bash
# Terminal 1: edit
nvim document.md

# Terminal 2: watch and rebuild (~150ms per rebuild)
echo document.md | entr pandoc document.md -o document.pdf --pdf-engine=typst

# Terminal 3: view (auto-reloads on file change, preserves scroll position)
zathura document.pdf
```

Or as a tmux layout script (`bin/md-preview`):
```bash
#!/bin/bash
FILE="${1:?Usage: md-preview <file.md>}"
PDF="${FILE%.md}.pdf"

# Initial build
pandoc "$FILE" -o "$PDF" --pdf-engine=typst

# Split: zathura right, entr watcher bottom
tmux split-window -h "zathura '$PDF'"
tmux split-window -v -t 0 "echo '$FILE' | entr pandoc '$FILE' -o '$PDF' --pdf-engine=typst"
tmux select-pane -t 0
```

#### Neovim Integration (two options)

**Option A: BufWritePost autocmd (no plugin needed)**
```lua
-- In lua/config/autocommands.lua
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function()
    local file = vim.fn.expand("%:p")
    local pdf = file:gsub("%.md$", ".pdf")
    vim.fn.jobstart({"pandoc", file, "-o", pdf, "--pdf-engine=typst"}, {detach = true})
  end,
})

-- Keybind to open zathura for current file's PDF
vim.keymap.set("n", "<leader>mp", function()
  local pdf = vim.fn.expand("%:p"):gsub("%.md$", ".pdf")
  vim.fn.jobstart({"zathura", pdf}, {detach = true})
end, {desc = "[m]arkdown [p]review PDF"})
```

**Option B: knap plugin (more features)**
```lua
{
  "frabjous/knap",
  config = function()
    vim.g.knap_settings = {
      mdtopdf = "pandoc %docroot% -o %outputfile% --pdf-engine=typst",
      mdtopdfviewerlaunch = "zathura %outputfile%",
      mdtopdfviewerrefresh = "none",  -- zathura auto-reloads
    }
  end,
  keys = {
    { "<F5>", function() require("knap").process_once() end, desc = "Compile document" },
    { "<F6>", function() require("knap").toggle_autopreviewing() end, desc = "Toggle auto-preview" },
  },
}
```

#### Tokyo Night Themed PDF (weasyprint CSS)

`themes/tokyo-night-pdf.css`:
```css
@page { size: A4; margin: 2cm; background: #1a1b26; }
body { font-family: "JetBrains Mono Nerd Font", monospace; color: #c0caf5; background: #1a1b26; font-size: 11pt; line-height: 1.6; }
h1, h2, h3 { color: #7aa2f7; }
a { color: #bb9af7; }
code { background: #24283b; color: #9ece6a; padding: 2px 4px; border-radius: 3px; }
pre { background: #24283b; padding: 1em; border-radius: 6px; border-left: 3px solid #7aa2f7; }
blockquote { border-left: 3px solid #bb9af7; padding-left: 1em; color: #7dcfff; }
```

Usage: `pandoc doc.md -o doc.pdf --pdf-engine=weasyprint --css=tokyo-night-pdf.css`

#### Obsidian Markdown Preprocessing

For vault notes with wikilinks/callouts, preprocess with obsidian-export before PDF:
```bash
obsidian-export --start-at vault/note.md vault/ /tmp/export/
pandoc /tmp/export/note.md -o note.pdf --pdf-engine=typst
```

## Files to Create

### New scripts (in dotfiles stow packages)

| File | Stow Package | Purpose |
|------|-------------|---------|
| `bin/sling-to-vault.sh` | bin | Common vault writer with frontmatter |
| `bin/clip-web` | bin | Manual web clipping from terminal |
| `bin/md-preview` | bin | Tmux layout: neovim + zathura + entr |
| `neomutt/scripts/email-to-obsidian.py` | neomutt | Neomutt pipe-message handler |
| `newsboat/scripts/save-to-obsidian.sh` | newsboat (new package) | Newsboat bookmark-cmd handler |
| `newsboat/scripts/pipe-to-obsidian.sh` | newsboat (new package) | Newsboat pipe-to handler |
| `themes/tokyo-night-pdf.css` | themes | CSS stylesheet for themed PDFs |

### Existing files to edit

| File | Change |
|------|--------|
| `nvim/lua/config/autocommands.lua` | Add BufWritePost PDF auto-compile |
| `nvim/lua/config/keymaps.lua` | Add `<leader>mp` for PDF preview |
| `zsh/.zsh/functions.zsh` | Add `clip-web` function |
| `zsh/.zsh/aliases.zsh` | Add `mdpdf` alias |
| `packages.txt` | Add pandoc, typst, weasyprint, etc. |

## MCP Integration (Future)

**obsidian-claude-code-mcp** ([iansinnott/obsidian-claude-code-mcp](https://github.com/iansinnott/obsidian-claude-code-mcp)) connects Claude Code to the vault via MCP/WebSocket. Once installed, Claude Code can read, search, and write notes directly. Could be used to:
- Summarize clipped articles after they land in the inbox
- Organize and tag clipped content
- Cross-reference emails with existing notes

## Implementation Order

1. **Markdown-to-PDF** (standalone, no dependencies on email/RSS)
   - Add pandoc, typst, zathura to packages.txt
   - Add BufWritePost autocmd and `<leader>mp` keymap
   - Create `bin/md-preview` tmux layout script
   - Create `themes/tokyo-night-pdf.css`

2. **Common vault writer** (`bin/sling-to-vault.sh`)
   - Design frontmatter template matching SlingMD
   - Handle filename sanitization, folder creation
   - Test with manual input

3. **Web clipper** (`bin/clip-web`)
   - Install trafilatura
   - Wire up to sling-to-vault.sh
   - Test with real URLs

4. **Neomutt integration** (after Phase 2 of email design)
   - Create email-to-obsidian.py
   - Add neomutt macro
   - Test with real emails

5. **Newsboat integration** (after newsboat is configured)
   - Create newsboat stow package
   - Add bookmark-cmd and pipe-to scripts
   - Configure newsboat config with macros

## Open Questions

- **SlingMD compatibility:** Should the terminal scripts produce byte-for-byte identical frontmatter to SlingMD, or is "same fields, same structure" sufficient?
- **Contact wikilinks:** SlingMD creates separate contact notes and links them with `[[Name]]`. Should the terminal scripts also create contact notes, or just use wikilinks and let the user create contact notes manually?
- **Attachment handling:** SlingMD supports three attachment storage modes. What should the terminal scripts do with email attachments? Save alongside note, centralized folder, or skip?
- **Obsidian CLI vs direct file writes:** Use Obsidian CLI (requires desktop app running) or write files directly to vault (works headlessly)?
- **Daily note integration:** Should clipped content append to today's daily note, or always create standalone notes in Inbox?
- **trafilatura Arch package:** Need to verify `python-trafilatura` exists in AUR. If not, use `pipx install trafilatura`.

## Next Steps

- [ ] Verify Arch package availability for trafilatura and markdownify
- [ ] Implement markdown-to-PDF setup (item 1 above) when ready
- [ ] Finalize SlingMD frontmatter spec with user
- [ ] Implement after neomutt (Phase 2) and newsboat are working
