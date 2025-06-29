import SwiftUI

struct ColorSchemeSelectionView: View {
    @EnvironmentObject var colorSchemeService: ColorSchemeService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(ColorSchemeService.schemeGroups.keys.sorted()), id: \.self) { groupName in
                    Section(header: Text(groupName)) {
                        if let schemes = ColorSchemeService.schemeGroups[groupName] {
                            ForEach(schemes.sorted { !$0.isDarkVariant && $1.isDarkVariant }, id: \.name) { scheme in
                                ColorSchemeRow(
                                    scheme: scheme,
                                    isSelected: scheme.name == colorSchemeService.currentScheme.name
                                ) {
                                    colorSchemeService.selectScheme(scheme)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Schemat kolorów")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Zaktualizowany komponent dla wiersza schematu kolorów
struct ColorSchemeRow: View {
    let scheme: AppColorScheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        // CAŁY WIERSZ JEST TERAZ PRZYCISKIEM
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Podgląd kolorów
                ColorPreview(scheme: scheme)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(scheme.isDarkVariant ? "Ciemny" : "Jasny")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    
                    Text(scheme.isDarkVariant ? "Wariant ciemny" : "Wariant jasny")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle()) // Ważne: sprawia, że cały obszar jest klikalny
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Zaktualizowany komponent podglądu kolorów
struct ColorPreview: View {
    let scheme: AppColorScheme
    
    var body: some View {
        HStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 4)
                .fill(scheme.backgroundColor)
                .frame(width: 24, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            RoundedRectangle(cornerRadius: 4)
                .fill(scheme.accentColor)
                .frame(width: 24, height: 24)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(scheme.uiElementColor)
                .frame(width: 24, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct ColorSchemeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ColorSchemeSelectionView()
            .environmentObject(ColorSchemeService())
    }
}
