import Foundation

struct OpenCodeSavedServer: Equatable, Codable, Sendable {
    var baseURL: String
    var username: String

    init(baseURL: String, username: String) {
        self.baseURL = baseURL
        self.username = username
    }

    init(config: OpenCodeServerConfig) {
        self.baseURL = config.baseURL
        self.username = config.username
    }

    var recentServerID: String {
        OpenCodeServerConfig(baseURL: baseURL, username: username, password: "").recentServerID
    }

    func serverConfig(password: String) -> OpenCodeServerConfig {
        OpenCodeServerConfig(baseURL: baseURL, username: username, password: password)
    }
}
