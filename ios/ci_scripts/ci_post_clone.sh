#!/bin/sh
# Xcode Cloud: Flutter SDK + 의존성 설치 (share_lib = Git 릴리즈 모드)
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts

set -e

echo "=== ci_post_clone: repo=${CI_PRIMARY_REPOSITORY_PATH} ==="

CLIENT_DIR="${CI_PRIMARY_REPOSITORY_PATH}/client"
IOS_DIR="${CLIENT_DIR}/ios"

if [ ! -f "${CLIENT_DIR}/pubspec.yaml" ]; then
  echo "error: ${CLIENT_DIR}/pubspec.yaml not found"
  exit 1
fi

FLUTTER_HOME="${HOME}/flutter"
if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  echo "=== Installing Flutter (stable) ==="
  rm -rf "${FLUTTER_HOME}"
  git clone https://github.com/flutter/flutter.git -b stable "${FLUTTER_HOME}"
fi
export PATH="${PATH}:${FLUTTER_HOME}/bin"
flutter --version

echo "=== share_lib release mode (git override) ==="
# shellcheck source=/dev/null
. "${CLIENT_DIR}/tool/share_lib_source.sh"
share_lib_use_git "${CLIENT_DIR}"

echo "=== flutter precache (iOS) ==="
cd "${CLIENT_DIR}"
flutter precache --ios

echo "=== flutter pub get ==="
flutter pub get

echo "=== CocoaPods ==="
if ! command -v pod >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
fi
cd "${IOS_DIR}"
pod install --repo-update

echo "=== ci_post_clone complete ==="
exit 0
