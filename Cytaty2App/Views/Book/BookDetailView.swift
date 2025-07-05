// Cytaty2App/Views/Book/BookDetailView.swift
import SwiftUI

struct BookDetailView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    let book: Book
    @State private var showingAddQuote = false
    @State private var showingEditBook = false
    @State private var refreshToggle = false
    
    // Funkcja pomocnicza do znajdowania aktualnej książki z ViewModel
    private var currentBook: Book {
        return viewModel.books.first { $0.id == book.id } ?? book
    }
    
    var body: some View {
        VStack {
            BookHeaderView(book: currentBook)
                .padding()
            
            if currentBook.quotes.isEmpty {
                EmptyQuoteView()
            } else {
                QuoteListView(book: currentBook)
            }
        }
        .navigationTitle(currentBook.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        showingAddQuote = true
                    }) {
                        Label("Dodaj cytat", systemImage: "quote.bubble.fill")
                    }
                    
                    Button(action: {
                        showingEditBook = true
                    }) {
                        Label("Edytuj książkę", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddQuote) {
            AddQuoteView(book: currentBook)
        }
        .sheet(isPresented: $showingEditBook) {
            AddEditBookView(
                isEditing: true,
                book: currentBook,
                onSave: { updatedBook in
                    viewModel.updateBook(updatedBook)
                    refreshToggle.toggle()
                }
            )
        }
        .id(refreshToggle)
    }
}

struct BookHeaderView: View {
    let book: Book
    
    // Funkcja do konwersji ścieżki na URL
    private func getFullCoverURL() -> URL? {
        guard let coverURL = book.coverURL else { return nil }
        
        if coverURL.hasPrefix("http") {
            return URL(string: coverURL)
        } else {
            // Względna ścieżka w dokumentach
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fullURL = documentsDirectory.appendingPathComponent(coverURL)
            
            // Sprawdź czy plik istnieje
            if FileManager.default.fileExists(atPath: fullURL.path) {
                print("📁 Lokalna okładka istnieje: \(fullURL.path)")
                return fullURL
            } else {
                print("❌ Lokalna okładka nie istnieje: \(fullURL.path)")
                return nil
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            if let coverURL = getFullCoverURL() {
                AsyncImage(url: coverURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(let error):
                        Image(systemName: "book")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onAppear {
                                print("❌ Błąd ładowania okładki w BookHeader: \(error.localizedDescription)")
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 140)
                .cornerRadius(5)
            } else {
                Image(systemName: "book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 140)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(book.author)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let publishYear = book.publishYear {
                    Text("Rok wydania: \(String(publishYear))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let isbn = book.isbn {
                    Text("ISBN: \(isbn)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct EmptyQuoteView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.quote")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Brak cytatów")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Dodaj pierwszy cytat z tej książki")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct QuoteListView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    let book: Book
    @State private var editingQuote: Quote?
    @State private var refreshToggle = false
    
    // Funkcja pomocnicza do znajdowania aktualnej książki z ViewModel
    private var currentBook: Book {
        return viewModel.books.first { $0.id == book.id } ?? book
    }
    
    var body: some View {
        List {
            ForEach(currentBook.quotes.sorted(by: { $0.addedDate > $1.addedDate })) { quote in
                NavigationLink(destination:
                    QuoteDetailView(quote: quote, book: currentBook)
                        .onDisappear {
                            refreshToggle.toggle()
                        }
                ) {
                    QuoteRowView(quote: quote)
                }
                .contextMenu {
                    Button(action: {
                        editingQuote = quote
                    }) {
                        Label("Edytuj", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        viewModel.deleteQuote(quote, from: currentBook)
                        refreshToggle.toggle()
                    }) {
                        Label("Usuń", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .sheet(item: $editingQuote) { quote in
            EditQuoteView(
                book: currentBook,
                quote: quote,
                onUpdate: {
                    refreshToggle.toggle()
                }
            )
        }
        .id(refreshToggle)
    }
}
