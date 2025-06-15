import Foundation

public struct Book: Identifiable, Codable, Equatable {
    public var id: String = UUID().uuidString
    public var title: String
    public var author: String
    public var coverURL: String?
    public var isbn: String?
    public var publishYear: Int?
    public var addedDate: Date = Date()
    public var quotes: [Quote] = []
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        author: String,
        coverURL: String? = nil,
        isbn: String? = nil,
        publishYear: Int? = nil,
        addedDate: Date = Date(),
        quotes: [Quote] = []
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.coverURL = coverURL
        self.isbn = isbn
        self.publishYear = publishYear
        self.addedDate = addedDate
        self.quotes = quotes
    }

    public static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
}
