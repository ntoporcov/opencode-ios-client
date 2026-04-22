import SwiftUI

struct MessageComposer: View {
    @Binding var text: String
    let isBusy: Bool
    let onSend: () -> Void
    let onStop: () -> Void

    private var canSend: Bool {
        !isBusy && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var canStop: Bool {
        isBusy
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message", text: $text, axis: .vertical)
                .lineLimit(1 ... 6)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .opencodeGlassSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .accessibilityIdentifier("chat.input")

            Button(action: isBusy ? onStop : onSend) {
                Image(systemName: isBusy ? "stop.fill" : "arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle((isBusy ? canStop : canSend) ? .primary : .secondary)
                    .frame(width: 32, height: 32)
            }
            .opencodePrimaryGlassButton()
            .disabled(isBusy ? !canStop : !canSend)
            .accessibilityLabel(isBusy ? "Stop" : "Send")
            .accessibilityIdentifier(isBusy ? "chat.stop" : "chat.send")
        }
        .shadow(color: .black.opacity(0.06), radius: 12, y: 3)
        .animation(opencodeSelectionAnimation, value: isBusy)
        .animation(opencodeSelectionAnimation, value: canSend)
    }
}
