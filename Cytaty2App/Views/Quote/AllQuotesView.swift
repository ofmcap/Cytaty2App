import SwiftUI

struct AllQuotesView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors
    @Environment(\.quoteSelectionAction) private var onQuoteSelected

    let initialTagFilter: String?

    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var showingTagFilter = false
    @State private var refreshToggle = false

    // Wszystkie cytaty z książkami
    private var allQuotesWithBooks: [QuoteWithBook] {
        var quotesWithBooks: [QuoteWithBook] = []
        for book in viewModel.books {
            for quote in book.quotes {
                quotesWithBooks.append(QuoteWithBook(quote: quote, book: book))
            }
        }
        return quotesWithBooks
    }

    // Filtrowane cytaty
    private var filteredQuotes: [QuoteWithBook] {
        var quotes = allQuotesWithBooks

        // Filtruj po tagu
        if let tag = selectedTag ?? initialTagFilter {
            quotes = quotes.filter { quoteWithBook in
                quoteWithBook.quote.tags.contains { $0.lowercased().contains(tag.lowercased()) }
            }
        }

        // Filtruj po tekście wyszukiwania
        if !searchText.isEmpty {
            quotes = quotes.filter { quoteWithBook in
                quoteWithBook.quote.content.localizedCaseInsensitiveContains(searchText) ||
                quoteWithBook.quote.tags.joined(separator: " ").localizedCaseInsensitiveContains(searchText) ||
                quoteWithBook.book.title.localizedCaseInsensitiveContains(searchText) ||
                quoteWithBook.book.author.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sortuj po dacie dodania (najnowsze na górze)
        return quotes.sorted { $0.quote.addedDate > $1.quote.addedDate }
    }

    // Wszystkie dostępne tagi
    private var allTags: [String] {
        let tags = allQuotesWithBooks.flatMap { $0.quote.tags }
        return Array(Set(tags)).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText, placeholder: "Szukaj cytatów...")
                .padding(.horizontal)
                .padding(.top, 8)

            // Tag Filter Button
            if !allTags.isEmpty {
                HStack {
                    Button(action: {
                        showingTagFilter = true
                    }) {
                        HStack {
                            Image(systemName: "tag")
                            Text(selectedTag ?? initialTagFilter ?? "Wszystkie tagi")
                            Image(systemName: "chevron.down")
                        }
                        .foregroundColor(appColors.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(appColors.accentColor.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if selectedTag != nil || initialTagFilter != nil {
                        Button(action: {
                            selectedTag = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(appColors.secondaryTextColor)
                        }
                    }

                    Spacer()

                    Text("\(filteredQuotes.count) cytatów")
                        .font(.caption)
                        .foregroundColor(appColors.secondaryTextColor)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            // Quotes List
            if filteredQuotes.isEmpty {
                emptyQuotesView
            } else {
                List {
                    ForEach(filteredQuotes, id: \.quote.id) { quoteWithBook in
                        Button(action: {
                            onQuoteSelected(quoteWithBook.quote, quoteWithBook.book)
                        }) {
                            QuoteListItemView(quoteWithBook: quoteWithBook)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: {
                                // Nawiguj do książki
                            }) {
                                Label("Zobacz książkę", systemImage: "book")
                            }

                            Button(action: {
                                shareQuote(quoteWithBook.quote, from: quoteWithBook.book)
                            }) {
                                Label("Udostępnij", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(appColors.backgroundColor)
                .scrollContentBackground(.hidden)
                .id(refreshToggle)
            }
        }
        .background(appColors.backgroundColor)
        .onAppear {
            if let initialTag = initialTagFilter {
                selectedTag = initialTag
            }
        }
        .sheet(isPresented: $showingTagFilter) {
            TagFilterView(
                selectedTag: $selectedTag,
                allTags: allTags
            )
        }
    }

    private var emptyQuotesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.bubble")
                .font(.system(size: 60))
                .foregroundColor(appColors.secondaryTextColor)

            if selectedTag != nil || initialTagFilter != nil {
                Text("Brak cytatów z tym tagiem")
                    .font(.title2)
                    .foregroundColor(appColors.primaryTextColor)

                Text("Spróbuj wybrać inny tag lub usuń filtr")
                    .font(.subheadline)
                    .foregroundColor(appColors.secondaryTextColor)
                    .multilineTextAlignment(.center)
            } else if !searchText.isEmpty {
                Text("Brak wyników wyszukiwania")
                    .font(.title2)
                    .foregroundColor(appColors.primaryTextColor)

                Text("Spróbuj innych słów kluczowych")
                    .font(.subheadline)
                    .foregroundColor(appColors.secondaryTextColor)
            } else {
                Text("Brak cytatów")
                    .font(.title2)
                    .foregroundColor(appColors.primaryTextColor)

                Text("Dodaj cytaty do swoich książek, aby zobaczyć je tutaj")
                    .font(.subheadline)
                    .foregroundColor(appColors.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundColor)
    }

    private func shareQuote(_ quote: Quote, from book: Book) {
        let text = "\"\(quote.content)\"\n\n— \(book.author), \"\(book.title)\""

        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

// MARK: - Quote Selection Extensions
struct QuoteSelectionModifier: ViewModifier {
    let onSelect: (Quote, Book) -> Void

    func body(content: Content) -> some View {
        content.environment(\.quoteSelectionAction, onSelect)
    }
}

extension View {
    func onQuoteSelected(_ action: @escaping (Quote, Book) -> Void) -> some View {
        modifier(QuoteSelectionModifier(onSelect: action))
    }
}

// Environment Key
private struct QuoteSelectionActionKey: EnvironmentKey {
    static let defaultValue: (Quote, Book) -> Void = { _, _ in }
}

extension EnvironmentValues {
    var quoteSelectionAction: (Quote, Book) -> Void {
        get { self[QuoteSelectionActionKey.self] }
        set { self[QuoteSelectionActionKey.self] = newValue }
    }
}
