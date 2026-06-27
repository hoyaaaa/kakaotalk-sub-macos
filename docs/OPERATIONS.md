# Operations

## macSandbox Source Checkout

Use the local checkout instead of an installed macSandbox app:

```sh
cd /Users/hoya/macSandbox
git remote -v
git pull --ff-only origin main
```

The upstream repository is:

`https://github.com/yourtablecloth/macSandbox.git`

The PR page is:

`https://github.com/yourtablecloth/macSandbox/pulls`

Do not assume `/Applications/macSandbox for Windows.app` exists. It was removed because this project should use macSandbox as source/reference code, not as the product runtime.

## Current Local Readiness

Verified on 2026-06-27:

- Homebrew is installed.
- `qemu-system-aarch64`, `qemu-img`, `sdl-freerdp`, and `wimlib-imagex` are installed.
- KakaoTalk installer exists at `/Users/hoya/Downloads/KakaoTalk-Windows/KakaoTalk_Setup_qwin64.exe`.
- `/Users/hoya/macSandbox` builds successfully with `swift build`.

Still missing:

- Windows 11 ARM64 ISO/VHDX path.
- macSandbox baseline directory at `/Users/hoya/Library/Application Support/MacSandbox/baseline`.

Download Windows 11 ARM64 ISO from Microsoft:

`https://www.microsoft.com/en-us/software-download/windows11arm64`

Then export:

```sh
export WIN11_ARM64_MEDIA="/path/to/windows11-arm64.iso"
```

Use:

```sh
scripts/check-env.sh
scripts/find-windows-media.sh
scripts/check-baseline.sh
```

Build baseline after ISO exists:

```sh
WIN11_ARM64_MEDIA="/path/to/windows11-arm64.iso" scripts/build-baseline.sh
scripts/check-baseline.sh
```

## Current Manual Recovery Notes

The macSandbox virtio download previously hung during `Preparing virtio-win drivers...`.

Observed state:

- `curl` process ran for more than 8 hours
- TCP connection was `CLOSED`
- partial file stopped around 386 MB

Local fix applied:

- resumed and completed `virtio-win.iso`
- verified final size: `789645312`
- verified ISO label: `virtio-win-0.1.285`

Expected final file when the macSandbox app support directory exists:

`/Users/hoya/Library/Application Support/MacSandbox/drivers/virtio-win.iso`

## Checking macSandbox Baseline State

```sh
cat "/Users/hoya/Library/Application Support/MacSandbox/baseline/metadata.json"
ls -lh "/Users/hoya/Library/Application Support/MacSandbox/baseline"
```

Baseline is usable only when metadata status is `ready`.

## Build Or Run macSandbox From Source For Validation

```sh
cd /Users/hoya/macSandbox
swift build
.build/debug/MacSandbox
```

This is useful only for baseline creation and behavior validation. It is not the target product because macSandbox discards runtime changes.

If a temporary `.wsb` validation is needed, pass the config to the source-built executable:

```sh
cd /Users/hoya/macSandbox
.build/debug/MacSandbox /Users/hoya/Downloads/KakaoTalk-Windows/kakaotalk-macsandbox.wsb
```

## Prototype Commands To Derive

Future prototype should derive QEMU args from:

`/Users/hoya/macSandbox/src/MacSandbox/Core/QEMURuntime.swift`

Key needed behavior:

- persistent overlay instead of disposable overlay
- fixed app support path
- RDP host forward
- no `.wsb`
