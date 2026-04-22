import SwiftUI

struct GitStatusView: View {
    @ObservedObject var viewModel: AppViewModel
    let onFileChosen: () -> Void

    private var statusIDs: String {
        viewModel.vcsFileStatuses.map(\.id).joined(separator: "|")
    }

    var body: some View {
        List {
            if let info = viewModel.vcsInfo {
                Section("Repository") {
                    HStack(spacing: 12) {
                        Label(info.branch ?? "Unknown", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        if let defaultBranch = info.defaultBranch, defaultBranch != info.branch {
                            Text("base \(defaultBranch)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !viewModel.availableVCSDiffModes.isEmpty {
                Section {
                    Picker("Diff Mode", selection: Binding(
                        get: { viewModel.selectedVCSDiffMode },
                        set: { viewModel.selectVCSMode($0) }
                    )) {
                        ForEach(viewModel.availableVCSDiffModes, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            if let errorMessage = viewModel.directoryState.vcsErrorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section(viewModel.selectedVCSDiffMode == .git ? "Working Tree" : "Branch Diff") {
                if viewModel.directoryState.isLoadingVCS && viewModel.vcsFileStatuses.isEmpty {
                    ProgressView("Loading changes")
                } else if viewModel.vcsFileStatuses.isEmpty {
                    Text("No changes")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.vcsFileStatuses) { file in
                        Button {
                            viewModel.selectVCSFile(file.path)
                            withAnimation(opencodeSelectionAnimation) {
                                onFileChosen()
                            }
                        } label: {
                            GitStatusRow(
                                title: relativeTitle(for: file.path),
                                subtitle: relativeSubtitle(for: file.path),
                                status: file.status,
                                additions: file.added,
                                deletions: file.removed,
                                selected: viewModel.selectedVCSFile == file.path
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(viewModel.selectedVCSFile == file.path ? Color.blue.opacity(0.10) : Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                }
            }
        }
        .listStyle(.plain)
        .task {
            await viewModel.loadGitViewDataIfNeeded()
        }
        .animation(opencodeSelectionAnimation, value: statusIDs)
        .animation(opencodeSelectionAnimation, value: viewModel.selectedVCSFile ?? "")
    }

    private func relativeTitle(for path: String) -> String {
        let relative = viewModel.relativeGitPath(path)
        return relative.split(separator: "/").last.map(String.init) ?? relative
    }

    private func relativeSubtitle(for path: String) -> String? {
        let relative = viewModel.relativeGitPath(path)
        let components = relative.split(separator: "/")
        guard components.count > 1 else { return nil }
        return components.dropLast().joined(separator: "/")
    }
}

private struct GitStatusRow: View {
    let title: String
    let subtitle: String?
    let status: String
    let additions: Int
    let deletions: Int
    let selected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                Text("+\(additions)")
                    .foregroundStyle(.green)
                Text("-\(deletions)")
                    .foregroundStyle(.red)
            }
            .font(.caption.monospacedDigit())
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .opacity(selected ? 1 : 0.96)
    }

    private var statusColor: Color {
        switch status {
        case "added":
            return .green
        case "deleted":
            return .red
        default:
            return .orange
        }
    }
}
