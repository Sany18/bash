# Can be sourced from different scripts
source ./deployment-commands.sh 2>/dev/null || true

# Install Docker and Docker Compose (if not already installed)
# Usage:
# install_docker
install_docker() {
  remote "command -v docker >/dev/null 2>&1 || \
    { curl -fsSL https://get.docker.com | sh && systemctl enable --now docker; }"
}

install_docker_compose() {
  remote "command -v docker-compose >/dev/null 2>&1 || \
    DOCKER_CONFIG=\${DOCKER_CONFIG:-\$HOME/.docker} && \
    mkdir -p \$DOCKER_CONFIG/cli-plugins && \
    curl -SL https://github.com/docker/compose/releases/download/v2.40.0/docker-compose-linux-x86_64 -o \$DOCKER_CONFIG/cli-plugins/docker-compose && \
    chmod +x \$DOCKER_CONFIG/cli-plugins/docker-compose"
}

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
