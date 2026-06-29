#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_APP="${SRC_APP:-/Applications/KakaoTalk.app}"
WRAPPER_APP="${WRAPPER_APP:-$PROJECT_DIR/카카오톡Sub.app}"
WRAPPER_ID="${WRAPPER_ID:-com.hoyaaaa.KakaoTalkSubLauncher}"
DISPLAY_NAME="${DISPLAY_NAME:-카카오톡Sub}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-KakaoTalkSubLauncher}"
LAUNCHER_SRC="$PROJECT_DIR/Sources/KakaoTalkSubLauncher/main.swift"

rm -rf "$WRAPPER_APP"
mkdir -p "$WRAPPER_APP/Contents/MacOS" "$WRAPPER_APP/Contents/Resources"

swiftc "$LAUNCHER_SRC" -o "$WRAPPER_APP/Contents/MacOS/$EXECUTABLE_NAME"

ICON_FILE=""
if [[ -d "$SRC_APP" ]]; then
  ICON_FILE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIconFile" "$SRC_APP/Contents/Info.plist" 2>/dev/null || true)
  if [[ -n "$ICON_FILE" ]]; then
    case "$ICON_FILE" in
      *.icns) icon_path="$SRC_APP/Contents/Resources/$ICON_FILE" ;;
      *) icon_path="$SRC_APP/Contents/Resources/$ICON_FILE.icns" ;;
    esac
    if [[ -f "$icon_path" ]]; then
      cp "$icon_path" "$WRAPPER_APP/Contents/Resources/$(basename "$icon_path")"
      ICON_FILE="$(basename "$icon_path")"
    else
      ICON_FILE=""
    fi
  fi
fi

INFO="$WRAPPER_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Clear dict" "$INFO" >/dev/null 2>&1 || true
/usr/libexec/PlistBuddy -c "Add :CFBundleDevelopmentRegion string ko" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string $EXECUTABLE_NAME" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $WRAPPER_ID" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleInfoDictionaryVersion string 6.0" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleName string $DISPLAY_NAME" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $DISPLAY_NAME" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 1" "$INFO" >/dev/null
/usr/libexec/PlistBuddy -c "Add :KakaoTalkSubProjectDir string $PROJECT_DIR" "$INFO" >/dev/null
if [[ -n "$ICON_FILE" ]]; then
  /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string $ICON_FILE" "$INFO" >/dev/null
fi

codesign --force --deep --sign - "$WRAPPER_APP" >/dev/null

echo "created wrapper: $WRAPPER_APP"
