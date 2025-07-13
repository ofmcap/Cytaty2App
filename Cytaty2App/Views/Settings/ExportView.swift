import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) private var appColors

    @State private var exportMessage: String = ""
    @State private var showingShareSheet: Bool = false
    @State private var exportedFileURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 80))
                    .foregroundColor(appColors.accentColor)

                Text("Eksportuj dane")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(appColors.primaryTextColor)

                Text("Wyeksportuj wszystkie swoje książki i cytaty do pliku JSON.")
                    .font(.body)
                    .foregroundColor(appColors.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    exportData()
                }) {
                    Label("Eksportuj dane", systemImage: "doc.badge.plus")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(appColors.accentColor)
                        .foregroundColor(appColors.primaryTextColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if !exportMessage.isEmpty {
                    Text(exportMessage)
                        .font(.subheadline)
                        .foregroundColor(appColors.primaryTextColor)
                        .padding()
                        .background(appColors.uiElementColor)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Eksportuj")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zamknij") {
                        dismiss()
                    }
                }
            }
            .background(appColors.backgroundColor)
            .sheet(isPresented: $showingShareSheet, content: {
                if let url = exportedFileURL {
                    ShareSheet(activityItems: [url])
                }
            })
        }
    }

    private func exportData() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(viewModel.books)

            let filename = "cytaty2app_export_\(Date().timeIntervalSince1970).json"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(filename)

            try data.write(to: fileURL)
            exportedFileURL = fileURL
            showingShareSheet = true
            exportMessage = "Pomyślnie wyeksportowano dane."
        } catch {
            exportMessage = "Błąd eksportu: \(error.localizedDescription)"
        }
    }
}

// Pomocnicza struktura do ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
}
