import Foundation
import Security
import StoreKit

enum OpenClientProductID {
    static let proUnlock = "com.ntoporcov.openclient.pro"
}

enum OpenClientCommerceLimits {
    static let dailyPromptLimit = 5
    static let freeSessionLimit = 1
}

enum OpenClientPaywallReason: Identifiable, Equatable {
    case promptLimit
    case sessionLimit
    case actions
    case manual

    var id: String {
        switch self {
        case .promptLimit: "promptLimit"
        case .sessionLimit: "sessionLimit"
        case .actions: "actions"
        case .manual: "manual"
        }
    }

    var title: String {
        switch self {
        case .promptLimit: "Daily Prompt Limit Reached"
        case .sessionLimit: "Create Unlimited Sessions"
        case .actions: "Unlock Actions"
        case .manual: "OpenClient Pro"
        }
    }

    var message: String {
        switch self {
        case .promptLimit:
            "Upgrade once to send unlimited prompts and support continued development of the open-source app."
        case .sessionLimit:
            "Free users can create one session. Upgrade once for unlimited sessions and prompts."
        case .actions:
            "Actions run project commands in temporary sessions and only surface when they need your attention."
        case .manual:
            "Unlock unlimited prompts and sessions, plus support the signed App Store build."
        }
    }
}

struct OpenClientUsageMeter: Codable, Equatable {
    var promptDay: String
    var dailyPromptCount: Int
    var createdSessionCount: Int

    static let empty = OpenClientUsageMeter(promptDay: Self.dayString(for: Date()), dailyPromptCount: 0, createdSessionCount: 0)

    mutating func normalize(for date: Date = Date()) {
        let currentDay = Self.dayString(for: date)
        if promptDay != currentDay {
            promptDay = currentDay
            dailyPromptCount = 0
        }
    }

    static func dayString(for date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
}

struct OpenClientUsageStore {
    private let service = "com.ntoporcov.openclient.usage-meter"
    private let account = "default"

    func load() -> OpenClientUsageMeter {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              var meter = try? JSONDecoder().decode(OpenClientUsageMeter.self, from: data) else {
            return .empty
        }
        meter.normalize()
        return meter
    }

    func save(_ meter: OpenClientUsageMeter) {
        guard let data = try? JSONEncoder().encode(meter) else { return }
        let attributes: [CFString: Any] = [kSecValueData: data]
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }

        var query = baseQuery
        query[kSecValueData as String] = data
        SecItemDelete(baseQuery as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}

#if DEBUG
enum OpenClientDebugEntitlementOverride: String, CaseIterable, Identifiable {
    case system
    case free
    case unlocked
    case limitReached

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .free: "Free"
        case .unlocked: "Unlocked"
        case .limitReached: "Limit Reached"
        }
    }
}
#endif

@MainActor
final class OpenClientPurchaseManager: ObservableObject {
    @Published private(set) var proProduct: Product?
    @Published private(set) var hasProUnlock = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchaseError: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = observeTransactions()
        Task {
            await refreshProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refreshProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let products = try await Product.products(for: [OpenClientProductID.proUnlock])
            proProduct = products.first
            purchaseError = nil
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func purchaseProUnlock() async {
        if proProduct == nil {
            await refreshProducts()
        }

        guard let proProduct else {
            purchaseError = "OpenClient Pro is not available yet."
            return
        }

        do {
            let result = try await proProduct.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                hasProUnlock = transaction.revocationDate == nil
                await transaction.finish()
                purchaseError = nil
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            purchaseError = nil
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.productID == OpenClientProductID.proUnlock, transaction.revocationDate == nil {
                unlocked = true
                break
            }
        }
        hasProUnlock = unlocked
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let transaction = try? self.checkVerified(result) {
                    await self.refreshEntitlements()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signedType):
            return signedType
        case .unverified:
            throw StoreKitError.notAvailableInStorefront
        }
    }
}
