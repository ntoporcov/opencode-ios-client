import SwiftUI

@main
struct OpenCodeIOSClientApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
                .onOpenURL { url in
                    Task { await viewModel.handleLiveActivityURL(url) }
                }
        }
    }
}
