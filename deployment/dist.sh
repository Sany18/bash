
# ============================================================================
# Content from scripts/load-envs.sh
# ============================================================================

set -o allexport
source "${ENV_FILE:-.env}"
set +o allexport

# ============================================================================
# Content from scripts/deployment-commands.sh
# ============================================================================

# Check and install rclone if not present
ensure_rclone() {
  if ! command -v rclone &> /dev/null; then
    echo "rclone not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      if command -v brew &> /dev/null; then
        brew install rclone
      else
        curl https://rclone.org/install.sh | sudo bash
      fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Linux
      curl https://rclone.org/install.sh | sudo bash
    else
      echo "Unsupported OS. Please install rclone manually: https://rclone.org/install/"
      return 1
    fi
    echo "rclone installed successfully."
  fi
}

# Execute a command on the remote server
# Usage:
# remote "<command>"
remote() {
  local sources="~/.bashrc ~/.profile ~/.nvm/nvm.sh ~/.bash_profile"
  local applySources="for f in $sources; do [ -f \$f ] && source \$f > /dev/null 2>&1; done;"
  local command="bash -lc \"$applySources $@\""
  
  if [ -z "$REMOTE_HOST" ]; then
    bash -c "$command" 2>&1 | grep -v 'Connection to'
  elif [ -n "$SSH_KEY" ]; then
    ssh -i "$SSH_KEY" -t ${REMOTE_USER:-root}@${REMOTE_HOST} "$command" 2>&1 | grep -v 'Connection to'
  else
    ssh -t ${REMOTE_USER:-root}@${REMOTE_HOST} "$command" 2>&1 | grep -v 'Connection to'
  fi
}

# Upload files to remote server (with progress)
# Usage:
# upload <source> <destination> -- [additional rclone options]
upload() {
  ensure_rclone
  local source="$1"
  local destination="$2"
  shift 2

  rclone copy --stats-one-line --stats 1s --sftp-host "${REMOTE_HOST}" --sftp-user "${REMOTE_USER:-root}" --sftp-key-file "$SSH_KEY" "$@" "$source" ":sftp:$destination" 2>&1 | grep -v 'Connection to'
}

# Download files from remote server (with progress)
# Usage:
# download <source> <destination> -- [additional rclone options]
download() {
  ensure_rclone
  local source="$1"
  local destination="$2"
  shift 2

  rclone copy --stats-one-line --stats 1s --sftp-host "${REMOTE_HOST}" --sftp-user "${REMOTE_USER:-root}" --sftp-key-file "$SSH_KEY" "$@" ":sftp:$source" "$destination" 2>&1 | grep -v 'Connection to'
}

# ============================================================================
# Content from scripts/install-apps.sh
# ============================================================================

# Can be sourced from different scripts
# source ./deployment-commands.sh

# Install Docker and Docker Compose (if not already installed)
# Usage:
# install_docker
install_docker() {
  remote "command -v docker >/dev/null 2>&1 || \
    { curl -fsSL https://get.docker.com | sh && systemctl enable --now docker; };"
}

# install_docker_compose() {
#   remote "command -v docker compose >/dev/null 2>&1 || \
# }

# Version: v0.40.3
# Usage:
# install_nvm
install_nvm() {
  remote "command -v nvm >/dev/null 2>&1 || \
    { curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && source \$HOME/.bash_profile; };"
}

# Usage:
# install_nodejs <version>
install_nodejs() {
  install_nvm
  local node_version="${1:-18}"

  remote "nvm install $node_version || nvm use $node_version;"
}

  
