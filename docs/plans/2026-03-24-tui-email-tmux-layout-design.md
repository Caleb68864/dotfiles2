---
date: 2026-03-24
topic: "TUI Email, Tmux Layout & Communication Stack for EndeavourOS"
author: Caleb Bennett
status: draft
tags:
  - design
  - email
  - neomutt
  - tmux
  - communication
---

# TUI Email, Tmux Layout & Communication Stack -- Design

## Summary

Add terminal email (neomutt), GUI email fallback (Evolution), Microsoft Teams, and auto-starting TUI apps to the dotfiles, with a redesigned tmux session model that supports multiple independent terminal windows. This migrates the user's email/communication workflow from Windows to Linux while keeping the terminal-first philosophy with GUI fallbacks for rich content.

## Goals

1. **Terminal email** -- Read, triage, and reply to email from neomutt (vim keybindings, offline-capable)
2. **Rich content fallback** -- One-key shortcut to open any email in Vivaldi for images, HTML, and attachments
3. **Obsidian integration** -- Save emails as markdown notes in the vault with frontmatter metadata
4. **Microsoft 365 support** -- OAuth2 authentication for work Outlook email
5. **Gmail support** -- App password authentication for personal email
6. **Microsoft Teams** -- GUI app on workspace 4 alongside Discord/Element
7. **Auto-starting TUI layout** -- Mail, news, and monitoring available immediately on terminal launch
8. **Multi-terminal independence** -- Multiple terminal windows show different tmux windows, not mirrors

## Architecture

### New Stow Packages

```
dotfiles2/
├── neomutt/                         # NEW Stow package (target: ~/.config/neomutt)
│   ├── neomuttrc                    # Main neomutt config
│   ├── mailcap                      # MIME type handlers (w3m, vivaldi, chafa, etc.)
│   ├── accounts/
│   │   ├── outlook365.muttrc        # Work email account config (O365 OAuth2)
│   │   └── gmail.muttrc            # Personal email account config (app password)
│   ├── colors/
│   │   └── tokyonight.muttrc       # Tokyo Night theme for neomutt
│   └── scripts/
│       ├── view-in-browser.sh       # Extract HTML part and open in qutebrowser
│       └── save-to-obsidian.sh      # Pipe email to Obsidian vault as markdown note
├── isync/                           # NEW Stow package (target: ~/.config)
│   └── mbsyncrc                     # isync/mbsync config for offline IMAP sync
├── msmtp/                           # NEW Stow package (target: ~/.config/msmtp)
│   └── config                       # SMTP send config for both accounts
```

### Existing Files Modified

```
├── hypr/hyprland.conf               # EDIT: add Teams window rule to workspace 4
├── zsh/.zshrc                       # EDIT: change tmux auto-start to grouped sessions
├── tmux/.tmux.conf                  # EDIT: add TUI app auto-start layout (optional)
├── zsh/.zsh/aliases.zsh             # EDIT: add mail aliases
├── packages.txt                     # EDIT: add new packages
├── install.sh                       # EDIT: add neomutt, isync, msmtp packages + stow targets
├── bin/tmux-command-center          # NEW: tmux session layout builder script
```

### How it fits the existing Stow model

- `neomutt/` stows to `~/.config/neomutt` (like yazi, atuin, swaync)
- `isync/` contains `.mbsyncrc` which stows to `~/.mbsyncrc` (target: `$HOME`)
  - OR stows to `~/.config/isync/mbsyncrc` if using XDG path
- `msmtp/` stows to `~/.config/msmtp` (XDG compliant)
- `bin/tmux-command-center` goes in existing `bin/` package (stows to `~/bin/`)

## Components

### 1. Neomutt Email Client

**Terminal email with vim keybindings, offline support, and rich content fallback.**

#### Why neomutt over alternatives

| Client | Pros | Cons |
|--------|------|------|
| **neomutt** | Most mature, best docs, Luke Smith's mutt-wizard, huge community, vim native | No inline images, OAuth2 is complex |
| **aerc** | Modern Go codebase, tabs, native JMAP | No OAuth2, smaller community, fewer features |
| **himalaya** | Rust, native OAuth2, scriptable CLI | Not a TUI (no interactive reading), early-stage TUI |

