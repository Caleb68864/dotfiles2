# TUI Tools Quick-Start Guide

A guide to all the terminal tools in this dotfiles setup. Each section explains what the tool does, how to get started, and the key commands you need.

## Tmux Window Layout

When you open a terminal, tmux auto-starts with these windows:

| Key | Window | Tool | What It Does |
|-----|--------|------|-------------|
| Alt+1 | tactical | zsh | Your main working shell |
| Alt+2-3 | (open) | - | Created on demand (pi-workspace, new windows) |
| Alt+4 | notes | basalt | Browse your Obsidian vault |
| Alt+5 | music | ncmpcpp + cava | Music player + audio visualizer |
| Alt+6 | mail | neomutt | Terminal email client |
| Alt+7 | calendar | khal | Interactive calendar (syncs with O365/Google) |
| Alt+8 | news | newsboat | RSS feed reader |
| Alt+9 | weechat | weechat | IRC, Discord, Slack chat |
| Alt+0 | gomuks | gomuks | Matrix/Element chat |

**Navigation:** `Alt+number` to jump to any window. `Ctrl+a, w` for window picker.

---

## Basalt (Notes Browser) -- Alt+4

**What:** TUI for browsing and reading your Obsidian vault with rendered markdown.

**First-time setup:** Basalt reads Obsidian's vault registry. If Obsidian has been installed and opened at least once, basalt auto-discovers your vaults.

**Key commands:**
| Key | Action |
|-----|--------|
| `j/k` | Navigate up/down in file tree |
| `l/Enter` | Open a note |
| `h` | Go back / collapse folder |
| `t` or `Ctrl+B` | Toggle file explorer sidebar |
| `Ctrl+O` | Toggle outline (heading navigation) |
| `n` | Create new note |
| `N` | Create new folder |
| `r` | Rename (auto-updates wikilinks!) |
| `s` | Sort files |
| `Ctrl+G` | Switch between vaults |
| `Ctrl+Alt+E` | Open current note in Neovim |
| `?` | Help (show all keybindings) |
| `q` | Quit |

---

## ncmpcpp (Music Player) -- Alt+5 left pane

**What:** A terminal music player that controls MPD (Music Player Daemon). MPD runs in the background managing your music library; ncmpcpp is the interface.

**First-time setup:**
```bash
# 1. Create music directory
mkdir -p ~/Music

# 2. Configure MPD (create ~/.config/mpd/mpd.conf)
# Key settings: music_directory, db_file, audio_output
# See: https://wiki.archlinux.org/title/Music_Player_Daemon

# 3. Start MPD
systemctl --user enable --now mpd

# 4. Update the database
ncmpcpp --host localhost
# Press 'u' inside ncmpcpp to update the database
```

**Key commands:**
| Key | Action |
|-----|--------|
| `1-8` | Switch between views (playlist, browser, search, library, etc.) |
| `Enter` | Play selected song |
| `p` | Pause/resume |
| `s` | Stop |
| `>` / `<` | Next / previous track |
| `+` / `-` | Volume up / down |
| `r` | Toggle repeat |
| `z` | Toggle random/shuffle |
| `a` | Add to playlist |
| `u` | Update database |
| `q` | Quit |

---

## cava (Audio Visualizer) -- Alt+5 right pane

**What:** Terminal audio visualizer that shows bouncing bars reacting to whatever audio is playing. Purely aesthetic but looks amazing.

**First-time setup:** Works out of the box with PipeWire/PulseAudio. Just play music and it responds.

**Key commands:**
| Key | Action |
|-----|--------|
| `Left/Right` | Change number of bars |
| `Up/Down` | Adjust sensitivity |
| `c` | Cycle color schemes |
| `b` | Toggle between bar styles |
| `r` | Restart |
| `q` | Quit |

---

## NeoMutt (Email) -- Alt+6

**What:** Terminal email client with vim keybindings. Reads local Maildir (synced by isync/mbsync).

