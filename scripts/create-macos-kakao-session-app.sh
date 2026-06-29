#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-KakaoTalk Isolated Session}"
APP_PATH="${APP_PATH:-$PWD/$APP_NAME.app}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPEN_SCRIPT="$SCRIPT_DIR/open-macos-kakao-session.sh"

if [[ ! -x "$OPEN_SCRIPT" ]]; then
  echo "missing executable: $OPEN_SCRIPT" >&2
  exit 1
fi

rm -rf "$APP_PATH"
osacompile -o "$APP_PATH" -e "do shell script quoted form of \"$OPEN_SCRIPT\""

echo "created: $APP_PATH"
echo "Move it to /Applications if wanted."
