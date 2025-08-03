import SwiftUI

struct BookListView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors
    @State private var showingAddBook = false
    @State private var showingSearchBooks = false
    @State private var searchText = ""
    @State private var selectedBook: Book? = nil

    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return viewModel.books
        } else {
            return viewModel.books.filter { book in
                book.title.lowercased().contains(searchText.lowercased()) ||
                book.author.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationStack {
            booksList
                .searchable(text: $searchText, prompt: "Szukaj książek")
                .navigationTitle("Książki")
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $showingAddBook) {
                    AddBookSheetView()
                }
                .sheet(isPresented: $showingSearchBooks) {
                    searchBooksSheet
                }
                .background(appColors.backgroundColor)
                .onAppear {
                    viewModel.loadBooks()
                }
        }
    }
    
    // MARK: - View Components
    
    private var booksList: some View {
        List {
            ForEach(filteredBooks) { book in
                NavigationLink(destination: BookDetailView(book: book)) {
                    BookRowView(book: book)
                }
            }
            .onDelete(perform: deleteBooks)
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button("Dodaj ręcznie") {
                    showingAddBook = true
                }
                Button("Wyszukaj w Google Books") {
                    showingSearchBooks = true
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private var searchBooksSheet: some View {
        SearchBooksView()
    }

    // MARK: - Actions
    
    private func deleteBooks(at offsets: IndexSet) {
        viewModel.deleteBook(at: offsets)
    }
}

// MARK: - Selection Modifier

struct BookSelectionModifier: ViewModifier {
    let onSelect: (Book) -> Void

    func body(content: Content) -> some View {
        content.environment(\.bookSelectionAction, onSelect)
    }
}

extension View {
    func onBookSelected(_ action: @escaping (Book) -> Void) -> some View {
        modifier(BookSelectionModifier(onSelect: action))
    }
}

// MARK: - Environment Key

private struct BookSelectionActionKey: EnvironmentKey {
    static let defaultValue: (Book) -> Void = { _ in }
}

extension EnvironmentValues {
    var bookSelectionAction: (Book) -> Void {
        get { self[BookSelectionActionKey.self] }
        set { self[BookSelectionActionKey.self] = newValue }
    }
}

