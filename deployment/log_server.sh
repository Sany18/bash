#!/bin/bash

# Use environment variables
set -o allexport
source .env.local
set +o allexport

echo "Connecting to $REMOTE_HOST to show logs..."

# Add here log file address!
ssh root@$REMOTE_HOST "tail -f /var/www/${DOMAIN}/app.log"