**Decision: neomutt.** It's the most proven, best documented, and mutt-wizard handles the hard setup parts. The lack of inline images is universal across all TUI email clients.

#### Image Handling Strategy

**No TUI email client supports Kitty graphics protocol for inline images.** This is a fundamental limitation of ncurses/tcell-based rendering. The strategy:

| Content Type | How It's Handled |
|-------------|-----------------|
| Plain text email | Rendered inline by neomutt (native) |
| HTML email | Rendered as text by w3m inline; press `V` to open in lightweight browser (qutebrowser) |
| Inline images | Press `V` to open full email in qutebrowser (instant startup, vim keybindings) |
| Image attachments | `chafa` for rough ASCII preview, or `kitten icat` for external Kitty window |
| PDF attachments | Open in zathura via mailcap |

#### Key Neomutt Keybindings

| Key | Action |
|-----|--------|
| `V` | Open current email in lightweight browser (qutebrowser -- instant, vim keys) |
| `Ctrl+U` | Extract URLs with urlscan, pick one to open |
| `Ctrl+O` | Save email to Obsidian vault as markdown note |
| `v` | View attachments list |
| `j/k` | Navigate messages (vim-style) |
| `d` | Delete, `u` = undelete |
| `r` | Reply, `g` = group reply |
| `m` | Compose new email |

#### Lightweight Browser for Email Viewing

Vivaldi is too heavy for quick email HTML viewing. Options:

| Browser | Startup | Vim Keys | Wayland | Notes |
|---------|---------|----------|---------|-------|
| **qutebrowser** | ~0.5s | Native | Yes | Best fit -- vim keybindings, Python/Qt, lightweight |
| surf | ~0.1s | No | No (X11 only) | Suckless, ultra-minimal, but X11 only |
| luakit | ~0.3s | Vim-like | Partial | WebKit-based, Lua config |
| nyxt | ~1s | Emacs/Vim | Yes | Lisp-based, heavier than qutebrowser |

**Decision: qutebrowser.** Vim keybindings native, Wayland native, fast startup, and you can close it with `q` just like everything else. Install: `yay -S qutebrowser`

#### Mailcap Configuration

```mailcap
# HTML: text rendering for inline view, lightweight browser for explicit open
text/html; qutebrowser %s; nametemplate=%s.html
text/html; w3m -dump -o display_link_number=true -T text/html %s; copiousoutput

# Images: chafa for rough inline preview, kitten icat for full view
image/*; kitten icat --hold %s
image/*; chafa --size=80x24 %s; copiousoutput

# PDFs: open in zathura
application/pdf; zathura %s
```

### 2. Email Account Authentication

#### Microsoft 365 (Work) -- OAuth2

OAuth2 is mandatory for O365. Two approaches:

**Option A: mutt_oauth2.py (ships with neomutt)**
- Requires Azure AD app registration (client ID + tenant ID)
- Handles token acquisition and refresh
- Tokens encrypted with GPG

**Option B: oauth2ms (AUR package)**
- Purpose-built for mutt + O365
- `yay -S oauth2ms`
- Simpler config than raw mutt_oauth2.py

**Decision: Start with oauth2ms.** Simpler setup, AUR package available.

**Prerequisite:** Azure AD app registration with IMAP.AccessAsUser.All, SMTP.Send, and offline_access permissions. If Caleb doesn't control the Azure tenant, admin consent may be needed.

#### Gmail (Personal) -- App Password

App passwords are the simplest and most reliable approach for personal Gmail:
1. Enable 2-Step Verification on Google account
2. Generate app password at myaccount.google.com > Security > App passwords
3. Store encrypted with GPG: `echo "password" | gpg --encrypt -r caleb@email.com > ~/.config/neomutt/gmail-pass.gpg`

### 3. Offline Email Sync (isync/mbsync)

isync (command: `mbsync`) syncs IMAP to local Maildir format. This means:
- Email is stored locally -- readable offline
- Fast searching (no network round-trips)
- Neomutt reads from local Maildir, not live IMAP
- Periodic sync via cron or manual `mbsync -a`

```
~/.local/share/mail/
├── outlook365/          # Work email Maildir
│   ├── INBOX/
│   ├── Sent/
│   ├── Drafts/
│   └── Archive/
└── gmail/               # Personal email Maildir
    ├── INBOX/
    ├── Sent/
    └── Archive/
```

