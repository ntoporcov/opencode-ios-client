import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct TodoStrip: View {
    let todos: [OpenCodeTodo]
    let onTapCard: () -> Void

    private var focusTodoID: String? {
        todos.first(where: { $0.isInProgress })?.id ?? todos.first(where: { !$0.isComplete })?.id
    }

    private var todoIDs: String {
        todos.map { $0.id }.joined(separator: "|")
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(todos) { todo in
                        Button {
                            onTapCard()
                        } label: {
                            TodoCard(todo: todo)
                        }
                        .buttonStyle(.plain)
                        .id(todo.id)
                    }
                }
                .padding(.horizontal, 1)
            }
            .scrollClipDisabled()
            .onAppear {
                scrollToFocus(with: proxy, animated: false)
            }
            .onChange(of: focusTodoID) { _, _ in
                scrollToFocus(with: proxy, animated: true)
            }
            .animation(opencodeSelectionAnimation, value: todoIDs)
        }
    }

    private func scrollToFocus(with proxy: ScrollViewProxy, animated: Bool) {
        guard let focusTodoID else { return }
        let action = {
            proxy.scrollTo(focusTodoID, anchor: .leading)
        }
        if animated {
            withAnimation(opencodeSelectionAnimation, action)
        } else {
            action()
        }
    }
}

enum ComposerAccessoryExpansion: Equatable {
    case collapsed
    case expanded(focus: Focus)

    enum Focus: String, Equatable {
        case todos
        case attachments
    }

    var focus: Focus? {
        if case let .expanded(focus) = self {
            return focus
        }
        return nil
    }

    var isExpanded: Bool {
        focus != nil
    }
}

struct ComposerAccessoryArea: View {
    let todos: [OpenCodeTodo]
    let attachments: [OpenCodeComposerAttachment]
    @Binding var expansion: ComposerAccessoryExpansion
    let onTapTodo: () -> Void
    let onTapAttachment: (OpenCodeComposerAttachment) -> Void
    let onRemoveAttachment: (OpenCodeComposerAttachment) -> Void

    private let todoSectionID = "composer-accessories-todos"
    private let attachmentSectionID = "composer-accessories-attachments"

    private var activeTodos: [OpenCodeTodo] {
        todos.filter { !$0.isComplete }
    }

    private var hasBothKinds: Bool {
        !activeTodos.isEmpty && !attachments.isEmpty
    }

    var body: some View {
        Group {
            if activeTodos.isEmpty && attachments.isEmpty {
                EmptyView()
            } else if hasBothKinds {
                if expansion.isExpanded {
                    expandedRail
                } else {
                    collapsedStacks
                }
            } else if !activeTodos.isEmpty {
                TodoStrip(todos: activeTodos, onTapCard: onTapTodo)
            } else {
                AttachmentStrip(
                    attachments: attachments,
                    allowsRemoval: true,
                    onTapAttachment: onTapAttachment,
                    onRemoveAttachment: onRemoveAttachment
                )
            }
        }
    }

    private var collapsedStacks: some View {
        HStack(spacing: 14) {
            AccessoryStackSummary(
                title: "Todos",
                count: activeTodos.count,
                tint: .blue,
                focus: .todos,
                expansion: $expansion
            ) {
                ForEach(Array(activeTodos.prefix(3).enumerated()), id: \.element.id) { entry in
                    let todo = entry.element
                    StackTodoCard(todo: todo)
                        .rotationEffect(.degrees(summaryRotation(index: entry.offset)))
                        .offset(x: CGFloat(entry.offset) * 5, y: CGFloat(entry.offset) * -2)
                }
            }

            AccessoryStackSummary(
                title: "Attachments",
                count: attachments.count,
                tint: .purple,
                focus: .attachments,
                expansion: $expansion
            ) {
                ForEach(Array(attachments.prefix(3).enumerated()), id: \.element.id) { entry in
                    let attachment = entry.element
                    StackAttachmentCard(attachment: attachment)
                        .rotationEffect(.degrees(summaryRotation(index: entry.offset)))
                        .offset(x: CGFloat(entry.offset) * 5, y: CGFloat(entry.offset) * -2)
                }
            }
        }
    }

