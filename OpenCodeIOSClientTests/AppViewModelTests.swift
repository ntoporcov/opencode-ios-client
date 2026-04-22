import XCTest
@testable import OpenCodeIOSClient

@MainActor
final class AppViewModelTests: XCTestCase {
    func testSendDirectoryPrefersSelectedWorkspaceScope() {
        let viewModel = AppViewModel()
        let session = OpenCodeSession(
            id: "ses_test",
            title: "Test",
            directory: "/tmp/session-dir",
            projectID: "proj_test",
            parentID: nil
        )

        viewModel.selectedDirectory = "/tmp/selected-dir"
        viewModel.currentProject = OpenCodeProject(
            id: "proj_test",
            worktree: "/tmp/selected-dir",
            vcs: "git",
            name: "selected-dir",
            icon: nil,
            time: nil
        )

        XCTAssertEqual(viewModel.sendDirectory(for: session), "/tmp/selected-dir")
    }

    func testSendDirectoryUsesSessionScopeForLocalSessionWhenGlobalProjectSelected() {
        let viewModel = AppViewModel()
        let session = OpenCodeSession(
            id: "ses_test",
            title: "Global",
            directory: "/tmp/session-dir",
            projectID: "global",
            parentID: nil
        )

        viewModel.selectedDirectory = nil
        viewModel.currentProject = OpenCodeProject(
            id: "global",
            worktree: "Global",
            vcs: nil,
            name: nil,
            icon: nil,
            time: nil
        )

        XCTAssertEqual(viewModel.sendDirectory(for: session), "/tmp/session-dir")
    }

    func testSelectedSessionDirectoryEventsRefreshWhenGlobalProjectSelected() {
        let viewModel = AppViewModel()
        let selectedSession = OpenCodeSession(
            id: "ses_selected",
            title: "Selected",
            directory: "/tmp/project",
            projectID: "proj_test",
            parentID: nil
        )

        viewModel.isConnected = true
        viewModel.selectedDirectory = nil
        viewModel.currentProject = OpenCodeProject(
            id: "global",
            worktree: "Global",
            vcs: nil,
            name: nil,
            icon: nil,
            time: nil
        )
        viewModel.directoryState.selectedSession = selectedSession
        viewModel.directoryState.sessionStatuses[selectedSession.id] = "busy"
        viewModel.lastStreamEventAt = .distantPast

        let event = OpenCodeManagedEvent(
            directory: "/tmp/project",
            envelope: OpenCodeEventEnvelope(
                type: "session.idle",
                properties: OpenCodeEventProperties(
                    sessionID: "ses_selected",
                    info: nil,
                    part: nil,
                    status: nil,
                    todos: nil,
                    messageID: nil,
                    partID: nil,
                    field: nil,
                    delta: nil,
                    id: nil,
                    permissionType: nil,
                    pattern: nil,
                    callID: nil,
                    title: nil,
                    metadata: nil,
                    permissionID: nil,
                    response: nil,
                    reply: nil,
                    message: nil,
                    error: nil
                )
            ),
            typed: .sessionIdle(sessionID: "ses_selected")
        )

        viewModel.handleManagedEvent(event)

        XCTAssertEqual(viewModel.directoryState.sessionStatuses[selectedSession.id], "idle")
        XCTAssertGreaterThan(viewModel.lastStreamEventAt, .distantPast)
    }

    func testUnrelatedScopedEventsDoNotRefreshActiveStreamTimestamp() {
        let viewModel = AppViewModel()
        let selectedSession = OpenCodeSession(
            id: "ses_selected",
            title: "Selected",
            directory: "/tmp/project",
            projectID: "proj_test",
            parentID: nil
        )

        viewModel.isConnected = true
        viewModel.selectedDirectory = "/tmp/project"
        viewModel.currentProject = OpenCodeProject(
            id: "proj_test",
            worktree: "/tmp/project",
            vcs: "git",
            name: "project",
            icon: nil,
            time: nil
        )
        viewModel.directoryState.selectedSession = selectedSession
        viewModel.lastStreamEventAt = .distantPast

        let event = OpenCodeManagedEvent(
            directory: "/tmp/project",
            envelope: OpenCodeEventEnvelope(
                type: "message.updated",
                properties: OpenCodeEventProperties(
                    sessionID: "ses_other",
                    info: OpenCodeEventInfo(message: OpenCodeMessage(id: "msg_other", role: "assistant", sessionID: "ses_other", time: nil, agent: nil, model: nil)),
                    part: nil,
                    status: nil,
                    todos: nil,
                    messageID: nil,
                    partID: nil,
                    field: nil,
                    delta: nil,
                    id: nil,
                    permissionType: nil,
                    pattern: nil,
                    callID: nil,
                    title: nil,
                    metadata: nil,
                    permissionID: nil,
                    response: nil,
                    reply: nil,
                    message: nil,
                    error: nil
                )
            ),
            typed: .messageUpdated(OpenCodeMessage(id: "msg_other", role: "assistant", sessionID: "ses_other", time: nil, agent: nil, model: nil))
        )

        viewModel.handleManagedEvent(event)

        XCTAssertEqual(viewModel.lastStreamEventAt, .distantPast)
    }

    func testActiveSessionEventsRefreshStreamTimestamp() {
        let viewModel = AppViewModel()
        let selectedSession = OpenCodeSession(
            id: "ses_selected",
            title: "Selected",
            directory: "/tmp/project",
            projectID: "proj_test",
            parentID: nil
        )

        viewModel.isConnected = true
        viewModel.selectedDirectory = "/tmp/project"
        viewModel.currentProject = OpenCodeProject(
            id: "proj_test",
            worktree: "/tmp/project",
            vcs: "git",
            name: "project",
            icon: nil,
            time: nil
        )
        viewModel.directoryState.selectedSession = selectedSession
        viewModel.lastStreamEventAt = .distantPast

        let event = OpenCodeManagedEvent(
            directory: "/tmp/project",
            envelope: OpenCodeEventEnvelope(
                type: "session.status",
                properties: OpenCodeEventProperties(
                    sessionID: "ses_selected",
                    info: nil,
                    part: nil,
                    status: OpenCodeSessionStatus(type: "busy"),
                    todos: nil,
                    messageID: nil,
                    partID: nil,
                    field: nil,
                    delta: nil,
                    id: nil,
                    permissionType: nil,
                    pattern: nil,
                    callID: nil,
                    title: nil,
                    metadata: nil,
                    permissionID: nil,
                    response: nil,
                    reply: nil,
                    message: nil,
                    error: nil
                )
            ),
            typed: .sessionStatus(sessionID: "ses_selected", status: "busy")
        )

        viewModel.handleManagedEvent(event)

        XCTAssertGreaterThan(viewModel.lastStreamEventAt, .distantPast)
    }
}
