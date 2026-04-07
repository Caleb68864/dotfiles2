# =============================================================================
# System Aliases (Arch Linux / EndeavourOS)
# =============================================================================
# These use "yay" — an AUR helper that can install packages from both
# the official Arch repos AND the AUR (Arch User Repository, where
# community members share their own packages).

alias update='yay -Syu'              # Update ALL installed packages to their latest versions
alias cleanup='yay -Sc --noconfirm && yay -Yc --noconfirm'
                                      # Clean up: remove cached old package files (Sc) AND
                                      # remove unneeded dependencies (Yc) to free disk space
alias orphans='yay -Qtdq'            # List "orphan" packages — packages that were installed as
                                      # dependencies but are no longer needed by anything
alias remove-orphans='yay -Rns $(yay -Qtdq)'
                                      # Remove all orphan packages AND their config files (-n)
                                      # AND their now-unneeded dependencies (-s). Full cleanup.
