import SwiftUI
import PhotosUI  // Dla PhotosPicker

struct AddBookSheetView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.appColors) private var appColors
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var publishYear = ""
    @State private var selectedCover: PhotosPickerItem? = nil
    @State private var coverURL: String? = nil  // Nowe: przechowuje URL po zapisie
    @State private var coverOption: CoverOption = .noAvailable  // Enum dla wyboru jak zrzut5

    enum CoverOption {
        case noAvailable, chooseCustom
    }

    private var isAddEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Artwork") {
                    Picker("Cover", selection: $coverOption) {
                        Text("No Cover Available").tag(CoverOption.noAvailable)
                        Text("Choose Custom").tag(CoverOption.chooseCustom)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    if coverOption == .chooseCustom {
                        PhotosPicker("Select Cover", selection: $selectedCover, matching: .images)
                    }
                }

                Section(header: Text("Book Details")) {
                    TextField("Tytuł", text: $title)
                    TextField("Autor", text: $author)
                    TextField("ISBN", text: $isbn)
                    TextField("Rok wydania", text: $publishYear).keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Book Manually")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dodaj") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
                        let newBook = Book(
                            title: trimmedTitle,
                            author: trimmedAuthor,
                            coverURL: coverURL,  // Przeniesione przed isbn
                            isbn: isbn.isEmpty ? nil : isbn,
                            publishYear: Int(publishYear)  // Zakładam optional, jeśli nie – dodaj check
                        )
                        viewModel.addBook(newBook)
                        dismiss()
                    }
                    .disabled(!isAddEnabled)
                }
            }
            .background(appColors.backgroundColor)
            .onChange(of: selectedCover) { oldValue, newValue in  // Nowa wersja onChange dla iOS 17+ – fix deprecated
                Task {
                    if let newItem = newValue, let data = try? await newItem.loadTransferable(type: Data.self) {
                        // Generujemy tymczasowe id (UUID jako String)
                        let tempBookId = UUID().uuidString

                        // Zapisz dane przez StorageService i pobierz URL – zmień na forBookId
                        if let savedURL = StorageService.shared.saveImageData(data, forBookId: tempBookId) {
                            coverURL = savedURL.absoluteString  // Konwertuj na String dla Book
                        }
                    }
                }
            }
        }
    }
}
