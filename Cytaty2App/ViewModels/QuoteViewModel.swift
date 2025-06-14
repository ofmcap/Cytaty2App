import Foundation
import Combine

class QuoteViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var searchResults: [Book] = []
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    
    private let storageService: StorageService
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(storageService: StorageService = DefaultStorageService(),
         networkService: NetworkService = DefaultNetworkService()) {
        self.storageService = storageService
        self.networkService = networkService
        
        loadBooks()
    }
    
    func loadBooks() {
        Task {
            do {
                let loadedBooks = try await storageService.loadBooks()
                await MainActor.run {
                    books = loadedBooks
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Nie udało się wczytać książek: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func saveBooks() {
        Task {
            do {
                try await storageService.saveBooks(books)
            } catch {
                await MainActor.run {
                    errorMessage = "Nie udało się zapisać książek: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func searchBooks() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        Task {
            do {
                let results = try await networkService.searchBooks(query: searchQuery)
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Błąd wyszukiwania: \(error.localizedDescription)"
                    isSearching = false
                }
            }
        }
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func deleteBook(at indexSet: IndexSet) {
        books.remove(atOffsets: indexSet)
        saveBooks()
    }
    
    func addQuote(_ quote: Quote, to book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].quotes.append(quote)
            saveBooks()
        }
    }
    
    func deleteQuote(_ quote: Quote, from book: Book) {
        if let bookIndex = books.firstIndex(where: { $0.id == book.id }),
           let quoteIndex = books[bookIndex].quotes.firstIndex(where: { $0.id == quote.id }) {
            books[bookIndex].quotes.remove(at: quoteIndex)
            saveBooks()
        }
    }
    
    func updateQuote(_ quote: Quote, in book: Book) {
        if let bookIndex = books.firstIndex(where: { $0.id == book.id }),
           let quoteIndex = books[bookIndex].quotes.firstIndex(where: { $0.id == quote.id }) {
            books[bookIndex].quotes[quoteIndex] = quote
            saveBooks()
        }
    }
    
    // Dodajemy nową metodę do QuoteViewModel
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }

}
