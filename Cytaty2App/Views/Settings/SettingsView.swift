import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: QuoteViewModel
    @Environment(\.appColors) var appColors
    @State private var showingImportSheet = false
    @State private var showingExportSheet = false
    @State private var showingColorSchemeSelection = false
    @State private var showingTestColorView = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Dane")) {
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(appColors.accentColor)
                            Text("Importuj dane")
                                .foregroundColor(appColors.primaryTextColor)
                        }
                    }
                    .sheet(isPresented: $showingImportSheet) {
                        ImportView()
                    }

                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(appColors.accentColor)
                            Text("Eksportuj dane")
                                .foregroundColor(appColors.primaryTextColor)
                        }
                    }
                    .sheet(isPresented: $showingExportSheet) {
                        ExportView()
                    }
                }

                Section(header: Text("Wygląd")) {
                    Button(action: {
                        showingColorSchemeSelection = true
                    }) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(appColors.accentColor)
                            Text("Wybierz schemat kolorów")
                                .foregroundColor(appColors.primaryTextColor)
                        }
                    }
                    .sheet(isPresented: $showingColorSchemeSelection) {
                        ColorSchemeSelectionView()
                    }

                    Button(action: {
                        showingTestColorView = true
                    }) {
                        HStack {
                            Image(systemName: "eyedropper.halffull")
                                .foregroundColor(appColors.accentColor)
                            Text("Testuj kolory")
                                .foregroundColor(appColors.primaryTextColor)
                        }
                    }
                    .sheet(isPresented: $showingTestColorView) {
                        TestColorView()
                    }
                }

                Section(header: Text("Informacje")) {
                    HStack {
                        Text("Wersja aplikacji")
                        Spacer()
                        Text("1.0.0") // Możesz pobrać z Bundle.main.infoDictionary
                    }
                    .foregroundColor(appColors.primaryTextColor)
                }
            }
            .navigationTitle("Ustawienia")
            .navigationBarTitleDisplayMode(.inline)
            .background(appColors.backgroundColor)
        }
    }
}
