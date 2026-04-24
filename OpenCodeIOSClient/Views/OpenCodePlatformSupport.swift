import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum OpenCodePlatformColor {
    static var groupedBackground: Color {
#if canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
#elseif canImport(UIKit)
        Color(uiColor: .systemGroupedBackground)
#else
        Color(.systemBackground)
#endif
    }

    static var secondaryGroupedBackground: Color {
#if canImport(AppKit)
        Color(nsColor: .controlBackgroundColor)
#elseif canImport(UIKit)
        Color(uiColor: .secondarySystemGroupedBackground)
#else
        Color.secondary.opacity(0.12)
#endif
    }
}

enum OpenCodeClipboard {
    static func copy(_ string: String) {
#if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
#elseif canImport(UIKit)
        UIPasteboard.general.string = string
#endif
    }
}

enum OpenCodeHaptics {
    enum ImpactStyle {
        case crisp
        case soft
        case strong
    }

    @MainActor
    static func impact(_ style: ImpactStyle) {
#if canImport(UIKit)
        let generator: UIImpactFeedbackGenerator
        switch style {
        case .crisp:
            generator = UIImpactFeedbackGenerator(style: .rigid)
        case .soft:
            generator = UIImpactFeedbackGenerator(style: .soft)
        case .strong:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        }
        generator.prepare()
        generator.impactOccurred()
#endif
    }
}

extension View {
    @ViewBuilder
    func opencodeInlineNavigationTitle() -> some View {
#if os(iOS) || targetEnvironment(macCatalyst)
        navigationBarTitleDisplayMode(.inline)
#else
        self
#endif
    }

    @ViewBuilder
    func opencodeLargeNavigationTitle() -> some View {
#if os(iOS) || targetEnvironment(macCatalyst)
        navigationBarTitleDisplayMode(.large)
#else
        self
#endif
    }

    @ViewBuilder
    func opencodeURLKeyboardType() -> some View {
#if os(iOS) || targetEnvironment(macCatalyst)
        keyboardType(.URL)
#else
        self
#endif
    }

    @ViewBuilder
    func opencodeDisableTextAutocapitalization() -> some View {
#if os(iOS) || targetEnvironment(macCatalyst)
        textInputAutocapitalization(.never)
#else
        self
#endif
    }

    @ViewBuilder
    func opencodeInteractiveKeyboardDismiss() -> some View {
#if os(iOS) || targetEnvironment(macCatalyst)
        scrollDismissesKeyboard(.interactively)
#else
        self
#endif
    }

    @ViewBuilder
    func opencodeGroupedListStyle() -> some View {
#if os(macOS)
        listStyle(.inset)
#else
        listStyle(.insetGrouped)
#endif
    }
}

extension ToolbarItemPlacement {
    static var opencodeLeading: ToolbarItemPlacement {
#if os(macOS)
        .automatic
#else
        .topBarLeading
#endif
    }

    static var opencodeTrailing: ToolbarItemPlacement {
#if os(macOS)
        .automatic
#else
        .topBarTrailing
#endif
    }
}
