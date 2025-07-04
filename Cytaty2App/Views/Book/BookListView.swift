// Cytaty2App/Views/Book/BookListView.swift
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
            
            // Lista książek
            if filteredBooks.isEmpty && !searchText.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(appColors.secondaryTextColor) // Zmiana z .grayText()
                    
                    Text("Brak wyników")
                        .font(.title2)
                        .foregroundColor(appColors.primaryTextColor) // Zmiana z .grayText()
                    
                    Text("Nie znaleziono książek pasujących do: \"\(searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(appColors.secondaryTextColor) // Zmiana z .secondary
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
                .scrollContentBackground(.hidden) // Ukryj domyślne tło
                .background(appColors.backgroundColor) // Dodaj tło ze schematu
            }
        }
        .background(appColors.backgroundColor) // Tło główne
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingSearchBooks = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(appColors.accentColor) // Dodaj kolor
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
