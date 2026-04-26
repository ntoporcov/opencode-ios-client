import Foundation

#if DEBUG
enum OpenClientScreenshotScene: String, CaseIterable {
    case connection
    case recentServers = "recent-servers"
    case projects
    case sessions
    case chat
    case permission
    case question
    case recentWidget = "recent-widget"
    case pinnedWidget = "pinned-widget"

    static var current: OpenClientScreenshotScene? {
        guard let rawValue = ProcessInfo.processInfo.environment["OPENCLIENT_SCREENSHOT_SCENE"] else {
            return nil
        }
        return OpenClientScreenshotScene(rawValue: rawValue)
    }

    var accessibilityIdentifier: String {
        "screenshot.scene.\(rawValue)"
    }
}

extension AppViewModel {
    static func screenshot(scene: OpenClientScreenshotScene) -> AppViewModel {
        switch scene {
        case .connection:
            return screenshotConnection()
        case .recentServers:
            return screenshotRecentServers()
        case .projects:
            return screenshotProjects()
        case .sessions:
            return screenshotSessions()
        case .chat:
            return screenshotChat()
        case .permission:
            return screenshotPermission()
        case .question, .recentWidget, .pinnedWidget:
            return screenshotQuestion()
        }
    }

    private static func screenshotConnection() -> AppViewModel {
        let viewModel = AppViewModel.preview(isConnected: false, hasSavedServer: false)
        viewModel.config = OpenClientScreenshotData.secureConfig
        viewModel.errorMessage = nil
        return viewModel
    }

    private static func screenshotRecentServers() -> AppViewModel {
        let viewModel = AppViewModel.preview(isConnected: false, hasSavedServer: true, recentServerConfigs: OpenClientScreenshotData.recentServers)
        viewModel.config = OpenClientScreenshotData.recentServers[0]
        viewModel.errorMessage = nil
        return viewModel
    }

    private static func screenshotProjects() -> AppViewModel {
        let viewModel = baseConnectedScreenshotViewModel()
        viewModel.currentProject = nil
        viewModel.selectedDirectory = nil
        viewModel.directoryState.selectedSession = nil
        return viewModel
    }

    private static func screenshotSessions() -> AppViewModel {
        let viewModel = baseConnectedScreenshotViewModel()
        viewModel.directoryState.selectedSession = nil
        viewModel.pinnedSessionIDsByScope = [viewModel.currentPinScopeKey: [OpenClientScreenshotData.releaseSession.id]]
        return viewModel
    }

    private static func screenshotChat() -> AppViewModel {
        baseConnectedScreenshotViewModel(selectedSession: OpenClientScreenshotData.releaseSession)
    }

    private static func screenshotPermission() -> AppViewModel {
        let viewModel = baseConnectedScreenshotViewModel(selectedSession: OpenClientScreenshotData.releaseSession)
        viewModel.directoryState.permissions = [OpenClientScreenshotData.permission]
        return viewModel
    }

    private static func screenshotQuestion() -> AppViewModel {
        let viewModel = baseConnectedScreenshotViewModel(selectedSession: OpenClientScreenshotData.releaseSession)
        viewModel.directoryState.questions = [OpenClientScreenshotData.questionRequest]
        return viewModel
    }

