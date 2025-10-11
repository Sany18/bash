# Can be sourced from different scripts
source ./deployment-commands.sh 2>/dev/null || true

local supressConnectionOutput="2>&1 | grep -v 'Connection to'"

# Install Docker and Docker Compose (if not already installed)
# Usage:
# install_docker
install_docker() {
  remote "command -v docker >/dev/null 2>&1 || \
    { curl -fsSL https://get.docker.com | sh && systemctl enable --now docker; }; \
    $supressConnectionOutput"
}

# install_docker_compose() {
#   remote "command -v docker compose >/dev/null 2>&1 || \
# }

# Version: v0.40.3
# Usage:
# install_nvm
install_nvm() {
  remote "command -v nvm >/dev/null 2>&1 || \
    { curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && source \$HOME/.bash_profile; }; \
    $supressConnectionOutput"
}

# Usage:
# install_nodejs <version>
install_nodejs() {
  install_nvm
  local node_version="${1:-18}"

  remote "nvm install $node_version || nvm use $node_version; \
  $supressConnectionOutput"
}
