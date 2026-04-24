import Foundation

#if canImport(ActivityKit) && os(iOS)
import ActivityKit
#endif

extension AppViewModel {
    private static let liveActivityGracePeriod: TimeInterval = 180

    func toggleLiveActivity(for session: OpenCodeSession) async {
        if activeLiveActivitySessionID == session.id {
            await stopLiveActivity(immediate: true)
        } else {
            await startLiveActivity(for: session)
        }
    }

    func startLiveActivity(for session: OpenCodeSession) async {
        #if canImport(ActivityKit) && os(iOS)
        do {
            let state = liveActivityState(for: session)
            let sessionID = session.id
            let sessionTitle = liveActivitySessionTitle(for: session)

            try await Task.detached(priority: .userInitiated) {
                if let existing = Activity<OpenCodeChatActivityAttributes>.activities.first(where: { $0.attributes.sessionID == sessionID }) {
                    await existing.update(ActivityContent(state: state, staleDate: nil))
                    return
                }

                if let existing = Activity<OpenCodeChatActivityAttributes>.activities.first {
                    await existing.end(nil, dismissalPolicy: .immediate)
                }

                _ = try Activity.request(
                    attributes: OpenCodeChatActivityAttributes(sessionID: sessionID, sessionTitle: sessionTitle),
                    content: ActivityContent(state: state, staleDate: nil),
                    pushType: nil
                )
            }.value
            activeLiveActivitySessionID = session.id
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        #endif
    }

    func stopLiveActivity(immediate: Bool = false) async {
        #if canImport(ActivityKit) && os(iOS)
        guard let sessionID = activeLiveActivitySessionID,
              let session = session(matching: sessionID) ?? sessions.first(where: { $0.id == sessionID }) ?? selectedSession else {
            activeLiveActivitySessionID = nil
            return
        }

        let state = liveActivityState(for: session)
        let gracePeriod = immediate ? nil : Self.liveActivityGracePeriod
        await Task.detached(priority: .userInitiated) {
            guard let activity = Activity<OpenCodeChatActivityAttributes>.activities.first(where: { $0.attributes.sessionID == sessionID }) else { return }
            let dismissalPolicy: ActivityUIDismissalPolicy = {
                guard let gracePeriod else { return .immediate }
                return .after(Date().addingTimeInterval(gracePeriod))
            }()
            await activity.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: dismissalPolicy)
        }.value
        activeLiveActivitySessionID = nil
        #endif
    }

