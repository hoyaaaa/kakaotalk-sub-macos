# Runtime Paths

## Known macSandbox Paths

Source:

`/Users/hoya/macSandbox`

Upstream repository:

`https://github.com/yourtablecloth/macSandbox.git`

Pull requests page:

`https://github.com/yourtablecloth/macSandbox/pulls`

Installed app:

Not expected. `/Applications/macSandbox for Windows.app` was removed and should not be treated as an input for this project.

App support:

`/Users/hoya/Library/Application Support/MacSandbox`

Expected baseline after successful build:

`/Users/hoya/Library/Application Support/MacSandbox/baseline`

Expected virtio ISO cache after successful driver download:

`/Users/hoya/Library/Application Support/MacSandbox/drivers/virtio-win.iso`

KakaoTalk installer:

`/Users/hoya/Downloads/KakaoTalk-Windows/KakaoTalk_Setup_qwin64.exe`

Windows 11 ARM64 ISO:

Download from:

`https://www.microsoft.com/en-us/software-download/windows11arm64`

Then pass the local path as:

`WIN11_ARM64_MEDIA=/path/to/windows11-arm64.iso`

## Proposed KakaoTalkWinApp Paths

Project:

`/Users/hoya/KakaoTalkWinApp`

Runtime app support:

`/Users/hoya/Library/Application Support/KakaoTalkWinApp`

Persistent overlay:

`/Users/hoya/Library/Application Support/KakaoTalkWinApp/kakaotalk.qcow2`

EFI vars:

`/Users/hoya/Library/Application Support/KakaoTalkWinApp/kakaotalk-efi.fd`

Temporary config disk:

`/Users/hoya/Library/Application Support/KakaoTalkWinApp/kakaotalk-cfg.img`

Logs:

`/Users/hoya/Library/Logs/KakaoTalkWinApp`
