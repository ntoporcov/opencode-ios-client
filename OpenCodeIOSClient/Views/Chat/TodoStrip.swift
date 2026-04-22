import SwiftUI

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