    func refreshLiveActivityIfNeeded(for sessionID: String? = nil, endIfIdle: Bool = false) {
        #if canImport(ActivityKit) && os(iOS)
        guard let activeSessionID = activeLiveActivitySessionID else { return }
        guard sessionID == nil || sessionID == activeSessionID else { return }
        guard let session = session(matching: activeSessionID) ?? sessions.first(where: { $0.id == activeSessionID }) ?? selectedSession else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            let state = self.liveActivityState(for: session)
            if endIfIdle && self.directoryState.sessionStatuses[activeSessionID] == "idle" {
                await Task.detached(priority: .utility) {
                    guard let activity = Activity<OpenCodeChatActivityAttributes>.activities.first(where: { $0.attributes.sessionID == activeSessionID }) else { return }
                    await activity.end(
                        ActivityContent(state: state, staleDate: nil),
                        dismissalPolicy: .after(Date().addingTimeInterval(Self.liveActivityGracePeriod))
                    )
                }.value
                self.activeLiveActivitySessionID = nil
                return
            }

            await Task.detached(priority: .utility) {
                guard let activity = Activity<OpenCodeChatActivityAttributes>.activities.first(where: { $0.attributes.sessionID == activeSessionID }) else { return }
                await activity.update(ActivityContent(state: state, staleDate: nil))
            }.value
        }
        #endif
    }

    func handleLiveActivityURL(_ url: URL) async {
        guard url.scheme == OpenCodeChatActivityDeepLink.scheme,
              url.host == OpenCodeChatActivityDeepLink.host else {
            return
        }

        let pathComponents = url.pathComponents
        guard pathComponents.count >= 3, pathComponents[1] == "session" else { return }

        let sessionID = pathComponents[2]
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        let action = queryItems.first(where: { $0.name == "action" })?.value

        await openSession(sessionID: sessionID)

        switch action {
        case "permission":
            guard let requestID = queryItems.first(where: { $0.name == "requestID" })?.value,
                  let reply = queryItems.first(where: { $0.name == "reply" })?.value,
                  let permission = permissions(for: sessionID).first(where: { $0.id == requestID }) else {
                return
            }
            await respondToPermission(permission, response: reply)
            refreshLiveActivityIfNeeded(for: sessionID)
        case "question":
            guard let requestID = queryItems.first(where: { $0.name == "requestID" })?.value,
                  let answer = queryItems.first(where: { $0.name == "answer" })?.value,
                  let question = questions(for: sessionID).first(where: { $0.id == requestID }) else {
                return
            }
            await respondToQuestion(question, answers: [[answer]])
            refreshLiveActivityIfNeeded(for: sessionID)
        default:
            return
        }
    }

    func isLiveActivityActive(for session: OpenCodeSession) -> Bool {
        activeLiveActivitySessionID == session.id
    }

    private func liveActivityState(for session: OpenCodeSession) -> OpenCodeChatActivityAttributes.ContentState {
        let pendingPermission = permissions(for: session.id).first
        let pendingQuestion = questions(for: session.id).first
        let latestSnippet = liveActivityLatestSnippet(for: session)

        if let pendingPermission {
            return OpenCodeChatActivityAttributes.ContentState(
                status: liveActivityStatusText(for: session),
                latestSnippet: latestSnippet,
                updatedAt: .now,
                pendingInteractionKind: "permission",
                interactionID: pendingPermission.id,
                interactionTitle: pendingPermission.title,
                interactionSummary: pendingPermission.summary,
                questionOptionLabels: [],
                canReplyToQuestionInline: false
            )
        }

        if let pendingQuestion,
           let firstQuestion = pendingQuestion.questions.first {
            let optionLabels = Array(firstQuestion.options.map(\.label).prefix(3))
            let canReplyInline = pendingQuestion.questions.count == 1 &&
                firstQuestion.multiple == false &&
                firstQuestion.custom != true &&
                optionLabels.count == firstQuestion.options.count

            return OpenCodeChatActivityAttributes.ContentState(
                status: liveActivityStatusText(for: session),
                latestSnippet: latestSnippet,
                updatedAt: .now,
                pendingInteractionKind: "question",
                interactionID: pendingQuestion.id,
                interactionTitle: firstQuestion.header,
                interactionSummary: firstQuestion.question,
                questionOptionLabels: optionLabels,
                canReplyToQuestionInline: canReplyInline
            )
        }

        return OpenCodeChatActivityAttributes.ContentState(
            status: liveActivityStatusText(for: session),
            latestSnippet: latestSnippet,
            updatedAt: .now,
            pendingInteractionKind: nil,
            interactionID: nil,
            interactionTitle: nil,
            interactionSummary: nil,
            questionOptionLabels: [],
            canReplyToQuestionInline: false
        )
    }

    private func liveActivitySessionTitle(for session: OpenCodeSession) -> String {
        let title = childSessionTitle(for: session)
        return title.isEmpty ? "Session" : title
    }

    private func liveActivityStatusText(for session: OpenCodeSession) -> String {
        switch directoryState.sessionStatuses[session.id] {
        case "busy":
            return "Working"
        case "idle":
            return "Ready"
        default:
            return "Watching"
        }
    }

    private func liveActivityLatestSnippet(for session: OpenCodeSession) -> String {
        if selectedSession?.id == session.id {
            if let assistant = latestMeaningfulSnippet(in: messages, role: "assistant") {
                return assistant
            }
            if let user = latestMeaningfulSnippet(in: messages, role: "user") {
                return user
            }
        }

        return sessionPreviews[session.id]?.text ?? "No messages yet"
    }

    private func latestMeaningfulSnippet(in messages: [OpenCodeMessageEnvelope], role: String) -> String? {
        messages
            .reversed()
            .first(where: { ($0.info.role ?? "").lowercased() == role })?
            .parts
            .compactMap { part in
                part.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
            .liveActivityLastLinePreview(limit: 140)
    }
}

private extension String {
    func liveActivityLastLinePreview(limit: Int = 140) -> String? {
        let lines = components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard let line = lines.last else { return nil }
        return String(line.prefix(limit))
    }
}
