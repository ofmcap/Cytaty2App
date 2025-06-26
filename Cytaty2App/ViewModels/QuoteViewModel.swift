import Foundation
import Combine
import UIKit // Dodaj ten import dla UIImage

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
        // Pobierz i zapisz okładkę przed dodaniem książki
        if let coverURL = book.coverURL, coverURL.hasPrefix("http") {
            downloadAndSaveCover(for: book)
        } else {
            books.append(book)
            saveBooks()
        }
    }
    
    // METODA: Pobieranie i zapisywanie okładki
    private func downloadAndSaveCover(for book: Book) {
        guard let coverURL = book.coverURL, let url = URL(string: coverURL) else {
            books.append(book)
            saveBooks()
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let image = UIImage(data: data) {
                    // Zapisz okładkę lokalnie
                    let fileName = "\(book.id).jpg"
                    if let localPath = storageService.saveCoverImage(image, fileName: fileName) {
                        // Utwórz książkę z lokalną ścieżką
                        var updatedBook = book
                        updatedBook.coverURL = localPath
                        
                        await MainActor.run {
                            var updatedBook = book
                            updatedBook.coverURL = localPath
                            books.append(updatedBook)
                            saveBooks()
                            print("✅ Okładka zapisana lokalnie dla: \(book.title)")
                            print("📁 Lokalna ścieżka: \(localPath)")
                        }

                    } else {
                        // Nie udało się zapisać, dodaj książkę bez okładki
                        await MainActor.run {
                            var bookWithoutCover = book
                            bookWithoutCover.coverURL = nil
                            books.append(bookWithoutCover)
                            saveBooks()
                            print("❌ Nie udało się zapisać okładki dla: \(book.title)")
                        }
                    }
                } else {
                    await MainActor.run {
                        var bookWithoutCover = book
                        bookWithoutCover.coverURL = nil
                        books.append(bookWithoutCover)
                        saveBooks()
                        print("❌ Nie udało się przekonwertować danych na obraz dla: \(book.title)")
                    }
                }
            } catch {
                await MainActor.run {
                    var bookWithoutCover = book
                    bookWithoutCover.coverURL = nil
                    books.append(bookWithoutCover)
                    saveBooks()
                    print("❌ Błąd pobierania okładki dla: \(book.title) - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteBook(at indexSet: IndexSet) {
        // Usuń również lokalnie zapisane okładki
        for index in indexSet {
            let book = books[index]
            if let coverURL = book.coverURL, !coverURL.hasPrefix("http") {
                // To jest lokalna ścieżka, usuń plik
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsDirectory.appendingPathComponent(coverURL)
                
                try? FileManager.default.removeItem(at: fileURL)
                print("🗑️ Usunięto lokalną okładkę: \(coverURL)")
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
}