    private static func baseConnectedScreenshotViewModel(selectedSession: OpenCodeSession? = OpenClientScreenshotData.releaseSession) -> AppViewModel {
        let viewModel = AppViewModel.preview(
            isConnected: true,
            currentProject: OpenClientScreenshotData.repoProject,
            selectedDirectory: OpenClientScreenshotData.repoProject.worktree,
            sessions: OpenClientScreenshotData.sessions,
            selectedSession: selectedSession,
            messages: OpenClientScreenshotData.messages,
            todos: OpenClientScreenshotData.todos,
            permissions: [],
            questions: [],
            sessionStatuses: [OpenClientScreenshotData.releaseSession.id: "busy"],
            draftMessage: "",
            draftAttachments: [],
            toolMessageDetails: OpenClientScreenshotData.toolMessageDetails
        )
        viewModel.config = OpenClientScreenshotData.secureConfig
        viewModel.backendMode = .server
        viewModel.projects = OpenClientScreenshotData.projects
        viewModel.currentProject = OpenClientScreenshotData.repoProject
        viewModel.selectedDirectory = OpenClientScreenshotData.repoProject.worktree
        viewModel.sessionPreviews = OpenClientScreenshotData.sessionPreviews
        viewModel.recentServerConfigs = OpenClientScreenshotData.recentServers
        viewModel.hasSavedServer = true
        viewModel.showSavedServerPrompt = false
        viewModel.activeLiveActivitySessionIDs = [OpenClientScreenshotData.releaseSession.id]
        return viewModel
    }
}

enum OpenClientScreenshotData {
    static let secureConfig = OpenCodeServerConfig(
        baseURL: "https://open-client.com/demo",
        username: "nick",
        password: "demo-token"
    )

    static let repoProject = OpenCodeProject(
        id: "screenshot-project",
        worktree: "/Users/nick/Code/openclient",
        vcs: "git",
        name: "openclient",
        icon: OpenCodeProject.Icon(color: "#5B7CFF"),
        time: OpenCodeProject.Time(created: 1_712_200_000, updated: 1_712_286_400)
    )

    static let docsProject = OpenCodeProject(
        id: "screenshot-docs",
        worktree: "/Users/nick/Notes/product-playbook",
        vcs: nil,
        name: "product-playbook",
        icon: OpenCodeProject.Icon(color: "#22C55E"),
        time: OpenCodeProject.Time(created: 1_712_100_000, updated: 1_712_180_000)
    )

    static let projects = [OpenCodePreviewData.globalProject, repoProject, docsProject]

    static let releaseSession = OpenCodeSession(
        id: "session-screenshot-release",
        title: "Launch polish pass",
        workspaceID: nil,
        directory: repoProject.worktree,
        projectID: repoProject.id,
        parentID: nil
    )

    static let followupSession = OpenCodeSession(
        id: "session-screenshot-followup",
        title: "Live Activity routing",
        workspaceID: nil,
        directory: repoProject.worktree,
        projectID: repoProject.id,
        parentID: nil
    )

    static let archivedSession = OpenCodeSession(
        id: "session-screenshot-archived",
        title: "Screenshot automation",
        workspaceID: nil,
        directory: repoProject.worktree,
        projectID: repoProject.id,
        parentID: nil
    )

    static let sessions = [releaseSession, followupSession, archivedSession]

    static let recentServers = [
        OpenCodeServerConfig(name: "Demo Cloud", iconName: "cloud.fill", baseURL: secureConfig.baseURL, username: secureConfig.username, password: secureConfig.password),
        OpenCodeServerConfig(name: "Tailscale", iconName: "network", baseURL: "http://100.92.11.7:4096", username: "nick", password: "tailnet-token"),
        OpenCodeServerConfig(iconName: "cube.box.fill", baseURL: "https://lab.open-client.com", username: "team", password: "lab-token")
    ]

    static let sessionPreviews: [String: SessionPreview] = [
        releaseSession.id: SessionPreview(text: "Tightened the release surface and App Store flow.", date: Date().addingTimeInterval(-180)),
        followupSession.id: SessionPreview(text: "Verified question actions route into the tracked chat.", date: Date().addingTimeInterval(-1_200)),
        archivedSession.id: SessionPreview(text: "Added deterministic screenshot scenes for launch assets.", date: Date().addingTimeInterval(-3_200)),
    ]

    static let todos = [
        OpenCodeTodo(content: "Finalize App Store screenshots", status: "in_progress", priority: "high"),
        OpenCodeTodo(content: "Wire GitHub Pages privacy URL", status: "pending", priority: "high"),
        OpenCodeTodo(content: "Ship first TestFlight build", status: "pending", priority: "medium"),
    ]

