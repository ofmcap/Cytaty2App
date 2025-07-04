// Cytaty2App/Utils/ViewColorExtensions.swift
import SwiftUI

extension View {
    // Metody zastępujące standardowe metody SwiftUI
    func adaptiveForegroundColor(_ colorName: String) -> some View {
        self.modifier(AdaptiveColorModifier(colorName: colorName, isBackground: false))
    }
    
    func adaptiveBackground(_ colorName: String) -> some View {
        self.modifier(AdaptiveColorModifier(colorName: colorName, isBackground: true))
    }
    
    // Szybkie metody dla często używanych kolorów - GŁÓWNE METODY DO UŻYWANIA
    func grayText() -> some View {
        self.adaptiveForegroundColor("gray")
    }
    
    func primaryText() -> some View {
        self.adaptiveForegroundColor("primary")
    }
    
    func secondaryText() -> some View {
        self.adaptiveForegroundColor("secondary")
    }
    
    func accentText() -> some View {
        self.adaptiveForegroundColor("accent")
    }
    
    func blueText() -> some View {
        self.adaptiveForegroundColor("blue")
    }
    
    func redText() -> some View {
        self.adaptiveForegroundColor("red")
    }
    
    func greenText() -> some View {
        self.adaptiveForegroundColor("green")
    }
    
    func orangeText() -> some View {
        self.adaptiveForegroundColor("orange")
    }
    
    func purpleText() -> some View {
        self.adaptiveForegroundColor("purple")
    }
    
    func yellowText() -> some View {
        self.adaptiveForegroundColor("yellow")
    }
    
    // Metody dla tła
    func grayBackground() -> some View {
        self.adaptiveBackground("gray")
    }
    
    func primaryBackground() -> some View {
        self.adaptiveBackground("primary")
    }
    
    func secondaryBackground() -> some View {
        self.adaptiveBackground("secondary")
    }
    
    func accentBackground() -> some View {
        self.adaptiveBackground("accent")
    }
    
    func appBackground() -> some View {
        self.adaptiveBackground("background")
    }
    
    func uiElementBackground() -> some View {
        self.adaptiveBackground("uiElement")
    }
}

struct AdaptiveColorModifier: ViewModifier {
    let colorName: String
    let isBackground: Bool
    @Environment(\.appColors) var appColors
    
    func body(content: Content) -> some View {
        let mapping = GlobalColorSettings.colorMappings[colorName] ?? .primary
        let color = mapping.color(for: appColors)
        
        if isBackground {
            content.background(color)
        } else {
            content.foregroundColor(color)
        }
    }
}
