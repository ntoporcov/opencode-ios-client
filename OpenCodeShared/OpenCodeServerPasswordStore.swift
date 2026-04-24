import Foundation
import Security

struct OpenCodeServerPasswordStore {
    private let service = "com.ntoporcov.openclient.server-password"
    private let accessGroupInfoKey = "OpenCodeSharedKeychainAccessGroup"

    func savePassword(_ password: String, for serverID: String) {
        let passwordData = Data(password.utf8)
        savePassword(passwordData, for: serverID, includeSharedAccessGroup: false)
        savePassword(passwordData, for: serverID, includeSharedAccessGroup: true)
    }

    func loadPassword(for serverID: String) -> String? {
        if let password = loadPassword(for: serverID, includeSharedAccessGroup: false) {
            return password
        }

        guard let sharedPassword = loadPassword(for: serverID, includeSharedAccessGroup: true) else {
            return nil
        }

        savePassword(Data(sharedPassword.utf8), for: serverID, includeSharedAccessGroup: false)
        return sharedPassword
    }

    func deletePassword(for serverID: String) {
        SecItemDelete(baseQuery(for: serverID, includeSharedAccessGroup: false) as CFDictionary)
        SecItemDelete(baseQuery(for: serverID, includeSharedAccessGroup: true) as CFDictionary)
    }

    private func loadPassword(for serverID: String, includeSharedAccessGroup: Bool) -> String? {
        var query = baseQuery(for: serverID, includeSharedAccessGroup: includeSharedAccessGroup)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        return password
    }

    private func savePassword(_ passwordData: Data, for serverID: String, includeSharedAccessGroup: Bool) {
        var query = baseQuery(for: serverID, includeSharedAccessGroup: includeSharedAccessGroup)
        let attributes: [CFString: Any] = [kSecValueData: passwordData]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }

        query[kSecValueData as String] = passwordData
        SecItemDelete(baseQuery(for: serverID, includeSharedAccessGroup: includeSharedAccessGroup) as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func baseQuery(for serverID: String, includeSharedAccessGroup: Bool) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: serverID,
        ]
        if includeSharedAccessGroup, let sharedAccessGroup {
            query[kSecAttrAccessGroup as String] = sharedAccessGroup
        }
        return query
    }

    private var sharedAccessGroup: String? {
        Bundle.main.object(forInfoDictionaryKey: accessGroupInfoKey) as? String
    }
}
