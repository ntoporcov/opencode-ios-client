#if os(iOS)
import ActivityKit
import AppIntents

struct OpenCodeReplyPermissionIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Reply to Permission"
    static let openAppWhenRun = false

    @Parameter(title: "Session ID") var sessionID: String
    @Parameter(title: "Request ID") var requestID: String
    @Parameter(title: "Reply") var reply: String
    @Parameter(title: "Base URL") var baseURL: String
    @Parameter(title: "Username") var username: String
    @Parameter(title: "Password") var password: String
    @Parameter(title: "Directory") var directory: String?
    @Parameter(title: "Workspace") var workspaceID: String?

    func perform() async throws -> some IntentResult {
        let client = OpenCodeLiveActivityActionClient(baseURL: baseURL, username: username, password: password)
        try await client.replyToPermission(requestID: requestID, reply: reply, directory: directory, workspaceID: workspaceID)
        return .result()
    }
}

struct OpenCodeReplyQuestionIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Reply to Question"
    static let openAppWhenRun = false

    @Parameter(title: "Session ID") var sessionID: String
    @Parameter(title: "Request ID") var requestID: String
    @Parameter(title: "Answer") var answer: String
    @Parameter(title: "Base URL") var baseURL: String
    @Parameter(title: "Username") var username: String
    @Parameter(title: "Password") var password: String
    @Parameter(title: "Directory") var directory: String?
    @Parameter(title: "Workspace") var workspaceID: String?

    func perform() async throws -> some IntentResult {
        let client = OpenCodeLiveActivityActionClient(baseURL: baseURL, username: username, password: password)
        try await client.replyToQuestion(requestID: requestID, answers: [[answer]], directory: directory, workspaceID: workspaceID)
        return .result()
    }
}

#endif