    static let userMessage = OpenCodeMessageEnvelope.local(
        role: "user",
        text: "Before we upload to TestFlight, can you tighten the launch polish and make the screenshots feel intentional?",
        sessionID: releaseSession.id,
        agent: "build",
        model: OpenCodeMessageModelReference(providerID: "openai", modelID: "gpt-5.4", variant: "balanced")
    )

    static let assistantMessage = OpenCodeMessageEnvelope(
        info: OpenCodeMessage(
            id: "message-screenshot-assistant",
            role: "assistant",
            sessionID: releaseSession.id,
            time: OpenCodeMessageTime(created: 1_712_286_520, completed: 1_712_286_580),
            agent: nil,
            model: OpenCodeMessageModelReference(providerID: "openai", modelID: "gpt-5.4", variant: "balanced")
        ),
        parts: [
            OpenCodePart(
                id: "part-screenshot-reasoning",
                messageID: "message-screenshot-assistant",
                sessionID: releaseSession.id,
                type: "reasoning",
                mime: nil,
                filename: nil,
                url: nil,
                reason: "completed",
                tool: nil,
                callID: nil,
                state: OpenCodeToolState(status: "completed", title: nil, error: nil, input: nil, output: nil, metadata: nil),
                text: "Making the App Store surface feel native means the screenshots need stable content, clean hierarchy, and no backend noise."
            ),
            OpenCodePart(
                id: "part-screenshot-text",
                messageID: "message-screenshot-assistant",
                sessionID: releaseSession.id,
                type: "text",
                mime: nil,
                filename: nil,
                url: nil,
                reason: nil,
                tool: nil,
                callID: nil,
                state: nil,
                text: "I added dedicated screenshot scenes so we can capture connection, sessions, chat, permissions, and questions without waiting on a live backend. From there we can reuse the same assets on the website and in App Store Connect."
            ),
        ]
    )

    static let toolMessage = OpenCodeMessageEnvelope(
        info: OpenCodeMessage(
            id: "message-screenshot-tool",
            role: "assistant",
            sessionID: releaseSession.id,
            time: OpenCodeMessageTime(created: 1_712_286_581, completed: 1_712_286_590),
            agent: nil,
            model: nil
        ),
        parts: [
            OpenCodePart(
                id: "part-screenshot-tool",
                messageID: "message-screenshot-tool",
                sessionID: releaseSession.id,
                type: "bash",
                mime: nil,
                filename: nil,
                url: nil,
                reason: "completed",
                tool: "bash",
                callID: "call-screenshot-1",
                state: OpenCodeToolState(
                    status: "completed",
                    title: "Capture screenshot scenes",
                    error: nil,
                    input: OpenCodeToolInput(
                        command: "fastlane ios screenshots",
                        description: "Captures the App Store screenshot set",
                        filePath: nil,
                        name: nil,
                        path: nil,
                        query: nil,
                        pattern: nil,
                        subagentType: nil,
                        url: nil
                    ),
                    output: "Prepared 6 deterministic scenes",
                    metadata: OpenCodeToolMetadata(output: "Prepared 6 deterministic scenes", description: "Screenshot automation", exit: 0, filediff: nil, loaded: nil, sessionId: nil, truncated: false, files: nil)
                ),
                text: nil
            )
        ]
    )

    static let messages = [userMessage, assistantMessage, toolMessage]

    static let permission = OpenCodePermission(
        id: "permission-screenshot-1",
        sessionID: releaseSession.id,
        permission: "write",
        patterns: ["docs/index.html"],
        always: nil,
        metadata: ["path": .string("docs/index.html")],
        tool: OpenCodePermissionTool(messageID: assistantMessage.id, callID: "call-screenshot-write")
    )

