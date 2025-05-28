import SwiftUI

struct RootView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var selectedTab: Int = 0
    @State private var previousTab: Int = 0
    @State private var tabSelectSubject = TabSelectSubject()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                BookListView()
                    .navigationTitle("Moje książki")
            }
            .tabItem {
                Label("Książki", systemImage: "book")
            }
            .tag(0)
            
            NavigationStack {
                AllQuotesView()
                    .navigationTitle("Wszystkie cytaty")
            }
            .tabItem {
                Label("Cytaty", systemImage: "quote.bubble")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
                    .navigationTitle("Ustawienia")
            }
            .tabItem {
                Label("Ustawienia", systemImage: "gear")
            }
            .tag(2)
        }
        #if compiler(>=5.9) && canImport(SwiftUI)
        .onChange(of: selectedTab) { oldValue, newValue in
            // Jeśli kliknięto tę samą zakładkę, zresetuj stos nawigacyjny
            if oldValue == newValue {
                handleTabTap(tab: newValue)
            }
            previousTab = newValue
        }
        #else
        .onChange(of: selectedTab) { newValue in
            // Jeśli kliknięto tę samą zakładkę, zresetuj stos nawigacyjny
            if previousTab == newValue {
                handleTabTap(tab: newValue)
            }
            previousTab = newValue
        }
        #endif
        .environment(\.selectedTabSubject, tabSelectSubject)
    }
    
    private func handleTabTap(tab: Int) {
        tabSelectSubject.send(tab)
    }
}

// Klasa do komunikacji między zakładkami
class TabSelectSubject: ObservableObject {
    @Published var selectedTab: Int?
    
    func send(_ tab: Int) {
        selectedTab = tab
    }
}

// Klucz środowiskowy dla przekazywania TabSelectSubject
struct SelectedTabSubjectKey: EnvironmentKey {
    static let defaultValue = TabSelectSubject()
}

extension EnvironmentValues {
    var selectedTabSubject: TabSelectSubject {
        get { self[SelectedTabSubjectKey.self] }
        set { self[SelectedTabSubjectKey.self] = newValue }
    }
}
