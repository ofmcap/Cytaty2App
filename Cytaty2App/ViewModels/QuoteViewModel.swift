import Foundation
import Combine
import UIKit

class QuoteViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var searchResults: [Book] = []
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    @Published var newlyAddedBook: Book? = nil
    

    private let storageService = StorageService.shared
    private let networkService = DefaultNetworkService()
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init() {
        loadBooks()
    }

    func loadBooks() {
        let loadedBooks = storageService.loadBooks()
        self.books = loadedBooks
    }

    func saveBooks() {
        storageService.saveBooks(books)
    }

    func searchBooks() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        searchTask?.cancel()
        isSearching = true

        searchTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await Task.sleep(nanoseconds: 300_000_000) // 0.3s debounce
                let results = try await self.networkService.searchBooks(query: self.searchQuery, language: "pl")
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Błąd wyszukiwania: \(error.localizedDescription)"
                    self.isSearching = false
                }
            }
        }
    }

    func addBook(_ book: Book) {
        // Dodaj książkę do listy
        books.append(book)
        newlyAddedBook = book
        saveBooks()

        // Pobierz okładkę w tle (jeśli potrzeba)
        if let coverURL = book.coverURL, coverURL.hasPrefix("http") {
            downloadAndSaveCover(for: book)
        }
    }

    private func downloadAndSaveCover(for book: Book) {
        guard let coverURL = book.coverURL, let url = URL(string: coverURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            if let localURL = self.storageService.saveImageData(data, forBookId: book.id) {
                DispatchQueue.main.async {
                    if let index = self.books.firstIndex(where: { $0.id == book.id }) {
                        self.books[index].coverURL = localURL.path
                        self.saveBooks()
                    }
                }
            }
        }.resume()
    }

    func deleteBook(at indexSet: IndexSet) {
        for index in indexSet {
            let book = books[index]
            if let coverURL = book.coverURL, !coverURL.hasPrefix("http") {
                let fileURL = URL(fileURLWithPath: coverURL)
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
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

    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }

    func clearNewlyAddedBook() {
        newlyAddedBook = nil
    }
}
    
