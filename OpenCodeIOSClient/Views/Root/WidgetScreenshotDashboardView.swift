import SwiftUI

#if DEBUG
struct WidgetScreenshotDashboardView: View {
    let title: String
    let serverName: String
    let sessions: [OpenCodeWidgetSessionSnapshot]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.07, blue: 0.13), Color.black, Color(red: 0.08, green: 0.11, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                VStack(spacing: 14) {
                    Text("Home Screen Widgets")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.62))
                        .textCase(.uppercase)
                    Text(title)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Track running sessions, approvals, and questions across projects.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 520)
                }

                VStack(spacing: 22) {
                    mediumWidget
                    largeWidget
                }
                .frame(maxWidth: 650)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 42)
        }
    }

    private var mediumWidget: some View {
        screenshotWidgetChrome(width: 360, height: 170) {
            if let session = sessions.first {
                WidgetScreenshotHeroCard(session: session)
            }
        }
    }

    private var largeWidget: some View {
        screenshotWidgetChrome(width: 360, height: 370) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                        Text(serverName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: 8) {
                    ForEach(Array(sessions.prefix(4))) { session in
                        WidgetScreenshotSessionRow(session: session)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private func screenshotWidgetChrome<Content: View>(width: CGFloat, height: CGFloat, contentPadding: CGFloat = 18, @ViewBuilder content: () -> Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 34, style: .continuous)
        return content()
            .padding(contentPadding)
            .frame(width: width, height: height, alignment: .topLeading)
            .opencodeGlassSurface(in: shape)
            .shadow(color: .black.opacity(0.42), radius: 30, x: 0, y: 22)
    }
}

struct LiveActivityScreenshotView: View {
    let session: OpenCodeSession
    let project: OpenCodeProject
    let permission: OpenCodePermission
    let question: OpenCodeQuestionRequest

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.025, blue: 0.04), Color(red: 0.07, green: 0.08, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 7) {
                    Text("2:41")
                        .font(.system(size: 72, weight: .semibold, design: .rounded))
                    Text("Tuesday, April 28")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
                .padding(.top, 34)

                Spacer(minLength: 0)

                VStack(spacing: 14) {
                    Text("Live Activities")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))
                        .textCase(.uppercase)

                    liveActivityCard

                    dynamicIslandPreview
                }
                .padding(.horizontal, 22)

                Spacer(minLength: 0)
            }
            .foregroundStyle(.white)
        }
    }

    private var liveActivityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                WidgetScreenshotAvatar(title: session.title ?? "OpenClient", size: 38)

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title ?? "Launch polish pass")
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text("Updated just now")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.62))
                }

                Spacer(minLength: 0)

                Text("Action")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.22), in: Capsule())
            }

            Text(permission.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.94))
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                liveActivityButton("Allow Once", tint: .green)
                liveActivityButton("Deny", tint: .red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: 520, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.38), radius: 28, x: 0, y: 18)
    }

    private var dynamicIslandPreview: some View {
        HStack(spacing: 12) {
            WidgetScreenshotAvatar(title: session.title ?? "OpenClient", size: 22)
            Text(question.questions.first?.question ?? "Which screen should anchor the screenshots?")
                .font(.caption.weight(.medium))
                .lineLimit(1)
            Spacer(minLength: 0)
            Circle()
                .fill(.orange)
                .frame(width: 9, height: 9)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .frame(maxWidth: 360)
        .background(.black, in: Capsule())
        .overlay {
            Capsule().strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.30), radius: 18, x: 0, y: 12)
    }

    private func liveActivityButton(_ title: String, tint: Color) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(tint, in: Capsule())
    }
}

private struct WidgetScreenshotHeroCard: View {
    let session: OpenCodeWidgetSessionSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                WidgetScreenshotAvatar(title: session.title, size: 38)
                VStack(alignment: .leading, spacing: 3) {
                    Text(session.title)
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                    Text(session.projectLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                WidgetScreenshotStatusChip(status: session.status)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(session.summaryKind.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(session.summaryText)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(3)
                    .lineSpacing(2)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

private struct WidgetScreenshotSessionRow: View {
    let session: OpenCodeWidgetSessionSnapshot

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            WidgetScreenshotAvatar(title: session.title, size: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(session.summaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let updatedAt = session.updatedAt {
                    Text(updatedAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
            Circle()
                .fill(widgetScreenshotStatusColor(session.status))
                .frame(width: 8, height: 8)
                .padding(.top, 5)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
    }
}

private struct WidgetScreenshotAvatar: View {
    let title: String
    let size: CGFloat

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.36, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
            .overlay { Circle().strokeBorder(.white.opacity(0.16), lineWidth: 1) }
    }

    private var initials: String {
        let words = title.split(whereSeparator: { $0.isWhitespace || $0 == "-" || $0 == "_" }).prefix(2)
        let letters = words.compactMap { $0.first }.map { String($0).uppercased() }
        return letters.isEmpty ? "OC" : letters.joined()
    }

    private var palette: [Color] {
        let palettes: [[Color]] = [
            [.blue, .purple],
            [.pink, .orange],
            [.teal, .blue],
            [.indigo, .mint],
            [.orange, .red],
            [.green, .teal],
        ]
        return palettes[Int(opencodeStableHash(title) % UInt64(palettes.count))]
    }
}

private struct WidgetScreenshotStatusChip: View {
    let status: OpenCodeWidgetSessionStatus

    var body: some View {
        Text(status.title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(widgetScreenshotStatusColor(status))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(widgetScreenshotStatusColor(status).opacity(0.10), in: Capsule())
    }
}

private func widgetScreenshotStatusColor(_ status: OpenCodeWidgetSessionStatus) -> Color {
    switch status {
    case .needsAction:
        return .orange
    case .working:
        return .green
    case .ready:
        return .blue
    case .watching:
        return .white.opacity(0.7)
    }
}
#endif
