---
date: 2026-04-07
topic: "Terminal PDA environment for Raspberry Pi Zero 2 W"
author: Caleb Bennett
status: evaluated
evaluated_date: 2026-04-07
tags:
  - design
  - terminal-pda-environment
  - pda
  - raspberry-pi
---

# Terminal PDA Environment -- Design

## Summary

Design a purpose-built terminal PDA environment running on a Raspberry Pi Zero 2 W with a physical keyboard and small screen. The PDA uses the existing dotfiles2 repo's shared config (shell-common, tmux-common, newsboat-common, nvim-common) with a new `pda-common` stow package layered on top via `*.local` override files. The result boots directly into a daily note in nvim, with instant access to RSS feeds, calendar, ebooks, media playback, and SSH -- all within tmux.

## Approach Selected

**Approach B: Single repo with PDA package (layered stow)** -- chosen because shared config stays in sync automatically (single `git pull`), the `*.local` override pattern already exists in tmux and hyprland configs, and the zsh glob loader auto-discovers `aliases-pda.zsh`. No submodule management needed.

## Architecture

```
                         dotfiles2 repo
                    +----------------------+
                    |                      |
   SHARED LAYER     |  shell-common        |  Stowed on ALL machines
   (terminal base)  |  tmux-common         |  (desktop, PDA, server)
                    |  newsboat-common     |
                    |  nvim-common         |
                    |                      |
   -----------------+----------------------+
                    |                      |
   DESKTOP LAYER    |  desktop-linux       |  Stowed on DESKTOP only
   (Linux GUI)      |  hyprland            |
                    |  kitty               |
                    |                      |
   -----------------+----------------------+
                    |                      |
   PDA LAYER        |  pda-common          |  Stowed on PDA only
   (Pi Zero 2 W)    |                      |
                    |                      |
   -----------------+----------------------+
```

Key principle: The shared layer works identically on both machines. The PDA layer overrides behavior through:
1. `*.local` config files (tmux, zsh) that the shared configs already source
2. `aliases-pda.zsh` auto-loaded by the glob loader in `.zshrc`
3. A PDA-specific tmux session builder that replaces the desktop's `tmux-command-center`
4. Neovim `after/` directory for PDA-specific markdown optimizations

Deployment:
- Desktop: `stow shell-common tmux-common newsboat-common nvim-common desktop-linux hyprland kitty`
- PDA: `stow shell-common tmux-common newsboat-common nvim-common pda-common`

## Components

### 1. `pda-common` stow package (stow target: $HOME)

All PDA-specific configuration and scripts.

| File | Purpose |
|------|---------|
| `.tmux.conf.local` | PDA tmux overrides: smaller status bar, PDA session name, small-screen opts |
| `.zsh/aliases-pda.zsh` | PDA aliases: `note`, `today`, `inbox`, `feeds`, `agenda`, `books`, `ssh-home`, `ssh-server` |
| `bin/tmux-pda-session` | PDA session builder: notes/inbox/feeds/calendar/books/media/ssh/scratch |
| `bin/pda-note` | Instant note capture: creates timestamped file in vault Inbox, opens in nvim |
| `bin/pda-agenda` | Formatted khal output for small screens |
| `.zsh/aliases-pda.zsh` also exports `PDA_MODE=1` and `TMUX_SESSION_BUILDER` | Env vars that gate nvim plugins and tmux session builder |

<!-- Assumption: ASM-3 resolved -- lazy.nvim ignores after/plugin/. Using PDA_MODE env var in plugin specs instead. -->
Note: Heavy nvim plugins (DAP, AI, Treesitter, telescope) are disabled via `enabled = not vim.env.PDA_MODE` in existing plugin spec files, NOT via an `after/plugin/` file. The `PDA_MODE=1` env var is set in `aliases-pda.zsh`.

### 2. `install-pda.sh` (root-level script)

PDA-specific installation:
1. Installs PDA system packages (khal, vdirsyncer, mpv, yt-dlp, ebook reader)
2. Stows only: shell-common, tmux-common, newsboat-common, nvim-common, pda-common
3. Creates PDA directory structure (~/Notes/, ~/Media/, ~/Books/)
4. Sets up vdirsyncer for CalDAV sync
5. Skips desktop packages entirely

### 3. PDA tmux session layout (`tmux-pda-session`)

