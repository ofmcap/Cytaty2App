import SwiftUI


struct BookDetailView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    let book: Book
    @State private var showingAddQuote = false
    
    // Funkcja pomocnicza do znajdowania aktualnej książki z ViewModel
    private var currentBook: Book {
        return viewModel.books.first { $0.id == book.id } ?? book
    }
    
    var body: some View {
        VStack {
            BookHeaderView(book: currentBook)
                .padding()
            
            if currentBook.quotes.isEmpty {
                EmptyQuoteView()
            } else {
                QuoteListView(book: currentBook)
            }
        }
        .navigationTitle(currentBook.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingAddQuote = true
                }) {
                    Image(systemName: "quote.bubble.fill")
                }
            }
        }
        .sheet(isPresented: $showingAddQuote) {
            AddQuoteView(book: currentBook)
        }
    }
}


struct BookHeaderView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 20) {
            if let coverURL = book.coverURL, let url = URL(string: coverURL) {
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
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 140)
                .cornerRadius(5)
            } else {
                Image(systemName: "book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 140)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(book.author)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let publishYear = book.publishYear {
                    Text("Rok wydania: \(publishYear)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let isbn = book.isbn {
                    Text("ISBN: \(isbn)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}


struct EmptyQuoteView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.quote")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Brak cytatów")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Dodaj pierwszy cytat z tej książki")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct QuoteListView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    let book: Book
    @State private var editingQuote: Quote?
    
    // Funkcja pomocnicza do znajdowania aktualnej książki z ViewModel
    private var currentBook: Book {
        return viewModel.books.first { $0.id == book.id } ?? book
    }
    
    var body: some View {
        List {
            ForEach(currentBook.quotes.sorted(by: { $0.addedDate > $1.addedDate })) { quote in
                QuoteRowView(quote: quote)
                    .contextMenu {
                        Button(action: {
                            editingQuote = quote
                        }) {
                            Label("Edytuj", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            viewModel.deleteQuote(quote, from: currentBook)
                        }) {
                            Label("Usuń", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .sheet(item: $editingQuote) { quote in
            EditQuoteView(book: currentBook, quote: quote)
        }
    }
}

