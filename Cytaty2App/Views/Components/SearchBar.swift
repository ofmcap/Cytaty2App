// Cytaty2App/Views/Components/SearchBar.swift
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    @State private var isEditing = false
    var onSubmit: (() -> Void)? = nil
    @Environment(\.appColors) var appColors
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(appColors.uiElementColor) // Zmiana z Color(.systemGray6)
                .foregroundColor(appColors.primaryTextColor) // Kolor tekstu
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(appColors.secondaryTextColor) // Zmiana z .gray
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(appColors.secondaryTextColor) // Zmiana z .gray
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    isEditing = true
                }
                .onSubmit {
                    if let onSubmit = onSubmit {
                        onSubmit()
                    }
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                   to: nil,
                                                   from: nil,
                                                   for: nil)
                }
                .submitLabel(.search)
            
            if isEditing {
                Button("Anuluj") {
                    text = ""
                    isEditing = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                   to: nil,
                                                   from: nil,
                                                   for: nil)
                }
                .foregroundColor(appColors.accentColor) // Dodaj kolor
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isEditing)
            }
        }
    }
}
