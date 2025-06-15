import SwiftUI

struct QuoteListItemView: View {
    let quoteWithBook: QuoteWithBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quoteWithBook.quote.content)
                .font(.body)
                .lineLimit(3)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quoteWithBook.book.title)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(quoteWithBook.book.author)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !quoteWithBook.quote.tags.isEmpty {
                    Text(quoteWithBook.quote.tags.first!)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                if quoteWithBook.quote.tags.count > 1 {
                    Text("+\(quoteWithBook.quote.tags.count - 1)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Wyświetlanie fragmentu notatki
            if let note = quoteWithBook.quote.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
                    .italic()
            }
        }
        .padding(.vertical, 4)
    }
}
