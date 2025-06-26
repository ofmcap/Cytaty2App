import SwiftUI

@main
struct Cytaty2AppApp: App {
    @StateObject private var viewModel = QuoteViewModel()
    @StateObject private var colorSchemeService = ColorSchemeService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(colorSchemeService)
                .preferredColorScheme(colorSchemeService.currentScheme.isDark ? .dark : .light)
        }
    }
}
