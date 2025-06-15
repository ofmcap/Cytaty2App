import Foundation

public struct Quote: Identifiable, Codable, Equatable {
    public var id: String = UUID().uuidString
    public var content: String
    public var page: Int?
    public var chapter: String?
    public var addedDate: Date = Date()
    public var tags: [String] = []
    public var note: String? = nil // Nowe pole dla notatki
    
    public init(id: String = UUID().uuidString, content: String, page: Int? = nil, chapter: String? = nil, addedDate: Date = Date(), tags: [String] = [], note: String? = nil) {
        self.id = id
        self.content = content
        self.page = page
        self.chapter = chapter
        self.addedDate = addedDate
        self.tags = tags
        self.note = note
    }
    
    public static func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct QuoteWithBook: Identifiable {
    public var id: String { quote.id }
    public let quote: Quote
    public let book: Book
    
    public init(quote: Quote, book: Book) {
        self.quote = quote
        self.book = book
    }
}
