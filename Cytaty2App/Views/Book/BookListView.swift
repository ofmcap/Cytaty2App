import SwiftUI

struct BookListView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var showingSearchBooks = false
    @State private var searchText = ""
    
    // Filtrowane książki na podstawie wyszukiwania
    private var filteredBooks: [Book] {
        if searchText.isEmpty {
            return viewModel.books
        } else {
            return viewModel.books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack {
            // Pasek wyszukiwania umieszczony na stałe
            SearchBar(text: $searchText, placeholder: "Szukaj w mojej bibliotece")
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Lista książek
            if filteredBooks.isEmpty && !searchText.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Brak wyników")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Nie znaleziono książek pasujących do: \"\(searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredBooks) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookRowView(book: book)
                        }
                    }
                    .onDelete(perform: viewModel.deleteBook)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Moje książki")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingSearchBooks = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingSearchBooks) {
            SearchBooksView()
        }
    }
}
