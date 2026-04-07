# =============================================================================
# Docker Aliases
# =============================================================================
# Docker lets you run applications in "containers" — lightweight isolated
# environments (like mini virtual machines). These aliases only load if
# Docker is actually installed on this machine.

if command -v docker &> /dev/null; then
    alias d='docker'                  # The main Docker command
    alias dc='docker compose'         # Docker Compose: manage multi-container apps defined in docker-compose.yml
    alias dps='docker ps'             # List running containers (like "task manager" for Docker)
    alias di='docker images'          # List downloaded container images (the "blueprints" for containers)
    alias dex='docker exec -it'       # Run a command inside a running container interactively
                                      # (e.g., "dex mycontainer bash" opens a shell inside it)
fi