    private var expandedRail: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    accessorySection(title: "Todos") {
                        HStack(spacing: 10) {
                            ForEach(activeTodos) { todo in
                                Button {
                                    onTapTodo()
                                } label: {
                                    TodoCard(todo: todo)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .id(todoSectionID)

                    accessorySection(title: "Attachments") {
                        HStack(spacing: 10) {
                            ForEach(attachments) { attachment in
                                AttachmentCard(
                                    attachment: attachment,
                                    allowsRemoval: true,
                                    onTap: { onTapAttachment(attachment) },
                                    onRemove: { onRemoveAttachment(attachment) }
                                )
                            }
                        }
                    }
                    .id(attachmentSectionID)
                }
                .padding(.horizontal, 1)
            }
            .scrollClipDisabled()
            .onAppear {
                scrollExpandedRail(with: proxy, animated: false)
            }
            .onChange(of: expansion) { _, _ in
                scrollExpandedRail(with: proxy, animated: true)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func accessorySection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            content()
        }
    }

    private func scrollExpandedRail(with proxy: ScrollViewProxy, animated: Bool) {
        guard let focus = expansion.focus else { return }
        let targetID = focus == .todos ? todoSectionID : attachmentSectionID
        let action = {
            proxy.scrollTo(targetID, anchor: .leading)
        }
        if animated {
            withAnimation(opencodeSelectionAnimation, action)
        } else {
            action()
        }
    }

    private func summaryRotation(index: Int) -> Double {
        switch index {
        case 0: return -4
        case 1: return 2
        default: return 5
        }
    }
}

struct AttachmentStrip: View {
    let attachments: [OpenCodeComposerAttachment]
    let allowsRemoval: Bool
    let onTapAttachment: (OpenCodeComposerAttachment) -> Void
    let onRemoveAttachment: (OpenCodeComposerAttachment) -> Void

    private var attachmentIDs: String {
        attachments.map { $0.id }.joined(separator: "|")
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(attachments) { attachment in
                        AttachmentCard(
                            attachment: attachment,
                            allowsRemoval: allowsRemoval,
                            onTap: { onTapAttachment(attachment) },
                            onRemove: { onRemoveAttachment(attachment) }
                        )
                        .id(attachment.id)
                    }
                }
                .padding(.horizontal, 1)
            }
            .scrollClipDisabled()
            .onAppear {
                scrollToLastAttachment(with: proxy, animated: false)
            }
            .onChange(of: attachmentIDs) { _, _ in
                scrollToLastAttachment(with: proxy, animated: true)
            }
            .animation(opencodeSelectionAnimation, value: attachmentIDs)
        }
    }

    private func scrollToLastAttachment(with proxy: ScrollViewProxy, animated: Bool) {
        guard let lastID = attachments.last?.id else { return }
        let action = {
            proxy.scrollTo(lastID, anchor: .trailing)
        }
        if animated {
            withAnimation(opencodeSelectionAnimation, action)
        } else {
            action()
        }
    }
}

