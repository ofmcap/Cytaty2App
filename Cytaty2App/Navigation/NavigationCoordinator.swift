import SwiftUI
import Combine

// Enum definiujący wszystkie możliwe ekrany w aplikacji
enum AppScreen: Hashable {
    case booksList
    case bookDetail(Book)
    case allQuotes(initialTagFilter: String? = nil)
    case quoteDetail(Quote, Book)
    case settings
}

class NavigationCoordinator: ObservableObject {
    // Ścieżki nawigacji dla każdej zakładki
    @Published var booksTabPath = NavigationPath()
    @Published var quotesTabPath = NavigationPath()
    @Published var settingsTabPath = NavigationPath()
    
    // Aktualnie wybrana zakładka
    @Published var selectedTab: AppScreen = .booksList
    
    // Aktualny tag do filtrowania (dla widoku cytatów)
    @Published var currentTagFilter: String? = nil
    
    // Metody nawigacyjne
    
    // Nawigacja do szczegółów książki
    func navigateToBookDetail(_ book: Book) {
        if selectedTab == .booksList {
            booksTabPath.append(AppScreen.bookDetail(book))
        } else {
            // Jeśli jesteśmy w innej zakładce, przełącz na zakładkę książek
            selectedTab = .booksList
            // Wyczyść ścieżkę i dodaj nową
            booksTabPath = NavigationPath()
            booksTabPath.append(AppScreen.bookDetail(book))
        }
    }
    
    // Nawigacja do szczegółów cytatu
    func navigateToQuoteDetail(quote: Quote, book: Book) {
        if selectedTab == .allQuotes() {
            quotesTabPath.append(AppScreen.quoteDetail(quote, book))
        } else if selectedTab == .booksList {
            // Jeśli jesteśmy w zakładce książek, dodaj do ścieżki książek
            booksTabPath.append(AppScreen.quoteDetail(quote, book))
        } else {
            // Jeśli jesteśmy w innej zakładce, przełącz na zakładkę cytatów
            selectedTab = .allQuotes()
            // Wyczyść ścieżkę i dodaj nową
            quotesTabPath = NavigationPath()
            quotesTabPath.append(AppScreen.quoteDetail(quote, book))
        }
    }
    
    // Nawigacja do widoku wszystkich cytatów z określonym tagiem
    func navigateToQuotesWithTag(_ tag: String) {
        currentTagFilter = tag
        selectedTab = .allQuotes(initialTagFilter: tag)
        // Resetuj ścieżkę cytatów
        quotesTabPath = NavigationPath()
    }
    
    // Resetowanie ścieżki dla aktualnej zakładki
    func resetCurrentTabPath() {
        switch selectedTab {
        case .booksList:
            booksTabPath = NavigationPath()
        case .allQuotes:
            quotesTabPath = NavigationPath()
        case .settings:
            settingsTabPath = NavigationPath()
        default:
            // Dla innych przypadków, resetuj do głównej zakładki
            selectedTab = .booksList
            booksTabPath = NavigationPath()
        }
    }
}
