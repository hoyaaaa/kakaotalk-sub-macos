#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MACSANDBOX_DIR="${MACSANDBOX_DIR:-/Users/hoya/macSandbox}"
KAKAOTALK_INSTALLER="${KAKAOTALK_INSTALLER:-/Users/hoya/Downloads/KakaoTalk-Windows/KakaoTalk_Setup_qwin64.exe}"
WIN11_ARM64_MEDIA="${WIN11_ARM64_MEDIA:-}"

missing=0

section() {
  printf '\n== %s ==\n' "$1"
}

check_cmd() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    printf 'ok   %s: %s\n' "$name" "$(command -v "$name")"
  else
    printf 'miss %s\n' "$name"
    missing=1
  fi
}

check_path() {
  local label="$1"
  local path="$2"
  if [[ -e "$path" ]]; then
    printf 'ok   %s: %s\n' "$label" "$path"
  else
    printf 'miss %s: %s\n' "$label" "$path"
    missing=1
  fi
}

section "Project"
check_path "project root" "$ROOT_DIR"
check_path "macSandbox checkout" "$MACSANDBOX_DIR"
check_path "KakaoTalk installer" "$KAKAOTALK_INSTALLER"

section "Tools"
check_cmd brew
check_cmd swift
check_cmd qemu-system-aarch64
check_cmd qemu-img
check_cmd sdl-freerdp
check_cmd wimlib-imagex

section "Windows 11 ARM64 media"
if [[ -n "$WIN11_ARM64_MEDIA" ]]; then
  check_path "WIN11_ARM64_MEDIA" "$WIN11_ARM64_MEDIA"
else
  printf 'miss WIN11_ARM64_MEDIA env not set\n'
  missing=1
fi

section "Suggested installs"
printf 'brew install qemu freerdp wimlib\n'

exit "$missing"
