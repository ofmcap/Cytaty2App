import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingResetAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Wygląd")) {
                Toggle("Tryb ciemny", isOn: $isDarkMode)
                    #if compiler(>=5.9) && canImport(SwiftUI)
                    .onChange(of: isDarkMode) { _, newValue in
                        setAppAppearance(isDark: newValue)
                    }
                    #else
                    .onChange(of: isDarkMode) { newValue in
                        setAppAppearance(isDark: newValue)
                    }
                    #endif
            }
            
            Section(header: Text("Dane")) {
                HStack {
                    Text("Liczba książek")
                    Spacer()
                    Text("\(viewModel.books.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Liczba cytatów")
                    Spacer()
                    let quoteCount = viewModel.books.reduce(0) { $0 + $1.quotes.count }
                    Text("\(quoteCount)")
                        .foregroundColor(.secondary)
                }
                
                Button("Eksportuj dane") {
                    showingExportSheet = true
                }
                
                Button("Importuj dane") {
                    showingImportSheet = true
                }
                
                Button("Resetuj wszystkie dane") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
            }
            
            Section(header: Text("O aplikacji")) {
                HStack {
                    Text("Wersja")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                Link("Polityka prywatności", destination: URL(string: "https://example.com/privacy")!)
                Link("Warunki użytkowania", destination: URL(string: "https://example.com/terms")!)
                Link("Kontakt", destination: URL(string: "mailto:contact@example.com")!)
            }
        }
        .alert("Resetuj dane", isPresented: $showingResetAlert) {
            Button("Anuluj", role: .cancel) { }
            Button("Resetuj", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("Czy na pewno chcesz usunąć wszystkie dane? Ta operacja jest nieodwracalna.")
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(books: viewModel.books)
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportView()
        }
    }
    
    private func setAppAppearance(isDark: Bool) {
        if #available(iOS 15.0, *) {
            // Nowa metoda dla iOS 15+
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            window.overrideUserInterfaceStyle = isDark ? .dark : .light
        } else {
            // Metoda dla starszych wersji iOS
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }
    
    private func resetAllData() {
        viewModel.books = []
        viewModel.saveBooks()
    }
}

