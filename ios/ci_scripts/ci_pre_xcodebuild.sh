#!/bin/sh
# Xcode Cloud: xcodebuild 직전 Flutter iOS 설정 생성 (Generated.xcconfig 등)

set -e

CLIENT_DIR="${CI_PRIMARY_REPOSITORY_PATH}/client"
export PATH="${PATH}:${HOME}/flutter/bin"

echo "=== ci_pre_xcodebuild: flutter build ios --config-only --release ==="
cd "${CLIENT_DIR}"
flutter build ios --config-only --release

echo "=== ci_pre_xcodebuild complete ==="
exit 0
