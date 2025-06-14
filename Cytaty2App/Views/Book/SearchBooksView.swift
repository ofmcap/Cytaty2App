import SwiftUI

struct SearchBooksView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var query: String = ""
    @State private var isEditing = false
    @State private var showingManualAdd = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Pasek wyszukiwania
                searchBar
                
                // Przyciski wyboru trybu dodawania
                HStack(spacing: 20) {
                    Button(action: {
                        showingManualAdd = true
                    }) {
                        VStack {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 24))
                            Text("Dodaj ręcznie")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        if !query.isEmpty {
                            viewModel.searchQuery = query
                            viewModel.searchBooks()
                        }
                    }) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                            Text("Szukaj online")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                if viewModel.isSearching {
                    ProgressView("Wyszukiwanie...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty && !query.isEmpty {
                    emptyResultsView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Dodaj książkę")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingManualAdd) {
                AddEditBookView(isEditing: false, onSave: { book in
                    viewModel.addBook(book)
                    dismiss()
                })
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
                .submitLabel(.search)
            
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
            
            Button(action: {
                showingManualAdd = true
            }) {
                Text("Dodaj książkę ręcznie")
                    .foregroundColor(.blue)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.top, 10)
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
