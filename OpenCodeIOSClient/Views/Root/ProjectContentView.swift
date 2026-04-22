import SwiftUI

struct ProjectContentView: View {
    @ObservedObject var viewModel: AppViewModel
    let onDetailChosen: () -> Void

    var body: some View {
        TabView(selection: $viewModel.selectedProjectContentTab) {
            SessionListView(viewModel: viewModel, onSessionChosen: onDetailChosen)
                .tabItem {
                    Label(AppViewModel.ProjectContentTab.sessions.title, systemImage: "bubble.left.and.bubble.right")
                }
                .tag(AppViewModel.ProjectContentTab.sessions)

            if viewModel.hasGitProject {
                GitStatusView(viewModel: viewModel, onFileChosen: onDetailChosen)
                    .tabItem {
                        Label(AppViewModel.ProjectContentTab.git.title, systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    }
                    .tag(AppViewModel.ProjectContentTab.git)
            }
        }
        .background(OpenCodePlatformColor.groupedBackground)
        .navigationTitle(projectTitle)
        .opencodeInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .opencodeTrailing) {
                Button(action: toolbarAction) {
                    Image(systemName: toolbarIcon)
                }
                .accessibilityLabel(toolbarLabel)
                .accessibilityIdentifier(toolbarIdentifier)
                .disabled(toolbarDisabled)
            }
        }
        .onAppear {
            syncProjectTabIfNeeded()
        }
        .onChange(of: viewModel.currentProject?.id) { _, _ in
            syncProjectTabIfNeeded()
        }
        .onChange(of: viewModel.selectedProjectContentTab) { _, tab in
            if tab == .git {
                viewModel.presentGitView()
            }
        }
    }

    private func syncProjectTabIfNeeded() {
        if !viewModel.hasGitProject, viewModel.selectedProjectContentTab == .git {
            viewModel.selectedProjectContentTab = .sessions
        }
    }

    private var projectTitle: String {
        viewModel.projectScopeTitle.split(separator: "/").last.map(String.init) ?? viewModel.projectScopeTitle
    }

    private var toolbarIcon: String {
        switch viewModel.selectedProjectContentTab {
        case .sessions:
            return "square.and.pencil"
        case .git:
            return "arrow.clockwise"
        }
    }

    private var toolbarLabel: String {
        switch viewModel.selectedProjectContentTab {
        case .sessions:
            return "Create Session"
        case .git:
            return "Refresh Git"
        }
    }

    private var toolbarIdentifier: String {
        switch viewModel.selectedProjectContentTab {
        case .sessions:
            return "sessions.create"
        case .git:
            return "git.refresh"
        }
    }

    private var toolbarDisabled: Bool {
        switch viewModel.selectedProjectContentTab {
        case .sessions:
            return false
        case .git:
            return viewModel.directoryState.isLoadingVCS
        }
    }

    private func toolbarAction() {
        switch viewModel.selectedProjectContentTab {
        case .sessions:
            viewModel.presentCreateSessionSheet()
        case .git:
            Task {
                await viewModel.reloadGitViewData(force: true)
            }
        }
    }
}
