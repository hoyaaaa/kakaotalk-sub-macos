#!/usr/bin/env bash
set -euo pipefail

MACSANDBOX_DIR="${MACSANDBOX_DIR:-/Users/hoya/macSandbox}"
WIN11_ARM64_MEDIA="${WIN11_ARM64_MEDIA:-}"
LOG_DIR="${LOG_DIR:-/Users/hoya/Library/Logs/KakaoTalkWinApp}"

if [[ -z "$WIN11_ARM64_MEDIA" ]]; then
  printf 'missing WIN11_ARM64_MEDIA\n' >&2
  printf 'download: https://www.microsoft.com/en-us/software-download/windows11arm64\n' >&2
  printf 'usage: WIN11_ARM64_MEDIA=/path/to/windows11-arm64.iso %s\n' "$0" >&2
  exit 2
fi

if [[ ! -f "$WIN11_ARM64_MEDIA" ]]; then
  printf 'ISO not found: %s\n' "$WIN11_ARM64_MEDIA" >&2
  exit 2
fi

mkdir -p "$LOG_DIR"

cd "$MACSANDBOX_DIR"
swift build

log="$LOG_DIR/build-baseline-$(date +%Y%m%d-%H%M%S).log"
printf 'baseline build log: %s\n' "$log"

.build/debug/MacSandbox --headless-build "$WIN11_ARM64_MEDIA" 2>&1 | tee "$log"
