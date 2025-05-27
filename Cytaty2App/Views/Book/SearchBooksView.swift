import SwiftUI

struct SearchBooksView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var query: String = ""
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                searchBar
                
                if viewModel.isSearching {
                    ProgressView("Wyszukiwanie...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty && !query.isEmpty {
                    emptyResultsView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Wyszukaj książkę")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Tytuł, autor lub ISBN", text: $query)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                query = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    isEditing = true
                }
                .onSubmit {
                    viewModel.searchQuery = query
                    viewModel.searchBooks()
                }
            
            if isEditing {
                Button("Szukaj") {
                    isEditing = false
                    viewModel.searchQuery = query
                    viewModel.searchBooks()
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isEditing)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Brak wyników")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Spróbuj zmienić zapytanie lub sprawdź pisownię")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchResultsList: some View {
        List {
            ForEach(viewModel.searchResults) { book in
                Button(action: {
                    viewModel.addBook(book)
                    dismiss()
                }) {
                    BookRowView(book: book)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

