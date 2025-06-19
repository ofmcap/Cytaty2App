import Foundation

protocol NetworkService {
    func searchBooks(query: String) async throws -> [Book]
}

class DefaultNetworkService: NetworkService {
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    
    func searchBooks(query: String) async throws -> [Book] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?q=\(encodedQuery)") else {
            throw NSError(domain: "InvalidURL", code: 400, userInfo: nil)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
        }
        
        return try parseGoogleBooksResponse(data)
    }
    
    private func parseGoogleBooksResponse(_ data: Data) throws -> [Book] {
        let decoder = JSONDecoder()
        let response = try decoder.decode(GoogleBooksResponse.self, from: data)
        
        return response.items.compactMap { item -> Book? in
            guard let volumeInfo = item.volumeInfo else { return nil }
            
            // Konwertujemy HTTP na HTTPS i dodajemy debugging
            var coverURL: String? = nil
            if let thumbnail = volumeInfo.imageLinks?.thumbnail {
                // Konwertuj HTTP na HTTPS
                coverURL = thumbnail.replacingOccurrences(of: "http://", with: "https://")
                
                // Dodajemy większy rozmiar obrazu
                if coverURL!.contains("zoom=1") {
                    coverURL = coverURL!.replacingOccurrences(of: "zoom=1", with: "zoom=2")
                }
                
                print("📚 Book: \(volumeInfo.title)")
                print("🖼️ Original thumbnail: \(thumbnail)")
                print("🔒 Converted HTTPS URL: \(coverURL!)")
                print("---")
            }
            
            return Book(
                id: item.id,
                title: volumeInfo.title,
                author: volumeInfo.authors?.joined(separator: ", ") ?? "Nieznany autor",
                coverURL: coverURL,
                isbn: volumeInfo.industryIdentifiers?.first(where: { $0.type.contains("ISBN") })?.identifier,
                publishYear: extractYear(from: volumeInfo.publishedDate)
            )
        }
    }
    
    private func extractYear(from dateString: String?) -> Int? {
        guard let dateString = dateString else { return nil }
        let yearPattern = "\\d{4}"
        
        guard let regex = try? NSRegularExpression(pattern: yearPattern),
              let match = regex.firstMatch(in: dateString, range: NSRange(dateString.startIndex..., in: dateString)) else {
            return nil
        }
        
        if let range = Range(match.range, in: dateString) {
            return Int(dateString[range])
        }
        return nil
    }
}
