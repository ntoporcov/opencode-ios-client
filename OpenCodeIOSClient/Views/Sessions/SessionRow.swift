import SwiftUI

struct SessionRow: View {
    @ObservedObject var viewModel: AppViewModel
    let session: OpenCodeSession

    var body: some View {
        HStack(spacing: 12) {
            SessionAvatar(title: session.title ?? "Untitled Session")

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(session.title ?? "Untitled Session")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if viewModel.hasPermissionRequest(for: session) {
                        Label("Needs approval", systemImage: "hand.raised.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.12), in: Capsule())
                    }

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .animation(opencodeSelectionAnimation, value: viewModel.hasPermissionRequest(for: session))
        .animation(opencodeSelectionAnimation, value: viewModel.sessionPreviews[session.id]?.text ?? "")
    }
}
