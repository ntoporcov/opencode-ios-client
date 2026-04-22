import SwiftUI

extension View {
    @ViewBuilder
    func opencodeToolbarGlassID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if #available(iOS 26.0, *) {
            self.glassEffectID(id, in: namespace)
        } else {
            self
        }
        #else
        self
        #endif
    }

    @ViewBuilder
    func opencodeGlassSurface<S: Shape>(clear: Bool = false, in shape: S) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if #available(iOS 26.0, *) {
            self
                .background(Color.clear, in: shape)
                .glassEffect(clear ? .clear : .regular, in: shape)
        } else {
            self.background(.thinMaterial, in: shape)
        }
        #elseif os(macOS)
        self
            .background(.ultraThinMaterial, in: shape)
            .overlay {
                shape
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            }
        #else
        self.background(.thinMaterial, in: shape)
        #endif
    }

    @ViewBuilder
    func opencodeGlassButton(clear: Bool) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if #available(iOS 26.1, *) {
            self.buttonStyle(.glass(clear ? .clear : .regular))
        } else {
            self.buttonStyle(.plain)
        }
        #elseif os(macOS)
        self.buttonStyle(OpenCodeSecondaryMacButtonStyle())
        #else
        self.buttonStyle(.plain)
        #endif
    }

    @ViewBuilder
    func opencodePrimaryGlassButton() -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.plain)
        }
        #elseif os(macOS)
        self.buttonStyle(OpenCodeProminentMacButtonStyle())
        #else
        self.buttonStyle(.plain)
        #endif
    }
}

#if os(macOS)
private struct OpenCodeProminentMacButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.95), Color.accentColor.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: .black.opacity(configuration.isPressed ? 0.12 : 0.20), radius: configuration.isPressed ? 4 : 10, y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

private struct OpenCodeSecondaryMacButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}
#endif
