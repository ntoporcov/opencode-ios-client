import SwiftUI

struct GitDiffView: View {
    @ObservedObject var viewModel: AppViewModel

    private var diff: OpenCodeVCSFileDiff? {
        viewModel.selectedVCSFileDiff
    }

    var body: some View {
        Group {
            if !viewModel.hasGitProject {
                ContentUnavailableView("Git Unavailable", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
            } else if let diff {
                OpenCodeUnifiedDiffView(
                    diff: OpenCodeUnifiedDiffData(
                        file: viewModel.relativeGitPath(diff.file),
                        patch: diff.patch,
                        additions: diff.additions,
                        deletions: diff.deletions,
                        status: diff.status
                    )
                )
                .navigationTitle(fileTitle(for: diff.file))
                .opencodeInlineNavigationTitle()
            } else if let selectedFile = viewModel.selectedVCSFile {
                ContentUnavailableView(
                    "Diff Unavailable",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(viewModel.relativeGitPath(selectedFile))
                )
            } else {
                ContentUnavailableView("Select a Changed File", systemImage: "doc.text")
            }
        }
    }

    private func fileTitle(for path: String) -> String {
        viewModel.relativeGitPath(path).split(separator: "/").last.map(String.init) ?? path
    }

}

struct ProjectFileContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Group {
            if !viewModel.hasGitProject {
                ContentUnavailableView("Files Unavailable", systemImage: "doc")
            } else if let path = viewModel.selectedProjectFilePath,
                      let content = viewModel.selectedProjectFileContent {
                fileContent(content, path: path)
                    .navigationTitle(fileTitle(for: path))
                    .opencodeInlineNavigationTitle()
            } else if viewModel.directoryState.isLoadingSelectedFileContent,
                      let path = viewModel.selectedProjectFilePath {
                ContentUnavailableView(
                    "Loading File",
                    systemImage: "doc.text",
                    description: Text(viewModel.relativeGitPath(path))
                )
            } else if let error = viewModel.directoryState.fileContentErrorMessage,
                      let path = viewModel.selectedProjectFilePath {
                ContentUnavailableView(
                    "Preview Unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text("\(viewModel.relativeGitPath(path))\n\n\(error)")
                )
            } else if let path = viewModel.selectedProjectFilePath {
                ContentUnavailableView(
                    "Select a File",
                    systemImage: "doc",
                    description: Text(viewModel.relativeGitPath(path))
                )
            } else {
                ContentUnavailableView("Select a File", systemImage: "doc")
            }
        }
    }

    @ViewBuilder
    private func fileContent(_ content: OpenCodeFileContent, path: String) -> some View {
        if content.type == "binary" {
            ContentUnavailableView(
                "Binary File",
                systemImage: "doc.fill",
                description: Text(viewModel.relativeGitPath(path))
            )
        } else {
            ScrollView([.vertical, .horizontal]) {
                Text(verbatim: content.content)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .textSelection(.enabled)
            }
            .background(OpenCodePlatformColor.groupedBackground)
        }
    }

    private func fileTitle(for path: String) -> String {
        viewModel.relativeGitPath(path).split(separator: "/").last.map(String.init) ?? path
    }
}

struct OpenCodeUnifiedDiffData: Identifiable, Hashable, Sendable {
    let file: String
    let patch: String
    let additions: Int
    let deletions: Int
    let status: String?

    var id: String { file }
}

