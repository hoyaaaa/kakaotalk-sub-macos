# Decisions

## 2026-06-29: Use a native macOS app clone

The VM path booted Windows and installed KakaoTalk, but the latest Windows
KakaoTalk UI process crashed under Windows ARM64 x64 emulation. The separate
macOS user path was also blocked by local Screen Sharing control limitations.

Decision:

Use a copied native `KakaoTalk.app` bundle with a distinct bundle id, display
name, executable name, URL scheme ownership, and ad-hoc signature.

## 2026-06-29: Keep isolation claims narrow

The clone separates normal per-bundle macOS storage such as app support, WebKit,
preferences, HTTP storage, cache, and logs. It does not create a new hardware
identity, OS identity, IP, or Kakao server-side account/session identity.

Decision:

Describe this as practical local app separation, not full device isolation.

## 2026-06-29: Do not preserve App Store entitlements

After `Info.plist` changes, Kakao's original signature is invalid. App Store
restricted entitlements are bound to Kakao's signing identity and are not safe
to preserve on a modified clone.

Decision:

Re-sign the clone ad-hoc with `codesign --force --deep --sign -`.

## 2026-06-27: Windows VM path abandoned

Windows 11 ARM64 via macSandbox reached boot, RDP, installer sharing, and
KakaoTalk installation. KakaoTalk `26.5.0.123` then crashed in
`KakaoTalkUI.exe` with `mimalloc.dll` / `c0000005`.

Decision:

Do not keep the VM scripts in the active repo.

## 2026-06-27: Windows 11 ARM64 was preferred over Windows 10 ARM64

Current KakaoTalk for Windows system requirements list Windows 10 or later, but official Windows 10 ARM64 media is hard to obtain and VM support is weaker.

Decision:

If the Windows path is revisited, prefer official Windows 11 ARM64 media first.
