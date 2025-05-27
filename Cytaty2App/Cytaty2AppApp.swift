import SwiftUI

@main
struct Cytaty2AppApp: App {
    @StateObject private var viewModel = QuoteViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
