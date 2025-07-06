import SwiftUI

struct BookDetailView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors

    let book: Book
    @State private var showingAddQuote = false
    @State private var showingEditBook = false
    @State private var refreshToggle = false

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
        .background(appColors.backgroundColor)
        .navigationTitle(currentBook.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        showingAddQuote = true
                    }) {
                        Label("Dodaj cytat", systemImage: "quote.bubble.fill")
                    }
                    Button(action: {
                        showingEditBook = true
                    }) {
                        Label("Edytuj książkę", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(appColors.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingAddQuote) {
            AddQuoteView(book: currentBook)
        }
        .sheet(isPresented: $showingEditBook) {
            AddEditBookView(
                isEditing: true,
                book: currentBook,
                onSave: { updatedBook in
                    viewModel.updateBook(updatedBook)
                    refreshToggle.toggle()
                }
            )
        }
        .id(refreshToggle)
    }
}

struct BookHeaderView: View {
    @Environment(\.appColors) private var appColors
    let book: Book

    // Funkcja do konwersji ścieżki na URL
    private func getFullCoverURL() -> URL? {
        guard let coverURL = book.coverURL else { return nil }
        if coverURL.hasPrefix("http") {
            return URL(string: coverURL)
        } else {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fullURL = documentsDirectory.appendingPathComponent(coverURL)
            if FileManager.default.fileExists(atPath: fullURL.path) {
                return fullURL
            } else {
                return nil
            }
        }
    }

    var body: some View {
        HStack(spacing: 20) {
            if let coverURL = getFullCoverURL() {
                AsyncImage(url: coverURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(appColors.accentColor)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "book")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(appColors.secondaryTextColor)
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
                    .foregroundColor(appColors.secondaryTextColor)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(appColors.primaryTextColor)

                Text(book.author)
                    .font(.headline)
                    .foregroundColor(appColors.secondaryTextColor)

                if let publishYear = book.publishYear {
                    Text("Rok wydania: \(String(publishYear))")
                        .font(.subheadline)
                        .foregroundColor(appColors.secondaryTextColor)
                }

                if let isbn = book.isbn {
                    Text("ISBN: \(isbn)")
                        .font(.caption)
                        .foregroundColor(appColors.secondaryTextColor)
                }
            }
        }
    }
}

struct EmptyQuoteView: View {
    @Environment(\.appColors) private var appColors

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.quote")
                .font(.system(size: 60))
                .foregroundColor(appColors.secondaryTextColor)

            Text("Brak cytatów")
                .font(.title2)
                .foregroundColor(appColors.primaryTextColor)

            Text("Dodaj pierwszy cytat z tej książki")
                .font(.subheadline)
                .foregroundColor(appColors.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundColor)
    }
}

struct QuoteListView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors

    let book: Book
    @State private var editingQuote: Quote?
    @State private var refreshToggle = false

    // Funkcja pomocnicza do znajdowania aktualnej książki z ViewModel
    private var currentBook: Book {
        return viewModel.books.first { $0.id == book.id } ?? book
    }

    var body: some View {
        List {
            ForEach(currentBook.quotes.sorted(by: { $0.addedDate > $1.addedDate })) { quote in
                NavigationLink(destination:
                    QuoteDetailView(quote: quote, book: currentBook)
                        .onDisappear {
                            refreshToggle.toggle()
                        }
                ) {
                    QuoteRowView(quote: quote)
                }
                .contextMenu {
                    Button(action: {
                        editingQuote = quote
                    }) {
                        Label("Edytuj", systemImage: "pencil")
                    }

                    Button(role: .destructive, action: {
                        viewModel.deleteQuote(quote, from: currentBook)
                        refreshToggle.toggle()
                    }) {
                        Label("Usuń", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .sheet(item: $editingQuote) { quote in
            EditQuoteView(
                book: currentBook,
                quote: quote,
                onUpdate: {
                    refreshToggle.toggle()
                }
            )
        }
        .id(refreshToggle)
        .background(appColors.backgroundColor)
        .scrollContentBackground(.hidden)
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor.clear
        }
        .onDisappear {
            UITableView.appearance().backgroundColor = nil
        }
        .listRowBackground(appColors.backgroundColor)
    }
}
