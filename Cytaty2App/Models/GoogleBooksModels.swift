import Foundation

// Struktury do parsowania odpowiedzi z Google Books API
struct GoogleBooksResponse: Decodable {
    let items: [GoogleBookItem]
}

struct GoogleBookItem: Decodable {
    let id: String
    let volumeInfo: GoogleBookVolumeInfo?
}

struct GoogleBookVolumeInfo: Decodable {
    let title: String
    let authors: [String]?
    let publishedDate: String?
    let industryIdentifiers: [GoogleBookIndustryIdentifier]?
    let imageLinks: GoogleBookImageLinks?
}

struct GoogleBookIndustryIdentifier: Decodable {
    let type: String
    let identifier: String
}

struct GoogleBookImageLinks: Decodable {
    let thumbnail: String?
}
