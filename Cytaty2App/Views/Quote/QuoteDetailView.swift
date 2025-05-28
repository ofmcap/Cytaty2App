import SwiftUI

struct QuoteDetailView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var refreshToggle = false // Dodajemy stan do wymuszenia odświeżenia
    
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
                        if let coverURL = currentBook.coverURL, let url = URL(string: coverURL) {
                            AsyncImage(url: url) { phase in
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
            }
            .padding()
        }
        .navigationTitle("Cytat")
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
                    // Wymuszamy odświeżenie widoku
                    refreshToggle.toggle()
                }
            )
        }
        // Dodajemy id do wymuszenia odświeżenia widoku
        .id(refreshToggle)
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