| Key | Window | App | Notes |
|-----|--------|-----|-------|
| Alt+1 | notes | nvim (daily note) | **Default** -- boots here |
| Alt+2 | inbox | nvim (inbox note) | Quick capture |
| Alt+3 | feeds | newsboat | RSS + YouTube |
| Alt+4 | calendar | khal interactive | Calendar view |
| Alt+5 | books | epy/bookokrat | Ebook reader |
| Alt+6 | media | (empty/mpv) | Media playback |
| Alt+7 | ssh | (empty) | SSH sessions |
| Alt+0 | scratch | shell | Quick one-offs |

Key difference from desktop: PDA boots directly into daily note (window 1), not an empty shell.

<!-- Assumption: ASM-4, ASM-12 resolved -- .zshrc uses $TMUX_SESSION_BUILDER variable -->
**Session builder override:** `.zshrc` tmux auto-start uses `$TMUX_SESSION_BUILDER` (defaults to `tmux-command-center`). `aliases-pda.zsh` exports `TMUX_SESSION_BUILDER="$HOME/bin/tmux-pda-session"`. Since alias files load before the tmux auto-start block, this works.

**Session name:** PDA uses the same session name "command-center" as the desktop. This ensures all shared tmux keybindings (smart-window Alt+N, prefix+Space, etc.) work without per-machine rebinding.

<!-- Assumption: ASM-11 resolved -- xdg-open needs $BROWSER on headless PDA -->
**Browser fallback:** `aliases-pda.zsh` exports `BROWSER=w3m` so `xdg-open` in newsboat falls back to a terminal browser instead of failing.

### 4. PDA filesystem layout

```
~/
+-- Notes/                    # Obsidian vault (synced via git or syncthing)
|   +-- .obsidian/
|   +-- Calendar Notes/
|   |   +-- Daily Notes/      # YYYY-MM-DD.md
|   +-- Inbox/                # Quick captures
+-- Media/
|   +-- Podcasts/             # podboat downloads
|   +-- Audiobooks/
+-- Books/                    # EPUBs
+-- dotfiles/                 # This repo
```

## Data Flow

### Boot sequence (power on -> writing)

```
Pi boots -> autologin to tty1
  -> zsh loads .zshrc
    -> sources shell-common (aliases, themes, env vars, cached inits)
    -> sources aliases-pda.zsh (PDA aliases, OBSIDIAN_VAULT override)
    -> tmux auto-start block runs
      -> no session -> runs $TMUX_SESSION_BUILDER (~/bin/tmux-pda-session on PDA)
        -> creates "command-center" session (same name on all machines for keybinding compat)
        -> window 1: opens today's daily note in nvim
        -> windows 2-7: created idle (lazy-loaded on first access)
        -> USER IS WRITING within seconds of boot
```

### Note capture

`pda-note` generates `$OBSIDIAN_VAULT/Inbox/YYYY-MM-DD-HHMMSS.md`, creates frontmatter, opens in nvim. Plain Markdown, Obsidian-compatible.

### Feed consumption

newsboat -> select article -> `,m` streams in mpv, `,o` clips to vault, `,d` downloads via yt-dlp, `e` enqueues in podboat.

### Media playback

mpv with `--save-position-on-quit` for resume. Audio-only for podcasts. Terminal video (`--vo=tct`) for small screen video.

### Calendar

khal interactive for browsing/editing. vdirsyncer cron job for CalDAV sync. `pda-agenda` alias for quick today+7d view.

## Error Handling

### Vault not present
`tmux-pda-session` checks `$OBSIDIAN_VAULT` exists. If not, window 1 shows setup instructions. `pda-note` creates Inbox with `mkdir -p` -- notes are never lost.

### Offline usage
PDA must be fully useful offline:
- newsboat: shows cached articles
- khal: locally cached calendar, edits saved for next sync
- Notes: fully local, Resilio Sync queues changes for when online
- Podcasts/books: all local files

### Small screen (40-50 cols)
- `.tmux.conf.local`: minimal status bar (session + window number only)
- Short window names (3-4 chars)
- nvim: word wrap, linebreak, no line numbers, no statusline plugins

