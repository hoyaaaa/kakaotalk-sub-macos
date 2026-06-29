import AppKit
import Foundation

struct AppVersion: Equatable {
    let shortVersion: String
    let build: String

    var display: String {
        "\(shortVersion) (\(build))"
    }
}

let fileManager = FileManager.default
let bundledProjectDir = Bundle.main.object(forInfoDictionaryKey: "KakaoTalkSubProjectDir") as? String
let fallbackProjectDir = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .path
let projectDir = ProcessInfo.processInfo.environment["PROJECT_DIR"] ?? bundledProjectDir ?? fallbackProjectDir

let sourceApp = URL(fileURLWithPath: ProcessInfo.processInfo.environment["SRC_APP"] ?? "/Applications/KakaoTalk.app")
let coreApp = URL(fileURLWithPath: ProcessInfo.processInfo.environment["CORE_APP"] ?? "\(projectDir)/runtime/카카오톡Sub.app")
let createCoreScript = URL(fileURLWithPath: "\(projectDir)/scripts/create-kakaotalk-core-clone.sh")
let coreBundleID = "com.hoyaaaa.KakaoTalkSub"

func version(for appURL: URL) -> AppVersion? {
    let plistURL = appURL.appendingPathComponent("Contents/Info.plist")
    guard
        let data = try? Data(contentsOf: plistURL),
        let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
        let shortVersion = plist["CFBundleShortVersionString"] as? String,
        let build = plist["CFBundleVersion"] as? String
    else {
        return nil
    }

    return AppVersion(shortVersion: shortVersion, build: build)
}

func alert(title: String, message: String, buttons: [String]) -> String {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .informational
    buttons.forEach { alert.addButton(withTitle: $0) }
    let response = alert.runModal()
    let index = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
    guard buttons.indices.contains(index) else {
        return buttons[0]
    }
    return buttons[index]
}

func quitCoreIfNeeded() -> Bool {
    let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: coreBundleID)
    guard !runningApps.isEmpty else {
        return true
    }

    let choice = alert(
        title: "카카오톡Sub 종료 필요",
        message: "업데이트하려면 실행 중인 카카오톡Sub를 먼저 종료해야 합니다.\n\n종료하고 업데이트할까요?",
        buttons: ["나중에", "종료 후 업데이트"]
    )

    guard choice == "종료 후 업데이트" else {
        return false
    }

    runningApps.forEach { _ = $0.terminate() }

    for _ in 0..<20 {
        if NSRunningApplication.runningApplications(withBundleIdentifier: coreBundleID).isEmpty {
            return true
        }
        Thread.sleep(forTimeInterval: 1)
    }

    _ = alert(
        title: "카카오톡Sub 업데이트 중단",
        message: "카카오톡Sub가 아직 종료되지 않아 업데이트하지 않았습니다.",
        buttons: ["확인"]
    )
    return false
}

func recreateCoreApp() throws {
    let logURL = URL(fileURLWithPath: "/tmp/kakaotalk-sub-launcher.log")
    fileManager.createFile(atPath: logURL.path, contents: nil)

    let process = Process()
    process.executableURL = createCoreScript
    process.environment = ProcessInfo.processInfo.environment.merging([
        "SRC_APP": sourceApp.path,
        "DEST_APP": coreApp.path
    ]) { _, new in new }

    let logHandle = try FileHandle(forWritingTo: logURL)
    process.standardOutput = logHandle
    process.standardError = logHandle

    try process.run()
    process.waitUntilExit()
    try? logHandle.close()

    guard process.terminationStatus == 0 else {
        throw NSError(
            domain: "KakaoTalkSubLauncher",
            code: Int(process.terminationStatus),
            userInfo: [NSLocalizedDescriptionKey: "create-kakaotalk-core-clone.sh failed"]
        )
    }
}

func launchCoreApp() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = [coreApp.path]
    try? process.run()
}

guard fileManager.fileExists(atPath: sourceApp.path) else {
    _ = alert(
        title: "카카오톡Sub 실행 실패",
        message: "공식 카카오톡을 찾을 수 없습니다.\n\n/Applications/KakaoTalk.app 설치 여부를 확인하세요.",
        buttons: ["확인"]
    )
    exit(1)
}

if !fileManager.fileExists(atPath: coreApp.path) {
    do {
        try recreateCoreApp()
    } catch {
        _ = alert(
            title: "카카오톡Sub 생성 실패",
            message: "카카오톡Sub 내부 앱을 만들지 못했습니다.\n\n로그: /tmp/kakaotalk-sub-launcher.log",
            buttons: ["확인"]
        )
        exit(1)
    }
}

if let sourceVersion = version(for: sourceApp),
   let coreVersion = version(for: coreApp),
   sourceVersion != coreVersion {
    let choice = alert(
        title: "카카오톡Sub 업데이트",
        message: """
        공식 카카오톡 버전과 카카오톡Sub 버전이 다릅니다.

        공식: \(sourceVersion.display)
        Sub: \(coreVersion.display)

        지금 카카오톡Sub를 새 공식 버전 기준으로 다시 만들까요?
        """,
        buttons: ["나중에", "업데이트"]
    )

    if choice == "업데이트", quitCoreIfNeeded() {
        do {
            try recreateCoreApp()
        } catch {
            _ = alert(
                title: "카카오톡Sub 업데이트 실패",
                message: "업데이트 중 오류가 발생했습니다.\n\n로그: /tmp/kakaotalk-sub-launcher.log",
                buttons: ["확인"]
            )
            exit(1)
        }
    }
}

launchCoreApp()
