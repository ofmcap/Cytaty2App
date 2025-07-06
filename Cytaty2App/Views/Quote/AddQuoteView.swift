import SwiftUI

struct AddQuoteView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.appColors) var appColors

    
    let book: Book
    
    @State private var content: String = ""
    @State private var page: String = ""
    @State private var chapter: String = ""
    @State private var tagInput: String = ""
    @State private var tags: [String] = []
    @State private var note: String = ""
    @State private var showingSuggestions = false
    @FocusState private var isTagInputFocused: Bool
    
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
                    Section(header: Text("Treść cytatu")
                        .foregroundColor(appColors.secondaryTextColor)) {
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                            .foregroundColor(appColors.primaryTextColor)
                    }
                    .listRowBackground(appColors.backgroundColor)
                    
                    Section(header: Text("Szczegóły (opcjonalne)")
                        .foregroundColor(appColors.secondaryTextColor)) {
                        TextField("Strona", text: $page)
                            .keyboardType(.numberPad)
                            .foregroundColor(appColors.primaryTextColor)
                        
                        TextField("Rozdział", text: $chapter)
                            .foregroundColor(appColors.primaryTextColor)
                    }
                    .listRowBackground(appColors.backgroundColor)
                    
                    Section(header: Text("Tagi")
                        .foregroundColor(appColors.secondaryTextColor)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                TextField("Dodaj tag", text: $tagInput)
                                    .focused($isTagInputFocused)
                                    .submitLabel(.done)
                                    .foregroundColor(appColors.primaryTextColor)
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
                                        .foregroundColor(appColors.accentColor)
                                }
                                .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            
                            // Sugestie tagów
                            if showingSuggestions && !tagSuggestions.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sugestie:")
                                        .font(.caption)
                                        .foregroundColor(appColors.secondaryTextColor)
                                    
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
                                                        .background(appColors.accentColor.opacity(0.1))
                                                        .foregroundColor(appColors.accentColor)
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
                                                    .foregroundColor(appColors.accentColor)
                                                
                                                Button(action: {
                                                    tags.removeAll { $0 == tag }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.caption)
                                                        .foregroundColor(appColors.secondaryTextColor)
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(appColors.accentColor.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .id("tagsSection")
                    }
                    .listRowBackground(appColors.backgroundColor)
                    
                    // Sekcja dla notatki
                    Section(header: Text("Notatka (opcjonalna)")
                        .foregroundColor(appColors.secondaryTextColor)) {
                        TextEditor(text: $note)
                            .frame(minHeight: 60)
                            .font(.footnote)
                            .foregroundColor(appColors.primaryTextColor)
                    }
                    .listRowBackground(appColors.backgroundColor)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .scrollContentBackground(.hidden)
                .background(appColors.backgroundColor)
                .navigationTitle("Nowy cytat")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Anuluj") {
                            dismiss()
                        }
                        .foregroundColor(appColors.secondaryTextColor)
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Zapisz") {
                            saveQuote()
                        }
                        .foregroundColor(appColors.accentColor)
                        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .onTapGesture {
                    showingSuggestions = false
                }
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
