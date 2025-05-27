import Foundation

struct Quote: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var content: String
    var page: Int?
    var chapter: String?
    var addedDate: Date = Date()
    var tags: [String] = []
    
    static func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.id == rhs.id
    }
}

struct QuoteWithBook: Identifiable {
    var id: String { quote.id }
    let quote: Quote
    let book: Book
}
