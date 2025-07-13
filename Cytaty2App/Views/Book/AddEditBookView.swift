import SwiftUI

struct AddEditBookView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors

    var isEditing: Bool
    @State private var book: Book
    var onSave: ((Book) -> Void)? = nil

    @State private var title: String
    @State private var author: String
    @State private var isbn: String
    @State private var publishYear: String

    // Nowy init, który ustawia stan na podstawie trybu i przekazanego book (lub pustej książki)
    init(isEditing: Bool, book: Book? = nil, onSave: ((Book) -> Void)? = nil) {
        self.isEditing = isEditing
        self.onSave = onSave

        if let book = book {
            _book = State(initialValue: book)
            _title = State(initialValue: book.title)
            _author = State(initialValue: book.author)
            _isbn = State(initialValue: book.isbn ?? "")
            _publishYear = State(initialValue: book.publishYear.map { String($0) } ?? "")
        } else {
            let emptyBook = Book(title: "", author: "", isbn: nil, publishYear: nil)
            _book = State(initialValue: emptyBook)
            _title = State(initialValue: "")
            _author = State(initialValue: "")
            _isbn = State(initialValue: "")
            _publishYear = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tytuł")) {
                    TextField("Tytuł książki", text: $title)
                }
                Section(header: Text("Autor")) {
                    TextField("Autor", text: $author)
                }
                Section(header: Text("ISBN")) {
                    TextField("ISBN", text: $isbn)
                }
                Section(header: Text("Rok wydania")) {
                    TextField("Rok wydania", text: $publishYear)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(isEditing ? "Edytuj książkę" : "Dodaj książkę")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        saveBook()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .background(appColors.backgroundColor)
        }
    }

    private func saveBook() {
        var updatedBook = book
        updatedBook.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedBook.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedBook.isbn = isbn.isEmpty ? nil : isbn
        updatedBook.publishYear = Int(publishYear)

        if isEditing {
            viewModel.updateBook(updatedBook)
        } else {
            viewModel.addBook(updatedBook)
        }
        onSave?(updatedBook)
        dismiss()
    }
}
