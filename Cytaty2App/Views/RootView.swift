import SwiftUI

struct RootView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) var appColors
    @StateObject private var coordinator = NavigationCoordinator()
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            // Zakładka Książki
            NavigationStack(path: $coordinator.booksTabPath) {
                BookListView()
                    .navigationTitle("Moje książki")
                    .onBookSelected { book in
                        coordinator.navigateToBookDetail(book)
                    }
                    .navigationDestination(for: AppScreen.self) { screen in
                        destinationView(for: screen)
                    }
            }
            .tabItem {
                Label("Książki", systemImage: "book")
            }
            .tag(AppScreen.booksList)
            
            // Zakładka Cytaty
            NavigationStack(path: $coordinator.quotesTabPath) {
                AllQuotesView(initialTagFilter: coordinator.currentTagFilter)
                    .navigationTitle("Wszystkie cytaty")
                    .onQuoteSelected { quote, book in
                        coordinator.navigateToQuoteDetail(quote: quote, book: book)
                    }
                    .navigationDestination(for: AppScreen.self) { screen in
                        destinationView(for: screen)
                    }
            }
            .tabItem {
                Label("Cytaty", systemImage: "quote.bubble")
            }
            .tag(AppScreen.allQuotes())
            
            // Zakładka Ustawienia
            NavigationStack(path: $coordinator.settingsTabPath) {
                SettingsView()
                    .navigationTitle("Ustawienia")
                    .navigationDestination(for: AppScreen.self) { screen in
                        destinationView(for: screen)
                    }
            }
            .tabItem {
                Label("Ustawienia", systemImage: "gear")
            }
            .tag(AppScreen.settings)
        }
        .tint(appColors.accentColor)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToQuotesWithTag"))) { notification in
            if let tag = notification.object as? String {
                coordinator.navigateToQuotesWithTag(tag)
            }
        }
        .onReceive(viewModel.$newlyAddedBook) { newBook in
            if let book = newBook {
                // Nawiguj do szczegółów nowo dodanej książki
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    coordinator.navigateToBookDetail(book)
                    viewModel.clearNewlyAddedBook()
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for screen: AppScreen) -> some View {
        switch screen {
        case .booksList:
            BookListView()
                .navigationTitle("Moje książki")
                .onBookSelected { book in
                    coordinator.navigateToBookDetail(book)
                }
        case .bookDetail(let book):
            BookDetailView(book: book)
                .onQuoteSelected { quote, book in
                    coordinator.navigateToQuoteDetail(quote: quote, book: book)
                }
        case .allQuotes(let initialTagFilter):
            AllQuotesView(initialTagFilter: initialTagFilter)
                .navigationTitle("Wszystkie cytaty")
                .onQuoteSelected { quote, book in
                    coordinator.navigateToQuoteDetail(quote: quote, book: book)
                }
        case .quoteDetail(let quote, let book):
            QuoteDetailView(quote: quote, book: book)
        case .settings:
            SettingsView()
                .navigationTitle("Ustawienia")
        }
    }
}
