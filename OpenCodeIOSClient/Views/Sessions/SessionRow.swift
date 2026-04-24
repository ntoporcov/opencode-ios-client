import SwiftUI

struct SessionRow: View {
    enum Style {
        case regular
        case compact
    }

    @ObservedObject var viewModel: AppViewModel
    let session: OpenCodeSession
    var isSelected = false
    var showsPinnedBadge = false
    var style: Style = .regular

    private var isBusy: Bool {
        viewModel.sessionStatuses[session.id] == "busy"
    }

    var body: some View {
        Group {
            switch style {
            case .regular:
                regularContent
            case .compact:
                compactContent
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(rowBorder, lineWidth: isSelected ? 1.4 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .animation(opencodeSelectionAnimation, value: isBusy)
        .animation(opencodeSelectionAnimation, value: viewModel.hasPermissionRequest(for: session))
        .animation(opencodeSelectionAnimation, value: viewModel.sessionPreviews[session.id]?.text ?? "")
    }

    private var regularContent: some View {
        HStack(spacing: 12) {
            SessionAvatar(title: session.title ?? "Untitled Session")

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    titleLine

                    Spacer(minLength: 8)

                    if let preview = viewModel.sessionPreviews[session.id],
                       let date = preview.date {
                        Text(date, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Text(viewModel.sessionPreviews[session.id]?.text ?? "No messages yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Spacer(minLength: 0)

                if isBusy {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }

            SessionAvatar(title: session.title ?? "Untitled Session")
                .frame(maxWidth: .infinity)

            Text(session.title ?? "Untitled Session")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if viewModel.hasPermissionRequest(for: session) {
                Label("Needs approval", systemImage: "hand.raised.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var titleLine: some View {
        Group {
            Text(session.title ?? "Untitled Session")
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)

            if isBusy {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }

            if viewModel.hasPermissionRequest(for: session) {
                Label("Needs approval", systemImage: "hand.raised.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.12), in: Capsule())
            }
        }
    }

    private var rowBackground: Color {
        isSelected ? Color.blue.opacity(0.10) : OpenCodePlatformColor.secondaryGroupedBackground
    }

    private var rowBorder: Color {
        isSelected ? Color.blue.opacity(0.28) : Color.primary.opacity(0.06)
    }
}
