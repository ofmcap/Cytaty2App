import SwiftUI

struct AllQuotesView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var showingAddQuoteSheet = false
    @State private var selectedBook: Book?
    @State private var refreshToggle = false // Stan do wymuszenia odświeżenia
    @Environment(\.selectedTabSubject) var tabSubject
    @Environment(\.dismiss) private var dismiss
    
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
    
    var body: some View {
        VStack {
            if allQuotes.isEmpty {
                emptyQuotesView
            } else {
                VStack {
                    SearchBar(text: $searchText, placeholder: "Szukaj cytatów")
                        .padding(.horizontal)
                    
                    if !allTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button(action: {
                                    selectedTag = nil
                                }) {
                                    Text("Wszystkie")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedTag == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedTag == nil ? .white : .primary)
                                        .cornerRadius(16)
                                }
                                
                                ForEach(allTags, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = tag
                                    }) {
                                        Text(tag)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedTag == tag ? .white : .primary)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                    
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
                        // Jeśli nie ma książek, pokazujemy alert
                        selectedBook = nil
                    }
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddQuoteSheet) {
            if let book = selectedBook {
                // Jeśli książka jest już wybrana, otwieramy bezpośrednio formularz dodawania cytatu
                AddQuoteView(book: book)
            } else {
                // W przeciwnym razie pokazujemy widok wyboru książki
                BookSelectionView(selectedBook: $selectedBook, showingAddQuoteSheet: $showingAddQuoteSheet)
            }
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
            // Gdy książka zostanie wybrana, pozostawiamy arkusz otwarty
            if newBook != nil {
                showingAddQuoteSheet = true
            }
        }
        #else
        .onChange(of: selectedBook) { newBook in
            // Gdy książka zostanie wybrana, pozostawiamy arkusz otwarty
            if newBook != nil {
                showingAddQuoteSheet = true
            }
        }
        #endif
        // Dodajemy .id zależny od refreshToggle, aby wymusić odświeżenie listy
        .id(refreshToggle)
        // Dodajemy obsługę zdarzeń dla resetowania stosu nawigacji
        .onReceive(tabSubject.$selectedTab) { tab in
            if tab == 1 {
                // Reset nawigacji dla zakładki cytatów
                dismiss()
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
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Brak pasujących cytatów")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Spróbuj zmienić kryteria wyszukiwania")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var quotesList: some View {
        List {
            ForEach(filteredQuotes) { quoteWithBook in
                NavigationLink(destination:
                    QuoteDetailView(quote: quoteWithBook.quote, book: quoteWithBook.book)
                        .onDisappear {
                            // Odświeżamy listę po powrocie z widoku szczegółów
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

