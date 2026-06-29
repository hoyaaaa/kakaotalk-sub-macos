# macOS Multiuser KakaoTalk Plan

## Goal

Run a second KakaoTalk instance without Windows, Wine, or a VM by using a
separate macOS user account as the isolation boundary.

This matches the acceptable model: Kakao may still see the same Mac model, OS,
IP, and KakaoTalk client, but local app state, container data, and keychain data
belong to a different macOS account.

## Why This Is The Next Path

Windows ARM64 VM boot, RDP, install, and persistence worked, but the official
Windows KakaoTalk build crashed before showing UI:

- executable: `KakaoTalkUI.exe`
- version: `26.5.0.123`
- fault module: `mimalloc.dll`
- exception: `c0000005`

Wine was already tried and did not work. CrossOver is paid. The strongest free
local isolation left is macOS multiuser separation.

## Runtime Shape

```text
macOS user: hoya
  /Users/hoya/Library/Containers/com.kakao.KakaoTalkMac
  /Users/hoya/Library/Keychains

macOS user: kakao2
  /Users/kakao2/Library/Containers/com.kakao.KakaoTalkMac
  /Users/kakao2/Library/Keychains
```

Both users can run the same `/Applications/KakaoTalk.app`, but each gets its
own sandbox container and keychain.

The secondary user should be a standard, hidden local account. Hidden means it
does not appear in the normal login-window user list. It is still a real GUI
user because KakaoTalk and Screen Sharing need a real login session.

## Scripts

```bash
scripts/setup-macos-kakao-user.sh
scripts/open-macos-kakao-session.sh
scripts/create-macos-kakao-session-app.sh
```

`setup-macos-kakao-user.sh` requires `sudo` because it creates a local macOS
account, marks it hidden by default, and enables Screen Sharing access.

Defaults:

- username: `kakao2`
- full name: `KakaoTalk 2`
- hidden from login-window user list: yes
- admin rights: removed if present

Override hiding only when needed:

```bash
HIDE_USER=0 scripts/setup-macos-kakao-user.sh
```

## Manual Verification

1. Run `scripts/setup-macos-kakao-user.sh`.
2. Run `scripts/open-macos-kakao-session.sh`.
3. Log in to Screen Sharing as `kakao2`.
4. Open `/Applications/KakaoTalk.app` inside that session.
5. Log in with the second KakaoTalk account.
6. Keep the Screen Sharing window open as the isolated KakaoTalk surface.

## Caveats

- This is not invisible to Kakao servers. It is only local OS-account isolation.
- A hidden user is not a disabled user. It can still log in through Screen
  Sharing by username and password.
- Screen Sharing may need manual approval in System Settings:
  `General -> Sharing -> Screen Sharing`.
- Notification forwarding into the primary account is not solved yet.
- UX is a session window first. A polished wrapper app can come later.