### No Wayland clipboard
<!-- Assumption: ASM-5 resolved -- wl-copy does NOT fail silently; it errors with "command not found". -->
The shared `.tmux.conf` hardcodes `wl-copy` in copy-mode bindings. On PDA, these will error ("command not found"), not fail silently. **Fix:** `.tmux.conf.local` must rebind all copy-mode keys to use `tmux load-buffer -` instead:
```
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "tmux load-buffer -"
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "tmux load-buffer -"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "tmux load-buffer -"
bind Y run-shell "tmux capture-pane -p | tmux load-buffer - && tmux display 'Pane copied to buffer!'"
```
For newsboat clipboard macro (`macro c`), it will also fail. `aliases-pda.zsh` sets `export BROWSER=w3m` as a fallback for `xdg-open`, and the clipboard macro can be overridden if a PDA-specific newsboat config is added later.

### Pi Zero 2 W resource limits (512MB RAM)
- nvim `pda.lua` disables: Treesitter, DAP, AI, telescope
- Tmux windows lazy-load apps on first access
- mpv: small cache (`--cache-secs=30`)
- Ebook reader chosen for low memory footprint

## Open Questions (Resolved)

1. **Vault sync mechanism:** Resilio Sync (already in use across devices). Low-overhead daemon, handles binary files well. Install `rslsync` on Pi, configure shared folders for each vault.
2. **Ebook reader:** Bookokrat preferred (Rust, library management features). Will test on Pi Zero 2 W; fallback to epy if resource-heavy.
3. **CalDAV provider:** Google Calendar + Outlook 365. vdirsyncer needs two calendar configs -- Google via OAuth2, Outlook via OAuth2 (or app password). Template both in `pda-common`.
4. **Vault identity:** Personal vault as default (`$OBSIDIAN_VAULT`). Multi-vault support planned -- scripts should accept a vault path argument and fall back to `$OBSIDIAN_VAULT`. Resilio Sync handles per-vault folder sync.
5. **Physical keyboard:** TBD -- not yet selected. Design Alt+N window switching as primary but keep prefix+N as fallback for keyboards without a numrow.
6. **Audio output:** Bluetooth audio for v1 (bluez + PipeWire). Speaker output deferred to v2. Needs `pipewire`, `wireplumber`, `bluez`, `bluetuith` (TUI Bluetooth manager, already aliased as `bt`).

## Approaches Considered

### Approach A: Submodule overlay
Separate `pda-dotfiles` repo with `dotfiles2` as git submodule. Clean separation but adds submodule friction (`git submodule update`), possible stow conflicts, two repos to maintain. Rejected because shared config sync was a stated requirement and submodules add unnecessary complexity.

### Approach B: Single repo + pda-common (SELECTED)
Add `pda-common` package to dotfiles2. Uses `*.local` overrides and selective stow. Single repo, instant sync, zero submodule management. The `*.local` pattern and glob alias loader were just built for this exact use case.

### Approach C: Separate repos, manual sync
Two independent repos with cherry-picks. Total independence but guaranteed config drift. Violates the "shared config stays in sync" requirement. Rejected.

## Commander's Intent

**Desired End State:** A Pi Zero 2 W that boots to a tmux session with today's daily note open in nvim, and provides instant access to RSS feeds (newsboat), calendar (khal), ebooks (bookokrat), media (mpv), and SSH -- all navigable with Alt+N window switching. The entire environment is configured by stowing `shell-common`, `tmux-common`, `newsboat-common`, `nvim-common`, and `pda-common` from dotfiles2.

**Purpose:** Replace phone-based note capture and content consumption with a dedicated, distraction-free terminal device that integrates with the existing Obsidian vault ecosystem.

**Constraints:**
- MUST: Run within 512MB RAM (Pi Zero 2 W)
- MUST: Boot to a writable note within 10 seconds of login
- MUST: Work fully offline (notes, cached feeds, local books/podcasts)
- MUST: Use plain Markdown files compatible with Obsidian vault structure
- MUST: Share base config with desktop dotfiles (single repo, selective stow)
- MUST NOT: Require Wayland, X11, or any display server
- MUST NOT: Modify shared config files in ways that break the desktop

**Freedoms:**
- The implementing agent MAY choose tmux window numbering and naming
- The implementing agent MAY choose the exact frontmatter template for `pda-note`
- The implementing agent MAY choose between `w3m` and `links` for PDA terminal browser
- The implementing agent MAY choose mpv flags for audio/video on small screen

## Execution Guidance

**Observe (signals to monitor during implementation):**
- Stow conflicts when deploying pda-common alongside shared packages
- nvim startup time on Pi (target: <3 seconds with PDA_MODE)
- RAM usage with tmux + nvim + newsboat running simultaneously
- Resilio Sync daemon memory footprint on Pi

