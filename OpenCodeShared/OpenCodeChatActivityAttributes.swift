import Foundation

#if canImport(ActivityKit) && os(iOS)
import ActivityKit

struct OpenCodeChatActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var latestSnippet: String
        var updatedAt: Date
        var pendingInteractionKind: String?
        var interactionID: String?
        var interactionTitle: String?
        var interactionSummary: String?
        var questionOptionLabels: [String]
        var canReplyToQuestionInline: Bool
    }

    var sessionID: String
    var sessionTitle: String
}

#endif

enum OpenCodeChatActivityDeepLink {
    static let scheme = "opencode"
    static let host = "live-activity"

    static func openAppURL(sessionID: String) -> URL? {
        var components = baseComponents(sessionID: sessionID)
        components.queryItems = [URLQueryItem(name: "action", value: "open")]
        return components.url
    }

    static func permissionURL(sessionID: String, requestID: String, reply: String) -> URL? {
        var components = baseComponents(sessionID: sessionID)
        components.queryItems = [
            URLQueryItem(name: "action", value: "permission"),
            URLQueryItem(name: "requestID", value: requestID),
            URLQueryItem(name: "reply", value: reply)
        ]
        return components.url
    }

    static func questionURL(sessionID: String, requestID: String, answer: String) -> URL? {
        var components = baseComponents(sessionID: sessionID)
        components.queryItems = [
            URLQueryItem(name: "action", value: "question"),
            URLQueryItem(name: "requestID", value: requestID),
            URLQueryItem(name: "answer", value: answer)
        ]
        return components.url
    }

    private static func baseComponents(sessionID: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/session/\(sessionID)"
        return components
    }
}
