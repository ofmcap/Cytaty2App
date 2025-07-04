// Cytaty2App/Cytaty2AppApp.swift
import SwiftUI

@main
struct Cytaty2AppApp: App {
    @StateObject private var viewModel = QuoteViewModel()
    @StateObject private var colorSchemeService = ColorSchemeService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(colorSchemeService)
                .appColorScheme(colorSchemeService.currentScheme)
                .onAppear {
                    setupGlobalColorMappings()
                }
        }
    }
    
    private func setupGlobalColorMappings() {
        // Tutaj możesz ustawić globalne mapowania
        // Przykład: zamień .gray na secondaryTextColor
        GlobalColorSettings.setMapping(for: "gray", to: .secondary)
        
        // Przykład: zamień .blue na accentColor
        GlobalColorSettings.setMapping(for: "blue", to: .accent)
        
        // Jeśli chcesz, żeby .primary używał primaryTextColor z schematu
        GlobalColorSettings.setMapping(for: "primary", to: .primary)
        
        // Jeśli chcesz, żeby .secondary używał secondaryTextColor z schematu
        GlobalColorSettings.setMapping(for: "secondary", to: .secondary)
    }
}
