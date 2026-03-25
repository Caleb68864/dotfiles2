# aerc Email Setup Guide

Terminal email client with Outlook 365, Gmail, and Obsidian integration.

## Prerequisites

```bash
# Install aerc and dependencies
yay -S aerc w3m urlscan python-markdownify qutebrowser

# Deploy the config
cd ~/dotfiles
stow -Rv -t "$HOME/.config/aerc" aerc

# Make scripts executable and symlink to PATH
chmod +x ~/.config/aerc/scripts/*
ln -sf ~/.config/aerc/scripts/mail-to-obsidian ~/.local/bin/mail-to-obsidian
ln -sf ~/.config/aerc/scripts/open-mail-html ~/.local/bin/open-mail-html
```

## File Overview

| File | Purpose |
|------|---------|
| `aerc.conf` | Main config: UI, filters, viewer, compose settings |
| `accounts.conf` | Email accounts (O365 + Gmail) with auth commands |
| `binds.conf` | Keybindings (vim-style + custom Obsidian/browser) |
| `scripts/mail-to-obsidian` | Python: export email to Obsidian vault as Markdown |
| `scripts/open-mail-html` | Bash: open email HTML in qutebrowser |

## Setting Up Gmail

### Option A: App Password (recommended, simplest)

1. Enable 2-Step Verification at https://myaccount.google.com/security
2. Generate an app password at https://myaccount.google.com/apppasswords
   - Select "Mail" as the app
   - Copy the 16-character password
3. Encrypt the password with GPG:
   ```bash
   # Create GPG key if you don't have one
   gpg --full-generate-key

   # Encrypt the password
   echo "your-16-char-app-password" | gpg --encrypt -r YOUR_EMAIL > \
     ~/.config/aerc/gmail-pass.gpg
   ```
4. Edit `accounts.conf`:
   - Replace `YOUR_GMAIL_EMAIL` with your email
   - Replace `YOUR_FULL_NAME` with your name
   - The `source-cred-cmd` already points to the GPG file

### Option B: OAuth2

See the comments in `accounts.conf` for OAuth2 setup with mutt_oauth2.py.

### Testing Gmail

```bash
# Launch aerc
aerc

# You should see your Gmail inbox appear
# If auth fails, check:
#   1. GPG can decrypt: gpg --decrypt ~/.config/aerc/gmail-pass.gpg
#   2. IMAP is enabled in Gmail settings
#   3. App password is correct (regenerate if needed)
```

## Setting Up Microsoft 365

### Step 1: Register Azure AD App

1. Go to https://portal.azure.com > Azure Active Directory > App registrations
2. Click "New registration"
   - Name: "aerc email client" (anything descriptive)
   - Supported account types: depends on your tenant
   - Redirect URI: http://localhost:5000 (Web)
3. Note the **Application (client) ID** and **Directory (tenant) ID**
4. Under "API permissions", add:
   - `IMAP.AccessAsUser.All`
   - `SMTP.Send`
   - `offline_access`
5. Under "Authentication":
   - Enable "Allow public client flows" (toggle to Yes)
6. If work-managed: ask IT admin to grant admin consent

### Step 2: Install and Configure oauth2ms

```bash
yay -S oauth2ms

# Create config
mkdir -p ~/.config/oauth2ms
cat > ~/.config/oauth2ms/config.json << 'EOF'
{
  "tenant_id": "YOUR_MS_TENANT_ID",
  "client_id": "YOUR_MS_CLIENT_ID",
  "client_secret": "",
  "redirect_host": "localhost",
  "redirect_port": "5000",
  "scopes": ["https://outlook.office365.com/.default"],
  "authority": "https://login.microsoftonline.com/YOUR_MS_TENANT_ID"
}
EOF
```

### Step 3: Authenticate

```bash
# This opens a browser for Microsoft login
oauth2ms --authorize

# Test that token refresh works
oauth2ms
# Should print an access token (long string)
```

### Step 4: Edit accounts.conf

Replace `YOUR_OUTLOOK_EMAIL`, `YOUR_FULL_NAME`, `YOUR_MS_TENANT_ID`, `YOUR_MS_CLIENT_ID`.

### Testing O365

```bash
aerc
# Switch to the Outlook tab (press Tab or :next-tab)
# You should see your inbox
# If auth fails:
#   1. Test token: oauth2ms (should print token)
#   2. Check Azure app permissions
#   3. Check if IT has blocked IMAP/SMTP
```

### Troubleshooting O365

| Problem | Cause | Fix |
|---------|-------|-----|
| "Authentication failed" | Token expired or invalid | Run `oauth2ms --authorize` again |
| "Connection refused" | IMAP/SMTP disabled by org | Ask IT to enable IMAP for your account |
| "AADSTS50011" | Redirect URI mismatch | Ensure Azure app has http://localhost:5000 as redirect |
| "Requires admin approval" | Org policy blocks custom apps | Ask IT for admin consent |

## Keybindings

### Message List
| Key | Action |
|-----|--------|
| `j/k` | Navigate messages |
| `l/Enter` | Open message |
| `E` | **Export to Obsidian** |
| `V` | **Open HTML in browser** |
| `S` | **Save raw email source** |
| `d` | Move to trash |
| `a` | Archive |
| `m` | Compose |
| `r/R` | Reply / Reply all |
| `f` | Forward |
| `t` | Toggle flag |
| `/` | Search |
| `Tab` | Switch account |

### Reading a Message
| Key | Action |
|-----|--------|
| `q/h` | Close/back |
| `E` | **Export to Obsidian** |
| `V` | **Open HTML in browser** |
| `Ctrl+U` | Extract URLs (urlscan) |
| `o` | Open attachment |
| `s` | Save attachment |

## Obsidian Export

Press `E` on any email to save it to your vault:

- **Location:** `~/Documents/Notes/Logic/Inbox/Email/`
- **Filename:** `YYYY-MM-DD Subject.md`
- **Attachments:** Saved to `_assets/` subfolder
- **Frontmatter:** title, subject, from, to, cc, date, message_id, tags

### Customizing the vault path

Set the `OBSIDIAN_VAULT` environment variable in `~/.zshrc.local`:
```bash
export OBSIDIAN_VAULT="$HOME/Documents/Notes/Logic"
```

## Limitations

- **No inline images in terminal** -- press `V` to view in browser
- **HTML rendering is best-effort** -- w3m does a decent job but complex emails need the browser
- **OAuth2 tokens expire** -- you may need to re-authenticate every 90 days for O365
- **aerc doesn't support calendars** -- use `khal` for that (Alt+7 in tmux)
