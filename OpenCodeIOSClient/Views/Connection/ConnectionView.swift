import SwiftUI

struct ConnectionView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        List {
            if viewModel.showSavedServerPrompt, viewModel.recentServerConfigs.isEmpty == false {
                Section("Recent") {
                    ForEach(viewModel.recentServerConfigs, id: \.recentServerID) { serverConfig in
                        ZStack(alignment: .topTrailing) {
                            Button {
                                Task { await viewModel.connect(to: serverConfig) }
                            } label: {
                                RecentServerCard(serverConfig: serverConfig)
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isLoading)
                            .contextMenu {
                                Button {
                                    viewModel.prepareToEditRecentServer(serverConfig)
                                } label: {
                                    Label("Edit", systemImage: "square.and.pencil")
                                }

                                Button(role: .destructive) {
                                    viewModel.removeRecentServer(serverConfig)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Remove", role: .destructive) {
                                viewModel.removeRecentServer(serverConfig)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowSpacing(0.0)
                .padding(.horizontal,1)
                .padding(.vertical,0)
            }

            Section("Server") {
                TextField("Base URL", text: $viewModel.config.baseURL)
                    .opencodeDisableTextAutocapitalization()
                    .autocorrectionDisabled()
                    .opencodeURLKeyboardType()
                    .accessibilityIdentifier("connection.baseURL")

                TextField("Username", text: $viewModel.config.username)
                    .opencodeDisableTextAutocapitalization()
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("connection.username")

                SecureField("Password", text: $viewModel.config.password)
                    .accessibilityIdentifier("connection.password")
            }

            Section {
                Button(viewModel.isLoading ? "Connecting..." : "Connect to OpenCode") {
                    Task { await viewModel.connect() }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier("connection.connect")
            }

            if let errorMessage = viewModel.errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .opencodeGroupedListStyle()
        .opencodeLargeNavigationTitle()
    }
}

private struct RecentServerCard: View {
    let serverConfig: OpenCodeServerConfig

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.22), Color.accentColor.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "server.rack")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(serverConfig.displayHost)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(serverConfig.trimmedBaseURL)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(serverConfig.trimmedUsername)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 52)

            Image(systemName: "arrow.up.right.circle.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
