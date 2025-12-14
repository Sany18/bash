
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
# upload <source> <destination> -- [additional rsync options]
upload() {
  local source="$1"
  local destination="$2"
  shift 2
  # choose progress option based on rsync support
  if rsync --info=progress2 --version >/dev/null 2>&1; then
    RSYNC_PROGRESS_OPT="--info=progress2"
  else
    RSYNC_PROGRESS_OPT="--progress"
  fi

  rsync -a $RSYNC_PROGRESS_OPT --out-format="%n %l" -e "ssh -i $SSH_KEY" "$@" "$source" root@${REMOTE_HOST}:"$destination" 2>&1 | grep -v 'Connection to'
}

# Download files from remote server (with progress)
# Usage:
# download <source> <destination> -- [additional rsync options]
download() {
  local source="$1"
  local destination="$2"
  shift 2
  # choose progress option based on rsync support
  if rsync --info=progress2 --version >/dev/null 2>&1; then
    RSYNC_PROGRESS_OPT="--info=progress2"
  else
    RSYNC_PROGRESS_OPT="--progress"
  fi

  rsync -a $RSYNC_PROGRESS_OPT --out-format="%n %l" -e "ssh -i $SSH_KEY" "$@" root@${REMOTE_HOST}:"$source" "$destination" 2>&1 | grep -v 'Connection to'
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

  
