import SwiftUI

struct QuoteRowView: View {
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.content)
                .font(.body)
                .lineLimit(5)
            
            HStack {
                if let page = quote.page {
                    Text("Strona: \(page)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let chapter = quote.chapter {
                    if quote.page != nil {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Rozdział: \(chapter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formatDate(quote.addedDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !quote.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(quote.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Wyświetlanie fragmentu notatki
            if let note = quote.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
                    .italic()
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
