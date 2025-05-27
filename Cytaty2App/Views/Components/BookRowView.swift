import SwiftUI

struct BookRowView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    let book: Book
    
    // Funkcja pomocnicza do znajdowania aktualnej książki z ViewModel
    private var currentBook: Book {
        return viewModel.books.first { $0.id == book.id } ?? book
    }
    
    // Funkcja do poprawnej odmiany słowa "cytat" w języku polskim
    private func quotesText(_ count: Int) -> String {
        if count == 1 {
            return "1 cytat"
        } else if count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20) {
            return "\(count) cytaty"
        } else {
            return "\(count) cytatów"
        }
    }
    
    var body: some View {
        HStack {
            if let coverURL = currentBook.coverURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "book")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 50, height: 70)
                .cornerRadius(5)
            } else {
                Image(systemName: "book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 70)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(currentBook.title)
                    .font(.headline)
                Text(currentBook.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(quotesText(currentBook.quotes.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
