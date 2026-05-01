import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct OpenClientPaywallView: View {
    @ObservedObject var viewModel: AppViewModel
    @ObservedObject var purchaseManager: OpenClientPurchaseManager
    let reason: OpenClientPaywallReason

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(minLength: 12)

                PaywallAppIcon()

                VStack(spacing: 10) {
                    Text(reason.title)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text(reason.message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 14) {
                    PaywallBenefitRow(
                        title: "Unlimited prompts",
                        systemImage: "paperplane.fill",
                        tint: .blue
                    )
                    PaywallBenefitRow(
                        title: "Unlimited sessions",
                        systemImage: "bubble.left.and.bubble.right.fill",
                        tint: .purple
                    )
                    PaywallBenefitRow(
                        title: "Supports the open-source app",
                        systemImage: "heart.fill",
                        tint: .pink
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .opencodeGlassSurface(in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(spacing: 10) {
                    Button {
                        Task { await viewModel.purchaseProUnlock() }
                    } label: {
                        Text(purchaseButtonTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Restore Purchases") {
                        Task { await viewModel.restoreProUnlock() }
                    }
                    .font(.subheadline.weight(.medium))

                    if !isScreenshotScene, let error = purchaseManager.purchaseError {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }

#if DEBUG
                if !isScreenshotScene {
                    OpenClientDebugEntitlementControls(viewModel: viewModel)
                        .padding(.top, 4)
                }
#endif

                Spacer(minLength: 0)
            }
            .padding(24)
            .navigationTitle("OpenClient Pro")
            .opencodeInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .opencodeTrailing) {
                    Button("Done") {
                        viewModel.paywallReason = nil
                    }
                }
            }
            .onChange(of: purchaseManager.hasProUnlock) { _, unlocked in
                if unlocked {
                    viewModel.paywallReason = nil
                }
            }
        }
    }

    private var purchaseButtonTitle: String {
        if isScreenshotScene {
            return "Unlock for $9.99"
        }
        if purchaseManager.isLoadingProducts {
            return "Loading..."
        }
        if let price = purchaseManager.proProduct?.displayPrice {
            return "Unlock for \(price)"
        }
        return "Unlock Pro"
    }

    private var isScreenshotScene: Bool {
        ProcessInfo.processInfo.environment["OPENCLIENT_SCREENSHOT_SCENE"] == "paywall"
    }

}

private struct PaywallBenefitRow: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(tint.opacity(0.16), lineWidth: 1)
                }

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}

private struct PaywallAppIcon: View {
    var body: some View {
        Group {
            if let image = Self.appIconImage {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.tint)
                    .padding(14)
            }
        }
        .frame(width: 82, height: 82)
        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 18, y: 8)
        .accessibilityHidden(true)
    }

    private static var appIconImage: Image? {
        let names = iconNames
        for name in names {
#if canImport(UIKit)
            if let image = UIImage(named: name) {
                return Image(uiImage: image)
            }
#elseif canImport(AppKit)
            if let image = NSImage(named: name) {
                return Image(nsImage: image)
            }
#endif
        }
        return nil
    }

    private static var iconNames: [String] {
        var names: [String] = []
        if let iconName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIconName") as? String {
            names.append(iconName)
        }

        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String] {
            names.append(contentsOf: files.reversed())
        }

        names.append(contentsOf: ["AppIcon", "ios-1024", "mac-1024"])
        return Array(NSOrderedSet(array: names)) as? [String] ?? names
    }
}
