import SwiftUI

struct PermissionActionStack: View {
    let permissions: [OpenCodePermission]
    let onDismiss: (OpenCodePermission) -> Void
    let onRespond: (OpenCodePermission, String) -> Void

    private var permissionIDs: String {
        permissions.map { $0.id }.joined(separator: "|")
    }

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(permissions.enumerated()), id: \.element.id) { index, permission in
                PermissionCard(permission: permission, onDismiss: onDismiss, onRespond: onRespond)
                    .offset(y: CGFloat(index) * 12)
                    .scaleEffect(max(0.94, 1 - (CGFloat(index) * 0.015)), anchor: .top)
                    .zIndex(Double(permissions.count - index))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom, CGFloat(max(permissions.count - 1, 0)) * 12)
        .animation(opencodeSelectionAnimation, value: permissionIDs)
    }
}
