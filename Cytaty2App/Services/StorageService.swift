import Foundation
import Combine

protocol StorageService {
    func saveBooks(_ books: [Book]) async throws
    func loadBooks() async throws -> [Book]
}

class DefaultStorageService: StorageService {
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var booksFileURL: URL {
        documentsDirectory.appendingPathComponent("books.json")
    }
    
    func saveBooks(_ books: [Book]) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(books)
        try data.write(to: booksFileURL)
    }
    
    func loadBooks() async throws -> [Book] {
        guard fileManager.fileExists(atPath: booksFileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: booksFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Book].self, from: data)
    }
}
