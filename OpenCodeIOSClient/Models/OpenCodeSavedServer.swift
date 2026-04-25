import Foundation

struct OpenCodeSavedServer: Equatable, Codable, Sendable {
    var name: String?
    var iconName: String?
    var baseURL: String
    var username: String

    init(name: String? = nil, iconName: String? = nil, baseURL: String, username: String) {
        self.name = name
        self.iconName = iconName
        self.baseURL = baseURL
        self.username = username
    }

    init(config: OpenCodeServerConfig) {
        self.name = config.trimmedName.isEmpty ? nil : config.trimmedName
        self.iconName = config.trimmedIconName.isEmpty ? nil : config.trimmedIconName
        self.baseURL = config.baseURL
        self.username = config.username
    }

    var recentServerID: String {
        OpenCodeServerConfig(baseURL: baseURL, username: username, password: "").recentServerID
    }

    func serverConfig(password: String) -> OpenCodeServerConfig {
        OpenCodeServerConfig(name: name ?? "", iconName: iconName ?? "", baseURL: baseURL, username: username, password: password)
    }
}
