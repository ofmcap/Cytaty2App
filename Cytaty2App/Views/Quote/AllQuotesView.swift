import SwiftUI

struct AllQuotesView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var showingAddQuoteSheet = false
    @State private var selectedBook: Book?
    @State private var refreshToggle = false
    @State private var showingTagFilter = false
    @State private var selectedQuote: QuoteWithBook? = nil
    @Environment(\.selectedTabSubject) var tabSubject
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appColors) var appColors

    let initialTagFilter: String?

    init(initialTagFilter: String? = nil) {
        self.initialTagFilter = initialTagFilter
    }

    var allQuotes: [QuoteWithBook] {
        var quotes: [QuoteWithBook] = []
        for book in viewModel.books {
            for quote in book.quotes {
                quotes.append(QuoteWithBook(quote: quote, book: book))
            }
        }
        return quotes.sorted(by: { $0.quote.addedDate > $1.quote.addedDate })
    }

    var filteredQuotes: [QuoteWithBook] {
        allQuotes.filter { quoteWithBook in
            let matchesSearch = searchText.isEmpty ||
                quoteWithBook.quote.content.localizedCaseInsensitiveContains(searchText) ||
                quoteWithBook.book.title.localizedCaseInsensitiveContains(searchText) ||
                quoteWithBook.book.author.localizedCaseInsensitiveContains(searchText)

            let matchesTag = selectedTag == nil || quoteWithBook.quote.tags.contains(selectedTag!)

            return matchesSearch && matchesTag
        }
    }

    var allTags: [String] {
        var tags = Set<String>()
        for book in viewModel.books {
            for quote in book.quotes {
                tags.formUnion(quote.tags)
            }
        }
        return Array(tags).sorted()
    }

    private func countQuotesForTag(_ tag: String) -> Int {
        return allQuotes.filter { $0.quote.tags.contains(tag) }.count
    }

    var body: some View {
        VStack {
            if allQuotes.isEmpty {
                emptyQuotesView
            } else {
                VStack {
                    SearchBar(text: $searchText, placeholder: "Szukaj cytatów")
                        .padding(.horizontal)

                    // Pasek z filtrem tagów
                    HStack {
                        if let selectedTag = selectedTag {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(appColors.accentColor)
                                    .font(.caption)

                                Text(selectedTag)
                                    .font(.subheadline)
                                    .foregroundColor(appColors.accentColor)
                                    .fontWeight(.medium)

                                Text("(\(countQuotesForTag(selectedTag)))")
                                    .font(.caption)
                                    .foregroundColor(appColors.secondaryTextColor)

                                Button(action: {
                                    self.selectedTag = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(appColors.secondaryTextColor)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(appColors.accentColor.opacity(0.1))
                            .cornerRadius(16)
                        } else {
                            Text("Wszystkie cytaty")
                                .font(.headline)
                                .foregroundColor(appColors.primaryTextColor)
                        }

                        Spacer()

                        Button(action: {
                            showingTagFilter = true
                        }) {
                            HStack {
                                Text("Filtry")
                                    .font(.subheadline)
                                    .foregroundColor(appColors.primaryTextColor)
                                Image(systemName: allTags.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                                    .foregroundColor(appColors.accentColor)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(appColors.backgroundColor.opacity(0.8))
                            .cornerRadius(8)
                        }
                        .disabled(allTags.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)

                    if filteredQuotes.isEmpty {
                        noResultsView
                    } else {
                        quotesList
                    }
                }
            }
        }
        .background(appColors.backgroundColor)
        .navigationTitle("Wszystkie cytaty")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if !viewModel.books.isEmpty {
                        showingAddQuoteSheet = true
                    } else {
                        selectedBook = nil
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(appColors.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingAddQuoteSheet) {
            if let book = selectedBook {
                AddQuoteView(book: book)
            } else {
                BookSelectionView(selectedBook: $selectedBook, showingAddQuoteSheet: $showingAddQuoteSheet)
            }
        }
        .sheet(isPresented: $showingTagFilter) {
            TagFilterView(selectedTag: $selectedTag, allTags: allTags)
        }
        .alert("Brak książek", isPresented: Binding<Bool>(
            get: { selectedBook == nil && viewModel.books.isEmpty },
            set: { _ in selectedBook = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Dodaj najpierw książkę, aby móc dodać cytat.")
        }
        #if compiler(>=5.9) && canImport(SwiftUI)
        .onChange(of: selectedBook) { oldBook, newBook in
            if newBook != nil {
                showingAddQuoteSheet = true
            }
        }
        #else
        .onChange(of: selectedBook) { newBook in
            if newBook != nil {
                showingAddQuoteSheet = true
            }
        }
        #endif
        .id(refreshToggle)
        .onReceive(tabSubject.$selectedTab) { tab in
            if tab == 1 {
                dismiss()
            }
        }
        .onAppear {
            if let tagFilter = initialTagFilter {
                selectedTag = tagFilter
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToQuotesWithTag"))) { notification in
            if let tag = notification.object as? String {
                selectedTag = tag
                refreshToggle.toggle()
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedQuote != nil },
            set: { isActive in if !isActive { selectedQuote = nil } }
        )) {
            if let quoteWithBook = selectedQuote {
                QuoteDetailView(quote: quoteWithBook.quote, book: quoteWithBook.book)
                    .onDisappear { refreshToggle.toggle() }
            }
        }
    }

    private var emptyQuotesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.bubble")
                .font(.system(size: 60))
                .foregroundColor(appColors.secondaryTextColor)

            Text("Brak cytatów")
                .font(.title2)
                .foregroundColor(appColors.primaryTextColor)

            Text("Dodaj cytaty do swoich książek, aby zobaczyć je tutaj")
                .font(.subheadline)
                .foregroundColor(appColors.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundColor)
    }

    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedTag != nil ? "tag.slash" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(appColors.secondaryTextColor)

            if selectedTag != nil && searchText.isEmpty {
                Text("Brak cytatów z tagiem \"\(selectedTag!)\"")
                    .font(.headline)
                    .foregroundColor(appColors.primaryTextColor)
                    .multilineTextAlignment(.center)

                Text("Spróbuj wybrać inny tag lub usuń filtr")
                    .font(.subheadline)
                    .foregroundColor(appColors.secondaryTextColor)
            } else if !searchText.isEmpty && selectedTag != nil {
                Text("Brak pasujących cytatów")
                    .font(.headline)
                    .foregroundColor(appColors.primaryTextColor)

                Text("Nie znaleziono cytatów pasujących do wyszukiwania i wybranego tagu")
                    .font(.subheadline)
                    .foregroundColor(appColors.secondaryTextColor)
                    .multilineTextAlignment(.center)
            } else {
                Text("Brak pasujących cytatów")
                    .font(.headline)
                    .foregroundColor(appColors.primaryTextColor)

                Text("Spróbuj zmienić kryteria wyszukiwania")
                    .font(.subheadline)
                    .foregroundColor(appColors.secondaryTextColor)
            }

            if selectedTag != nil {
                Button("Usuń filtr tagu") {
                    selectedTag = nil
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(appColors.backgroundColor)
    }

    private var quotesList: some View {
        List {
            ForEach(filteredQuotes) { quoteWithBook in
                Button(action: {
                    selectedQuote = quoteWithBook
                }) {
                    HStack(alignment: .center, spacing: 12) {
                        QuoteListItemView(quoteWithBook: quoteWithBook)
                            .padding(.vertical, 10)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .foregroundColor(appColors.secondaryTextColor)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .background(appColors.uiElementColor)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .listRowBackground(appColors.backgroundColor)
                .listRowInsets(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(appColors.backgroundColor)
        .padding(.horizontal) // padding pola cytatu
    }
}

// Widok wyboru książki
struct BookSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Binding var selectedBook: Book?
    @Binding var showingAddQuoteSheet: Bool

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.books) { book in
                    Button(action: {
                        selectedBook = book
                    }) {
                        BookRowView(book: book)
                    }
                }
            }
            .navigationTitle("Wybierz książkę")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
        }
    }
}
