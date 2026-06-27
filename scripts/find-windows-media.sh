#!/usr/bin/env bash
set -euo pipefail

SEARCH_ROOTS=(
  "/Users/hoya/Downloads"
  "/Users/hoya/Documents"
  "/Users/hoya/Desktop"
)

printf '== Windows ARM64 media candidates ==\n'

found=0
for root in "${SEARCH_ROOTS[@]}"; do
  [[ -d "$root" ]] || continue
  while IFS= read -r path; do
    printf '%s\n' "$path"
    found=1
  done < <(
    find "$root" -maxdepth 4 -type f \( \
      -iname '*arm64*.iso' -o \
      -iname '*aarch64*.iso' -o \
      -iname '*arm64*.vhdx' -o \
      -iname '*aarch64*.vhdx' \
    \) 2>/dev/null | sort
  )
done

if [[ "$found" -eq 0 ]]; then
  printf 'none\n'
  exit 1
fi
