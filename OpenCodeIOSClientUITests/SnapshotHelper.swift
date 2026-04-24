import Foundation
import XCTest

@MainActor
func setupSnapshot(_ app: XCUIApplication) {
    app.launchEnvironment["FASTLANE_SNAPSHOT"] = "YES"
    app.launchEnvironment["FASTLANE_LANGUAGE"] = Locale.current.identifier
}

@MainActor
func snapshot(_ name: String, waitForLoadingIndicator: Bool = true) {
    let sanitizedName = name.replacingOccurrences(of: " ", with: "_")
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.name = "\(simulatorIdentifier())-\(sanitizedName)"
    attachment.lifetime = .keepAlways
    XCTContext.runActivity(named: "Snapshot \(sanitizedName)") { activity in
        activity.add(attachment)
    }

    writeScreenshotPNG(screenshot.pngRepresentation, name: sanitizedName)
}

private func writeScreenshotPNG(_ data: Data, name: String) {
    let locale = ProcessInfo.processInfo.environment["FASTLANE_LANGUAGE"] ?? Locale.current.identifier
    let outputRoot = ProcessInfo.processInfo.environment["OPENCLIENT_SCREENSHOT_OUTPUT_DIR"] ?? defaultScreenshotOutputRoot()
    let directoryURL = URL(fileURLWithPath: outputRoot, isDirectory: true).appendingPathComponent(locale, isDirectory: true)

    do {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let filename = "\(simulatorIdentifier())-\(name).png"
        try data.write(to: directoryURL.appendingPathComponent(filename))
    } catch {
        XCTFail("Failed to write screenshot \(name): \(error.localizedDescription)")
    }
}

private func defaultScreenshotOutputRoot() -> String {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("fastlane", isDirectory: true)
        .appendingPathComponent("screenshots", isDirectory: true)
        .path
}

private func simulatorIdentifier() -> String {
    let environment = ProcessInfo.processInfo.environment
    let raw = environment["SIMULATOR_DEVICE_NAME"] ?? environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "simulator"
    return raw.replacingOccurrences(of: " ", with: "-")
}
