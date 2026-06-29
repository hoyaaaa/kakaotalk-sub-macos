#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="com.hoyaaaa.KakaoTalkSub.update-checker"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
APP_SUPPORT_ID="com.hoyaaaa.KakaoTalkSub"
WRAPPER_ID="com.hoyaaaa.KakaoTalkSubLauncher"

if [[ "${1:-}" != "--yes" ]]; then
  echo "This will remove /Applications/카카오톡Sub.app, LaunchAgent, runtime files, and com.hoyaaaa.KakaoTalkSub user data."
  read -r -p "Type REMOVE to continue: " answer
  if [[ "$answer" != "REMOVE" ]]; then
    echo "cancelled"
    exit 0
  fi
fi

osascript -e "tell application id \"$APP_SUPPORT_ID\" to quit" >/dev/null 2>&1 || true
osascript -e "tell application id \"$WRAPPER_ID\" to quit" >/dev/null 2>&1 || true
launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true

rm -f "$PLIST"
rm -rf   "/Applications/카카오톡Sub.app"   "$PROJECT_DIR/카카오톡Sub.app"   "$PROJECT_DIR/runtime"   "$PROJECT_DIR/.build"   "$HOME/Library/Application Support/$APP_SUPPORT_ID"   "$HOME/Library/WebKit/$APP_SUPPORT_ID"   "$HOME/Library/Caches/$APP_SUPPORT_ID"   "$HOME/Library/HTTPStorages/$APP_SUPPORT_ID"   "$HOME/Library/Preferences/$APP_SUPPORT_ID.plist"   "$HOME/Library/Saved Application State/$APP_SUPPORT_ID.savedState"

find "$HOME/Library/Logs" -maxdepth 2 -name "*$APP_SUPPORT_ID*" -exec rm -rf {} + 2>/dev/null || true

echo "removed KakaoTalkSub app, updater, runtime, and local user data"
echo "source repo kept: $PROJECT_DIR"
