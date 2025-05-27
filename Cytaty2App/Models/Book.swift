import Foundation

struct Book: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var author: String
    var coverURL: String?
    var isbn: String?
    var publishYear: Int?
    var addedDate: Date = Date()
    var quotes: [Quote] = []
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
}
