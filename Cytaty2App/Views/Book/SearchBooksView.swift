import SwiftUI

struct SearchBooksView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.appColors) private var appColors

    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>? // 🆕 Kontrola wyszukiwania

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, placeholder: "Szukaj książek")
                    .padding()

                if viewModel.isSearching {
                    ProgressView("Wyszukiwanie...")
                        .padding()
                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { book in
                        Button(action: {
                            viewModel.addBook(book)
                            dismiss()
                        }) {
                            BookRowView(book: book)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listStyle(InsetGroupedListStyle())
                } else if !searchText.isEmpty && !viewModel.isSearching {
                    Text("Brak wyników")
                        .foregroundColor(appColors.secondaryTextColor)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(appColors.secondaryTextColor)
                        Text("Wpisz tytuł lub autora książki")
                            .foregroundColor(appColors.secondaryTextColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Wyszukaj książki")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        searchTask?.cancel()
                        dismiss()
                    }
                }
            }
            .onChange(of: searchText) { _, newValue in
                // 🔧 DEBOUNCING - anuluj poprzednie wyszukiwanie
                searchTask?.cancel()
                
                if newValue.isEmpty {
                    viewModel.searchResults = []
                    viewModel.isSearching = false
                } else if newValue.count >= 2 { // Wyszukuj od 2 znaków
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                        
                        if !Task.isCancelled {
                            await MainActor.run {
                                viewModel.searchQuery = newValue
                                viewModel.searchBooks()
                            }
                        }
                    }
                }
            }
            .background(appColors.backgroundColor)
        }
        .onDisappear {
            searchTask?.cancel()
        }
    }
}
