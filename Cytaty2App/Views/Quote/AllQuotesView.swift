import SwiftUI

struct AllQuotesView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var showingAddQuoteSheet = false
    @State private var selectedBook: Book?
    @State private var refreshToggle = false
    @State private var showingTagFilter = false
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
    
    // Liczenie cytatów dla każdego tagu
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
                        // Wyświetlanie aktualnego filtra
                        if let selectedTag = selectedTag {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                
                                Text(selectedTag)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                                
                                Text("(\(countQuotesForTag(selectedTag)))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    self.selectedTag = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                        } else {
                            Text("Wszystkie cytaty")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Przycisk otwierający ekran filtrów
                        Button(action: {
                            showingTagFilter = true
                        }) {
                            HStack {
                                Text("Filtry")
                                    .font(.subheadline)
                                Image(systemName: allTags.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
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
            // Ustaw filtr tagu z parametru inicjalizacji
            if let tagFilter = initialTagFilter {
                selectedTag = tagFilter
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToQuotesWithTag"))) { notification in
            // Obsługa nawigacji z kliknięcia na tag w widoku szczegółów cytatu
            if let tag = notification.object as? String {
                selectedTag = tag
                refreshToggle.toggle() // Wymuś odświeżenie widoku
            }
        }
    }
    
    private var emptyQuotesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.bubble")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Brak cytatów")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Dodaj cytaty do swoich książek, aby zobaczyć je tutaj")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedTag != nil ? "tag.slash" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            if selectedTag != nil && searchText.isEmpty {
                Text("Brak cytatów z tagiem \"\(selectedTag!)\"")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("Spróbuj wybrać inny tag lub usuń filtr")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if !searchText.isEmpty && selectedTag != nil {
                Text("Brak pasujących cytatów")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Nie znaleziono cytatów pasujących do wyszukiwania i wybranego tagu")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Brak pasujących cytatów")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Spróbuj zmienić kryteria wyszukiwania")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
    }
    
    private var quotesList: some View {
        List {
            ForEach(filteredQuotes) { quoteWithBook in
                NavigationLink(destination:
                    QuoteDetailView(quote: quoteWithBook.quote, book: quoteWithBook.book)
                        .onDisappear {
                            refreshToggle.toggle()
                        }
                ) {
                    QuoteListItemView(quoteWithBook: quoteWithBook)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

// Widok wyboru książki
struct BookSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Binding var selectedBook: Book?
    @Binding var showingAddQuoteSheet: Bool
    
    var body: some View {
        NavigationView {
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
