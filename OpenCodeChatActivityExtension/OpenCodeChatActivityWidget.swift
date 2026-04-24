import ActivityKit
import SwiftUI
import WidgetKit

struct OpenCodeChatActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OpenCodeChatActivityAttributes.self) { context in
            OpenCodeChatActivityView(context: context)
                .widgetURL(
                    OpenCodeChatActivityDeepLink.openAppURL(
                        sessionID: context.attributes.sessionID,
                        directory: context.attributes.directory,
                        workspaceID: context.attributes.workspaceID
                    )
                )
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 10) {
                        OpenCodeChatActivityAvatar(title: context.attributes.sessionTitle, size: 28)

                        Text(context.attributes.sessionTitle)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    statusBadge(for: context.state.status)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(context.state.latestSnippet)
                            .font(.subheadline)
                            .lineLimit(3)

                        OpenCodeChatActivityActions(context: context)
                    }
                }
            } compactLeading: {
                OpenCodeChatActivityAvatar(title: context.attributes.sessionTitle, size: 20)
            } compactTrailing: {
                Circle()
                    .fill(statusColor(for: context.state.status))
                    .frame(width: 10, height: 10)
            } minimal: {
                Image(systemName: "bubble.left.fill")
            }
            .widgetURL(
                OpenCodeChatActivityDeepLink.openAppURL(
                    sessionID: context.attributes.sessionID,
                    directory: context.attributes.directory,
                    workspaceID: context.attributes.workspaceID
                )
            )
            .keylineTint(statusColor(for: context.state.status))
        }
    }

    @ViewBuilder
    private func statusBadge(for status: String) -> some View {
        Text(status)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(statusColor(for: status).opacity(0.3), in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            }
    }

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "working":
            return .green
        case "ready":
            return .blue
        default:
            return .white
        }
    }
}

private struct OpenCodeChatActivityView: View {
    let context: ActivityViewContext<OpenCodeChatActivityAttributes>

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 10) {
                    OpenCodeChatActivityAvatar(title: context.attributes.sessionTitle, size: 38)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.sessionTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(context.state.updatedAt, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.62))
                    }

                    Spacer(minLength: 0)

                    Text(context.state.status)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(statusColor.opacity(0.22), in: Capsule())
                }

                primaryContent
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
    }

    private var statusColor: Color {
        switch context.state.status.lowercased() {
        case "action":
            return .orange
        case "live":
            return .green
        case "ready":
            return .blue
        default:
            return .white
        }
    }

    @ViewBuilder
    private var primaryContent: some View {
        if context.state.pendingInteractionKind == "permission" {
            OpenCodeChatActivityPermissionContent(context: context)
        } else if context.state.pendingInteractionKind == "question" {
            OpenCodeChatActivityQuestionContent(context: context)
        } else {
            Text(context.state.latestSnippet)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.96))
                .lineSpacing(3)
                .lineLimit(5)
                .padding(.horizontal, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct OpenCodeChatActivityPermissionContent: View {
    let context: ActivityViewContext<OpenCodeChatActivityAttributes>

    var body: some View {
        if let summary = context.state.interactionSummary {
            VStack(alignment: .leading, spacing: 10) {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.94))
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                OpenCodeChatActivityActions(context: context)
            }
        }
    }
}

private struct OpenCodeChatActivityQuestionContent: View {
    let context: ActivityViewContext<OpenCodeChatActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let summary = context.state.interactionSummary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.94))
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            OpenCodeChatActivityActions(context: context)
        }
    }
}

private struct OpenCodeChatActivityActions: View {
    let context: ActivityViewContext<OpenCodeChatActivityAttributes>

    var body: some View {
        if context.state.pendingInteractionKind == "permission",
           let requestID = context.state.interactionID {
            HStack(spacing: 8) {
                actionLink(
                    title: "Allow Once",
                    destination: OpenCodeChatActivityDeepLink.permissionURL(
                        sessionID: context.attributes.sessionID,
                        requestID: requestID,
                        reply: "allow",
                        directory: context.attributes.directory,
                        workspaceID: context.attributes.workspaceID
                    ),
                    tint: .green
                )
                .frame(maxWidth: .infinity)

                actionLink(
                    title: "Deny",
                    destination: OpenCodeChatActivityDeepLink.permissionURL(
                        sessionID: context.attributes.sessionID,
                        requestID: requestID,
                        reply: "deny",
                        directory: context.attributes.directory,
                        workspaceID: context.attributes.workspaceID
                    ),
                    tint: .red
                )
                .frame(maxWidth: .infinity)
            }
        } else if context.state.pendingInteractionKind == "question",
                  let requestID = context.state.interactionID,
                  context.state.canReplyToQuestionInline {
            HStack(spacing: 8) {
                ForEach(context.state.questionOptionLabels, id: \.self) { option in
                    actionLink(
                        title: option,
                        destination: OpenCodeChatActivityDeepLink.questionURL(
                            sessionID: context.attributes.sessionID,
                            requestID: requestID,
                            answer: option,
                            directory: context.attributes.directory,
                            workspaceID: context.attributes.workspaceID
                        ),
                        tint: .blue
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        } else if context.state.pendingInteractionKind == "question" {
            actionLink(
                title: "Open App",
                destination: OpenCodeChatActivityDeepLink.openAppURL(
                    sessionID: context.attributes.sessionID,
                    directory: context.attributes.directory,
                    workspaceID: context.attributes.workspaceID
                ),
                tint: .white.opacity(0.16)
            )
        }
    }

    private func actionLink(title: String, destination: URL?, tint: Color) -> some View {
        Group {
            if let destination {
                Link(destination: destination) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(tint, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
    }

}

private struct OpenCodeChatActivityAvatar: View {
    let title: String
    let size: CGFloat

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.36, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [gradientColors.0, gradientColors.1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            }
    }

    private var initials: String {
        let words = title
            .split(whereSeparator: { $0.isWhitespace || $0 == "-" || $0 == "_" })
            .prefix(2)
        let letters = words.compactMap { $0.first }.map { String($0).uppercased() }
        return letters.isEmpty ? "OC" : letters.joined()
    }

    private var gradientColors: (Color, Color) {
        palette(for: title)
    }
}

private func palette(for title: String) -> (Color, Color) {
    let palettes: [(Color, Color)] = [
        (.blue, .purple),
        (.pink, .orange),
        (.teal, .blue),
        (.indigo, .mint),
        (.orange, .red),
        (.green, .teal),
    ]
    let paletteIndex = Int(opencodeStableHash(title) % UInt64(palettes.count))
    return palettes[paletteIndex]
}
