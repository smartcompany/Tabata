#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
  set +a
fi

export PLAY_PACKAGE_NAME="${PLAY_PACKAGE_NAME:-com.smartcompany.tabata}"
DEFAULT_PLAY_KEY="/Users/smart/Projects/auth/play-publisher/play-publisher-504708-798db1ae50fd.json"
export PLAY_SERVICE_ACCOUNT_JSON="${PLAY_SERVICE_ACCOUNT_JSON:-$DEFAULT_PLAY_KEY}"

if [[ ! -d "$SCRIPT_DIR/node_modules/googleapis" ]]; then
  echo "Installing dependencies (googleapis)…"
  npm install --no-fund --no-audit
fi

if [[ "${1:-}" == "--dry-run" ]] || [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  exec node "$SCRIPT_DIR/update-whats-new.mjs" "$@"
fi

if [[ -z "${PLAY_SERVICE_ACCOUNT_JSON:-}" ]]; then
  echo "PLAY_SERVICE_ACCOUNT_JSON is required."
  exit 1
fi

echo "Package: $PLAY_PACKAGE_NAME"
echo "Key:     $PLAY_SERVICE_ACCOUNT_JSON"
echo

exec node "$SCRIPT_DIR/update-whats-new.mjs" "$@"
