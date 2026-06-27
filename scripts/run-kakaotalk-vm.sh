#!/usr/bin/env bash
set -euo pipefail

APP_SUPPORT="${APP_SUPPORT:-$HOME/Library/Application Support/KakaoTalkWinApp}"
OVERLAY="$APP_SUPPORT/kakaotalk.qcow2"
EFI_VARS="$APP_SUPPORT/kakaotalk-efi.fd"
EFI_CODE="${EFI_CODE:-/opt/homebrew/share/qemu/edk2-aarch64-code.fd}"
QEMU="${QEMU:-/opt/homebrew/bin/qemu-system-aarch64}"
RDP_PORT="${RDP_PORT:-13389}"
QMP_SOCKET="${QMP_SOCKET:-/tmp/kakaotalk-winapp-qmp.sock}"
SERIAL_LOG="${SERIAL_LOG:-$APP_SUPPORT/serial.log}"

host_cores="$(/usr/sbin/sysctl -n hw.ncpu)"
host_mem_mb="$(($( /usr/sbin/sysctl -n hw.memsize ) / 1024 / 1024))"
default_cpus="$(( host_cores > 4 ? host_cores / 2 : 2 ))"
if [[ "$default_cpus" -gt 8 ]]; then default_cpus=8; fi
default_mem="$(( host_mem_mb / 2 ))"
if [[ "$default_mem" -lt 4096 ]]; then default_mem=4096; fi
if [[ "$default_mem" -gt $((host_mem_mb - 4096)) ]]; then default_mem=$((host_mem_mb - 4096)); fi
if [[ "$default_mem" -lt 4096 ]]; then default_mem=4096; fi

CPUS="${CPUS:-$default_cpus}"
MEMORY_MB="${MEMORY_MB:-$default_mem}"

if [[ ! -f "$OVERLAY" || ! -f "$EFI_VARS" ]]; then
  "$(dirname "$0")/create-kakaotalk-overlay.sh"
fi

if [[ ! -x "$QEMU" ]]; then
  echo "missing qemu-system-aarch64: $QEMU" >&2
  exit 1
fi

if [[ ! -f "$EFI_CODE" ]]; then
  echo "missing UEFI code firmware: $EFI_CODE" >&2
  exit 1
fi

mkdir -p "$APP_SUPPORT"
rm -f "$QMP_SOCKET"

echo "RDP forwarding: 127.0.0.1:$RDP_PORT -> guest 3389"
echo "disk: $OVERLAY"
echo "cpus=$CPUS memory=${MEMORY_MB}MB"

exec "$QEMU" \
  -name KakaoTalkWinApp \
  -machine virt,highmem=on,gic-version=3 \
  -accel hvf \
  -cpu host \
  -smp "$CPUS" \
  -m "$MEMORY_MB" \
  -drive "if=pflash,format=raw,readonly=on,file=$EFI_CODE" \
  -drive "if=pflash,format=raw,file=$EFI_VARS" \
  -drive "if=none,id=sysdisk,format=qcow2,file=$OVERLAY" \
  -device nvme,drive=sysdisk,serial=s0 \
  -device qemu-xhci,id=usb \
  -device usb-kbd \
  -device usb-tablet \
  -device ramfb \
  -display none \
  -vnc 127.0.0.1:1 \
  -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:$RDP_PORT-:3389" \
  -device virtio-net-pci,netdev=net0 \
  -rtc base=localtime,clock=host \
  -serial "file:$SERIAL_LOG" \
  -qmp "unix:$QMP_SOCKET,server,nowait"