    static let questionRequest = OpenCodeQuestionRequest(
        id: "question-screenshot-1",
        sessionID: releaseSession.id,
        questions: [
            OpenCodeQuestion(
                question: "Which screen should anchor the App Store screenshots?",
                header: "Launch Assets",
                options: [
                    OpenCodeQuestionOption(label: "Chat", description: "Lead with the polished conversation view."),
                    OpenCodeQuestionOption(label: "Sessions", description: "Show the mobile session browser first."),
                    OpenCodeQuestionOption(label: "Live", description: "Feature the Live Activity and on-the-go flow."),
                ],
                multiple: false,
                custom: false
            )
        ],
        tool: OpenCodeQuestionTool(messageID: assistantMessage.id, callID: "call-screenshot-question")
    )

    static let toolMessageDetails: [String: OpenCodeMessageEnvelope] = [toolMessage.id: toolMessage]

    static let widgetServer = OpenCodeWidgetServerSnapshot(
        id: secureConfig.recentServerID,
        displayName: secureConfig.displayName,
        baseURL: secureConfig.baseURL,
        username: secureConfig.username,
        generatedAt: Date(),
        isLastConnected: true
    )

    static let recentWidgetSessions: [OpenCodeWidgetSessionSnapshot] = [
        OpenCodeWidgetSessionSnapshot(
            id: releaseSession.id,
            serverID: secureConfig.recentServerID,
            projectID: repoProject.id,
            title: releaseSession.title ?? "Launch polish pass",
            projectLabel: repoProject.name ?? "openclient",
            directory: releaseSession.directory,
            workspaceID: releaseSession.workspaceID,
            status: .needsAction,
            summaryKind: .permission,
            summaryText: permission.summary,
            updatedAt: Date().addingTimeInterval(-90),
            lastActiveAt: Date().addingTimeInterval(-90),
            isPinned: true,
            pinOrder: 0
        ),
        OpenCodeWidgetSessionSnapshot(
            id: followupSession.id,
            serverID: secureConfig.recentServerID,
            projectID: repoProject.id,
            title: followupSession.title ?? "Live Activity routing",
            projectLabel: repoProject.name ?? "openclient",
            directory: followupSession.directory,
            workspaceID: followupSession.workspaceID,
            status: .working,
            summaryKind: .snippet,
            summaryText: sessionPreviews[followupSession.id]?.text ?? "Verified Live Activity routing.",
            updatedAt: Date().addingTimeInterval(-1_200),
            lastActiveAt: Date().addingTimeInterval(-1_200),
            isPinned: false,
            pinOrder: nil
        ),
        OpenCodeWidgetSessionSnapshot(
            id: "session-screenshot-docs",
            serverID: secureConfig.recentServerID,
            projectID: docsProject.id,
            title: "Product launch notes",
            projectLabel: docsProject.name ?? "product-playbook",
            directory: docsProject.worktree,
            workspaceID: nil,
            status: .needsAction,
            summaryKind: .question,
            summaryText: questionRequest.questions.first?.question ?? "Which screen should anchor the screenshots?",
            updatedAt: Date().addingTimeInterval(-1_800),
            lastActiveAt: Date().addingTimeInterval(-1_800),
            isPinned: false,
            pinOrder: nil
        ),
        OpenCodeWidgetSessionSnapshot(
            id: archivedSession.id,
            serverID: secureConfig.recentServerID,
            projectID: repoProject.id,
            title: archivedSession.title ?? "Screenshot automation",
            projectLabel: repoProject.name ?? "openclient",
            directory: archivedSession.directory,
            workspaceID: archivedSession.workspaceID,
            status: .ready,
            summaryKind: .snippet,
            summaryText: sessionPreviews[archivedSession.id]?.text ?? "Added deterministic screenshot scenes.",
            updatedAt: Date().addingTimeInterval(-3_200),
            lastActiveAt: Date().addingTimeInterval(-3_200),
            isPinned: true,
            pinOrder: 1
        ),
    ]

    static var pinnedWidgetSessions: [OpenCodeWidgetSessionSnapshot] {
        recentWidgetSessions.filter(\.isPinned).sorted { ($0.pinOrder ?? Int.max) < ($1.pinOrder ?? Int.max) }
    }
}
#endif
