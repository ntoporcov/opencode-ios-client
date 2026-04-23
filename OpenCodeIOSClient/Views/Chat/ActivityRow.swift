import SwiftUI

struct ActivityStyle {
    let title: String
    let subtitle: String?
    let icon: String
    let tint: Color
    let isRunning: Bool
    let showsDisclosure: Bool
    let shimmerTitle: Bool
}

struct ActivityRow: View {
    let style: ActivityStyle
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: style.icon)
                .font(.system(size: compact ? 13 : 14, weight: .semibold))
                .foregroundStyle(style.tint)
                .frame(width: compact ? 24 : 28, height: compact ? 24 : 28)
                .background(style.tint.opacity(compact ? 0.12 : 0.14), in: RoundedRectangle(cornerRadius: compact ? 7 : 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                ShimmeringText(text: style.title, active: style.shimmerTitle)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle = style.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .layoutPriority(1)

            Spacer()

            if style.isRunning {
                ProgressView()
                    .controlSize(.small)
                    .tint(style.tint)
            } else if style.showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, compact ? 10 : 12)
        .padding(.vertical, compact ? 8 : 10)
        .background(OpenCodePlatformColor.secondaryGroupedBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ShimmeringText: View {
    let text: String
    let active: Bool

    @State private var phase: CGFloat = -1

    var body: some View {
        Text(text)
            .foregroundStyle(.primary)
            .overlay {
                if active {
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.8), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: geometry.size.width * 0.85)
                        .offset(x: geometry.size.width * phase)
                        .blendMode(.plusLighter)
                    }
                    .mask(Text(text))
                    .allowsHitTesting(false)
                }
            }
            .onAppear {
                guard active else { return }
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
            .onChange(of: active) { _, isActive in
                if isActive {
                    phase = -1
                    withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                        phase = 1.3
                    }
                } else {
                    phase = -1
                }
            }
    }
}
