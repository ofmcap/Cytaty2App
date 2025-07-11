import SwiftUI
import PhotosUI

struct AddEditBookView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.appColors) private var appColors

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var isbn: String = ""
    @State private var publishYear: String = ""
    @State private var coverImage: UIImage?
    @State private var coverImageItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var existingCoverURL: String? = nil

    let isEditing: Bool
    var book: Book?
    var onSave: (Book) -> Void

    init(isEditing: Bool = false, book: Book? = nil, onSave: @escaping (Book) -> Void) {
        self.isEditing = isEditing
        self.book = book
        self.onSave = onSave

        if let book = book {
            _title = State(initialValue: book.title)
            _author = State(initialValue: book.author)
            _isbn = State(initialValue: book.isbn ?? "")
            _publishYear = State(initialValue: book.publishYear != nil ? "\(book.publishYear!)" : "")
            _existingCoverURL = State(initialValue: book.coverURL)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: sectionHeader("Informacje podstawowe")) {
                    TextField("Tytuł książki", text: $title)
                        .foregroundColor(appColors.primaryTextColor)
                    TextField("Autor", text: $author)
                        .foregroundColor(appColors.primaryTextColor)
                }
                .listRowBackground(appColors.backgroundColor)

                Section(header: sectionHeader("Informacje dodatkowe")) {
                    TextField("ISBN", text: $isbn)
                        .keyboardType(.numbersAndPunctuation)
                        .foregroundColor(appColors.primaryTextColor)

                    TextField("Rok wydania", text: $publishYear)
                        .keyboardType(.numberPad)
                        .foregroundColor(appColors.primaryTextColor)
                }
                .listRowBackground(appColors.backgroundColor)

                Section(header: sectionHeader("Okładka")) {
                    VStack {
                        coverImageView()

                        HStack {
                            Spacer()

                            PhotosPicker("Wybierz z galerii", selection: $coverImageItem, matching: .images)
                                .buttonStyle(.bordered)
                                .foregroundColor(appColors.accentColor)
                                .tint(appColors.accentColor)

                            if coverImage != nil || existingCoverURL != nil {
                                Button("Usuń") {
                                    coverImage = nil
                                    coverImageItem = nil
                                    existingCoverURL = nil
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            }

                            Spacer()
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                .listRowBackground(appColors.backgroundColor)
            }
            .background(appColors.backgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle(isEditing ? "Edytuj książkę" : "Dodaj książkę")
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
                        saveBook()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                    .foregroundColor(title.isEmpty || author.isEmpty ? appColors.secondaryTextColor : appColors.accentColor)
                }
            }
            .onChange(of: coverImageItem) { loadImage() }
            .onAppear {
                loadExistingCoverImage()
            }
        }
    }

    // MARK: - Helper Views

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(appColors.secondaryTextColor)
            .font(.caption)
            .textCase(.uppercase)
    }

    private func coverImageView() -> some View {
        Group {
            if let coverImage = coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding(.vertical)
            } else if let existingCoverURL = existingCoverURL {
                AsyncImage(url: getFullCoverURL(from: existingCoverURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(appColors.accentColor)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.vertical)
                    case .failure:
                        Image(systemName: "book.closed")
                            .font(.system(size: 80))
                            .foregroundColor(appColors.secondaryTextColor)
                            .padding()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "book.closed")
                    .font(.system(size: 80))
                    .foregroundColor(appColors.secondaryTextColor)
                    .padding()
            }
        }
    }

    // MARK: - Helper Functions

    private func getFullCoverURL(from coverURL: String) -> URL? {
        if coverURL.hasPrefix("http") {
            return URL(string: coverURL)
        } else {
            // Względna ścieżka w dokumentach
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent(coverURL)
        }
    }

    private func loadExistingCoverImage() {
        if let coverURL = existingCoverURL, let url = getFullCoverURL(from: coverURL) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.coverImage = image
                        }
                    }
                } catch {
                    print("Błąd ładowania obrazu: \(error)")
                }
            }
        }
    }

    private func loadImage() {
        Task {
            if let coverImageItem = coverImageItem,
               let data = try? await coverImageItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.coverImage = image
                    self.existingCoverURL = nil // Usuwamy stary URL, jeśli dodajemy nowy obraz
                }
            }
        }
    }

    private func saveBook() {
        // Określamy końcowy URL okładki
        var finalCoverURL = existingCoverURL

        // Jeśli mamy nowy obraz, zapisujemy go i uzyskujemy nowy URL
        if let image = coverImage, existingCoverURL == nil {
            // Usuwamy starą okładkę jeśli istnieje i to lokalna ścieżka
            if let existingURL = book?.coverURL, !existingURL.hasPrefix("http") {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let oldFileURL = documentsDirectory.appendingPathComponent(existingURL)
                try? FileManager.default.removeItem(at: oldFileURL)
                print("🗑️ Usunięto starą okładkę: \(existingURL)")
            }

            // Zapisujemy nową okładkę
            let fileName = "\(book?.id ?? UUID().uuidString).jpg"
            if let relativePath = DefaultStorageService().saveCoverImage(image, fileName: fileName) {
                finalCoverURL = relativePath
                print("✅ Zapisano nową okładkę: \(relativePath)")
            } else {
                print("❌ Nie udało się zapisać okładki")
                finalCoverURL = nil
            }
        }

        let newBook = Book(
            id: book?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            coverURL: finalCoverURL,
            isbn: isbn.isEmpty ? nil : isbn,
            publishYear: Int(publishYear),
            addedDate: book?.addedDate ?? Date(),
            quotes: book?.quotes ?? []
        )

        onSave(newBook)
        dismiss()
    }
}
