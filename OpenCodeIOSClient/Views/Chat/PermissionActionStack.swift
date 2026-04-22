import SwiftUI

struct PermissionActionStack: View {
    let permissions: [OpenCodePermission]
    let onDismiss: (OpenCodePermission) -> Void
    let onRespond: (OpenCodePermission, String) -> Void

    private var permissionIDs: String {
        permissions.map { $0.id }.joined(separator: "|")
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(permissions) { permission in
                PermissionCard(permission: permission, onDismiss: onDismiss, onRespond: onRespond)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(opencodeSelectionAnimation, value: permissionIDs)
    }
}
