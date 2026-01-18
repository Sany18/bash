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

  rclone copy --log-level ERROR --stats-one-line --stats 1s --sftp-host "${REMOTE_HOST}" --sftp-user "${REMOTE_USER:-root}" --sftp-key-file "$SSH_KEY" "$@" "$source" ":sftp:$destination" 2>&1 | grep -v 'Connection to'
}

# Download files from remote server (with progress)
# Usage:
# download <source> <destination> -- [additional rclone options]
download() {
  ensure_rclone
  local source="$1"
  local destination="$2"
  shift 2

  rclone copy --log-level ERROR --stats-one-line --stats 1s --sftp-host "${REMOTE_HOST}" --sftp-user "${REMOTE_USER:-root}" --sftp-key-file "$SSH_KEY" "$@" ":sftp:$source" "$destination" 2>&1 | grep -v 'Connection to'
}
