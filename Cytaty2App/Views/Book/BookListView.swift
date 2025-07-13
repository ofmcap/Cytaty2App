import SwiftUI

struct BookListView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors
    @Environment(\.bookSelectionAction) private var onBookSelected

    @State private var searchText = ""
    @State private var showingAddBook = false
    @State private var refreshToggle = false

    @State private var bookToEdit: Book? = nil
    @State private var showingEditBook = false

    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return viewModel.books.sorted(by: { $0.title < $1.title })
        } else {
            return viewModel.books.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Szukaj książek")
                .padding(.horizontal)

            if filteredBooks.isEmpty {
                emptyBooksView
            } else {
                List {
                    ForEach(filteredBooks, id: \.id) { book in
                        Button(action: {
                            onBookSelected(book)
                        }) {
                            BookRowView(book: book)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: {
                                bookToEdit = book
                                showingEditBook = true
                            }) {
                                Label("Edytuj", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                if let index = viewModel.books.firstIndex(where: { $0.id == book.id }) {
                                    viewModel.deleteBook(at: IndexSet(integer: index))
                                    refreshToggle.toggle()
                                }
                            } label: {
                                Label("Usuń", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .id(refreshToggle)
                .background(appColors.backgroundColor)
                .scrollContentBackground(.hidden)
            }
        }
        .background(appColors.backgroundColor)
        .navigationTitle("Moje książki")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingAddBook = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(appColors.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingAddBook) {
            AddEditBookView(isEditing: false) { newBook in
                viewModel.addBook(newBook)
                showingAddBook = false
                refreshToggle.toggle()
            }
        }
        .sheet(isPresented: $showingEditBook, onDismiss: {
            bookToEdit = nil
        }) {
            if let bookToEdit = bookToEdit {
                AddEditBookView(isEditing: true, book: bookToEdit) { updatedBook in
                    viewModel.updateBook(updatedBook)
                    showingEditBook = false
                    refreshToggle.toggle()
                }
            } else {
                Text("Błąd: brak książki do edycji")
            }
        }
    }

    private var emptyBooksView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book")
                .font(.system(size: 60))
                .foregroundColor(appColors.secondaryTextColor)

            Text("Brak książek")
                .font(.title2)
                .foregroundColor(appColors.primaryTextColor)

            Text("Dodaj książki, aby zobaczyć je tutaj")
                .font(.subheadline)
                .foregroundColor(appColors.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundColor)
    }
}

// MARK: - Selection Modifier i rozszerzenie dla BookListView

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



// Environment Key dla bookSelectionAction

private struct BookSelectionActionKey: EnvironmentKey {
    static let defaultValue: (Book) -> Void = { _ in }
}

extension EnvironmentValues {
    var bookSelectionAction: (Book) -> Void {
        get { self[BookSelectionActionKey.self] }
        set { self[BookSelectionActionKey.self] = newValue }
    }
}
