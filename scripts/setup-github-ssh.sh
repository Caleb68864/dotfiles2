#!/usr/bin/env bash
# Generate SSH key for GitHub and configure ssh-agent

set -e

EMAIL="${1:-}"
KEY_FILE="$HOME/.ssh/id_ed25519_github"

if [[ -z "$EMAIL" ]]; then
    if [[ -t 0 ]]; then
        read -rp "Enter your GitHub email: " EMAIL
    else
        EMAIL="github-key"
    fi
fi

# Generate key
echo ""
echo "Generating ed25519 SSH key for GitHub..."
ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""

# Configure ~/.ssh/config to use this key for GitHub
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    echo "" >> "$SSH_CONFIG"
    cat >> "$SSH_CONFIG" <<EOF
Host github.com
    HostName github.com
    User git
    IdentityFile $KEY_FILE
    AddKeysToAgent yes
EOF
    chmod 600 "$SSH_CONFIG"
    echo "Added GitHub entry to ~/.ssh/config"
fi

# Add to ssh-agent
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add "$KEY_FILE"

# Show and copy the public key
echo ""
echo "Your public key (also copied to clipboard):"
echo "────────────────────────────────────────────────────────────────"
cat "${KEY_FILE}.pub"
echo "────────────────────────────────────────────────────────────────"
echo ""
wl-copy < "${KEY_FILE}.pub"
echo "Public key copied to clipboard."
echo ""
echo "Next steps:"
echo "  1. Go to: https://github.com/settings/ssh/new"
echo "  2. Paste the key and save"
echo "  3. Test with: ssh -T git@github.com"
echo ""
echo "Then update your dotfiles remote:"
echo "  git remote set-url origin git@github.com:Caleb68864/dotfiles2.git"
echo "  git push -u origin main"
