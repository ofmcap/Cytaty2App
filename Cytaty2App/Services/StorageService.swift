import Foundation
import Combine
import UIKit // Dodaj import UIKit dla klasy UIImage

protocol StorageService {
    func saveBooks(_ books: [Book]) async throws
    func loadBooks() async throws -> [Book]
    func getFullURLForCover(relativePath: String) -> URL?
    func saveCoverImage(_ image: UIImage, fileName: String?) -> String?
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
        
        do {
            let data = try Data(contentsOf: booksFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Zabezpieczenie przed uszkodzonym plikiem
            return try decoder.decode([Book].self, from: data)
        } catch {
            // Logowanie błędu
            print("Błąd wczytywania książek: \(error)")
            
            // Próba utworzenia kopii zapasowej
            if let backupURL = try? createBackup() {
                print("Utworzono kopię zapasową w: \(backupURL.path)")
            }
            
            // Zamiast rzucania wyjątku, zwróć pustą tablicę
            return []
        }
    }
    
    // Metoda do tworzenia kopii zapasowej
    private func createBackup() throws -> URL {
        let backupURL = documentsDirectory.appendingPathComponent("books_backup_\(Date().timeIntervalSince1970).json")
        if fileManager.fileExists(atPath: booksFileURL.path) {
            try fileManager.copyItem(at: booksFileURL, to: backupURL)
        }
        return backupURL
    }
    
    // Metoda do konwersji względnej ścieżki na pełny URL
    func getFullURLForCover(relativePath: String) -> URL? {
        if relativePath.hasPrefix("http") {
            return URL(string: relativePath)
        } else {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(relativePath)
        }
    }
    
    // Metoda do zapisywania obrazu okładki
    func saveCoverImage(_ image: UIImage, fileName: String? = nil) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let actualFileName = fileName ?? "\(UUID().uuidString).jpg"
        let relativePath = "BookCovers/\(actualFileName)"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let coverDirectory = documentsDirectory.appendingPathComponent("BookCovers")
        
        do {
            // Tworzenie katalogu BookCovers, jeśli nie istnieje
            if !FileManager.default.fileExists(atPath: coverDirectory.path) {
                try FileManager.default.createDirectory(at: coverDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            let fileURL = documentsDirectory.appendingPathComponent(relativePath)
            try data.write(to: fileURL)
            
            return relativePath
        } catch {
            print("Błąd zapisywania okładki: \(error)")
            return nil
        }
    }
}

