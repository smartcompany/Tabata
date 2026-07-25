#!/usr/bin/env bash
# Build TabataWatch and capture App Store screenshots per locale (Ultra 3, 422x514).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IOS="$ROOT/ios"
OUT_ROOT="${1:-$ROOT/tools/asc-metadata/screenshots/watch}"
DEVICE_NAME="Apple Watch Ultra 3 (49mm)"
BUNDLE_ID="com.smartcompany.tabata.watchkitapp"
TARGET_W=422
TARGET_H=514

# ASC locale → AppleLanguages / AppleLocale
LOCALES=(
  "ko:ko:ko_KR"
  "en-US:en:en_US"
  "ja:ja:ja_JP"
  "zh-Hans:zh-Hans:zh_CN"
)

mkdir -p "$OUT_ROOT"

UDID="$(xcrun simctl list devices available | python3 -c '
import re,sys
name=sys.argv[1]
for line in sys.stdin:
    if name in line and "unavailable" not in line.lower():
        m=re.search(r"\(([0-9A-F-]{36})\)", line)
        if m:
            print(m.group(1))
            break
' "$DEVICE_NAME")"
if [[ -z "${UDID:-}" ]]; then
  echo "Simulator not found: $DEVICE_NAME"
  xcrun simctl list devices available | grep -i watch || true
  exit 1
fi

echo "Device: $DEVICE_NAME ($UDID)"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b

echo "Building TabataWatch…"
xcodebuild \
  -project "$IOS/Runner.xcodeproj" \
  -scheme TabataWatch \
  -destination "platform=watchOS Simulator,id=$UDID" \
  -configuration Debug \
  -derivedDataPath "$IOS/build/WatchScreenshots" \
  build \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tail -30

APP="$(find "$IOS/build/WatchScreenshots" -name 'TabataWatch.app' -type d | head -1)"
if [[ -z "$APP" ]]; then
  echo "TabataWatch.app not found after build"
  exit 1
fi

# Confirm Localizable.strings / catalog shipped
if ! find "$APP" -name '*.strings' -o -name '*.lproj' | head -5 | grep -q .; then
  echo "Warning: no .lproj/.strings found in app bundle — checking xcstrings compile…"
  find "$APP" -iname '*Localizable*' -o -iname '*.lproj' | head -20 || true
fi

xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"

flatten_png() {
  local src="$1"
  local dest="$2"
  local jpg="${dest%.png}.jpg"
  sips -z "$TARGET_H" "$TARGET_W" "$src" --out "$dest" >/dev/null
  sips -s format jpeg "$dest" --out "$jpg" >/dev/null
  sips -s format png "$jpg" --out "$dest" >/dev/null
  sips -z "$TARGET_H" "$TARGET_W" "$dest" >/dev/null
  rm -f "$jpg"
}

capture() {
  local out_dir="$1"
  local mode="$2"
  local name="$3"
  local lang="$4"
  local locale="$5"
  local arg="-demo${mode}"
  local raw="$out_dir/${name}.raw.png"
  local final="$out_dir/${name}.png"

  xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
  # Force UI language for String Catalog
  xcrun simctl launch "$UDID" "$BUNDLE_ID" \
    -AppleLanguages "($lang)" \
    -AppleLocale "$locale" \
    "$arg"
  sleep 2.5
  xcrun simctl io "$UDID" screenshot "$raw"
  flatten_png "$raw" "$final"
  rm -f "$raw"
  echo "  Wrote $final"
}

for entry in "${LOCALES[@]}"; do
  IFS=':' read -r asc_locale lang apple_locale <<<"$entry"
  out_dir="$OUT_ROOT/$asc_locale"
  mkdir -p "$out_dir"
  echo
  echo "=== $asc_locale (AppleLanguages=$lang) ==="
  capture "$out_dir" Idle "01-idle" "$lang" "$apple_locale"
  capture "$out_dir" Workout "02-workout" "$lang" "$apple_locale"
  capture "$out_dir" Done "03-done" "$lang" "$apple_locale"
done

echo
echo "Screenshots in: $OUT_ROOT"
find "$OUT_ROOT" -name '*.png' | sort