### 4. Obsidian Integration

Press `Ctrl+O` in neomutt to save current email to Obsidian vault:

- Extracts: subject, sender, date, body
- Converts HTML body to markdown via pandoc
- Saves to `~/Documents/Notes/Logic/Email Inbox/YYYY-MM-DD Subject.md`
- YAML frontmatter with tags, from, date, subject fields
- Attachments saved to vault's attachment folder

**Future:** Extend SlingMD project to handle email-to-note pipeline more robustly.

### 5. Microsoft Teams

**Option A: teams-for-linux (AUR Electron wrapper)**
- `yay -S teams-for-linux`
- Native Wayland support, works on Hyprland
- Window rule to workspace 4 alongside Discord/Element

**Option B: Vivaldi web app**
- Open teams.microsoft.com in Vivaldi
- Use Vivaldi's "Install as App" feature
- No extra Electron process

**Decision: teams-for-linux** for dedicated app feel with notifications. Add window rule:
```
windowrule = workspace 4 silent, match:class ^(teams-for-linux)$
```

### 6. GUI Email: Evolution

For rich content, calendar invites, and when you need the full email experience:
- `yay -S evolution evolution-ews`
- Native Exchange Web Services for O365
- CalDAV/CardDAV for calendars and contacts
- Window rule to workspace 4 or separate workspace

### 7. Tmux Session Redesign

#### Problem: Multiple terminals mirror the same view

Current `.zshrc` uses `exec tmux attach-session -t command-center` which forces every terminal window to show the same tmux window. Opening 3 Kitty windows = 3 identical views.

#### Solution: Grouped sessions

```bash
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    if tmux has-session -t command-center 2>/dev/null; then
        # Create a GROUPED session -- shares windows but each terminal
        # can independently view a different window
        exec tmux new-session -t command-center
    else
        # First terminal: create the main session with auto-start layout
        exec ~/bin/tmux-command-center
    fi
fi
```

**How grouped sessions work:**
- All terminals share the same window set (tactical, mail, monitor, etc.)
- But each terminal can look at a **different** window independently
- Alt+1 in terminal 1 goes to window 1; terminal 2 stays on window 3
- If a terminal closes, the main session and all apps keep running
- SSH reconnects just create a new grouped session -- instant recovery
- The `aggressive-resize` setting (already in .tmux.conf) optimizes for this

#### Auto-Start Layout Script: `bin/tmux-command-center`

Creates the full session with TUI apps pre-loaded:

```bash
#!/bin/bash
# tmux-command-center -- Create the command-center session with TUI apps

SESSION="command-center"

# Create session with first window
tmux new-session -d -s "$SESSION" -n tactical

# Window 2: mail (neomutt)
tmux new-window -t "$SESSION" -n mail
tmux send-keys -t "$SESSION:mail" "neomutt" Enter

# Window 3: monitor (btop)
tmux new-window -t "$SESSION" -n monitor
tmux send-keys -t "$SESSION:monitor" "btop" Enter

# Window 4: news (newsboat -- future, starts empty for now)
# tmux new-window -t "$SESSION" -n news
# tmux send-keys -t "$SESSION:news" "newsboat" Enter

# Focus on window 1 (tactical)
tmux select-window -t "$SESSION:tactical"

# Attach to the session
exec tmux attach -t "$SESSION"
```

#### Final Window Layout

| Window # | Name | Content | Alt+Key |
|----------|------|---------|---------|
| 1 | tactical | Default shell (your working terminal) | Alt+1 |
| 2 | mail | neomutt | Alt+2 |
| 3 | monitor | btop | Alt+3 |
| 4 | news | newsboat (future) | Alt+4 |
| 5+ | agent | Created on demand by pi-workspace | Alt+5+ |

## Data Flow

