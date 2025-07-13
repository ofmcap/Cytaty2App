import Foundation

struct QuoteWithBook: Identifiable, Hashable {
    let id: String
    let quote: Quote
    let book: Book

    init(quote: Quote, book: Book) {
        self.quote = quote
        self.book = book
        self.id = quote.id
    }
}
