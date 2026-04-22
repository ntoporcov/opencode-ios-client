import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ChatView: View {
    @ObservedObject var viewModel: AppViewModel
    let sessionID: String

    @Namespace private var toolbarGlassNamespace
    @State private var keyboardHeight: CGFloat = 0
    @State private var copiedDebugLog = false
    @State private var selectedActivityDetail: ActivityDetail?
    @State private var showingTodoInspector = false
    @State private var visibleMessageCount = 80
    @State private var hasLoadedInitialWindow = false
    @State private var hasSnappedInitially = false
    @State private var questionAnswers: [String: Set<String>] = [:]
    @State private var questionCustomAnswers: [String: String] = [:]
    @State private var keyboardScrollTask: Task<Void, Never>?

    private let messageWindowSize = 10
    private var displayedMessageIDs: String {
        displayedMessages.map { $0.id }.joined(separator: "|")
    }

    private var todoIDs: String {
        viewModel.todos.map { $0.id }.joined(separator: "|")
    }

    private var permissionIDs: String {
        viewModel.selectedSessionPermissions.map { $0.id }.joined(separator: "|")
    }

    private var questionIDs: String {
        viewModel.selectedSessionQuestions.map { $0.id }.joined(separator: "|")
    }

    private var liveSession: OpenCodeSession {
        if let selected = viewModel.selectedSession, selected.id == sessionID {
            return selected
        }

        guard let session = viewModel.session(matching: sessionID) else {
            fatalError("Missing session for ChatView: \(sessionID)")
        }
        return session
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if hiddenMessageCount > 0 {
                            Button {
                                withAnimation(opencodeSelectionAnimation) {
                                    visibleMessageCount = min(viewModel.messages.count, visibleMessageCount + messageWindowSize)
                                }
                            } label: {
                                Text("View older messages (\(hiddenMessageCount))")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom, 4)
                        }

                        ForEach(displayedMessages) { message in
                            MessageBubble(
                                message: message,
                                detailedMessage: viewModel.toolMessageDetails[message.id],
                                isStreamingMessage: isStreamingMessage(message)
                            ) { part in
                                selectedActivityDetail = ActivityDetail(message: message, part: part)
                            }
                            .id(message.id)
                        }

                        if shouldShowThinking {
                            ThinkingRow()
                                .id("thinking-row")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, messageBottomPadding)
                }
                .defaultScrollAnchor(.bottom)
                .scrollDismissesKeyboard(.interactively)
                .background(Color(uiColor: .systemGroupedBackground))
                .accessibilityIdentifier("chat.scroll")
                .safeAreaInset(edge: .bottom) {
                    composerStack
                }
                .onAppear {
                    if !hasLoadedInitialWindow {
                        visibleMessageCount = min(viewModel.messages.count, messageWindowSize)
                        hasLoadedInitialWindow = true
                    }
                    scrollToBottom(with: proxy, animated: false)
                }
                .onChange(of: viewModel.messages.count) { _, count in
                    if !hasLoadedInitialWindow {
                        visibleMessageCount = min(count, messageWindowSize)
                        return
                    }

                    visibleMessageCount = min(count, max(visibleMessageCount, messageWindowSize))
                }
                .onChange(of: visibleMessageCount) { _, _ in
                    if !hasSnappedInitially {
                        scrollToBottom(with: proxy, animated: false)
                        hasSnappedInitially = true
                    }
                }
                .onChange(of: displayedMessages.last?.id) { _, _ in
                    scrollToBottom(with: proxy, animated: hasSnappedInitially)
                }
                .onChange(of: messageContentVersion) { _, _ in
                    scrollToBottom(with: proxy, animated: hasSnappedInitially)
                }
                .onChange(of: shouldShowThinking) { _, _ in
                    scrollToBottom(with: proxy, animated: hasSnappedInitially)
                }
                .onChange(of: keyboardHeight) { _, newValue in
                    keyboardScrollTask?.cancel()
                    guard newValue > 0 else { return }

                    scrollToBottom(with: proxy, animated: true)
                    keyboardScrollTask = Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(180))
                        guard !Task.isCancelled else { return }
                        scrollToBottom(with: proxy, animated: false)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                    keyboardHeight = keyboardHeight(from: notification, geometry: geometry)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    keyboardScrollTask?.cancel()
                    keyboardHeight = 0
                }
            }
        }
        .navigationTitle(liveSession.title ?? "Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { chatToolbar }
#if DEBUG
        .sheet(isPresented: $viewModel.isShowingDebugProbe) {
            ChatDebugProbeSheet(viewModel: viewModel, copiedDebugLog: $copiedDebugLog)
        }
#endif
        .sheet(item: $selectedActivityDetail) { detail in
            NavigationStack {
                ActivityDetailView(viewModel: viewModel, detail: detail)
            }
        }
        .sheet(isPresented: $showingTodoInspector) {
            NavigationStack {
                TodoInspectorView(viewModel: viewModel)
            }
        }
    }

    private var composerStack: some View {
        VStack(spacing: 6) {
            if viewModel.todos.contains(where: { !$0.isComplete }) {
                TodoStrip(todos: viewModel.todos) {
                    showingTodoInspector = true
                }
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if !viewModel.selectedSessionPermissions.isEmpty {
                PermissionActionStack(
                    permissions: viewModel.selectedSessionPermissions,
                    onDismiss: { permission in
                        viewModel.dismissPermission(permission)
                    },
                    onRespond: { permission, response in
                        Task { await viewModel.respondToPermission(permission, response: response) }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if !viewModel.selectedSessionQuestions.isEmpty {
                QuestionPanel(
                    requests: viewModel.selectedSessionQuestions,
                    answers: $questionAnswers,
                    customAnswers: $questionCustomAnswers,
                    onDismiss: { request in
                        Task { await viewModel.dismissQuestion(request) }
                    },
                    onSubmit: { request, answers in
                        Task { await viewModel.respondToQuestion(request, answers: answers) }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                let isBusy = viewModel.sessionStatuses[liveSession.id] == "busy"
                MessageComposer(
                    text: $viewModel.draftMessage,
                    isBusy: isBusy,
                    onSend: {
                        Task { await viewModel.sendMessage(viewModel.draftMessage, sessionID: sessionID, userVisible: true) }
                    },
                    onStop: {
                        Task { await viewModel.stopCurrentSession() }
                    }
                )
                .id(viewModel.composerResetToken)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.clear)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(opencodeSelectionAnimation, value: todoIDs)
        .animation(opencodeSelectionAnimation, value: permissionIDs)
        .animation(opencodeSelectionAnimation, value: questionIDs)
    }

    private func scrollToBottom(with proxy: ScrollViewProxy, animated: Bool) {
        let action = {
            if shouldShowThinking {
                proxy.scrollTo("thinking-row", anchor: .bottom)
            } else if let lastMessageID = displayedMessages.last?.id {
                proxy.scrollTo(lastMessageID, anchor: .bottom)
            }
        }

        if animated {
            withAnimation(opencodeSelectionAnimation, action)
        } else {
            action()
        }
    }

    private func keyboardHeight(from notification: Notification, geometry: GeometryProxy) -> CGFloat {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 0
        }

        let overlap = geometry.frame(in: .global).maxY - value.minY
        return max(0, overlap)
    }

    private var messageBottomPadding: CGFloat { 96 }

    private var messageContentVersion: String {
        displayedMessages.map { message in
            let text = message.parts.compactMap { $0.text }.joined(separator: "|")
            return "\(message.id):\(text)"
        }.joined(separator: "||")
    }

    private var displayedMessages: ArraySlice<OpenCodeMessageEnvelope> {
        viewModel.messages.suffix(visibleMessageCount)
    }

    private var hiddenMessageCount: Int {
        max(0, viewModel.messages.count - displayedMessages.count)
    }

    private var shouldShowThinking: Bool {
        guard viewModel.sessionStatuses[liveSession.id] == "busy" else { return false }
        guard let lastUserIndex = displayedMessages.lastIndex(where: { ($0.info.role ?? "").lowercased() == "user" }) else {
            return false
        }

        let assistantTextAfterUser = displayedMessages
            .suffix(from: displayedMessages.index(after: lastUserIndex))
            .contains { message in
                guard (message.info.role ?? "").lowercased() == "assistant" else { return false }
                return message.parts.contains { part in
                    guard let text = part.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
                    return !text.isEmpty
                }
            }

        return !assistantTextAfterUser
    }

    private func isStreamingMessage(_ message: OpenCodeMessageEnvelope) -> Bool {
        guard viewModel.sessionStatuses[liveSession.id] == "busy" else { return false }
        guard (message.info.role ?? "").lowercased() == "assistant" else { return false }
        return displayedMessages.last?.id == message.id
    }

    @ToolbarContentBuilder
    private var chatToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AgentToolbarMenu(viewModel: viewModel, session: liveSession, glassNamespace: toolbarGlassNamespace)
        }

        if #available(iOS 26.0, *) {
            ToolbarSpacer(.flexible, placement: .topBarTrailing)
        }

        ToolbarItem(placement: .topBarTrailing) {
            ModelToolbarMenu(viewModel: viewModel, session: liveSession, glassNamespace: toolbarGlassNamespace)
        }
    }
}
