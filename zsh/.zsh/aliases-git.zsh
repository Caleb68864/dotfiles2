# =============================================================================
# Git Aliases
# =============================================================================
# Git is the version control system that tracks changes to your code.
# These aliases make common git commands faster to type.
# (Oh-My-Zsh's git plugin adds many more, but these are personal favorites.)

alias gs='git status'                 # Show which files are changed, staged, or untracked
alias ga='git add'                    # Stage files to be included in the next commit
alias gc='git commit'                 # Save staged changes as a new commit (snapshot)
alias gp='git push'                   # Upload your commits to the remote server (GitHub)
alias gl='git pull'                   # Download new commits from the remote server
alias gd='git diff'                   # Show what changed in files (line by line)
alias gco='git checkout'              # Switch to a different branch or restore files
alias gb='git branch'                 # List, create, or delete branches
alias glog='git log --oneline --graph --decorate --all'  # Show a pretty visual tree of all branches and commits
alias lg='lazygit'                    # Open LazyGit — a beautiful terminal UI for git
                                      # (much easier than remembering all git commands)
