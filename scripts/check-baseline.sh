#!/usr/bin/env bash
set -euo pipefail

BASELINE_DIR="${BASELINE_DIR:-/Users/hoya/Library/Application Support/MacSandbox/baseline}"
METADATA="$BASELINE_DIR/metadata.json"
BASELINE_QCOW2="$BASELINE_DIR/baseline.qcow2"

missing=0

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

printf '== macSandbox baseline ==\n'
check_path "baseline dir" "$BASELINE_DIR"
check_path "metadata" "$METADATA"
check_path "baseline qcow2" "$BASELINE_QCOW2"

if [[ -f "$METADATA" ]]; then
  printf '\n== metadata ==\n'
  cat "$METADATA"
  printf '\n'
fi

exit "$missing"
