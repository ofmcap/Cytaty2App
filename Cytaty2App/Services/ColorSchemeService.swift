// Cytaty2App/Services/ColorSchemeService.swift
import Foundation
import SwiftUI

class ColorSchemeService: ObservableObject {
    @Published var currentScheme: AppColorScheme
    @AppStorage("selectedColorSchemeName") private var selectedSchemeName: String = "Graphite Light"
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false

    static let allSchemes: [AppColorScheme] = [
        // Graphite
        AppColorScheme(name: "Graphite Light", displayName: "Graphite", background: "#F8F8F8", primaryText: "#1C1C1E", secondaryText: "#6D6D72", accent: "#007AFF", uiElement: "#E5E5EA", isDarkVariant: false),
        AppColorScheme(name: "Graphite Dark", displayName: "Graphite", background: "#1C1C1E", primaryText: "#FFFFFF", secondaryText: "#A1A1A6", accent: "#0A84FF", uiElement: "#2C2C2E", isDarkVariant: true),
        
        // Solarized
        AppColorScheme(name: "Solarized Light", displayName: "Solarized", background: "#FDF6E3", primaryText: "#586E75", secondaryText: "#93A1A1", accent: "#268BD2", uiElement: "#EEE8D5", isDarkVariant: false),
        AppColorScheme(name: "Solarized Dark", displayName: "Solarized", background: "#002B36", primaryText: "#839496", secondaryText: "#586E75", accent: "#268BD2", uiElement: "#073642", isDarkVariant: true),
        
        // Red Ochre
        AppColorScheme(name: "Red Ochre Light", displayName: "Red Ochre", background: "#FFF8F6", primaryText: "#3C1F1F", secondaryText: "#7E4B4B", accent: "#D72638", uiElement: "#F3D3D3", isDarkVariant: false),
        AppColorScheme(name: "Red Ochre Dark", displayName: "Red Ochre", background: "#2B1717", primaryText: "#E8C4C4", secondaryText: "#B8888B", accent: "#FF4757", uiElement: "#3D2424", isDarkVariant: true),
        
        // Midnight Blue
        AppColorScheme(name: "Midnight Blue Light", displayName: "Midnight Blue", background: "#F0F4F8", primaryText: "#1A365D", secondaryText: "#4A5568", accent: "#3182CE", uiElement: "#E2E8F0", isDarkVariant: false),
        AppColorScheme(name: "Midnight Blue Dark", displayName: "Midnight Blue", background: "#0D1117", primaryText: "#C9D1D9", secondaryText: "#8B949E", accent: "#58A6FF", uiElement: "#161B22", isDarkVariant: true),
        
        // Forest Green
        AppColorScheme(name: "Forest Green Light", displayName: "Forest Green", background: "#F4F7F5", primaryText: "#1B2B2A", secondaryText: "#5A6B6A", accent: "#228B22", uiElement: "#DCE4DF", isDarkVariant: false),
        AppColorScheme(name: "Forest Green Dark", displayName: "Forest Green", background: "#1A2B1A", primaryText: "#C8D8C8", secondaryText: "#98A898", accent: "#4CAF50", uiElement: "#243324", isDarkVariant: true),
        
        // Sand Dune
        AppColorScheme(name: "Sand Dune Light", displayName: "Sand Dune", background: "#F5F1EB", primaryText: "#4E3B31", secondaryText: "#8C7B6A", accent: "#C19A6B", uiElement: "#E3D5C0", isDarkVariant: false),
        AppColorScheme(name: "Sand Dune Dark", displayName: "Sand Dune", background: "#2D2319", primaryText: "#E8D5C4", secondaryText: "#B8A898", accent: "#D4B895", uiElement: "#3D3025", isDarkVariant: true),
        
        // Mauve Twilight
        AppColorScheme(name: "Mauve Twilight Light", displayName: "Mauve Twilight", background: "#F8F5FB", primaryText: "#3A2D4D", secondaryText: "#827396", accent: "#9B5DE5", uiElement: "#E6E0F1", isDarkVariant: false),
        AppColorScheme(name: "Mauve Twilight Dark", displayName: "Mauve Twilight", background: "#2A1D3D", primaryText: "#E5D5F5", secondaryText: "#B895C8", accent: "#B575ED", uiElement: "#3D2A52", isDarkVariant: true),
        
        // Nord
        AppColorScheme(name: "Nord Light", displayName: "Nord", background: "#ECEFF4", primaryText: "#2E3440", secondaryText: "#4C566A", accent: "#5E81AC", uiElement: "#D8DEE9", isDarkVariant: false),
        AppColorScheme(name: "Nord Dark", displayName: "Nord", background: "#2E3440", primaryText: "#D8DEE9", secondaryText: "#81A1C1", accent: "#88C0D0", uiElement: "#3B4252", isDarkVariant: true)
    ]
    
    // Grupy schematów według typu bazowego
    static var schemeGroups: [String: [AppColorScheme]] {
        Dictionary(grouping: allSchemes) { $0.displayName }
    }

    init() {
        // Najpierw inicjalizujemy currentScheme domyślną wartością
        self.currentScheme = Self.allSchemes[0]
        
        // Następnie ładujemy zapisany schemat
        loadSavedScheme()
    }
    
    private func loadSavedScheme() {
        let savedName = UserDefaults.standard.string(forKey: "selectedColorSchemeName") ?? "Graphite Light"
        if let matched = Self.allSchemes.first(where: { $0.name == savedName }) {
            self.currentScheme = matched
        }
        
        // Synchronizacja @AppStorage z faktyczną wartością
        selectedSchemeName = currentScheme.name
        isDarkModeEnabled = currentScheme.isDarkVariant
    }

    func selectScheme(_ scheme: AppColorScheme) {
        currentScheme = scheme
        selectedSchemeName = scheme.name
        isDarkModeEnabled = scheme.isDarkVariant
        
        // Automatyczne zaktualizowanie UI poprzez @Published
        objectWillChange.send()
    }
    
    func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        
        // Znajdź odpowiedni wariant (jasny/ciemny) aktualnego schematu
        let targetIsDark = isDarkModeEnabled
        let baseDisplayName = currentScheme.displayName
        
        if let targetScheme = Self.allSchemes.first(where: {
            $0.displayName == baseDisplayName && $0.isDarkVariant == targetIsDark
        }) {
            selectScheme(targetScheme)
        }
    }
}
