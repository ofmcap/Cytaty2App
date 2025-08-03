import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let booksFileName = "books.json"
    private let quotesFileName = "quotes.json"
    
    private init() {}
    
    // MARK: - Books Storage
    
    func saveBooks(_ books: [Book]) {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(booksFileName) else { return }
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: url)
        } catch {
            print("Error saving books: \(error)")
        }
    }
    
    func loadBooks() -> [Book] {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(booksFileName) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Book].self, from: data)
        } catch {
            print("Error loading books: \(error)")
            return []
        }
    }
    
    // MARK: - Quotes Storage
    
    func saveQuotes(_ quotes: [Quote]) {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(quotesFileName) else { return }
        do {
            let data = try JSONEncoder().encode(quotes)
            try data.write(to: url)
        } catch {
            print("Error saving quotes: \(error)")
        }
    }
    
    func loadQuotes() -> [Quote] {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(quotesFileName) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Quote].self, from: data)
        } catch {
            print("Error loading quotes: \(error)")
            return []
        }
    }
    
    // MARK: - Helper
    
    private func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // Nowa metoda: Zapisuje dane obrazu w podfolderze "covers" i zwraca lokalny URL
    func saveImageData(_ data: Data, forBookId bookId: String) -> URL? {
        guard let documentsDirectory = getDocumentsDirectory() else { return nil }
        
        // Twórz podfolder "covers" jeśli nie istnieje
        let coversDirectory = documentsDirectory.appendingPathComponent("covers")
        do {
            try FileManager.default.createDirectory(at: coversDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Błąd tworzenia folderu covers: \(error)")
            return nil
        }
        
        // Unikalna nazwa pliku: bookId + .jpg (bookId jako String)
        let fileName = "\(bookId).jpg"
        let fileURL = coversDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Błąd zapisu obrazu: \(error)")
            return nil
        }
    }
}
