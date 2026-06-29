#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="com.hoyaaaa.KakaoTalkSub.update-checker"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-3600}"
UPDATER_BIN="$PROJECT_DIR/.build/KakaoTalkSubUpdater"
UPDATER_SRC="$PROJECT_DIR/Sources/KakaoTalkSubUpdater/main.swift"

mkdir -p "$HOME/Library/LaunchAgents"
mkdir -p "$PROJECT_DIR/.build"

swiftc "$UPDATER_SRC" -o "$UPDATER_BIN"

cat >"$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$UPDATER_BIN</string>
    <string>$PROJECT_DIR</string>
  </array>
  <key>StartInterval</key>
  <integer>$INTERVAL_SECONDS</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/kakaotalk-sub-update-checker.out.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/kakaotalk-sub-update-checker.err.log</string>
</dict>
</plist>
PLIST

chmod 644 "$PLIST"

launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/$LABEL"

echo "installed: $PLIST"
echo "interval: ${INTERVAL_SECONDS}s"
