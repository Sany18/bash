#!/bin/bash
ENV_FILE=".env.prod"
SSH_KEY="./deploy-key"

# == Import deployment helper functions ==
remote_content=$(curl -fsSL https://raw.githubusercontent.com/Sany18/bash/refs/heads/main/deployment/dist.sh)
if ! cmp -s <(echo "$remote_content") deploy-scripts.sh; then
  echo "$remote_content" > deploy-scripts.sh
  echo "[deploy] Updated deploy-scripts.sh"
fi
source ./deploy-scripts.sh

# == Install missed packages ==
install_docker
install_nodejs 22

# == Env ==
upload "$ENV_FILE" "/var/www/${DOMAIN}/.env"

# == App ==
cd app && npm run build && cd ..
upload "./app/build/" "/var/www/${DOMAIN}/app"

# == API ==
cd api && npm run build && cd ..
upload "./api/dist" "/var/www/${DOMAIN}/api"

# == Nginx ==
upload "nginx" "/var/www/${DOMAIN}/"
remote "cd /var/www/${DOMAIN}/nginx && \
  docker compose --env-file ../.env down -v && \
  docker compose --env-file ../.env up -d --build"

# == DB ==
upload "db" "/var/www/${DOMAIN}/"
remote "cd /var/www/${DOMAIN}/db && ./start-db.sh"

# == [Clear] ==
remote "docker images -f "dangling=true" -q | xargs -r docker rmi"

# Reset cloudflare cache
echo "[deploy] Cloudflare: Purging cache"
response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/purge_cache" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}')

if echo "[deploy] $response" | grep -q '"success": true'; then
  echo "[deploy] Cloudflare: Cache purge successful"
else
  echo "[deploy] Cloudflare: Cache purge failed"
fi
