# macOS KakaoTalk App Clone Experiment

## Goal

Create a second KakaoTalk macOS app bundle that is as locally distinct from the
official install as practical without another OS account, VM, Wine, or paid
software.

This cannot change hardware identifiers, IP address, Mac model, OS version, or
server-side account/session facts. It can only change local app identity:

- bundle id
- display name
- executable name
- Launch Services identity
- URL scheme ownership
- app signature

## Script

```bash
scripts/create-kakaotalk-macos-clone.sh
open -n "KakaoTalk Max Isolated.app"
```

Defaults:

- source: `/Applications/KakaoTalk.app`
- clone: `./KakaoTalk Max Isolated.app`
- bundle id: `com.hoya.KakaoTalkMaxIsolated`
- display name: `KakaoTalk Max Isolated`
- executable name: `KakaoTalkMaxIsolated`

The script also rewrites URL schemes with a `-maxisolated` suffix so the clone
does not compete with the official app for `kakaotalk`, `kakaoshare`,
`kakaoopen`, or `kakaoplus` links.

## Important Caveat

The original App Store app is sandboxed and signed with Kakao's entitlements.
After changing `Info.plist`, the original signature is invalid. The clone is
therefore ad-hoc signed without preserving restricted App Store entitlements.

This is the most likely way to make a modified clone launch at all, but it may
also break KakaoTalk if the app requires its original sandbox, application
group, receipt, or keychain access group.

Observed after login, the clone used separate local storage under
`com.hoya.KakaoTalkMaxIsolated` for app support, WebKit, preferences, HTTP
storage, cache, and logs. It is still running as the same macOS user and should
not be described as complete device isolation.
