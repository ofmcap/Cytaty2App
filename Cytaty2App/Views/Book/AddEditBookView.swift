import SwiftUI
import PhotosUI

struct AddEditBookView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var isbn: String = ""
    @State private var publishYear: String = ""
    @State private var coverImage: UIImage?
    @State private var coverImageItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var existingCoverURL: String? = nil // Dla przechowywania oryginalnego URL
    
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
                Section(header: Text("Informacje podstawowe")) {
                    TextField("Tytuł książki", text: $title)
                    TextField("Autor", text: $author)
                }
                
                Section(header: Text("Informacje dodatkowe")) {
                    TextField("ISBN", text: $isbn)
                        .keyboardType(.numbersAndPunctuation)
                    
                    TextField("Rok wydania", text: $publishYear)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Okładka")) {
                    VStack {
                        if let coverImage = coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .cornerRadius(8)
                                .padding(.vertical)
                        } else if let existingCoverURL = existingCoverURL, let url = URL(string: existingCoverURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
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
                                        .foregroundColor(.gray)
                                        .padding()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "book.closed")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                                .padding()
                        }
                        
                        HStack {
                            Spacer()
                            
                            PhotosPicker("Wybierz z galerii", selection: $coverImageItem, matching: .images)
                                .buttonStyle(.bordered)
                            
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
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
            .onChange(of: coverImageItem) { loadImage() }
            .onAppear {
                // Ładujemy istniejący obrazek okładki
                loadExistingCoverImage()
            }
        }
    }
    
    private func loadExistingCoverImage() {
        if let coverURL = existingCoverURL, let url = URL(string: coverURL) {
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
            if let data = image.jpegData(compressionQuality: 0.8) {
                let fileName = "\(UUID().uuidString).jpg"
                
                // Zapisujemy w folderze dokumentów aplikacji
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: fileURL)
                    
                    // Używamy względnej ścieżki zamiast absolutnej
                    let relativePath = "BookCovers/\(fileName)"
                    
                    // Upewniamy się, że folder BookCovers istnieje
                    let coverDirectory = documentsDirectory.appendingPathComponent("BookCovers")
                    if !FileManager.default.fileExists(atPath: coverDirectory.path) {
                        try FileManager.default.createDirectory(at: coverDirectory, withIntermediateDirectories: true)
                    }
                    
                    let finalURL = documentsDirectory.appendingPathComponent(relativePath)
                    try data.write(to: finalURL)
                    
                    finalCoverURL = relativePath
                } catch {
                    print("Błąd zapisywania obrazu: \(error)")
                }
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
