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
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(title)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                    Text("Track running sessions, approvals, and questions across projects.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
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

    private func screenshotWidgetChrome<Content: View>(width: CGFloat, height: CGFloat, contentPadding: CGFloat = 0, @ViewBuilder content: () -> Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 34, style: .continuous)
        return content()
            .padding(contentPadding)
            .frame(width: width, height: height, alignment: .topLeading)
            .opencodeGlassSurface(in: shape)
            .shadow(color: .black.opacity(0.42), radius: 30, x: 0, y: 22)
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
