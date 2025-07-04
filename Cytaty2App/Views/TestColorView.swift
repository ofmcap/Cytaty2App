// Cytaty2App/Views/TestColorView.swift
import SwiftUI

struct TestColorView: View {
    @Environment(\.appColors) var appColors
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Test kolorów")
                .font(.title)
                .primaryText()
            
            Text("Tekst szary (mapowany)")
                .grayText()
            
            Text("Tekst niebieski (mapowany)")
                .blueText()
            
            Text("Tekst drugorzędny")
                .secondaryText()
            
            Text("Tekst akcentowy")
                .accentText()
            
            Text("Tekst czerwony (systemowy)")
                .redText()
            
            Text("Tekst zielony (systemowy)")
                .greenText()
            
            VStack {
                Text("Tło z UI Element")
                    .primaryText()
                    .padding()
            }
            .uiElementBackground()
            .cornerRadius(10)
            
            VStack {
                Text("Tło akcentowe")
                    .foregroundColor(.white)
                    .padding()
            }
            .accentBackground()
            .cornerRadius(10)
        }
        .padding()
        .appBackground()
    }
}

struct TestColorView_Previews: PreviewProvider {
    static var previews: some View {
        TestColorView()
            .environmentObject(ColorSchemeService())
    }
}
