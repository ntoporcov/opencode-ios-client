import Foundation

struct OpenCodeWidgetStore {
    static let appGroupIdentifier = "group.com.ntoporcov.openclient"

    private let storageKey = "OpenCodeWidgetSnapshotPayload"


    func load() -> OpenCodeWidgetSnapshotPayload {
        guard let data = defaults.data(forKey: storageKey),
              let payload = try? JSONDecoder().decode(OpenCodeWidgetSnapshotPayload.self, from: data) else {
            return .empty
        }
        return payload
    }

    func save(_ payload: OpenCodeWidgetSnapshotPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func updatingServer(
        _ server: OpenCodeWidgetServerSnapshot,
        projects: [OpenCodeWidgetProjectSnapshot],
        sessions: [OpenCodeWidgetSessionSnapshot],
        replacingSessionIDs: Set<String>
    ) {
        var payload = load()
        payload.servers.removeAll { $0.id == server.id }
        payload.servers = payload.servers.map { existing in
            OpenCodeWidgetServerSnapshot(
                id: existing.id,
                displayName: existing.displayName,
                baseURL: existing.baseURL,
                username: existing.username,
                generatedAt: existing.generatedAt,
                isLastConnected: false
            )
        }
        payload.servers.insert(server, at: 0)
        payload.projects.removeAll { $0.serverID == server.id }
        payload.projects.append(contentsOf: projects)
        payload.sessions.removeAll { $0.serverID == server.id && replacingSessionIDs.contains($0.id) }
        payload.sessions.append(contentsOf: sessions)
        payload.generatedAt = Date()
        save(payload)
    }

    func removeSession(serverID: String, sessionID: String) {
        var payload = load()
        payload.sessions.removeAll { $0.serverID == serverID && $0.id == sessionID }
        payload.generatedAt = Date()
        save(payload)
    }

    private var defaults: UserDefaults {
        UserDefaults(suiteName: Self.appGroupIdentifier) ?? .standard
    }
}
