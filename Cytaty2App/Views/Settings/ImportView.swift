import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @State private var importSuccess = false
    @State private var importError: String?
    @State private var isSelecting = false
    @State private var selectedURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if importSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .padding()
                    
                    Text("Import zakończony pomyślnie")
                        .font(.title2)
                    
                    Text("Twoje dane zostały zaimportowane")
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Zamknij") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                } else if let error = importError {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Błąd importu")
                        .font(.title2)
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Wybierz inny plik") {
                        isSelecting = true
                    }
                    .buttonStyle(.borderedProminent)
                } else if selectedURL != nil {
                    ProgressView()
                        .padding()
                    
                    Text("Importowanie danych...")
                        .font(.title2)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text("Wybierz plik JSON do importu")
                        .font(.title2)
                    
                    Text("Wybierz plik zawierający dane do zaimportowania")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Wybierz plik") {
                        isSelecting = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Import danych")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isSelecting) {
                DocumentPicker(selectedURL: $selectedURL)
            }
           // .onChange(of: selectedURL) { url in
           //     if url != nil {
           //         importData()
           //     }
           // }
            
            // Nowy kod zgodny z iOS 17:
            #if compiler(>=5.9) && canImport(SwiftUI)
            .onChange(of: selectedURL) { oldURL, newURL in
                if newURL != nil {
                    importData()
                }
            }
            #else
            .onChange(of: selectedURL) { url in
                if url != nil {
                    importData()
                }
            }
            #endif
            
            
        }
    }
    
    private func importData() {
        guard let url = selectedURL else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importedBooks = try decoder.decode([Book].self, from: data)
            
            viewModel.books = importedBooks
            viewModel.saveBooks()
            importSuccess = true
        } catch {
            importError = "Nie udało się zaimportować danych: \(error.localizedDescription)"
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedURL = url
        }
    }
}
