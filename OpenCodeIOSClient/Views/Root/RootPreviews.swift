import SwiftUI

#if DEBUG
#Preview("Disconnected") {
    RootView(viewModel: AppViewModel.preview(isConnected: false))
}

#Preview("Connected") {
    RootView(viewModel: AppViewModel.preview())
}
#endif
