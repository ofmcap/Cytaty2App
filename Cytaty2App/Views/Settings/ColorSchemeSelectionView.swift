import SwiftUI

struct ColorSchemeSelectionView: View {
    @EnvironmentObject var colorSchemeService: ColorSchemeService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ColorSchemeService.allSchemes, id: \.name) { scheme in
                    ColorSchemeRow(
                        scheme: scheme,
                        isSelected: scheme.name == colorSchemeService.currentScheme.name,
                        onSelect: {
                            colorSchemeService.selectScheme(scheme)
                        }
                    )
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

// Wydzielony komponent dla wiersza schematu kolorów
struct ColorSchemeRow: View {
    let scheme: AppColorScheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Podgląd kolorów
                ColorPreview(scheme: scheme)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(scheme.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(scheme.isDark ? "Ciemny motyw" : "Jasny motyw")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Komponent podglądu kolorów
struct ColorPreview: View {
    let scheme: AppColorScheme
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .fill(scheme.backgroundColor)
                .frame(width: 20, height: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            RoundedRectangle(cornerRadius: 4)
                .fill(scheme.accentColor)
                .frame(width: 20, height: 20)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(scheme.uiElementColor)
                .frame(width: 20, height: 20)
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
