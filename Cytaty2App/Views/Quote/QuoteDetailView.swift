import SwiftUI

struct QuoteDetailView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var refreshToggle = false
    
    let quote: Quote
    let book: Book
    
    // Pobieranie aktualnej książki i cytatu z ViewModel
    private var currentBook: Book {
        return viewModel.books.first { $0.id == book.id } ?? book
    }
    
    private var currentQuote: Quote {
        return currentBook.quotes.first { $0.id == quote.id } ?? quote
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Główna zawartość w ScrollView
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(currentQuote.content)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "book")
                            Text("Źródło")
                                .font(.headline)
                        }
                        .foregroundColor(.secondary)
                        
                        HStack {
                            if let coverURL = getCoverURLForSource() {
                                AsyncImage(url: coverURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    case .failure:
                                        Image(systemName: "book")
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 50, height: 70)
                                .cornerRadius(5)
                            } else {
                                Image(systemName: "book")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 70)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(currentBook.title)
                                    .font(.headline)
                                
                                Text(currentBook.author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    if currentQuote.page != nil || currentQuote.chapter != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.book.closed")
                                Text("Lokalizacja w książce")
                                    .font(.headline)
                            }
                            .foregroundColor(.secondary)
                            
                            HStack(spacing: 20) {
                                if let page = currentQuote.page {
                                    VStack {
                                        Text("\(page)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("Strona")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if let chapter = currentQuote.chapter {
                                    VStack {
                                        Text(chapter)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("Rozdział")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    if !currentQuote.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "tag")
                                Text("Tagi")
                                    .font(.headline)
                            }
                            .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(currentQuote.tags, id: \.self) { tag in
                                        Button(action: {
                                            // Przejdź do widoku wszystkich cytatów z filtrem tego tagu
                                            navigateToAllQuotesWithTag(tag)
                                        }) {
                                            Text(tag)
                                                .font(.subheadline)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // SEKCJA NOTATKI
                    if let note = currentQuote.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.orange)
                                Text("Notatka")
                                    .font(.headline)
                            }
                            .foregroundColor(.secondary)
                            
                            Text(note)
                                .font(.footnote)
                                .padding(12)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.vertical, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Data dodania")
                                .font(.headline)
                        }
                        .foregroundColor(.secondary)
                        
                        Text(formatDate(currentQuote.addedDate))
                            .font(.subheadline)
                    }
                    .padding(.vertical, 8)
                    
                    // Dodatkowy padding na dole dla przycisku
                    Spacer(minLength: 80)
                }
                .padding()
            }
            
            // PRZYCISK "Zobacz książkę" na dole - zawsze widoczny
            VStack(spacing: 0) {
                Divider()
                
                NavigationLink(destination: BookDetailView(book: currentBook)) {
                    HStack {
                        // Miniaturka okładki
                        if let coverURL = getCoverURLForButton() {
                            AsyncImage(url: coverURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 30, height: 40)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 40)
                                        .cornerRadius(3)
                                case .failure:
                                    Image(systemName: "book")
                                        .frame(width: 30, height: 40)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "book")
                                .frame(width: 30, height: 40)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Zobacz książkę")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text(currentBook.title)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(currentBook.quotes.count) \(quotesText(currentBook.quotes.count))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6).opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("Cytat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("Edytuj", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        viewModel.deleteQuote(currentQuote, from: currentBook)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("Usuń", systemImage: "trash")
                    }
                    
                    Button(action: {
                        shareQuote()
                    }) {
                        Label("Udostępnij", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditQuoteView(
                book: currentBook,
                quote: currentQuote,
                onUpdate: {
                    refreshToggle.toggle()
                }
            )
        }
        .id(refreshToggle)
    }
    
    // Funkcja do poprawnej odmiany słowa "cytat" w języku polskim
    private func quotesText(_ count: Int) -> String {
        if count == 1 {
            return "cytat"
        } else if count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20) {
            return "cytaty"
        } else {
            return "cytatów"
        }
    }
    
    // Funkcja pomocnicza dla okładki w sekcji źródło
    private func getCoverURLForSource() -> URL? {
        guard let coverURL = currentBook.coverURL else { return nil }
        
        if coverURL.hasPrefix("http") {
            return URL(string: coverURL)
        } else {
            // Względna ścieżka w dokumentach
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fullURL = documentsDirectory.appendingPathComponent(coverURL)
            
            // Sprawdź czy plik istnieje
            if FileManager.default.fileExists(atPath: fullURL.path) {
                return fullURL
            } else {
                return nil
            }
        }
    }
    
    // Funkcja pomocnicza dla okładki w przycisku
    private func getCoverURLForButton() -> URL? {
        guard let coverURL = currentBook.coverURL else { return nil }
        
        if coverURL.hasPrefix("http") {
            return URL(string: coverURL)
        } else {
            // Względna ścieżka w dokumentach
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fullURL = documentsDirectory.appendingPathComponent(coverURL)
            
            // Sprawdź czy plik istnieje
            if FileManager.default.fileExists(atPath: fullURL.path) {
                return fullURL
            } else {
                return nil
            }
        }
    }
    
    private func navigateToAllQuotesWithTag(_ tag: String) {
        // Powiadomimy RootView o zmianie zakładki i filtrze
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToQuotesWithTag"),
            object: tag
        )
        
        // Wróć do głównego widoku
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func shareQuote() {
        var shareText = "\"\(currentQuote.content)\"\n\n— \(currentBook.author), \"\(currentBook.title)\""
        
        if let page = currentQuote.page {
            shareText += ", strona \(page)"
        }
        
        // Dodanie notatki do udostępnianego tekstu, jeśli istnieje
        if let note = currentQuote.note, !note.isEmpty {
            shareText += "\n\nNotatka: \(note)"
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}
