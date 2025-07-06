import SwiftUI

struct SearchBooksView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.appColors) private var appColors

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
                        .foregroundColor(appColors.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(appColors.backgroundColor.opacity(0.8))
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
                        .foregroundColor(appColors.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(appColors.backgroundColor.opacity(0.8))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                if viewModel.isSearching {
                    ProgressView("Wyszukiwanie...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tint(appColors.accentColor)
                } else if viewModel.searchResults.isEmpty && !query.isEmpty {
                    emptyResultsView
                } else {
                    searchResultsList
                }
            }
            .background(appColors.backgroundColor)
            .navigationTitle("Dodaj książkę")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                    .foregroundColor(appColors.secondaryTextColor)
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
                .background(appColors.uiElementColor.opacity(0.15))
                .cornerRadius(8)
                .foregroundColor(appColors.primaryTextColor)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(appColors.secondaryTextColor)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing {
                            Button(action: {
                                query = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(appColors.secondaryTextColor)
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
                .foregroundColor(appColors.accentColor)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var emptyResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(appColors.secondaryTextColor)

            Text("Brak wyników")
                .font(.title2)
                .foregroundColor(appColors.primaryTextColor)

            Text("Spróbuj zmienić zapytanie lub sprawdź pisownię")
                .font(.subheadline)
                .foregroundColor(appColors.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                showingManualAdd = true
            }) {
                Text("Dodaj książkę ręcznie")
                    .foregroundColor(appColors.accentColor)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(appColors.accentColor.opacity(0.1))
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
        .background(appColors.backgroundColor)
    }
}
