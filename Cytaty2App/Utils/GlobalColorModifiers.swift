// Cytaty2App/Utils/GlobalColorModifiers.swift
import SwiftUI

// Struktura przechowująca globalne mapowania kolorów
struct GlobalColorSettings {
    // Tutaj definiujesz, które systemowe kolory mają być zastąpione
    static var colorMappings: [String: AppColorMapping] = [
        "gray": .systemGray,           // .gray → appColors.secondaryTextColor
        "blue": .systemBlue,           // .blue → appColors.accentColor
        "primary": .primary,           // .primary → appColors.primaryTextColor
        "secondary": .secondary,       // .secondary → appColors.secondaryTextColor
        "background": .background,     // tła
        "accent": .accent,             // akcenty
        "red": .systemRed,            // czerwony pozostaje systemowy
        "green": .systemGreen,        // zielony pozostaje systemowy
        "orange": .systemOrange,      // pomarańczowy pozostaje systemowy
        "purple": .systemPurple,      // fioletowy pozostaje systemowy
        "yellow": .systemYellow       // żółty pozostaje systemowy
    ]
    
    // Metoda do zmiany mapowania globalnie
    static func setMapping(for colorName: String, to mapping: AppColorMapping) {
        colorMappings[colorName] = mapping
    }
    
    // Metoda do resetowania mapowania do systemowego
    static func resetMapping(for colorName: String) {
        switch colorName {
        case "gray":
            colorMappings["gray"] = .systemGray
        case "blue":
            colorMappings["blue"] = .systemBlue
        case "primary":
            colorMappings["primary"] = .primary
        case "secondary":
            colorMappings["secondary"] = .secondary
        default:
            break
        }
    }
}

// Environment key dla globalnych ustawień kolorów
struct GlobalColorSettingsKey: EnvironmentKey {
    static let defaultValue = GlobalColorSettings()
}

extension EnvironmentValues {
    var globalColorSettings: GlobalColorSettings {
        get { self[GlobalColorSettingsKey.self] }
        set { self[GlobalColorSettingsKey.self] = newValue }
    }
}

// Rozszerzenie Color z automatycznym mapowaniem
extension Color {
    // Metody zastępujące systemowe kolory
    static func adaptiveGray(scheme: AppColorScheme) -> Color {
        let mapping = GlobalColorSettings.colorMappings["gray"] ?? .systemGray
        return mapping.color(for: scheme)
    }
    
    static func adaptiveBlue(scheme: AppColorScheme) -> Color {
        let mapping = GlobalColorSettings.colorMappings["blue"] ?? .systemBlue
        return mapping.color(for: scheme)
    }
    
    static func adaptivePrimary(scheme: AppColorScheme) -> Color {
        let mapping = GlobalColorSettings.colorMappings["primary"] ?? .primary
        return mapping.color(for: scheme)
    }
    
    static func adaptiveSecondary(scheme: AppColorScheme) -> Color {
        let mapping = GlobalColorSettings.colorMappings["secondary"] ?? .secondary
        return mapping.color(for: scheme)
    }
}
