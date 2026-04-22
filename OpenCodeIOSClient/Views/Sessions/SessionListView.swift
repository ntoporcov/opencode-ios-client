import SwiftUI

struct SessionListView: View {
    @ObservedObject var viewModel: AppViewModel
    let onSessionChosen: () -> Void

    var body: some View {
        let sessionIDs = viewModel.sessions.map { $0.id }.joined(separator: "|")

        List {
            Section("Sessions") {
                ForEach(viewModel.sessions) { session in
                    Button {
                        Task {
                            await viewModel.selectSession(session)
                            withAnimation(opencodeSelectionAnimation) {
                                onSessionChosen()
                            }
                        }
                    } label: {
                        SessionRow(viewModel: viewModel, session: session)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(viewModel.selectedSession?.id == session.id ? Color.blue.opacity(0.10) : Color.clear)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteSession(session) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $viewModel.isShowingCreateSessionSheet) {
            CreateSessionSheet(viewModel: viewModel)
        }
        .animation(opencodeSelectionAnimation, value: viewModel.selectedSession?.id)
        .animation(opencodeSelectionAnimation, value: sessionIDs)
        .animation(opencodeSelectionAnimation, value: viewModel.errorMessage ?? "")
    }
}
