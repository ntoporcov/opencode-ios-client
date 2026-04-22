import SwiftUI

struct CreateSessionSheet: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Session Name") {
                    TextField("Optional title", text: $viewModel.draftTitle)
                        .accessibilityIdentifier("sessions.create.title")
                }

                Section("Scope") {
                    Text(viewModel.projectScopeTitle)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button(viewModel.isLoading ? "Creating..." : "Create Session") {
                        Task { await viewModel.createSession() }
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityIdentifier("sessions.create.confirm")
                }
            }
            .navigationTitle("New Session")
            .opencodeInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .opencodeLeading) {
                    Button("Cancel") {
                        viewModel.isShowingCreateSessionSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
