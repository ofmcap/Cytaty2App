import SwiftUI

struct AddQuoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors

    let book: Book
    @State private var content: String = ""
    @State private var page: String = ""
    @State private var chapter: String = ""
    @State private var tagsText: String = ""
    @State private var note: String = ""

    var onSave: (() -> Void)? = nil

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
            .navigationTitle("Dodaj cytat")
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
            .background(appColors.backgroundColor)
        }
    }

    private func saveQuote() {
        let newQuote = Quote(
            id: UUID().uuidString,
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            page: Int(page),
            chapter: chapter.isEmpty ? nil : chapter,
            addedDate: Date(),
            tags: tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
            note: note.isEmpty ? nil : note
        )

        viewModel.addQuote(newQuote, to: book)
        onSave?()
        dismiss()
    }
}
