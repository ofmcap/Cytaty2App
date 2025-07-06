import SwiftUI

struct BookListView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @EnvironmentObject var colorSchemeService: ColorSchemeService
    @State private var showingSearchBooks = false
    @State private var searchText = ""
    @Environment(\.selectedTabSubject) var tabSubject
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appColors) var appColors

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

            // Lista książek lub komunikat o braku wyników
            if filteredBooks.isEmpty && !searchText.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(appColors.secondaryTextColor)

                    Text("Brak wyników")
                        .font(.title2)
                        .foregroundColor(appColors.primaryTextColor)

                    Text("Nie znaleziono książek pasujących do: \"\(searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(appColors.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(appColors.backgroundColor)
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
                .scrollContentBackground(.hidden)
                .background(appColors.backgroundColor)
                .onAppear {
                    UITableView.appearance().backgroundColor = UIColor.clear
                }
                .onDisappear {
                    UITableView.appearance().backgroundColor = nil
                }
                .listRowBackground(appColors.backgroundColor)
            }
        }
        .background(appColors.backgroundColor)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingSearchBooks = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(appColors.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingSearchBooks) {
            SearchBooksView()
        }
        .onReceive(tabSubject.$selectedTab) { tab in
            if tab == 0 {
                // Reset nawigacji dla zakładki książek
                dismiss()
            }
        }
    }
}
