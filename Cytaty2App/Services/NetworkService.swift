import Foundation

protocol NetworkService {
    func searchBooks(query: String, language: String) async throws -> [Book]  // Dodany language
}

class DefaultNetworkService: NetworkService {
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    
    func searchBooks(query: String, language: String) async throws -> [Book] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NSError(domain: "InvalidURL", code: 400, userInfo: nil)
        }
        
        // Udoskonalone query: dodaj maxResults, orderBy i inteligentny filtr autora w q=
        var modifiedQuery = encodedQuery
        if query.lowercased().contains("autor:") {  // Zachowany Twój logic
            // Przykład: Jeśli query = "harry potter autor: rowling", zmień na "harry+potter+inauthor:rowling"
            let parts = query.components(separatedBy: "autor:")
            if parts.count > 1 {
                let authorPart = parts[1].trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                modifiedQuery = (parts[0].trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") + "+inauthor:" + authorPart
            }
        }
        
        // Dla Podejścia 2: Wzmocnij filtrem intitle + inauthor dla search by title/author
        modifiedQuery = "intitle:\(modifiedQuery)+OR+inauthor:\(modifiedQuery)"
        
        let langParam = language == "any" ? "" : "&langRestrict=\(language)"
        let urlString = "\(baseURL)?q=\(modifiedQuery)\(langParam)&maxResults=20&orderBy=relevance"  // Zmienione na 20
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "InvalidURL", code: 400, userInfo: nil)
        }
        
        print("Debug: Fetching URL: \(urlString)")  // Debug: Jaki URL jest budowany
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "HTTPError", code: 500, userInfo: nil)
        }
        print("Debug: API response status: \(httpResponse.statusCode)")  // Debug: Czy 200, czy error (np. 403)
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
        }
        
        return try parseGoogleBooksResponse(data)
    }
    
    private func parseGoogleBooksResponse(_ data: Data) throws -> [Book] {
        print("Debug: Starting parsing response data (size: \(data.count) bytes)")  // Debug: Czy dochodzi do parsowania
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(GoogleBooksResponse.self, from: data)  // Zakładam GoogleBooksResponse to Twój model, dostosuj jeśli to GoogleBooksModels.SearchResponse
        
        let parsedBooks = response.items.compactMap { item -> Book? in
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
        
        print("Debug: Parsed \(parsedBooks.count) books")  // Debug: Ile książek sparsowano
        return parsedBooks
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
