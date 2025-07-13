import SwiftUI

struct EditQuoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors

    let book: Book
    @State var quote: Quote
    var onUpdate: (() -> Void)? = nil

    @State private var content: String = ""
    @State private var page: String = ""
    @State private var chapter: String = ""
    @State private var tagsText: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Cytat")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }

                Section(header: Text("Lokalizacja")) {
                    TextField("Strona", text: $page)
                        .keyboardType(.numberPad)
                    TextField("Rozdział", text: $chapter)
                }

                Section(header: Text("Tagi (oddzielone przecinkami)")) {
                    TextField("Tagi", text: $tagsText)
                }

                Section(header: Text("Notatka")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
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
            .onAppear {
                content = quote.content
                page = quote.page != nil ? String(quote.page!) : ""
                chapter = quote.chapter ?? ""
                tagsText = quote.tags.joined(separator: ", ")
                note = quote.note ?? ""
            }
            .background(appColors.backgroundColor)
        }
    }

    private func saveQuote() {
        var updatedQuote = quote
        updatedQuote.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedQuote.page = Int(page)
        updatedQuote.chapter = chapter.isEmpty ? nil : chapter
        updatedQuote.tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        updatedQuote.note = note.isEmpty ? nil : note

        viewModel.updateQuote(updatedQuote, in: book)
        onUpdate?()
        dismiss()
    }
}
