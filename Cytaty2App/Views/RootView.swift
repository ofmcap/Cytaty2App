import SwiftUI

struct RootView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var selectedTab: Int = 0
    @State private var booksNavigationId = UUID()
    @State private var quotesNavigationId = UUID()
    @State private var settingsNavigationId = UUID()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                BookListView()
            }
            .id(booksNavigationId) // Unikalny ID dla resetu stosu nawigacji
            .tabItem {
                Label("Książki", systemImage: "book")
            }
            .tag(0)
            
            NavigationView {
                AllQuotesView()
            }
            .id(quotesNavigationId) // Unikalny ID dla resetu stosu nawigacji
            .tabItem {
                Label("Cytaty", systemImage: "quote.bubble")
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .id(settingsNavigationId)
            .tabItem {
                Label("Ustawienia", systemImage: "gear")
            }
            .tag(2)
        }
        #if compiler(>=5.9) && canImport(SwiftUI)
        .onChange(of: selectedTab) { oldTab, newTab in
            if oldTab == newTab {
                // Jeśli kliknięto tę samą zakładkę, zresetuj stos nawigacji
                resetNavigationStack(for: newTab)
            }
        }
        #else
        .onChange(of: selectedTab) { newTab in
            resetNavigationStack(for: newTab)
        }
        #endif
    }
    
    private func resetNavigationStack(for tab: Int) {
        if tab == 0 {
            booksNavigationId = UUID()
        } else if tab == 1 {
            quotesNavigationId = UUID()
        } else if tab == 2 {
            settingsNavigationId = UUID()
        }
    }
}
