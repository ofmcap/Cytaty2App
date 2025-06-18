import SwiftUI

struct AddQuoteView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    
    let book: Book
    
    @State private var content: String = ""
    @State private var page: String = ""
    @State private var chapter: String = ""
    @State private var tagInput: String = ""
    @State private var tags: [String] = []
    @State private var note: String = ""
    @State private var showingSuggestions = false
    @FocusState private var isTagInputFocused: Bool // Nowy stan dla focus
    
    // Wszystkie istniejące tagi w aplikacji
    private var allExistingTags: [String] {
        var allTags = Set<String>()
        for book in viewModel.books {
            for quote in book.quotes {
                allTags.formUnion(quote.tags)
            }
        }
        return Array(allTags).sorted()
    }
    
    // Filtrowane sugestie tagów
    private var tagSuggestions: [String] {
        if tagInput.isEmpty {
            return []
        }
        
        return allExistingTags.filter { tag in
            tag.localizedCaseInsensitiveContains(tagInput) && !tags.contains(tag)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
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
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                TextField("Dodaj tag", text: $tagInput)
                                    .focused($isTagInputFocused)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        addTag()
                                    }
                                    #if compiler(>=5.9) && canImport(SwiftUI)
                                    .onChange(of: tagInput) { _, newValue in
                                        showingSuggestions = !newValue.isEmpty && !tagSuggestions.isEmpty
                                    }
                                    #else
                                    .onChange(of: tagInput) { newValue in
                                        showingSuggestions = !newValue.isEmpty && !tagSuggestions.isEmpty
                                    }
                                    #endif
                                
                                Button(action: addTag) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                }
                                .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            
                            // Sugestie tagów
                            if showingSuggestions && !tagSuggestions.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sugestie:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(tagSuggestions.prefix(5), id: \.self) { suggestion in
                                                Button(action: {
                                                    tagInput = suggestion
                                                    addTag()
                                                }) {
                                                    Text(suggestion)
                                                        .font(.caption)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.blue.opacity(0.1))
                                                        .foregroundColor(.blue)
                                                        .cornerRadius(12)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            // Dodane tagi
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
                                }
                                .padding(.top, 4)
                            }
                        }
                        .id("tagsSection") // ID dla ScrollViewReader
                    }
                    
                    // Sekcja dla notatki
                    Section(header: Text("Notatka (opcjonalna)")) {
                        TextEditor(text: $note)
                            .frame(minHeight: 60)
                            .font(.footnote)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .navigationTitle("Nowy cytat")
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
                .onTapGesture {
                    // Ukryj sugestie po kliknięciu w inne miejsce
                    showingSuggestions = false
                }
                // Obsługa przewijania gdy focus na polu tagów
                .onChange(of: isTagInputFocused) { _, isFocused in
                    if isFocused {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("tagsSection", anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    private func addTag() {
        let tag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tag.isEmpty && !tags.contains(tag) {
            withAnimation(.spring()) {
                tags.append(tag)
            }
            tagInput = ""
            showingSuggestions = false
        }
    }
    
    private func saveQuote() {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote = trimmedNote.isEmpty ? nil : trimmedNote
        
        let quote = Quote(
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            page: Int(page),
            chapter: chapter.isEmpty ? nil : chapter,
            tags: tags,
            note: finalNote
        )
        
        viewModel.addQuote(quote, to: book)
        dismiss()
    }
}

