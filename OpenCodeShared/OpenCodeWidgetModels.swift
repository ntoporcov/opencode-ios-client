import Foundation

enum OpenCodeWidgetKind {
    static let recentSessions = "OpenCodeRecentSessionsWidget"
    static let pinnedSessions = "OpenCodePinnedSessionsWidget"
}

enum OpenCodeWidgetSessionStatus: String, Codable, Hashable, Sendable {
    case needsAction
    case working
    case ready
    case watching

    var title: String {
        switch self {
        case .needsAction:
            return "Needs Action"
        case .working:
            return "Working"
        case .ready:
            return "Ready"
        case .watching:
            return "Watching"
        }
    }
}

enum OpenCodeWidgetSummaryKind: String, Codable, Hashable, Sendable {
    case permission
    case question
    case snippet

    var title: String {
        switch self {
        case .permission:
            return "Permission"
        case .question:
            return "Question"
        case .snippet:
            return "Latest"
        }
    }
}

struct OpenCodeWidgetServerSnapshot: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let displayName: String
    let baseURL: String
    let username: String
    let generatedAt: Date
    let isLastConnected: Bool
}

struct OpenCodeWidgetProjectSnapshot: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let serverID: String
    let title: String
    let worktree: String?
    let sortTitle: String
}

struct OpenCodeWidgetSessionSnapshot: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let serverID: String
    let projectID: String
    let title: String
    let projectLabel: String
    let directory: String?
    let workspaceID: String?
    let status: OpenCodeWidgetSessionStatus
    let summaryKind: OpenCodeWidgetSummaryKind
    let summaryText: String
    let updatedAt: Date?
    let lastActiveAt: Date
    let isPinned: Bool
    let pinOrder: Int?
}

struct OpenCodeWidgetSnapshotPayload: Codable, Hashable, Sendable {
    var servers: [OpenCodeWidgetServerSnapshot]
    var projects: [OpenCodeWidgetProjectSnapshot]
    var sessions: [OpenCodeWidgetSessionSnapshot]
    var generatedAt: Date

    static let empty = OpenCodeWidgetSnapshotPayload(servers: [], projects: [], sessions: [], generatedAt: .distantPast)

    func lastConnectedServerID() -> String? {
        servers.first(where: \.isLastConnected)?.id ?? servers.sorted { $0.generatedAt > $1.generatedAt }.first?.id
    }
}
