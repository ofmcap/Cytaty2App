import SwiftUI

enum AppScreen: Hashable {
    case booksList
    case bookDetail(Book)
    case allQuotes(initialTagFilter: String? = nil)
    case quoteDetail(Quote, Book)
    case settings
}

struct RootView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) var appColors

    @State private var selectedTab: AppScreen = .booksList
    @State private var navigationPath = NavigationPath()
    @State private var tagToFilter: String? = nil

    var body: some View {
        NavigationStack(path: $navigationPath) {
            tabView(for: selectedTab)
                .navigationDestination(for: AppScreen.self) { screen in
                    switch screen {
                    case .booksList:
                        BookListView()
                            .navigationTitle("Moje książki")
                    case .bookDetail(let book):
                        BookDetailView(book: book)
                    case .allQuotes(let initialTagFilter):
                        AllQuotesView(initialTagFilter: initialTagFilter)
                            .navigationTitle("Wszystkie cytaty")
                    case .quoteDetail(let quote, let book):
                        QuoteDetailView(quote: quote, book: book)
                    case .settings:
                        SettingsView()
                            .navigationTitle("Ustawienia")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        tabPicker
                    }
                }
                .tint(appColors.accentColor)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToQuotesWithTag"))) { notification in
                    if let tag = notification.object as? String {
                        tagToFilter = tag
                        selectedTab = .allQuotes(initialTagFilter: tag)
                        navigationPath.removeLast(navigationPath.count) // reset path
                    }
                }
        }
    }

    @ViewBuilder
    private func tabView(for screen: AppScreen) -> some View {
        switch screen {
        case .booksList:
            BookListView()
                .navigationTitle("Moje książki")
                .onBookSelected { book in
                    navigationPath.append(AppScreen.bookDetail(book))
                }
        case .bookDetail(let book):
            BookDetailView(book: book)
        case .allQuotes(let initialTagFilter):
            AllQuotesView(initialTagFilter: initialTagFilter)
                .navigationTitle("Wszystkie cytaty")
                .onQuoteSelected { quote, book in
                    navigationPath.append(AppScreen.quoteDetail(quote, book))
                }
        case .quoteDetail(let quote, let book):
            QuoteDetailView(quote: quote, book: book)
        case .settings:
            SettingsView()
                .navigationTitle("Ustawienia")
        }
    }

    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            Label("Książki", systemImage: "book").tag(AppScreen.booksList)
            Label("Cytaty", systemImage: "quote.bubble").tag(AppScreen.allQuotes())
            Label("Ustawienia", systemImage: "gear").tag(AppScreen.settings)
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: selectedTab) { newValue in
            navigationPath.removeLast(navigationPath.count) // reset path on tab change
            if case .allQuotes = newValue {
                tagToFilter = nil
            }
        }
    }
}
