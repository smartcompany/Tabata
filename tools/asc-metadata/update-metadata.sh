#!/usr/bin/env bash
# Upload App Store listing + What's New metadata via App Store Connect API.
#
# Usage:
#   ./update-metadata.sh --dry-run
#   ./update-metadata.sh
#   ./update-metadata.sh --only whatsNew
#   ./update-metadata.sh --only name,subtitle,description,keywords,promotionalText
#   ./update-metadata.sh --version 1.0.3
#
# Requires: Node 18+, ASC_ISSUER_ID (env or .env)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DEFAULT_KEY="/Users/smart/Projects/auth/fastlaneAuthKeys/AuthKey_7FN57R567Z.p8"
DEFAULT_KEY_ID="7FN57R567Z"
DEFAULT_BUNDLE_ID="com.smartcompany.tabata"

if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
  set +a
fi

export ASC_KEY_ID="${ASC_KEY_ID:-$DEFAULT_KEY_ID}"
export ASC_PRIVATE_KEY_PATH="${ASC_PRIVATE_KEY_PATH:-$DEFAULT_KEY}"
export ASC_BUNDLE_ID="${ASC_BUNDLE_ID:-$DEFAULT_BUNDLE_ID}"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  exec node "$SCRIPT_DIR/update-metadata.mjs" --help
fi

if [[ -z "${ASC_ISSUER_ID:-}" ]]; then
  echo "ASC_ISSUER_ID is required."
  echo "App Store Connect → Users and Access → Keys → Issuer ID 를 복사한 뒤:"
  echo "  1) $SCRIPT_DIR/.env 에 ASC_ISSUER_ID=... 추가, 또는"
  echo "  2) ASC_ISSUER_ID=... ./update-metadata.sh"
  exit 1
fi

if [[ ! -f "$ASC_PRIVATE_KEY_PATH" ]]; then
  echo "Auth key not found: $ASC_PRIVATE_KEY_PATH"
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "node is required (Node 18+)."
  exit 1
fi

echo "Key ID:  $ASC_KEY_ID"
echo "Key:     $ASC_PRIVATE_KEY_PATH"
echo "Bundle:  $ASC_BUNDLE_ID"
echo

exec node "$SCRIPT_DIR/update-metadata.mjs" "$@"
