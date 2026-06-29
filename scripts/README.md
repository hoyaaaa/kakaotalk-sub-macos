# Scripts

This directory contains prototype setup and runtime scripts.

- `check-env.sh`: verify local tools, installer, and Windows media path
- `check-baseline.sh`: verify macSandbox baseline readiness
- `find-windows-media.sh`: find local Windows ARM64 ISO/VHDX candidates
- `build-baseline.sh`: run macSandbox headless baseline build from `WIN11_ARM64_MEDIA`
- `create-kakaotalk-overlay.sh`: create persistent KakaoTalk overlay from baseline
- `run-kakaotalk-vm.sh`: run QEMU with RDP forwarding on `127.0.0.1:13389`
- `connect-rdp.sh`: connect with external FreeRDP and share the KakaoTalk installer folder
- `collect-kakao-debug.ps1`: collect Windows KakaoTalk crash/process diagnostics from inside the VM
- `setup-macos-kakao-user.sh`: create/prepare a separate macOS user for isolated native KakaoTalk
- `open-macos-kakao-session.sh`: open Screen Sharing to the isolated macOS session
- `create-macos-kakao-session-app.sh`: create a small launcher app for the Screen Sharing session

Do not put secrets here.
