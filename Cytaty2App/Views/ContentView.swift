import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        RootView()
            .onReceive(viewModel.$errorMessage) { message in
                if let message = message, !message.isEmpty {
                    alertMessage = message
                    showingAlert = true
                    // Reset errorMessage po pokazaniu alertu
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.errorMessage = nil
                    }
                }
            }
            .alert("Błąd", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
    }
}
