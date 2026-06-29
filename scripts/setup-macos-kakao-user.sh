#!/usr/bin/env bash
set -euo pipefail

SECONDARY_USER="${1:-kakao2}"
FULL_NAME="${FULL_NAME:-KakaoTalk 2}"
KICKSTART="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
SCREENSHARING_PLIST="/System/Library/LaunchDaemons/com.apple.screensharing.plist"

if [[ "$SECONDARY_USER" == "$(id -un)" ]]; then
  echo "secondary user must differ from current user" >&2
  exit 1
fi

if ! id -Gn | tr ' ' '\n' | grep -qx admin; then
  echo "current user must be an admin user" >&2
  exit 1
fi

echo "This creates or prepares a separate macOS user for isolated KakaoTalk."
echo "User: $SECONDARY_USER"
echo "Full name: $FULL_NAME"
echo
echo "You will be asked for your macOS admin password by sudo."
sudo -v

if dscl . -read "/Users/$SECONDARY_USER" >/dev/null 2>&1; then
  echo "user exists: $SECONDARY_USER"
else
  read -r -s -p "New password for $SECONDARY_USER: " ACCOUNT_PASSWORD
  echo
  read -r -s -p "Repeat password for $SECONDARY_USER: " ACCOUNT_PASSWORD_2
  echo
  if [[ "$ACCOUNT_PASSWORD" != "$ACCOUNT_PASSWORD_2" ]]; then
    echo "password mismatch" >&2
    exit 1
  fi
  if [[ -z "$ACCOUNT_PASSWORD" ]]; then
    echo "empty password is not allowed" >&2
    exit 1
  fi

  sudo sysadminctl \
    -addUser "$SECONDARY_USER" \
    -fullName "$FULL_NAME" \
    -password "$ACCOUNT_PASSWORD" \
    -home "/Users/$SECONDARY_USER"
  echo "created user: $SECONDARY_USER"
fi

if [[ -f "$SCREENSHARING_PLIST" ]]; then
  sudo launchctl enable system/com.apple.screensharing || true
  sudo launchctl bootstrap system "$SCREENSHARING_PLIST" 2>/dev/null || true
  sudo launchctl kickstart -k system/com.apple.screensharing || true
fi

if [[ -x "$KICKSTART" ]]; then
  sudo "$KICKSTART" \
    -activate \
    -configure -access -on \
    -configure -allowAccessFor -specifiedUsers \
    -configure -users "$SECONDARY_USER" \
    -restart -agent >/dev/null || true
fi

echo
echo "Next:"
echo "1. Run: scripts/open-macos-kakao-session.sh"
echo "2. Log in as $SECONDARY_USER in Screen Sharing."
echo "3. Open /Applications/KakaoTalk.app inside that session and log in."
