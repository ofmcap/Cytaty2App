// Cytaty2App/Utils/ColorMapping.swift
import SwiftUI

// Enum definiujący mapowania kolorów
enum AppColorMapping {
    case primary        // Główny tekst
    case secondary      // Drugorzędny tekst
    case accent         // Kolor akcentowy
    case background     // Tło
    case uiElement      // Elementy UI
    case systemGray     // Mapowanie dla .gray
    case systemBlue     // Mapowanie dla .blue
    case systemRed      // Mapowanie dla .red
    case systemGreen    // Mapowanie dla .green
    case systemOrange   // Mapowanie dla .orange
    case systemPurple   // Mapowanie dla .purple
    case systemYellow   // Mapowanie dla .yellow
    
    // Funkcja zwracająca odpowiedni kolor ze schematu
    func color(for scheme: AppColorScheme) -> Color {
        switch self {
        case .primary:
            return scheme.primaryTextColor
        case .secondary:
            return scheme.secondaryTextColor
        case .accent:
            return scheme.accentColor
        case .background:
            return scheme.backgroundColor
        case .uiElement:
            return scheme.uiElementColor
        case .systemGray:
            return scheme.secondaryTextColor // Mapowane na secondaryText
        case .systemBlue:
            return scheme.accentColor // Mapowane na accent
        case .systemRed:
            return Color.red // Pozostaw systemowy czerwony
        case .systemGreen:
            return Color.green // Pozostaw systemowy zielony
        case .systemOrange:
            return Color.orange
        case .systemPurple:
            return Color.purple
        case .systemYellow:
            return Color.yellow
        }
    }
}

// Rozszerzenie Color z metodami mapowania
extension Color {
    // Statyczne metody dla łatwego dostępu
    static func appColor(_ mapping: AppColorMapping, scheme: AppColorScheme) -> Color {
        return mapping.color(for: scheme)
    }
    
    // Mapowane kolory z prostymi nazwami
    static func appPrimary(scheme: AppColorScheme) -> Color {
        return AppColorMapping.primary.color(for: scheme)
    }
    
    static func appSecondary(scheme: AppColorScheme) -> Color {
        return AppColorMapping.secondary.color(for: scheme)
    }
    
    static func appAccent(scheme: AppColorScheme) -> Color {
        return AppColorMapping.accent.color(for: scheme)
    }
    
    static func appBackground(scheme: AppColorScheme) -> Color {
        return AppColorMapping.background.color(for: scheme)
    }
    
    static func appUIElement(scheme: AppColorScheme) -> Color {
        return AppColorMapping.uiElement.color(for: scheme)
    }
    
    // Mapowane systemowe kolory
    static func appGray(scheme: AppColorScheme) -> Color {
        return AppColorMapping.systemGray.color(for: scheme)
    }
    
    static func appBlue(scheme: AppColorScheme) -> Color {
        return AppColorMapping.systemBlue.color(for: scheme)
    }
}
