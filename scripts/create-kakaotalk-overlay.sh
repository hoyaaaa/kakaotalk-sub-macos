#!/usr/bin/env bash
set -euo pipefail

MACSANDBOX_SUPPORT="${MACSANDBOX_SUPPORT:-$HOME/Library/Application Support/MacSandbox}"
APP_SUPPORT="${APP_SUPPORT:-$HOME/Library/Application Support/KakaoTalkWinApp}"
BASELINE_META="$MACSANDBOX_SUPPORT/baseline/metadata.json"
BASELINE_DISK="$MACSANDBOX_SUPPORT/baseline/baseline.qcow2"
OVERLAY="$APP_SUPPORT/kakaotalk.qcow2"
EFI_VARS="$APP_SUPPORT/kakaotalk-efi.fd"
VARS_TEMPLATE="${VARS_TEMPLATE:-/opt/homebrew/share/qemu/edk2-arm-vars.fd}"

if [[ ! -f "$BASELINE_META" ]]; then
  echo "missing baseline metadata: $BASELINE_META" >&2
  exit 1
fi

if ! grep -q '"status"[[:space:]]*:[[:space:]]*"ready"' "$BASELINE_META"; then
  echo "baseline is not ready: $BASELINE_META" >&2
  exit 1
fi

if [[ ! -f "$BASELINE_DISK" ]]; then
  echo "missing baseline disk: $BASELINE_DISK" >&2
  exit 1
fi

if [[ ! -f "$VARS_TEMPLATE" ]]; then
  echo "missing UEFI vars template: $VARS_TEMPLATE" >&2
  exit 1
fi

mkdir -p "$APP_SUPPORT"

if [[ ! -f "$OVERLAY" ]]; then
  /opt/homebrew/bin/qemu-img create -f qcow2 -b "$BASELINE_DISK" -F qcow2 "$OVERLAY"
  echo "created overlay: $OVERLAY"
else
  echo "overlay exists: $OVERLAY"
fi

if [[ ! -f "$EFI_VARS" ]]; then
  cp "$VARS_TEMPLATE" "$EFI_VARS"
  echo "created efi vars: $EFI_VARS"
else
  echo "efi vars exists: $EFI_VARS"
fi

echo "ready"
