// Cytaty2App/Utils/ColorEnvironment.swift
import SwiftUI

// Environment Key dla schematów kolorów
struct AppColorEnvironmentKey: EnvironmentKey {
    static let defaultValue = ColorSchemeService.allSchemes[0] // Graphite Light jako domyślny
}

extension EnvironmentValues {
    var appColors: AppColorScheme {
        get { self[AppColorEnvironmentKey.self] }
        set { self[AppColorEnvironmentKey.self] = newValue }
    }
}

// Modyfikator dla łatwego aplikowania kolorów schematu
struct AppColorModifier: ViewModifier {
    let colorScheme: AppColorScheme
    
    func body(content: Content) -> some View {
        content
            .environment(\.appColors, colorScheme)
            .preferredColorScheme(colorScheme.isDarkVariant ? .dark : .light)
    }
}

extension View {
    func appColorScheme(_ scheme: AppColorScheme) -> some View {
        self.modifier(AppColorModifier(colorScheme: scheme))
    }
}
