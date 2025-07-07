#!/usr/bin/env bash
set -euo pipefail

install_curl() {
  if command -v curl &>/dev/null; then return; fi
  echo "curl not found — installing..."
  if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y curl
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y curl
  elif command -v yum &>/dev/null; then
    sudo yum install -y curl
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm curl
  elif command -v apk &>/dev/null; then
    sudo apk add curl
  else
    echo "Unable to detect a package manager to install curl" >&2
    exit 1
  fi
}

install_docker() {
  if command -v docker &>/dev/null && docker compose version &>/dev/null; then return; fi
  echo "Installing Docker and docker compose..."
  curl -fsSL https://raw.githubusercontent.com/onezuppi/install-docker-sh/master/install-docker.sh -o install-docker.sh
  sudo bash install-docker.sh
  rm -f install-docker.sh
  if ! groups "$USER" | grep -q '\bdocker\b'; then
    sudo usermod -aG docker "$USER"
    echo "User $USER added to docker group. Re-login or run 'newgrp docker'."
  fi
}

prompt_auth_code() {
  read -rp "Enter auth_code (valid 1 minute): " AUTH_CODE
  if [[ -z "${AUTH_CODE}" ]]; then
    echo "auth_code cannot be empty" >&2
    exit 1
  fi
}

request_jwt() {
  echo "Requesting JWT from BringYour API..."
  RESPONSE=$(curl -sS -X POST \
    -H "Accept: */*" \
    -H "Content-Type: application/json" \
    -d "{\"auth_code\":\"${AUTH_CODE}\"}" \
    https://api.bringyour.com/auth/code-login)
  if command -v jq &>/dev/null; then
    BY_JWT=$(printf '%s' "$RESPONSE" | jq -r '.by_jwt // empty')
  else
    BY_JWT=$(printf '%s' "$RESPONSE" | grep -o '"by_jwt"[^"]*"[^\"]*"' | sed 's/.*"by_jwt"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  fi
  if [[ -z "${BY_JWT}" ]]; then
    echo "Failed to extract by_jwt from response" >&2
    exit 1
  fi
}

save_jwt() {
  mkdir -p ./urnetwork
  echo "${BY_JWT}" > ./urnetwork/jwt
  chmod 600 ./urnetwork/jwt
  echo "JWT saved to ./urnetwork/jwt"
}

create_compose() {
  cat > docker-compose.yml <<'EOF'
services:
  urnetwork:
    container_name: urnetwork-provider
    image: bringyour/community-provider:g4-latest
    network_mode: host
    entrypoint: "/usr/local/sbin/bringyour-provider provide"
    restart: unless-stopped
    volumes:
      - ./urnetwork:/root/.urnetwork
EOF
  echo "docker-compose.yml created"
}

start_compose() {
  echo "Starting urnetwork-provider container..."
  docker compose up -d
  echo "urnetwork-provider is running"
}

main() {
  install_curl
  install_docker
  prompt_auth_code
  request_jwt
  save_jwt
  create_compose
  start_compose
}

main "$@"
