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
