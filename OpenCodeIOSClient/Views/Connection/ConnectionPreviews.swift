import SwiftUI

#if DEBUG
#Preview("Connection Form") {
    NavigationStack {
        ConnectionView(viewModel: AppViewModel.preview(isConnected: false))
            .navigationTitle("OpenCode")
    }
}

#Preview("Reconnect Prompt") {
    NavigationStack {
        ConnectionView(
            viewModel: AppViewModel.preview(
                isConnected: false,
                errorMessage: "Authentication failed",
                showSavedServerPrompt: true,
                hasSavedServer: true
            )
        )
        .navigationTitle("OpenCode")
    }
}
#Preview("Recent Servers") {
    NavigationStack {
        ConnectionView(
            viewModel: AppViewModel.preview(
                isConnected: false,
                showSavedServerPrompt: true,
                hasSavedServer: true,
                recentServerConfigs: [
                    OpenCodeServerConfig(baseURL: "http://10.0.1.12:4096", username: "nick", password: "secret"),
                    OpenCodeServerConfig(baseURL: "https://lab.example.com", username: "dev", password: "secret"),
                    OpenCodeServerConfig(baseURL: "http://192.168.1.44:4096", username: "team", password: "secret")
                ]
            )
        )
        .navigationTitle("OpenCode")
    }
}

#Preview("Add Server Sheet") {
    NavigationStack {
        ConnectionView(
            viewModel: AppViewModel.preview(
                isConnected: false,
                hasSavedServer: true,
                recentServerConfigs: [
                    OpenCodeServerConfig(baseURL: "http://10.0.1.12:4096", username: "nick", password: "secret"),
                    OpenCodeServerConfig(baseURL: "https://lab.example.com", username: "dev", password: "secret")
                ],
                isShowingAddServerSheet: true
            )
        )
        .navigationTitle("OpenCode")
    }
}
#endif
