import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        Group {
            if viewModel.isConnected {
                NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
                    ProjectListView(viewModel: viewModel) {
                        withAnimation(opencodeSelectionAnimation) {
                            preferredCompactColumn = .content
                        }
                    }
                } content: {
                    ProjectContentView(viewModel: viewModel) {
                        withAnimation(opencodeSelectionAnimation) {
                            preferredCompactColumn = .detail
                        }
                    }
                } detail: {
                    if viewModel.selectedProjectContentTab == .git, viewModel.hasGitProject {
                        GitDiffView(viewModel: viewModel)
                    } else if let session = viewModel.selectedSession {
                        ChatView(viewModel: viewModel, sessionID: session.id)
                            .id(session.id)
                    } else {
                        ContentUnavailableView("Select a Session", systemImage: "bubble.left.and.bubble.right")
                    }
                }
                .onChange(of: viewModel.selectedSession?.id) { _, sessionID in
                    if sessionID == nil {
                        withAnimation(opencodeSelectionAnimation) {
                            preferredCompactColumn = .content
                        }
                    }
                }
                .animation(opencodeSelectionAnimation, value: viewModel.selectedSession?.id)
            } else {
                NavigationStack {
                    ConnectionView(viewModel: viewModel)
                        .navigationTitle("OpenCode")
                        .opencodeLargeNavigationTitle()
                }
            }
        }
        .animation(opencodeSelectionAnimation, value: viewModel.isConnected)
    }
}
