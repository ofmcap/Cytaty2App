import SwiftUI

struct ExportView: View {
    let books: [Book]
    @Environment(\.dismiss) var dismiss
    @State private var exportSuccess = false
    @State private var exportError: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if exportSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .padding()
                    
                    Text("Eksport zakończony pomyślnie")
                        .font(.title2)
                    
                    Text("Dane zostały zapisane do pliku w folderze Dokumenty")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Zamknij") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                } else if let error = exportError {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Błąd eksportu")
                        .font(.title2)
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Spróbuj ponownie") {
                        exportData()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    ProgressView()
                        .padding()
                    
                    Text("Eksportowanie danych...")
                        .font(.title2)
                }
            }
            .padding()
            .navigationTitle("Eksport danych")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                exportData()
            }
        }
    }
    
    private func exportData() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(books)
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "cytaty_eksport_\(formattedDate()).json"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            exportSuccess = true
        } catch {
            exportError = "Nie udało się zapisać danych: \(error.localizedDescription)"
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        return formatter.string(from: Date())
    }
}
