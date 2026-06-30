#!/usr/bin/env bash
# Flutter iOS: (선택) 버전 패치 증가 → config-only → ios/fastlane release
# 앱 ID: com.smartcompany.tabata
#
# 어디서든 실행 가능:
#   ./ios_build_with_version.sh
#   ./client/ios_build_with_version.sh

set -euo pipefail

BUMP=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

for arg in "$@"; do
  case "$arg" in
    -b|--bump) BUMP=true ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [options] [project_dir]

Options:
  -b, --bump    pubspec 패치 버전 증가 (예: 1.0.0 → 1.0.1)
  -h, --help    도움말

기본 project_dir: 이 스크립트가 있는 client/ 폴더
EOF
      exit 0
      ;;
    *)
      PROJECT_DIR="$arg"
      ;;
  esac
done

log()  { printf "\n\033[1;34m[release]\033[0m %s\n" "$*"; }
fail() { printf "\n\033[1;31m[error]\033[0m %s\n" "$*" >&2; exit 1; }

command -v flutter >/dev/null  || fail "Flutter가 PATH에 없음"
command -v fastlane >/dev/null || fail "fastlane이 설치 안됨 (gem install fastlane)"

cd "$PROJECT_DIR" || fail "프로젝트 경로 진입 실패: $PROJECT_DIR"
[ -f pubspec.yaml ] || fail "pubspec.yaml 없음 (Flutter 프로젝트 루트인지 확인)"
[ -d ios ] || fail "ios 폴더 없음"
[ -f ios/fastlane/Fastfile ] || fail "ios/fastlane/Fastfile 없음"
# shellcheck source=tool/share_lib_source.sh
source "${PROJECT_DIR}/tool/share_lib_source.sh"

restore_share_lib_local() {
  share_lib_use_local "$PROJECT_DIR"
  flutter pub get >/dev/null 2>&1 || true
}
trap restore_share_lib_local EXIT

log "share_lib → GitHub (릴리즈 빌드)"
share_lib_use_git "$PROJECT_DIR"
flutter pub get

if $BUMP; then
  CURRENT_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  [ -n "$CURRENT_VERSION" ] || fail "pubspec.yaml에서 version을 찾지 못함"

  BASE_VERSION=${CURRENT_VERSION%%+*}
  BUILD_NUMBER=""
  if [[ "$CURRENT_VERSION" == *"+"* ]]; then
    BUILD_NUMBER="${CURRENT_VERSION#*+}"
  fi

  IFS='.' read -r MAJOR MINOR PATCH <<<"$BASE_VERSION"
  PATCH=$((PATCH + 1))
  NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
  if [ -n "$BUILD_NUMBER" ]; then
    NEW_VERSION="${NEW_VERSION}+${BUILD_NUMBER}"
  fi

  log "버전 패치 증가: $CURRENT_VERSION → $NEW_VERSION"

  if sed --version >/dev/null 2>&1; then
    sed -i "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml
  else
    sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml
  fi
else
  log "버전 증가는 건너뜀 (옵션 미지정)"
fi

log "기존 빌드 아티팩트 정리 중..."
cd ios || fail "ios 폴더 이동 실패"
if [ -d "build" ]; then
  rm -rf build
fi
if [ -d "Runner.xcworkspace/xcuserdata" ]; then
  rm -rf Runner.xcworkspace/xcuserdata
fi
if [ -d "Runner.xcodeproj/xcuserdata" ]; then
  rm -rf Runner.xcodeproj/xcuserdata
fi
cd ..

log "flutter build ios --config-only --release"
flutter build ios --config-only --release

cd ios || fail "ios 폴더 이동 실패"
log "fastlane release"
fastlane release

log "✅ 완료"
