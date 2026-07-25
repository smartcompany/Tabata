#!/usr/bin/env bash
# Upload Apple Watch screenshots to App Store Connect.
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

if [[ -z "${ASC_ISSUER_ID:-}" ]]; then
  echo "ASC_ISSUER_ID is required (.env)"
  exit 1
fi

exec node "$SCRIPT_DIR/update-watch-screenshots.mjs" "$@"
