
# ============================================================================
# Content from scripts/load-envs.sh
# ============================================================================

set -o allexport
source "${ENV_FILE:-.env}"
set +o allexport

# ============================================================================
# Content from scripts/deployment-commands.sh
# ============================================================================

# Execute a command on the remote server
# Usage:
# remote "<command>"
remote() {
  local command="bash -lc '$1'"
  
  if [ -z "$REMOTE_HOST" ]; then
    bash -c "$command"
  elif [ -n "$SSH_KEY" ]; then
    ssh -i "$SSH_KEY" -t root@${REMOTE_HOST} "$command"
  else
    ssh -t root@${REMOTE_HOST} "$command"
  fi
}

# Upload files to remote server (with progress)
# Usage:
# upload_files <source> <destination>
upload() {
  local source="$1"
  local destination="$2"
  
  rsync -av --progress -e "ssh -i $SSH_KEY" "$source" root@${REMOTE_HOST}:"$destination"
}

# ============================================================================
# Content from scripts/install-apps.sh
# ============================================================================

# Can be sourced from different scripts
source ./deployment-commands.sh 2>/dev/null || true

# Install Docker and Docker Compose (if not already installed)
# Usage:
# install_docker
install_docker() {
  remote "command -v docker >/dev/null 2>&1 || \
    { curl -fsSL https://get.docker.com | sh && systemctl enable --now docker; }"
}

# install_docker_compose() {
#   remote "command -v docker compose >/dev/null 2>&1 || \
# }

# Version: v0.40.3
# Usage:
# install_nvm
install_nvm() {
  remote "command -v nvm >/dev/null 2>&1 || \
    { curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && source \$HOME/.bash_profile; }"
}

# Usage:
# install_nodejs <version>
install_nodejs() {
  install_nvm
  local node_version="${1:-18}"

  remote "nvm install $node_version || nvm use $node_version"
}

  