struct OpenCodeUnifiedDiffView: View {
    let diff: OpenCodeUnifiedDiffData
    var showsHeader = true

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            LazyVStack(alignment: .leading, spacing: 0) {
                if showsHeader {
                    header(diff)
                        .padding(16)
                }

                ForEach(GitPatchParser.parse(diff.patch)) { line in
                    DiffLineRow(line: line)
                }
            }
        }
        .background(OpenCodePlatformColor.groupedBackground)
    }

    private func header(_ diff: OpenCodeUnifiedDiffData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(diff.file)
                .font(.headline)

            HStack(spacing: 12) {
                Text(statusTitle(diff.status))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(statusColor(diff.status))
                Text("+\(diff.additions)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.green)
                Text("-\(diff.deletions)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OpenCodePlatformColor.secondaryGroupedBackground)
    }

    private func statusTitle(_ status: String?) -> String {
        switch status {
        case "added":
            return "Added"
        case "deleted":
            return "Deleted"
        default:
            return "Modified"
        }
    }

    private func statusColor(_ status: String?) -> Color {
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

private struct DiffLineRow: View {
    let line: GitPatchParser.Line

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            gutterText(line.oldLineNumber)
            gutterText(line.newLineNumber)

            Text(verbatim: line.prefix)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(line.foregroundColor)
                .frame(width: 18, alignment: .center)

            Text(verbatim: line.content.isEmpty ? " " : line.content)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(line.foregroundColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
        .background(line.backgroundColor)
    }

    private func gutterText(_ value: Int?) -> some View {
        Text(value.map(String.init) ?? "")
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
            .frame(width: 44, alignment: .trailing)
            .padding(.trailing, 8)
            .textSelection(.enabled)
    }
}

enum GitPatchParser {
    struct Line: Identifiable {
        enum Kind {
            case header
            case hunk
            case addition
            case deletion
            case context
        }

        let id: Int
        let text: String
        let kind: Kind
        let oldLineNumber: Int?
        let newLineNumber: Int?

        var prefix: String {
            guard let first = text.first else { return "" }
            switch kind {
            case .addition, .deletion, .context:
                return String(first)
            case .header:
                return ""
            case .hunk:
                return "@"
            }
        }

        var content: String {
            switch kind {
            case .addition, .deletion, .context:
                return String(text.dropFirst())
            case .hunk:
                return text
            case .header:
                return text
            }
        }

        var backgroundColor: Color {
            switch kind {
            case .header:
                return OpenCodePlatformColor.secondaryGroupedBackground
            case .hunk:
                return Color.blue.opacity(0.10)
            case .addition:
                return Color.green.opacity(0.12)
            case .deletion:
                return Color.red.opacity(0.12)
            case .context:
                return .clear
            }
        }

        var foregroundColor: Color {
            switch kind {
            case .header:
                return .secondary
            case .hunk:
                return .blue
            case .addition:
                return .green
            case .deletion:
                return .red
            case .context:
                return .primary
            }
        }
    }

    static func parse(_ patch: String) -> [Line] {
        let rows = patch.components(separatedBy: .newlines)
        var lines: [Line] = []
        var oldLineNumber: Int?
        var newLineNumber: Int?

        for (index, raw) in rows.enumerated() {
            let kind: Line.Kind
            let oldValue: Int?
            let newValue: Int?

            if raw.hasPrefix("@@") {
                kind = .hunk
                let range = parseHunkRange(raw)
                oldLineNumber = range?.oldStart
                newLineNumber = range?.newStart
                oldValue = nil
                newValue = nil
            } else if raw.hasPrefix("+++") || raw.hasPrefix("---") || raw.hasPrefix("diff --git") || raw.hasPrefix("index ") || raw.hasPrefix("new file mode") || raw.hasPrefix("deleted file mode") {
                kind = .header
                oldValue = nil
                newValue = nil
            } else if raw.hasPrefix("+") {
                kind = .addition
                oldValue = nil
                newValue = newLineNumber
                if newLineNumber != nil {
                    selfIncrement(&newLineNumber)
                }
            } else if raw.hasPrefix("-") {
                kind = .deletion
                oldValue = oldLineNumber
                newValue = nil
                if oldLineNumber != nil {
                    selfIncrement(&oldLineNumber)
                }
            } else {
                kind = .context
                oldValue = oldLineNumber
                newValue = newLineNumber
                if oldLineNumber != nil {
                    selfIncrement(&oldLineNumber)
                }
                if newLineNumber != nil {
                    selfIncrement(&newLineNumber)
                }
            }

            lines.append(
                Line(
                    id: index,
                    text: raw,
                    kind: kind,
                    oldLineNumber: oldValue,
                    newLineNumber: newValue
                )
            )
        }

        return lines
    }

    private static func parseHunkRange(_ line: String) -> (oldStart: Int, newStart: Int)? {
        guard let firstSpace = line.firstIndex(of: " "),
              let secondSpace = line[line.index(after: firstSpace)...].firstIndex(of: " ") else {
            return nil
        }

        let oldToken = String(line[line.index(after: firstSpace)..<secondSpace])
        let remainderStart = line.index(after: secondSpace)
        let remainder = line[remainderStart...]
        guard let thirdSpace = remainder.firstIndex(of: " ") else {
            return nil
        }

        let newToken = String(remainder[..<thirdSpace])
        guard let oldStart = parseRangeStart(oldToken),
              let newStart = parseRangeStart(newToken) else {
            return nil
        }

        return (oldStart, newStart)
    }

    private static func parseRangeStart(_ token: String) -> Int? {
        guard let sign = token.first, sign == "-" || sign == "+" else {
            return nil
        }

        let body = token.dropFirst()
        let startText = body.split(separator: ",", maxSplits: 1).first.map(String.init) ?? String(body)
        return Int(startText)
    }

    private static func selfIncrement(_ value: inout Int?) {
        guard let current = value else { return }
        value = current + 1
    }
}