**First-time setup:** See `docs/plans/2026-03-24-tui-email-tmux-layout-design.md` for the full setup guide covering Gmail and O365.

**Key commands:**
| Key | Action |
|-----|--------|
| `j/k` | Navigate messages |
| `Enter` | Open/read message |
| `r` | Reply |
| `g` | Group reply (reply all) |
| `m` | Compose new email |
| `d` | Delete |
| `u` | Undelete |
| `s` | Save to folder |
| `t` | Tag/select message |
| `/` | Search |
| `v` | View attachments |
| `V` | Open in qutebrowser (HTML + images) |
| `Ctrl+O` | Save to Obsidian vault |
| `q` | Quit / go back |

---

## khal (Calendar) -- Alt+7

**What:** Terminal calendar that syncs with O365 and Google Calendar via vdirsyncer.

**First-time setup:**
```bash
# 1. Configure vdirsyncer to sync your calendars
# Edit ~/.config/vdirsyncer/config
# See: https://vdirsyncer.pimutils.org/en/stable/

# 2. Run initial sync
vdirsyncer discover
vdirsyncer sync

# 3. Configure khal to read the synced calendars
# Edit ~/.config/khal/config
# See: https://khal.readthedocs.io/en/latest/

# 4. Launch
khal interactive   # Full interactive view
khal list today 7d # Quick agenda for the week
```

**Key commands (interactive mode):**
| Key | Action |
|-----|--------|
| `j/k` | Navigate days |
| `h/l` | Previous/next week |
| `t` | Jump to today |
| `n` | New event |
| `e` | Edit event |
| `d` | Delete event |
| `Tab` | Switch between calendar and event list |
| `Enter` | View event details |
| `q` | Quit |

**Quick alias:** `agenda` shows your next 7 days without opening the full calendar.

---

## Newsboat (RSS Reader) -- Alt+8

**What:** Terminal RSS/Atom feed reader. Subscribe to blogs, YouTube channels, GitHub releases, Reddit, and read everything in one place.

**First-time setup:**
```bash
# Add feeds to ~/.config/newsboat/urls (one per line):
# https://hnrss.org/newest "~Hacker News"
# https://www.reddit.com/r/neovim/.rss "~r/neovim"
# https://github.com/neovim/neovim/releases.atom "~Neovim Releases"
# https://lukesmith.xyz/rss.xml "~Luke Smith"
# https://www.youtube.com/feeds/videos.xml?channel_id=CHANNEL_ID "~YouTuber"

# For YouTube, find the channel ID in the page source or use:
# https://www.youtube.com/feeds/videos.xml?channel_id=UC2eYFnH61tmktItuZa2pNtQ
```

**Key commands:**
| Key | Action |
|-----|--------|
| `j/k` | Navigate up/down |
| `l/Enter` | Open feed / read article |
| `h/q` | Go back |
| `r` | Reload current feed |
| `R` | Reload ALL feeds |
| `o` | Open article in browser |
| `b` | Bookmark article (save to Obsidian -- future) |
| `n/N` | Next/previous unread |
| `J/K` | Next/previous feed |
| `G/g` | Go to bottom/top |
| `/` | Search |
| `q` | Quit |

---

## Weechat (IRC/Discord/Slack) -- Alt+9

**What:** Extensible terminal chat client. Supports IRC natively, Discord and Slack via plugins.

**First-time setup:**
```bash
# IRC is built-in:
/server add libera irc.libera.chat/6697 -tls
/connect libera
/nick YourNick
/join #archlinux

# For Discord (via weechat-discord plugin):
# See: https://github.com/terminal-discord/weechat-discord

# For Slack (via wee-slack plugin):
# See: https://github.com/wee-slack/wee-slack
```