**Orient (context to maintain):**
- Follow existing script patterns from `tmux-command-center` and `tmux-smart-window`
- Match comment style and documentation level of existing dotfiles (heavily commented)
- Use `command -v` guards for optional tools (same pattern as `tmux-command-center`)
- Use `${VAR:-default}` pattern for all paths (same as `OBSIDIAN_VAULT` usage throughout repo)

**Escalate When:**
- Stow conflicts between pda-common and any shared package (means package boundaries are wrong)
- nvim startup exceeds 5 seconds even with PDA_MODE (may need a separate minimal init)
- Resilio Sync uses >100MB RAM on Pi (may need a lighter sync solution)
- Any change to shared config is needed (must not break desktop)

**Shortcuts (Apply Without Deliberation):**
- Use `#!/bin/bash` + `set -e` for all new scripts (matches existing bin/ scripts)
- Use the `EXECUTABLE_SCRIPTS` pattern from `install.sh` for chmod in `install-pda.sh`
- Use `command -v app &> /dev/null` guards for optional apps (matches `tmux-command-center`)
- Use `mkdir -p` before writing to any vault path (matches `pda-note` and `newsboat-to-obsidian`)

## Decision Authority

**Agent Decides Autonomously:**
- File and folder structure within `pda-common/`
- Script implementations (tmux-pda-session, pda-note, pda-agenda)
- Alias naming and function signatures in aliases-pda.zsh
- Tmux window layout, numbering, and naming
- nvim PDA_MODE conditionals placement in plugin specs
- mpv configuration flags
- install-pda.sh structure and flow

**Agent Recommends, Human Approves:**
- Which nvim plugins to disable in PDA_MODE (list the specific plugins)
- Newsboat config changes affecting shared behavior
- Resilio Sync folder configuration
- vdirsyncer CalDAV auth setup templates
- Any new system packages added to packages-pda.txt

**Human Decides:**
- Vault directory structure and naming on Pi
- CalDAV account credentials and OAuth tokens
- SSH host aliases, keys, and connection details
- Physical hardware selection (keyboard, screen, case)
- Resilio Sync shared folder pairing with other devices
- Whether to ship w3m or links as the PDA terminal browser

## War-Game Results

**Most Likely Failure:** nvim startup time on Pi Zero 2 W. Even with PDA_MODE disabling heavy plugins, lazy.nvim's bootstrap + completion engine + LSP may take 5-10 seconds on the single-core ARM CPU. **Mitigation:** Test actual startup. If >3 seconds, create a `$HOME/.config/nvim/init-pda.lua` that bypasses lazy.nvim entirely: just loads options, keymaps, and basic syntax highlighting. Set `NVIM_APPNAME=nvim-pda` in aliases-pda.zsh to use it.

**Dependency Risk:** Resilio Sync is proprietary and closed-source. If ARM builds are discontinued, sync breaks. **Mitigation:** Vault is plain files. Syncthing is an open-source drop-in. Git-based sync is always a manual fallback. No vendor lock-in on the data.

**Maintenance (6-month):** Design is clear. The `pda-common` package is self-contained. A developer reading the plan would know exactly what to build. The `PDA_MODE` env var approach is particularly clean -- grep for `PDA_MODE` to find all PDA-specific behavior.

**Resilio Sync resource concern:** 512MB RAM is tight. Resilio Sync typically uses 50-150MB. With tmux + nvim + newsboat, total could approach 400MB. **Mitigation:** Monitor with `free -h` during testing. If tight, consider Syncthing (typically lighter) or cron-based rsync over SSH.

## Evaluation Metadata
- Evaluated: 2026-04-07
- Cynefin Domain: Complicated
- Critical Gaps Found: 2 (2 resolved)
- Important Gaps Found: 3 (3 resolved)
- Suggestions: 3 (documented)

## Next Steps
- [ ] Turn this design into a Forge spec (`/forge docs/plans/2026-04-07-terminal-pda-environment-design.md`)
- [ ] Refactor `.zshrc` tmux auto-start to use `$TMUX_SESSION_BUILDER` variable
- [ ] Add `PDA_MODE` guards to nvim plugin specs (dap.lua, ai.lua, treesitter.lua, editor.lua telescope)
- [ ] Test Pi Zero 2 W resource usage with target tools (nvim, newsboat, mpv, khal)
- [ ] Set up Pi Zero 2 W hardware and test autologin -> tmux -> nvim boot sequence
