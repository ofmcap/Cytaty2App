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
    
    // Funkcja do konwersji ścieżki na URL
    private func getFullCoverURL() -> URL? {
        guard let coverURL = currentBook.coverURL else {
            print("❌ No coverURL for book: \(currentBook.title)")
            return nil
        }
        
        if coverURL.hasPrefix("http") {
            let url = URL(string: coverURL)
            print("🌐 Using web URL for \(currentBook.title): \(coverURL)")
            return url
        } else {
            // Względna ścieżka w dokumentach
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(coverURL)
            print("📁 Using local file for \(currentBook.title): \(url.path)")
            return url
        }
    }
    
    var body: some View {
        HStack {
            if let coverURL = getFullCoverURL() {
                AsyncImage(url: coverURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 70)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onAppear {
                                print("✅ Successfully loaded image for: \(currentBook.title)")
                            }
                    case .failure(let error):
                        Image(systemName: "book")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .onAppear {
                                print("❌ Failed to load image for \(currentBook.title): \(error.localizedDescription)")
                                print("🔗 Failed URL: \(coverURL)")
                            }
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
