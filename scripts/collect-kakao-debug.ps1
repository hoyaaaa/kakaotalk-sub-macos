$Out='\\tsclient\KakaoInstaller\kakao-debug.txt'
'== kakao debug == ' + (Get-Date) | Out-File $Out -Encoding UTF8

'== processes ==' | Out-File $Out -Append
Get-Process |
  Where-Object { $_.ProcessName -match 'Kakao|Talk|UI' -or $_.Path -match 'Kakao|Talk|UI' } |
  Select-Object Id,ProcessName,MainWindowTitle,MainWindowHandle,Path |
  Format-List | Out-File $Out -Append

'== tasklist kakao ==' | Out-File $Out -Append
tasklist /v | findstr /i "kakao talk ui" | Out-File $Out -Append

'== installed exe candidates ==' | Out-File $Out -Append
Get-ChildItem 'C:\Program Files*', $env:LOCALAPPDATA -Recurse -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match 'Kakao|Talk|UI' -and $_.Extension -eq '.exe' } |
  Select-Object FullName,Length,LastWriteTime |
  Format-List | Out-File $Out -Append

'== event log ==' | Out-File $Out -Append
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=(Get-Date).AddHours(-2)} -ErrorAction SilentlyContinue |
  Where-Object { $_.Message -match 'Kakao|KakaoUI|KakaoTalk|Talk' -or $_.ProviderName -match 'Application Error|Windows Error Reporting' } |
  Select-Object TimeCreated,ProviderName,Id,LevelDisplayName,Message |
  Format-List | Out-File $Out -Append

'== done ==' | Out-File $Out -Append
