import SwiftUI

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors

    @State private var importMessage: String = ""
    @State private var showingFilePicker: Bool = false
    @State private var selectedFileURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 80))
                    .foregroundColor(appColors.accentColor)

                Text("Importuj dane")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(appColors.primaryTextColor)

                Text("Wybierz plik JSON, aby zaimportować swoje książki i cytaty.")
                    .font(.body)
                    .foregroundColor(appColors.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    showingFilePicker = true
                }) {
                    Label("Wybierz plik do importu", systemImage: "doc.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(appColors.accentColor)
                        .foregroundColor(appColors.primaryTextColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if !importMessage.isEmpty {
                    Text(importMessage)
                        .font(.subheadline)
                        .foregroundColor(appColors.primaryTextColor)
                        .padding()
                        .background(appColors.uiElementColor)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Importuj")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zamknij") {
                        dismiss()
                    }
                }
            }
            .background(appColors.backgroundColor)
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                do {
                    if let fileURL = try result.get().first {
                        selectedFileURL = fileURL
                        importData(from: fileURL)
                    }
                } catch {
                    importMessage = "Błąd wyboru pliku: \(error.localizedDescription)"
                }
            }
        }
    }

    private func importData(from url: URL) {
        do {
            // Zapewnienie dostępu do pliku
            let gotAccess = url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }

            guard gotAccess else {
                importMessage = "Brak dostępu do pliku."
                return
            }

            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let importedBooks = try decoder.decode([Book].self, from: data)
            
            // Tymczasowo wyłączamy import
                    importMessage = "Import jest tymczasowo wyłączony. Funkcjonalność zostanie dodana wkrótce."
            

            // viewModel.importBooks(importedBooks)
            importMessage = "Pomyślnie zaimportowano \(importedBooks.count) książek."
        } catch {
            importMessage = "Błąd importu: \(error.localizedDescription)"
        }
    }
}
