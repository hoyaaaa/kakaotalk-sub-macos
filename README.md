# KakaoTalkWinApp

Goal: build a macOS app that feels like a second KakaoTalk instance.

The original Windows ARM64 VM path reached boot, install, and RDP, but the
official Windows KakaoTalk UI binary crashes under Windows ARM64 x64
emulation. The current free/local path is native macOS KakaoTalk isolated by a
separate macOS user account.

The active practical design is:

- primary macOS user keeps the normal KakaoTalk session
- secondary macOS user, for example `kakao2`, owns a separate KakaoTalk data container and keychain
- Screen Sharing opens the secondary session as an app-like window

The previous VM design was:

- macOS app shell: `KakaoTalk Windows.app`
- QEMU Windows 11 ARM64 VM in the background
- persistent qcow2 overlay dedicated to KakaoTalk
- embedded RDP view for display/input/clipboard
- Windows auto-logon and KakaoTalk auto-launch

## Current Context

Known local inputs:

- macSandbox source: `/Users/hoya/macSandbox`
- macSandbox upstream: `https://github.com/yourtablecloth/macSandbox.git`
- macSandbox PRs page: `https://github.com/yourtablecloth/macSandbox/pulls`
- Windows KakaoTalk installer: `/Users/hoya/Downloads/KakaoTalk-Windows/KakaoTalk_Setup_qwin64.exe`

Current Windows target:

- Microsoft Store lists KakaoTalk for Windows as requiring Windows 10 or later.
- Primary MVP target is Windows 11 ARM64 because official ARM64 media is available and macSandbox is built around Windows 11 ARM64 baseline generation.
- Windows 10 ARM64 remains an experimental low-spec target, but official media availability, VM support, drivers, and app compatibility are weaker.

Current local reality:

- `/Applications/macSandbox for Windows.app` is not expected to exist; it was removed because it is not used directly.
- Use the local macSandbox source checkout and upstream repository as the reference implementation.
- Build or run from source when baseline generation or runtime behavior needs to be exercised.
- Baseline generation has been verified locally with the official Microsoft Windows 11 ARM64 ISO.

Expected macSandbox runtime paths after building/running from source:

- virtio cache: `/Users/hoya/Library/Application Support/MacSandbox/drivers/virtio-win.iso`
- baseline: `/Users/hoya/Library/Application Support/MacSandbox/baseline`
- KakaoTalk persistent overlay: `/Users/hoya/Library/Application Support/KakaoTalkWinApp/kakaotalk.qcow2`

Windows 11 ARM64 media:

- Official Microsoft download page: `https://www.microsoft.com/en-us/software-download/windows11arm64`
- Local ISO used for baseline: `/Users/hoya/Downloads/Win11_25H2_Korean_Arm64_v2.iso`
- Microsoft SHA256 verified: `723fdcb737b39a5ec1f4b0eadacf288f1a2c4c4c8c845eb1f6a433cc264bd426`

Current prototype flow:

```bash
scripts/check-baseline.sh
scripts/create-kakaotalk-overlay.sh
scripts/run-kakaotalk-vm.sh
scripts/connect-rdp.sh
```

`run-kakaotalk-vm.sh` stays in the foreground while the VM is running. Run `connect-rdp.sh` from another terminal after Windows has booted. The RDP session exposes the installer folder as `\\tsclient\KakaoInstaller`.

## Non-Goals

- Do not build a general Windows sandbox.
- Do not preserve `.wsb` compatibility.
- Do not expose printer, microphone, webcam, arbitrary folder mapping, or disposable sandbox controls in the MVP.
- Do not pretend this is native Windows app execution. It is a VM-backed app wrapper.

## MVP

1. Reuse or create a Windows 11 ARM64 baseline.
2. Create one persistent overlay for KakaoTalk.
3. Boot the overlay with QEMU and RDP port forwarding.
4. Auto-logon to Windows.
5. Auto-run KakaoTalk.
6. Show the RDP session inside one macOS window titled `KakaoTalk Windows`.
7. Keep the overlay after quit so KakaoTalk install/login state persists.

## Recommended First Implementation

Start with a minimal Swift macOS app rather than modifying macSandbox directly.

Copy only the useful parts from macSandbox:

- `QEMURuntime`
- `DiskService`
- `SandboxPaths` ideas
- embedded `CFreeRDP` bridge if we want in-app RDP

For the very first prototype, using external `sdl-freerdp` is acceptable. Once VM lifecycle is stable, replace it with embedded RDP.

## Docs

- [macOS Multiuser Plan](docs/MACOS_MULTIUSER_PLAN.md)
- [Product Brief](docs/PRODUCT_BRIEF.md)
- [Architecture](docs/ARCHITECTURE.md)
- [macSandbox Analysis](docs/MACSANDBOX_ANALYSIS.md)
- [Implementation Plan](docs/IMPLEMENTATION_PLAN.md)
- [Runtime Paths](docs/RUNTIME_PATHS.md)
- [Open Questions](docs/OPEN_QUESTIONS.md)
- [Security and Licensing](docs/SECURITY_LICENSE.md)
- [Operations](docs/OPERATIONS.md)
