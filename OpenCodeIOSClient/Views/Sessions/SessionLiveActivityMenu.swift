import SwiftUI

struct SessionLiveActivityMenu: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Menu {
            Section {
                Text("Auto-start Live Activity for this project.")

                Button {
                    viewModel.setLiveActivityAutoStartEnabled(!viewModel.isLiveActivityAutoStartEnabled)
                } label: {
                    Label(
                        viewModel.isLiveActivityAutoStartEnabled ? "Disable Auto-Start" : "Enable Auto-Start",
                        systemImage: viewModel.isLiveActivityAutoStartEnabled ? "bolt.slash" : "bolt.badge.a"
                    )
                }
            }
        } label: {
            Image(systemName: toolbarSymbolName)
        }
        .accessibilityLabel("Live Activity Settings")
    }

    private var toolbarSymbolName: String {
        viewModel.isLiveActivityAutoStartEnabled ? "bolt.badge.a" : "waveform.badge.plus"
    }
}
