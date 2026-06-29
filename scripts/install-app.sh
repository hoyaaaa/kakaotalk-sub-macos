#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="카카오톡Sub.app"
LOCAL_APP="$PROJECT_DIR/$APP_NAME"
INSTALL_APP="/Applications/$APP_NAME"

"$PROJECT_DIR/scripts/create-kakaotalk-macos-clone.sh"

if [[ -d "$INSTALL_APP" ]]; then
  rm -rf "$INSTALL_APP"
fi

ditto "$LOCAL_APP" "$INSTALL_APP"
xattr -cr "$INSTALL_APP" || true
codesign --force --deep --sign - "$INSTALL_APP" >/dev/null

"$PROJECT_DIR/scripts/install-update-checker.sh"

echo "installed app: $INSTALL_APP"
echo "open: open "$INSTALL_APP""
