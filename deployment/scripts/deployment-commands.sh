# Execute a command on the remote server
# Usage:
# remote "<command>"
remote() {
  local sources="~/.bashrc ~/.profile ~/.nvm/nvm.sh ~/.bash_profile"
  local applySources="for f in $sources; do [ -f \$f ] && source \$f > /dev/null 2>&1; done;"
  local command="bash -lc '$applySources $@'"
  
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
