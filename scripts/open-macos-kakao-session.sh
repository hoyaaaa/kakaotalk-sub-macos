#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-localhost}"

echo "Opening Screen Sharing: vnc://$TARGET"
echo "Log in with the separate macOS user, e.g. kakao2."
open "vnc://$TARGET"