**Key commands:**
| Key | Action |
|-----|--------|
| `Alt+1-9` | Switch between chat buffers (channels) |
| `Alt+Left/Right` | Previous/next buffer |
| `Ctrl+N/P` | Next/previous buffer |
| `/msg nick message` | Send private message |
| `/join #channel` | Join a channel |
| `/part` | Leave current channel |
| `/quit` | Quit weechat |
| `F11/F12` | Scroll nick list |
| `PgUp/PgDown` | Scroll chat history |

**Note:** Weechat's Alt+number keys may conflict with tmux's Alt+number window switching. Inside the weechat window, use `Esc` then the number (press Esc, release, then press the number) or configure weechat to use a different key.

---

## Gomuks (Matrix/Element) -- Alt+0

**What:** Terminal client for the Matrix protocol (what Element uses). Encrypted chat, rooms, direct messages.

**First-time setup:**
```bash
# Launch gomuks
gomuks

# On first run, it asks for:
# 1. Homeserver URL (usually https://matrix.org or your company's server)
# 2. Username
# 3. Password
# It stores credentials locally and auto-connects next time.
```

**Key commands:**
| Key | Action |
|-----|--------|
| `Alt+Up/Down` | Switch between rooms |
| `Enter` | Send message |
| `Ctrl+L` | Toggle room list sidebar |
| `/join #room:server` | Join a room |
| `/leave` | Leave current room |
| `/reply` | Reply to a message |
| `/react 👍` | Add a reaction |
| `Tab` | Autocomplete usernames |
| `Ctrl+C` | Quit |

---

## On-Demand Tools (not auto-started, just type the alias)

| Alias | Tool | What It Does |
|-------|------|-------------|
| `audio` | pulsemixer | TUI audio mixer -- adjust volume, switch outputs |
| `bt` | bluetuith | TUI bluetooth manager -- pair, connect, disconnect devices |
| `top` | btop | System monitor -- CPU, RAM, disk, network, processes |
| `notes` | basalt | Obsidian vault browser (also Alt+4 in tmux) |
| `agenda` | khal | Show your calendar agenda for the next 7 days |
| `lg` | lazygit | Full Git TUI -- stage, commit, push, rebase, resolve conflicts |

---

## Other CLI Tools Installed

These are command-line tools you use directly in the shell:

| Tool | Replaces | What It Does |
|------|----------|-------------|
| `bat` | `cat` | Print files with syntax highlighting |
| `eza` | `ls` | List files with icons and colors |
| `fd` | `find` | Fast file finder with sane defaults |
| `rg` | `grep` | Fast text search across files |
| `dust` | `du` | Visual disk usage tree |
| `duf` | `df` | Pretty mounted filesystem table |
| `procs` | `ps` | Modern process viewer with search |
| `jq` | - | JSON processor (query/transform JSON) |
| `yq` | - | YAML/TOML/XML processor (like jq for YAML) |
| `xh` | `curl` | Friendly HTTP client with colors |
| `glow` | - | Render markdown beautifully in terminal |
| `tldr` | `man` | Simplified command examples (tealdeer) |
| `ouch` | `tar/unzip` | Universal compress/decompress |
| `navi` | - | Interactive cheatsheet browser (fzf-powered) |
| `age` | `gpg` | Simple modern file encryption |
| `just` | `make` | Project-specific command runner |
| `direnv` | - | Auto-load environment variables per directory |
| `ncdu` | - | Interactive disk usage explorer |
| `w3m` | - | Terminal web browser |
| `yt-dlp` | - | Download YouTube/web videos |
| `rsync` | `cp/scp` | Efficient file sync between machines |

---

## Getting Help

- **Tmux cheat sheet:** Press `Ctrl+a` then `/`
- **Neovim cheat sheet:** Press `Space` then `?`
- **Any tool's quick help:** `tldr <toolname>` (e.g., `tldr rsync`)
- **Full manual:** `man <toolname>`
- **Navi cheatsheets:** Just type `navi` for an interactive cheatsheet browser
