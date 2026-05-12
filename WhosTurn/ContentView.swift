import SwiftUI
import WTPicker
import WTTeamSetup

struct ContentView: View {
    @State private var showTeamSetup = false
    @State private var pickerViewModel = PickerViewModel()

    var body: some View {
        PickerView(viewModel: pickerViewModel) {
            showTeamSetup = true
        }
        .sheet(isPresented: $showTeamSetup, onDismiss: {
            Task { await pickerViewModel.loadData() }
        }) {
            TeamSetupView()
        }
    }
}

#Preview {
    ContentView()
}
