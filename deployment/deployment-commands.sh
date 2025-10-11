set -o allexport
source "${ENV_FILE:-.env}"
set +o allexport

# Execute a command on the remote server
# Usage:
# remote "<command>"
remote() {
  local command="bash -lc '$1'"
  
  if [ -z "$REMOTE_HOST" ]; then
    bash -c "$command"
  elif [ -n "$SSH_KEY" ]; then
    ssh -i "$SSH_KEY" root@${REMOTE_HOST} "$command"
  else
    ssh root@${REMOTE_HOST} "$command"
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
