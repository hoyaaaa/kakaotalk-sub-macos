# KakaoTalkSubMacos

macOS에서 공식 카카오톡 앱을 복사해 **카카오톡Sub**라는 별도 앱으로 설치하는 스크립트입니다.

`/Applications/카카오톡Sub.app` 자체가 실제 실행 앱입니다. 업데이트 확인은 설치 시 등록되는 LaunchAgent가 백그라운드에서 담당합니다.

## 기능

- 공식 macOS 카카오톡을 기반으로 별도 앱인 `/Applications/카카오톡Sub.app`을 만듭니다.
- 원본 카카오톡과 다른 번들 ID(`com.hoyaaaa.KakaoTalkSub`)를 사용해 앱 지원 파일, WebKit, 캐시, 설정 파일이 분리되도록 합니다.
- 앱 이름, 실행 파일 이름, 한국어 표시 이름을 `카카오톡Sub`로 맞춥니다.
- 카카오톡 URL 스킴에 `-sub` 접미사를 붙여 원본 앱과 URL 스킴 소유권이 충돌하지 않도록 합니다.
- 수정된 앱 번들을 ad-hoc 서명해 macOS에서 실행 가능하도록 만듭니다.
- 알림 충돌 가능성을 줄이기 위해 `카카오톡Sub`의 알림, 알림 사운드, 미리보기, 메뉴 막대 뱃지 기본값을 꺼둡니다.
- `/Applications`에 바로 설치하므로 Dock 고정, Spotlight, Finder 실행이 자연스럽습니다.
- 5분마다 공식 카카오톡과 `카카오톡Sub`의 버전을 비교하고, 버전이 다르면 업데이트 확인 창을 띄웁니다.
- 업데이트 helper는 `~/Library/Application Support/KakaoTalkSubMacos`에 설치되어, 설치 후 repo 폴더를 옮겨도 자동 업데이트 확인이 계속 동작합니다.
- `scripts/uninstall.sh`로 앱, LaunchAgent, 업데이트 helper, `카카오톡Sub` 사용자 데이터를 정리할 수 있습니다.

## 차이점

단순히 앱을 복사하고 `Info.plist` 문자열 몇 개만 바꾸는 방식보다 더 많은 부분을 자동으로 처리합니다.

- 한국어 환경에서 Dock/Finder에 다시 `카카오톡`으로 보이지 않도록 로컬라이즈된 `InfoPlist.strings`까지 수정합니다.
- 실행 파일 이름까지 바꿔 프로세스와 번들 구성이 `카카오톡Sub` 기준으로 맞춰집니다.
- URL 스킴을 원본과 분리해 `kakaotalk`, `kakaoshare` 같은 링크 처리 충돌 가능성을 줄입니다.
- 설치 결과가 `/Applications/카카오톡Sub.app` 하나로 정리되어 Dock에 고정해도 runtime 경로나 임시 앱이 잡히지 않습니다.
- 공식 카카오톡이 업데이트돼도 5분 주기 버전 비교로 감지하고, 확인 후 `카카오톡Sub`를 다시 만들 수 있습니다.
- 업데이트 확인용 helper가 repo 바깥에 설치되어 repo 폴더 위치 변경에 덜 민감합니다.
- 완전 제거 스크립트를 제공해 남는 LaunchAgent나 helper 파일을 직접 찾아 지울 필요를 줄입니다.

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

`카카오톡Sub`의 알림 기본값을 끄지 않고 설치하려면:

```bash
DISABLE_NOTIFICATIONS=0 scripts/install-app.sh
```

설치되는 항목:

- 실행 앱: `/Applications/카카오톡Sub.app`
- 번들 ID: `com.hoyaaaa.KakaoTalkSub`
- 표시 이름: `카카오톡Sub`
- 업데이트 체커: `~/Library/LaunchAgents/com.hoyaaaa.KakaoTalkSub.update-checker.plist`
- 업데이트 helper: `~/Library/Application Support/KakaoTalkSubMacos`

## 실행

```bash
open "/Applications/카카오톡Sub.app"
```

## 업데이트 확인

설치 스크립트가 LaunchAgent를 등록하므로, macOS가 5분마다 공식 카카오톡과 `/Applications/카카오톡Sub.app`의 버전을 비교합니다.

버전이 다르면 macOS 확인 창으로 업데이트 여부를 묻고, 사용자가 동의하면 최신 공식 앱을 기준으로 `/Applications/카카오톡Sub.app`을 다시 만듭니다.

## 수동 업데이트

공식 카카오톡이 업데이트된 뒤 직접 갱신하고 싶으면 다시 실행하면 됩니다.

```bash
scripts/install-app.sh
```

이 명령은 `/Applications/카카오톡Sub.app`을 새로 만들지만, 일반적으로 `~/Library/Application Support/com.hoyaaaa.KakaoTalkSub` 같은 사용자 데이터 폴더는 지우지 않습니다.

## 한계

- 같은 macOS 사용자 안에서 실행되는 앱 복사본입니다.
- 하드웨어 정보, Mac 모델, OS 버전, IP 주소, 카카오 서버의 계정/세션 정보까지 숨기지는 않습니다.
- 공식 앱과 완전히 다른 기기처럼 보장하는 방식은 아닙니다.
- 원본 앱과 다른 번들 ID로 ad-hoc 서명되므로 macOS 알림, Dock 뱃지, Notification Center 등록은 안정적으로 동작한다고 보장하지 않습니다. 기본 설치는 충돌 가능성을 줄이기 위해 `카카오톡Sub`의 알림 관련 기본값을 꺼둡니다.
- 공식 앱 업데이트 후에는 `카카오톡Sub.app`을 다시 만들어야 합니다.
- 카카오톡 정책 변경이나 앱 업데이트에 따라 언제든 동작하지 않을 수 있습니다.

## 제거

완전히 제거하려면:

```bash
scripts/uninstall.sh
```

이 스크립트는 `/Applications/카카오톡Sub.app`, LaunchAgent, 업데이트 helper, `com.hoyaaaa.KakaoTalkSub` 사용자 데이터를 제거합니다. 실행 시 확인 문구를 요구하며, 소스 repo 폴더 자체는 지우지 않습니다.

확인 없이 제거하려면:

```bash
scripts/uninstall.sh --yes
```

## 라이선스

이 프로젝트의 코드는 MIT License로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 확인하세요.

카카오톡, KakaoTalk 및 관련 상표와 앱은 Kakao Corp.의 소유입니다. 이 프로젝트는 Kakao Corp.와 관련이 없는 비공식 도구입니다.
