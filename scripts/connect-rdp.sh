#!/usr/bin/env bash
set -euo pipefail

RDP_PORT="${RDP_PORT:-13389}"
FREERDP="${FREERDP:-}"
INSTALLER_DIR="${INSTALLER_DIR:-$HOME/Downloads/KakaoTalk-Windows}"
USER_NAME="${USER_NAME:-WDAGUtilityAccount}"
PASSWORD="${PASSWORD:-Sandbox!2026}"

if [[ -z "$FREERDP" ]]; then
  for candidate in /opt/homebrew/bin/sdl-freerdp3 /opt/homebrew/bin/sdl-freerdp /opt/homebrew/bin/xfreerdp3 /opt/homebrew/bin/xfreerdp; do
    if [[ -x "$candidate" ]]; then
      FREERDP="$candidate"
      break
    fi
  done
fi

if [[ -z "$FREERDP" ]]; then
  echo "missing FreeRDP. Run: brew install freerdp" >&2
  exit 1
fi

args=(
  "/v:127.0.0.1:$RDP_PORT"
  "/u:$USER_NAME"
  "/p:$PASSWORD"
  "/sec:tls"
  "/cert:ignore"
  "/w:1440"
  "/h:900"
  "+smart-sizing"
  "+clipboard"
  "/title:KakaoTalk Windows"
)

if [[ -d "$INSTALLER_DIR" ]]; then
  args+=("/drive:KakaoInstaller,$INSTALLER_DIR")
fi

echo "connecting to 127.0.0.1:$RDP_PORT with $FREERDP"
exec "$FREERDP" "${args[@]}"