```
Terminal opens
  └── .zshrc tmux auto-start
       ├── First time: ~/bin/tmux-command-center creates session + TUI apps
       └── Subsequent: tmux new-session -t command-center (grouped)
            └── Independent window view per terminal

Email flow:
  mbsync -a  ──→  ~/.local/share/mail/  ──→  neomutt reads Maildir
                                               ├── Inline: w3m text render
                                               ├── Press V: open in qutebrowser
                                               ├── Press Ctrl+O: save to Obsidian
                                               └── Press Ctrl+U: urlscan links

Sending:
  neomutt compose  ──→  msmtp  ──→  smtp.office365.com (OAuth2)
                                     smtp.gmail.com (app password)
```

## Packages to Install

```bash
# Email
yay -S neomutt isync msmtp msmtp-mta oauth2ms w3m urlscan pandoc qutebrowser

# Communication
yay -S teams-for-linux evolution evolution-ews

# Monitoring / TUI
yay -S btop newsboat
```

Add all to `packages.txt`.

## Error Handling

- **OAuth2 token expired:** `oauth2ms` auto-refreshes. If refresh token expires (90 days), re-run `oauth2ms --authorize` to re-authenticate via browser
- **Azure AD admin consent needed:** If work tenant blocks the app, fall back to Evolution for work email and use neomutt for Gmail only
- **mbsync fails:** Neomutt still reads last-synced Maildir -- offline capability preserved
- **neomutt not installed:** `tmux-command-center` script should check `command -v neomutt` before launching mail window
- **Grouped session detach:** If main session is killed, grouped sessions die too. The auto-start script recreates it on next terminal open

## Open Questions

- **Azure AD tenant access:** Does Caleb have permission to register apps in the work tenant? If not, oauth2ms setup needs IT admin involvement
- **Email volume:** How much email? High-volume may need notmuch indexing on top of Maildir for fast search
- **Calendar:** Should neomutt/terminal handle calendar invites, or delegate entirely to Evolution?
- **Contacts:** Use abook (terminal address book) or rely on Evolution/O365 contacts?
- **Auto-sync interval:** How often should mbsync run? Options: cron every 5 min, systemd timer, or manual `mbsync -a`
- **Notifications:** Should new email trigger a swaync notification? (mbsync + notify-send in a cron/timer)

## Implementation Checklist

### Phase 1: Tmux Redesign (do first -- no new packages needed)
- [ ] Create `bin/tmux-command-center` script
- [ ] Edit `zsh/.zshrc` to use grouped sessions + layout script
- [ ] Test: open 3 terminals, verify independent window views
- [ ] Add `btop` to packages.txt if not present

### Phase 2: Neomutt + Gmail (simpler auth, good for learning)
- [ ] Create `neomutt/` stow package directory
- [ ] Write `neomuttrc` with Tokyo Night theme, vim keybindings, sidebar
- [ ] Write `mailcap` with w3m, vivaldi, chafa, zathura handlers
- [ ] Configure Gmail account with app password (encrypted via GPG)
- [ ] Configure isync/mbsync for Gmail
- [ ] Configure msmtp for Gmail sending
- [ ] Write `save-to-obsidian.sh` and `view-in-browser.sh` scripts
- [ ] Add to install.sh: neomutt stow package
- [ ] Test: send and receive email from terminal

### Phase 3: Microsoft 365 (OAuth2 complexity)
- [ ] Register Azure AD application (or get IT to do it)
- [ ] Install and configure oauth2ms
- [ ] Add O365 account to neomutt
- [ ] Add O365 to mbsync config
- [ ] Add O365 to msmtp config
- [ ] Test: send and receive work email from terminal

### Phase 4: Teams + Evolution + Window Rules
- [ ] Install teams-for-linux
- [ ] Add Hyprland window rule for teams to workspace 4
- [ ] Install Evolution + evolution-ews
- [ ] Configure Evolution with O365 account
- [ ] Add to packages.txt and install.sh

### Phase 5: Polish
- [ ] Add mail aliases to aliases.zsh
- [ ] Update CLAUDE.md with email architecture
- [ ] Set up mbsync auto-sync (cron or systemd timer)
- [ ] Optional: new email notifications via swaync
- [ ] Optional: newsboat window in tmux-command-center (future phase)

## Next Steps

- [ ] Implement Phase 1 (tmux redesign) immediately -- zero dependencies
- [ ] Set up GPG key on Linux machine if not done
- [ ] Get Azure AD tenant info from IT for Phase 3
- [ ] Turn this into a Forge spec for phased implementation
