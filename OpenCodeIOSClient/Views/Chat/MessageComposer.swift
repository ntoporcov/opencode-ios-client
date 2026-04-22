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
        #if os(macOS)
        macComposer
        #else
        iosComposer
        #endif
    }

    #if os(macOS)
    private var macComposer: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Message", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.body)
                .lineLimit(1 ... 8)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .frame(minHeight: 46)
                .accessibilityIdentifier("chat.input")

            Button(action: isBusy ? onStop : onSend) {
                Image(systemName: isBusy ? "stop.fill" : "arrow.up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white.opacity((isBusy ? canStop : canSend) ? 1 : 0.78))
                    .frame(width: 18, height: 18)
                    .frame(width: 40, height: 40)
                    .background {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor.opacity(0.96), Color.accentColor.opacity(0.74)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity((isBusy ? canStop : canSend) ? 0.18 : 0.10), radius: 10, y: 4)
                    .opacity((isBusy ? canStop : canSend) ? 1 : 0.6)
            }
            .buttonStyle(.plain)
            .disabled(isBusy ? !canStop : !canSend)
            .accessibilityLabel(isBusy ? "Stop" : "Send")
            .accessibilityIdentifier(isBusy ? "chat.stop" : "chat.send")
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.clear)
        )
        .opencodeGlassSurface(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 16, y: 6)
        .animation(opencodeSelectionAnimation, value: isBusy)
        .animation(opencodeSelectionAnimation, value: canSend)
    }
    #endif

    private var iosComposer: some View {
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
