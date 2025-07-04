// Cytaty2App/Views/Settings/ColorSchemeSelectionView.swift
import SwiftUI

struct ColorSchemeSelectionView: View {
    @EnvironmentObject var colorSchemeService: ColorSchemeService
    @Environment(\.appColors) var appColors
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(ColorSchemeService.schemeGroups.keys.sorted()), id: \.self) { groupName in
                    Section(header: Text(groupName)) {
                        let schemes = ColorSchemeService.schemeGroups[groupName] ?? []
                        ForEach(schemes.sorted(by: { !$0.isDarkVariant && $1.isDarkVariant })) { scheme in
                            SchemeRow(
                                scheme: scheme,
                                isSelected: scheme.name == colorSchemeService.currentScheme.name
                            ) {
                                colorSchemeService.selectScheme(scheme)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Schematy kolorów")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Gotowe") {
                        dismiss()
                    }
                    .foregroundColor(appColors.accentColor)
                }
            }
        }
        .background(appColors.backgroundColor)
    }
}

struct SchemeRow: View {
    let scheme: AppColorScheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Podgląd kolorów
                HStack(spacing: 4) {
                    Circle()
                        .fill(scheme.backgroundColor)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Circle()
                        .fill(scheme.primaryTextColor)
                        .frame(width: 20, height: 20)
                    
                    Circle()
                        .fill(scheme.accentColor)
                        .frame(width: 20, height: 20)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(scheme.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(scheme.isDarkVariant ? "Ciemny" : "Jasny")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.body.weight(.semibold))
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorPreview: View {
    let scheme: AppColorScheme
    
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(scheme.backgroundColor)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Circle()
                .fill(scheme.primaryTextColor)
                .frame(width: 16, height: 16)
            
            Circle()
                .fill(scheme.accentColor)
                .frame(width: 16, height: 16)
        }
    }
}
