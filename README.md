# KakaoTalkSubMacos

macOS에서 공식 카카오톡 앱을 복사해 **카카오톡Sub**라는 별도 앱으로 실행하는 래퍼 앱 생성 스크립트입니다.

사용자가 여는 `카카오톡Sub.app`은 Swift 래퍼 앱입니다. 래퍼는 실행될 때 공식 카카오톡과 내부 복제 앱의 버전을 비교하고, 필요하면 업데이트 확인 창을 띄운 뒤 실제 카카오톡 복제 앱을 실행합니다.

## 주의

이 프로젝트는 카카오에서 제공하거나 보증하는 공식 도구가 아닙니다.

이 도구 사용으로 인해 카카오톡 이용약관 위반, 로그인 제한, 계정 정지, 데이터 손실, 앱 오작동, 기타 불이익이 발생할 수 있습니다. 사용 여부와 그 결과에 대한 책임은 전적으로 사용자 본인에게 있습니다.

## 준비

- macOS용 공식 카카오톡이 `/Applications/KakaoTalk.app`에 설치되어 있어야 합니다.
- Xcode Command Line Tools의 기본 도구(`swiftc`, `/usr/libexec/PlistBuddy`, `plutil`, `codesign`)를 사용합니다.

## 설치

```bash
git clone https://github.com/hoyaaaa/kakaotalk-sub-macos.git
cd kakaotalk-sub-macos
scripts/install-app.sh
```

설치되는 항목:

- 실행 앱: `/Applications/카카오톡Sub.app`
- 내부 복제 앱: `./runtime/카카오톡Sub.app`
- 래퍼 번들 ID: `com.hoyaaaa.KakaoTalkSubLauncher`
- 내부 복제 앱 번들 ID: `com.hoyaaaa.KakaoTalkSub`
- 표시 이름: `카카오톡Sub`
- 업데이트 체커: `~/Library/LaunchAgents/com.hoyaaaa.KakaoTalkSub.update-checker.plist`

## 실행

```bash
open "/Applications/카카오톡Sub.app"
```

## 업데이트 확인

`카카오톡Sub.app`을 실행할 때마다 공식 카카오톡과 내부 복제 앱의 버전을 비교합니다.

버전이 다르면 macOS 확인 창으로 업데이트 여부를 묻고, 사용자가 동의하면 최신 공식 앱을 기준으로 내부 복제 앱을 다시 만듭니다.

설치 스크립트가 LaunchAgent도 함께 등록하므로, 앱을 실행하지 않아도 1시간마다 공식 카카오톡과 내부 복제 앱의 버전을 비교합니다.

repo 폴더를 옮긴 경우에는 LaunchAgent에 저장된 경로도 바뀌어야 하므로 아래 명령을 다시 실행하세요.

```bash
scripts/install-update-checker.sh
```

## 수동 업데이트

공식 카카오톡이 업데이트된 뒤 직접 갱신하고 싶으면 다시 실행하면 됩니다.

```bash
scripts/install-app.sh
```

이 명령은 `카카오톡Sub.app` 래퍼와 내부 복제 앱을 새로 만들지만, 일반적으로 `~/Library/Application Support/com.hoyaaaa.KakaoTalkSub` 같은 사용자 데이터 폴더는 지우지 않습니다.

## 한계

- 같은 macOS 사용자 안에서 실행되는 앱 복사본입니다.
- 하드웨어 정보, Mac 모델, OS 버전, IP 주소, 카카오 서버의 계정/세션 정보까지 숨기지는 않습니다.
- 공식 앱과 완전히 다른 기기처럼 보장하는 방식은 아닙니다.
- 공식 앱 업데이트 후에는 `카카오톡Sub.app`을 다시 만들어야 합니다.
- 카카오톡 정책 변경이나 앱 업데이트에 따라 언제든 동작하지 않을 수 있습니다.

## 제거

완전히 제거하려면:

```bash
scripts/uninstall.sh
```

이 스크립트는 `/Applications/카카오톡Sub.app`, LaunchAgent, 로컬 런타임, `com.hoyaaaa.KakaoTalkSub` 사용자 데이터를 제거합니다. 실행 시 확인 문구를 요구하며, 소스 repo 폴더 자체는 지우지 않습니다.

확인 없이 제거하려면:

```bash
scripts/uninstall.sh --yes
```
