import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var showingSearch = false
    
    var body: some View {
        RootView()
            .alert(item: Binding<AlertItem?>(
                get: { viewModel.errorMessage != nil ? AlertItem(message: viewModel.errorMessage!) : nil },
                set: { _ in viewModel.errorMessage = nil }
            )) { alertItem in
                Alert(title: Text("Błąd"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
            }
    }
}

struct AlertItem: Identifiable {
    var id = UUID()
    var message: String
}
