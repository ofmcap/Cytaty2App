import SwiftUI

struct SearchBooksView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.appColors) private var appColors

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, placeholder: "Szukaj książek")
                    .padding()

                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { book in
                        Button(action: {
                            viewModel.addBook(book)
                            dismiss()
                        }) {
                            BookRowView(book: book)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else if !searchText.isEmpty {
                    Text("Brak wyników")
                        .foregroundColor(appColors.secondaryTextColor)
                        .padding()
                } else {
                    Spacer()
                }
            }
            .navigationTitle("Wyszukaj książki")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    viewModel.searchQuery = newValue
                    viewModel.searchBooks()
                } else {
                    viewModel.searchResults = []
                }
            }
            .background(appColors.backgroundColor)
        }
    }
}
