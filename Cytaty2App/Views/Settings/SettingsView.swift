// Cytaty2App/Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @EnvironmentObject var colorSchemeService: ColorSchemeService
    @Environment(\.appColors) var appColors
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingResetAlert = false
    @State private var showingColorSchemeSelection = false
    
    var body: some View {
        Form {
            Section(header: Text("Wygląd")) {
                // Wybór schematu kolorystycznego
                Button(action: {
                    showingColorSchemeSelection = true
                }) {
                    HStack {
                        Text("Schemat kolorów")
                            .foregroundColor(appColors.primaryTextColor)
                        
                        Spacer()
                        
                        // Podgląd aktualnego schematu
                        ColorPreview(scheme: colorSchemeService.currentScheme)
                        
                        Text(colorSchemeService.currentScheme.displayName)
                            .foregroundColor(appColors.secondaryTextColor)
                            .font(.caption)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(appColors.secondaryTextColor)
                    }
                }
                
                // Przełącznik trybu ciemny/jasny
                HStack {
                    Text("Tryb ciemny")
                        .foregroundColor(appColors.primaryTextColor)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { colorSchemeService.currentScheme.isDarkVariant },
                        set: { _ in colorSchemeService.toggleDarkMode() }
                    ))
                    .tint(appColors.accentColor)
                }
            }
            
            Section(header: Text("Dane")) {
                HStack {
                    Text("Liczba książek")
                        .foregroundColor(appColors.primaryTextColor)
                    Spacer()
                    Text("\(viewModel.books.count)")
                        .foregroundColor(appColors.secondaryTextColor)
                }
                
                HStack {
                    Text("Liczba cytatów")
                        .foregroundColor(appColors.primaryTextColor)
                    Spacer()
                    let quoteCount = viewModel.books.reduce(0) { $0 + $1.quotes.count }
                    Text("\(quoteCount)")
                        .foregroundColor(appColors.secondaryTextColor)
                }
                
                Button("Eksportuj dane") {
                    showingExportSheet = true
                }
                .foregroundColor(appColors.accentColor)
                
                Button("Importuj dane") {
                    showingImportSheet = true
                }
                .foregroundColor(appColors.accentColor)
                
                Button("Resetuj wszystkie dane") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
            }
            
            Section(header: Text("O aplikacji")) {
                HStack {
                    Text("Wersja")
                        .foregroundColor(appColors.primaryTextColor)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(appColors.secondaryTextColor)
                }
                
                Link("Polityka prywatności", destination: URL(string: "https://example.com/privacy")!)
                    .foregroundColor(appColors.accentColor)
                Link("Warunki użytkowania", destination: URL(string: "https://example.com/terms")!)
                    .foregroundColor(appColors.accentColor)
                Link("Kontakt", destination: URL(string: "mailto:contact@example.com")!)
                    .foregroundColor(appColors.accentColor)
            }
        }
        .background(appColors.backgroundColor)
        .scrollContentBackground(.hidden) // Ukryj domyślne tło Form
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
        .sheet(isPresented: $showingColorSchemeSelection) {
            ColorSchemeSelectionView()
        }
    }
    
    private func resetAllData() {
        viewModel.books = []
        viewModel.saveBooks()
    }
}
