import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var showingSearch = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        RootView()
            .onReceive(viewModel.$errorMessage) { message in
                if let message = message {
                    alertMessage = message
                    showingAlert = true
                    // ❗ Reset errorMessage po stronie widoku,
                    // ale nie w czasie renderowania body
                    viewModel.errorMessage = nil
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Błąd"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}
