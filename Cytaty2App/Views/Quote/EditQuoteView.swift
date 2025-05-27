import SwiftUI

struct EditQuoteView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    
    let book: Book
    let quote: Quote
    
    @State private var content: String
    @State private var page: String
    @State private var chapter: String
    @State private var tagInput: String = ""
    @State private var tags: [String]
    
    init(book: Book, quote: Quote) {
        self.book = book
        self.quote = quote
        
        _content = State(initialValue: quote.content)
        _page = State(initialValue: quote.page != nil ? "\(quote.page!)" : "")
        _chapter = State(initialValue: quote.chapter ?? "")
        _tags = State(initialValue: quote.tags)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Treść cytatu")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Szczegóły (opcjonalne)")) {
                    TextField("Strona", text: $page)
                        .keyboardType(.numberPad)
                    
                    TextField("Rozdział", text: $chapter)
                }
                
                Section(header: Text("Tagi")) {
                    HStack {
                        TextField("Dodaj tag", text: $tagInput)
                        
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                        
                                        Button(action: {
                                            tags.removeAll { $0 == tag }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Edytuj cytat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        saveQuote()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let tag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tag.isEmpty && !tags.contains(tag) {
            tags.append(tag)
            tagInput = ""
        }
    }
    
    private func saveQuote() {
        let updatedQuote = Quote(
            id: quote.id,
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            page: Int(page),
            chapter: chapter.isEmpty ? nil : chapter,
            addedDate: quote.addedDate,
            tags: tags
        )
        
        viewModel.updateQuote(updatedQuote, in: book)
        dismiss()
    }
}
