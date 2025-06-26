//ChatGPT
import Foundation
import SwiftUI

class ColorSchemeService: ObservableObject {
    @Published var currentScheme: AppColorScheme

    static let allSchemes: [AppColorScheme] = [
        AppColorScheme(name: "Graphite Light", background: "#F8F8F8", primaryText: "#1C1C1E", secondaryText: "#6D6D72", accent: "#007AFF", uiElement: "#E5E5EA"),
        AppColorScheme(name: "Graphite Dark", background: "#1C1C1E", primaryText: "#FFFFFF", secondaryText: "#A1A1A6", accent: "#0A84FF", uiElement: "#2C2C2E"),
        AppColorScheme(name: "Solarized Light", background: "#FDF6E3", primaryText: "#586E75", secondaryText: "#93A1A1", accent: "#268BD2", uiElement: "#EEE8D5"),
        AppColorScheme(name: "Solarized Dark", background: "#002B36", primaryText: "#839496", secondaryText: "#586E75", accent: "#268BD2", uiElement: "#073642"),
        AppColorScheme(name: "Red Ochre", background: "#FFF8F6", primaryText: "#3C1F1F", secondaryText: "#7E4B4B", accent: "#D72638", uiElement: "#F3D3D3"),
        AppColorScheme(name: "Midnight Blue", background: "#0D1117", primaryText: "#C9D1D9", secondaryText: "#8B949E", accent: "#58A6FF", uiElement: "#161B22"),
        AppColorScheme(name: "Forest Green", background: "#F4F7F5", primaryText: "#1B2B2A", secondaryText: "#5A6B6A", accent: "#228B22", uiElement: "#DCE4DF"),
        AppColorScheme(name: "Sand Dune", background: "#F5F1EB", primaryText: "#4E3B31", secondaryText: "#8C7B6A", accent: "#C19A6B", uiElement: "#E3D5C0"),
        AppColorScheme(name: "Mauve Twilight", background: "#F8F5FB", primaryText: "#3A2D4D", secondaryText: "#827396", accent: "#9B5DE5", uiElement: "#E6E0F1"),
        AppColorScheme(name: "Nord", background: "#2E3440", primaryText: "#D8DEE9", secondaryText: "#81A1C1", accent: "#88C0D0", uiElement: "#3B4252"),
        AppColorScheme(name: "Nordic Ice", background: "#ECEFF4", primaryText: "#2E3440", secondaryText: "#4C566A", accent: "#5E81AC", uiElement: "#D8DEE9")
    ]

    private let selectedSchemeKey = "selectedColorSchemeName"

    init() {
        let savedName = UserDefaults.standard.string(forKey: selectedSchemeKey) ?? "Graphite Light"
        if let matched = Self.allSchemes.first(where: { $0.name == savedName }) {
            self.currentScheme = matched
        } else {
            self.currentScheme = Self.allSchemes[0]
        }
    }

    func selectScheme(_ scheme: AppColorScheme) {
        currentScheme = scheme
        UserDefaults.standard.set(scheme.name, forKey: selectedSchemeKey)
        updateAppAppearance()
    }

    private func updateAppAppearance() {
        if #available(iOS 15.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            window.overrideUserInterfaceStyle = currentScheme.isDark ? .dark : .light
        } else {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = currentScheme.isDark ? .dark : .light
        }
    }
}
