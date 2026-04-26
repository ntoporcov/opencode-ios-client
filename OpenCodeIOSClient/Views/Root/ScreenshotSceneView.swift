import SwiftUI

#if DEBUG
struct ScreenshotSceneView: View {
    let scene: OpenClientScreenshotScene
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            screenshotContent

            Text(scene.rawValue)
                .font(.caption2)
                .foregroundStyle(.clear)
                .padding(1)
                .accessibilityIdentifier(scene.accessibilityIdentifier)
        }
    }

    @ViewBuilder
    private var screenshotContent: some View {
        switch scene {
        case .connection, .recentServers:
            NavigationStack {
                ConnectionView(viewModel: viewModel)
            }
        case .projects:
            NavigationStack {
                ProjectListView(viewModel: viewModel) {}
            }
        case .sessions:
            NavigationStack {
                SessionListView(viewModel: viewModel) {}
                    .navigationTitle("Sessions")
            }
        case .chat, .permission, .question:
            NavigationStack {
                ChatView(viewModel: viewModel, sessionID: OpenClientScreenshotData.releaseSession.id)
            }
        case .recentWidget:
            WidgetScreenshotDashboardView(
                title: "Recent Sessions",
                serverName: OpenClientScreenshotData.widgetServer.displayName,
                sessions: OpenClientScreenshotData.recentWidgetSessions
            )
        case .pinnedWidget:
            WidgetScreenshotDashboardView(
                title: "Pinned Sessions",
                serverName: OpenClientScreenshotData.widgetServer.displayName,
                sessions: OpenClientScreenshotData.pinnedWidgetSessions
            )
        }
    }
}
#endif
