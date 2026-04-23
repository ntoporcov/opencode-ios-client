import Foundation

extension AppViewModel {
    private static let maxRecentServerCount = 4

    func connect() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let bootstrap = try await OpenCodeBootstrap.bootstrapGlobal(client: client)
            isConnected = bootstrap.health.healthy
            serverVersion = bootstrap.health.version
            errorMessage = nil
            persistConfig()
            loadNewSessionDefaults()
            projects = bootstrap.projects
            selectedDirectory = directorySelection(for: bootstrap.currentProject)
            selectedProjectContentTab = .sessions
            reconcileCurrentProjectSelection(serverProject: bootstrap.currentProject)
            try await reloadSessions()
            await loadComposerOptions()
            streamDirectory = directoryState.sessions.first?.directory
            startEventStream()
            await runUITestBootstrapIfNeeded()
        } catch {
            stopEventStream()
            isConnected = false
            directoryState = OpenCodeDirectoryState()
            errorMessage = error.localizedDescription
        }
    }

    func connect(to serverConfig: OpenCodeServerConfig) async {
        config = serverConfig
        await connect()
    }

    func prepareToEditRecentServer(_ serverConfig: OpenCodeServerConfig) {
        config = serverConfig
        errorMessage = nil
        showSavedServerPrompt = false
    }

    func disconnect() {
        stopEventStream()
        isConnected = false
        serverVersion = ""
        projects = []
        currentProject = nil
        selectedDirectory = nil
        selectedProjectContentTab = .sessions
        projectSearchQuery = ""
        projectSearchResults = []
        directoryState = OpenCodeDirectoryState()
        availableAgents = []
        availableProviders = []
        selectedAgentNamesBySessionID = [:]
        selectedModelsBySessionID = [:]
        selectedVariantsBySessionID = [:]
        newSessionDefaults = NewSessionDefaults()
        errorMessage = nil
        showSavedServerPrompt = hasSavedServer
    }

    func reconnectToSavedServer() async {
        guard hasSavedServer else { return }
        await connect()
    }

    func dismissSavedServerPrompt() {
        showSavedServerPrompt = false
    }

    func persistConfig() {
        let recentConfigs = ([config] + recentServerConfigs)
            .reduce(into: [OpenCodeServerConfig]()) { deduped, serverConfig in
                guard serverConfig.hasCredentials else { return }
                guard deduped.contains(where: { $0.recentServerID == serverConfig.recentServerID }) == false else { return }
                deduped.append(serverConfig)
            }

        recentServerConfigs = Array(recentConfigs.prefix(Self.maxRecentServerCount))
        hasSavedServer = recentServerConfigs.isEmpty == false
        showSavedServerPrompt = false

        guard let latestConfig = recentServerConfigs.first,
              let latestData = try? JSONEncoder().encode(latestConfig),
              let recentData = try? JSONEncoder().encode(recentServerConfigs) else {
            return
        }

        UserDefaults.standard.set(latestData, forKey: StorageKey.lastServerConfig)
        UserDefaults.standard.set(recentData, forKey: StorageKey.recentServerConfigs)
    }

    func loadSavedConfig() -> OpenCodeServerConfig? {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.lastServerConfig) else {
            return nil
        }

        return try? JSONDecoder().decode(OpenCodeServerConfig.self, from: data)
    }

    func loadRecentServerConfigs() -> [OpenCodeServerConfig] {
        if let data = UserDefaults.standard.data(forKey: StorageKey.recentServerConfigs),
           let configs = try? JSONDecoder().decode([OpenCodeServerConfig].self, from: data) {
            return Array(configs.prefix(Self.maxRecentServerCount))
        }

        if let savedConfig = loadSavedConfig() {
            return [savedConfig]
        }

        return []
    }

    func removeRecentServer(_ serverConfig: OpenCodeServerConfig) {
        recentServerConfigs.removeAll { $0.recentServerID == serverConfig.recentServerID }
        hasSavedServer = recentServerConfigs.isEmpty == false
        showSavedServerPrompt = hasSavedServer && showSavedServerPrompt

        if config.recentServerID == serverConfig.recentServerID,
           let replacement = recentServerConfigs.first {
            config = replacement
        }

        if recentServerConfigs.isEmpty {
            UserDefaults.standard.removeObject(forKey: StorageKey.lastServerConfig)
            UserDefaults.standard.removeObject(forKey: StorageKey.recentServerConfigs)
            return
        }

        guard let latestData = try? JSONEncoder().encode(recentServerConfigs[0]),
              let recentData = try? JSONEncoder().encode(recentServerConfigs) else {
            return
        }

        UserDefaults.standard.set(latestData, forKey: StorageKey.lastServerConfig)
        UserDefaults.standard.set(recentData, forKey: StorageKey.recentServerConfigs)
    }

    func configureUITestEnvironmentIfNeeded() -> Bool {
        let environment = ProcessInfo.processInfo.environment
        guard environment["OPENCODE_UI_TEST_MODE"] == "1" else {
            return false
        }

        UserDefaults.standard.removeObject(forKey: StorageKey.lastServerConfig)
        UserDefaults.standard.removeObject(forKey: StorageKey.recentServerConfigs)
        config.baseURL = environment["OPENCODE_UI_TEST_BASE_URL"] ?? "http://127.0.0.1:4096"
        config.username = environment["OPENCODE_UI_TEST_USERNAME"] ?? "opencode"
        config.password = environment["OPENCODE_UI_TEST_PASSWORD"] ?? ""
        uiTestBootstrapTitle = environment["OPENCODE_UI_TEST_SESSION_TITLE"]
        uiTestBootstrapPrompt = environment["OPENCODE_UI_TEST_PROMPT"]
        uiTestDirectory = environment["OPENCODE_UI_TEST_DIRECTORY"]
        hasSavedServer = false
        showSavedServerPrompt = false
        return true
    }

    func runUITestBootstrapIfNeeded() async {
        guard let title = uiTestBootstrapTitle,
              let prompt = uiTestBootstrapPrompt else {
            return
        }

        uiTestBootstrapTitle = nil
        uiTestBootstrapPrompt = nil

        do {
            if let uiTestDirectory, !uiTestDirectory.isEmpty {
                await selectDirectory(uiTestDirectory)
            }
            let session = try await client.createSession(title: title, directory: effectiveSelectedDirectory)
            upsertVisibleSession(session)
            directoryState.selectedSession = session
            try await loadMessages(for: session)
            try await client.sendMessageAsync(sessionID: session.id, text: prompt, directory: sendDirectory(for: session))
            try await loadMessages(for: session)
            try await reloadSessions()
            upsertVisibleSession(session)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
