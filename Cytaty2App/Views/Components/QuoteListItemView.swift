import SwiftUI

struct QuoteListItemView: View {
    let quoteWithBook: QuoteWithBook
    @Environment(\.appColors) private var appColors

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quoteWithBook.quote.content)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(appColors.primaryTextColor)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quoteWithBook.book.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(appColors.primaryTextColor)

                    Text(quoteWithBook.book.author)
                        .font(.caption2)
                        .foregroundColor(appColors.secondaryTextColor)
                }

                Spacer()

                if let firstTag = quoteWithBook.quote.tags.first {
                    Text(firstTag)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(appColors.accentColor.opacity(0.1))
                        .foregroundColor(appColors.accentColor)
                        .cornerRadius(8)
                }

                if quoteWithBook.quote.tags.count > 1 {
                    Text("+\(quoteWithBook.quote.tags.count - 1)")
                        .font(.caption2)
                        .foregroundColor(appColors.secondaryTextColor)
                }
            }

            if let note = quoteWithBook.quote.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(appColors.secondaryTextColor)
                    .lineLimit(2)
                    .padding(.top, 2)
                    .italic()
            }
        }
        .padding(.vertical, 4)
    }
}
