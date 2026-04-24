import SwiftUI

@main
struct OpenCodeIOSClientApp: App {
    @StateObject private var viewModel: AppViewModel
#if DEBUG
    private let screenshotScene: OpenClientScreenshotScene?
#endif

    init() {
#if DEBUG
        let screenshotScene = OpenClientScreenshotScene.current
        self.screenshotScene = screenshotScene
        if let screenshotScene {
            _viewModel = StateObject(wrappedValue: AppViewModel.screenshot(scene: screenshotScene))
        } else {
            _viewModel = StateObject(wrappedValue: AppViewModel())
        }
#else
        _viewModel = StateObject(wrappedValue: AppViewModel())
#endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
#if DEBUG
                if let screenshotScene {
                    ScreenshotSceneView(scene: screenshotScene, viewModel: viewModel)
                } else {
                    RootView(viewModel: viewModel)
                }
#else
                RootView(viewModel: viewModel)
#endif
            }
            .onOpenURL { url in
                Task { await viewModel.handleLiveActivityURL(url) }
            }
        }
    }
}