struct AttachmentCard: View {
    let attachment: OpenCodeComposerAttachment
    let allowsRemoval: Bool
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                cardContent
            }
            .buttonStyle(.plain)

            if allowsRemoval {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .padding(8)
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        if attachment.isImage {
            AttachmentThumbnail(attachment: attachment)
                .frame(width: 140, height: 140)
                .background(OpenCodePlatformColor.secondaryGroupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            VStack(alignment: .leading, spacing: 8) {
                AttachmentThumbnail(attachment: attachment)
                    .frame(height: 78)

                VStack(alignment: .leading, spacing: 4) {
                    Text(attachment.filename)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(attachmentLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .frame(width: 140, alignment: .leading)
            .background(OpenCodePlatformColor.secondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var attachmentLabel: String {
        if attachment.isImage { return "Image" }
        if attachment.mime == "application/pdf" { return "PDF" }
        if attachment.mime.lowercased().contains("text") { return "Text File" }
        if attachment.filename.lowercased().hasSuffix(".txt") { return "Text File" }
        return attachment.mime
    }
}

struct AttachmentPreviewSheet: View {
    let attachment: OpenCodeComposerAttachment

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if attachment.isImage {
                    AttachmentThumbnail(attachment: attachment, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .background(OpenCodePlatformColor.secondaryGroupedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: fileSymbol(for: attachment))
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text(attachment.filename)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                    .background(OpenCodePlatformColor.secondaryGroupedBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 10) {
                    attachmentDetailRow(title: "Name", value: attachment.filename)
                    attachmentDetailRow(title: "Type", value: attachment.mime)
                }
                .padding(16)
                .background(OpenCodePlatformColor.secondaryGroupedBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(20)
        }
        .background(OpenCodePlatformColor.groupedBackground)
        .navigationTitle(attachment.isImage ? "" : attachment.filename)
        .opencodeInlineNavigationTitle()
    }

    private func attachmentDetailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
        }
    }
}

struct AttachmentThumbnail: View {
    let attachment: OpenCodeComposerAttachment
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if attachment.isImage, let image = image(for: attachment) {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: fileSymbol(for: attachment))
                        .font(.system(size: 28, weight: .semibold))
                    Text(shortFileLabel(for: attachment))
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(OpenCodePlatformColor.groupedBackground)
            }
        }
        .background(OpenCodePlatformColor.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct AccessoryStackSummary<Cards: View>: View {
    let title: String
    let count: Int
    let tint: Color
    let focus: ComposerAccessoryExpansion.Focus
    @Binding var expansion: ComposerAccessoryExpansion
    @ViewBuilder let cards: () -> Cards

    var body: some View {
        Button {
            withAnimation(opencodeSelectionAnimation) {
                expansion = .expanded(focus: focus)
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                cards()

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text("\(count) item\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity, minHeight: 94, alignment: .bottomLeading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(tint.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(tint.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct StackTodoCard: View {
    let todo: OpenCodeTodo

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(OpenCodePlatformColor.secondaryGroupedBackground)
            .frame(height: 86)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(todo.content)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(2)
                    Text(todo.status.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
            }
    }
}

private struct StackAttachmentCard: View {
    let attachment: OpenCodeComposerAttachment

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(OpenCodePlatformColor.secondaryGroupedBackground)
            .frame(height: 86)
            .overlay {
                HStack(spacing: 10) {
                    AttachmentThumbnail(attachment: attachment)
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(attachment.filename)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                        Text(attachment.isImage ? "Image" : "Attachment")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
            }
    }
}

private func fileSymbol(for attachment: OpenCodeComposerAttachment) -> String {
    if attachment.isImage { return "photo" }
    if attachment.mime == "application/pdf" { return "doc.richtext" }
    if attachment.mime.lowercased().contains("text") { return "doc.text" }
    return "doc"
}

private func shortFileLabel(for attachment: OpenCodeComposerAttachment) -> String {
    if attachment.isImage { return "Image" }
    if attachment.mime == "application/pdf" { return "PDF" }
    if attachment.mime.lowercased().contains("text") { return "TXT" }
    if attachment.filename.lowercased().hasSuffix(".txt") { return "TXT" }
    return "FILE"
}

private func image(for attachment: OpenCodeComposerAttachment) -> Image? {
    guard let data = dataPayload(from: attachment.dataURL) else { return nil }

#if canImport(AppKit)
    guard let platformImage = NSImage(data: data) else { return nil }
    return Image(nsImage: platformImage)
#elseif canImport(UIKit)
    guard let platformImage = UIImage(data: data) else { return nil }
    return Image(uiImage: platformImage)
#else
    return nil
#endif
}

private func dataPayload(from dataURL: String) -> Data? {
    guard let commaIndex = dataURL.firstIndex(of: ",") else { return nil }
    let payload = dataURL[dataURL.index(after: commaIndex)...]
    return Data(base64Encoded: String(payload))
}
