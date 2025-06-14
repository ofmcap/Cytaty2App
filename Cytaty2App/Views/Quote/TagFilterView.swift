import SwiftUI

struct TagFilterView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTag: String?
    let allTags: [String]
    @State private var searchText = ""
    
    // Filtrowanie tagów na podstawie wyszukiwania
    private var filteredTags: [String] {
        if searchText.isEmpty {
            return allTags.sorted()
        } else {
            return allTags.filter { tag in
                tag.localizedCaseInsensitiveContains(searchText)
            }.sorted()
        }
    }
    
    // Grupowanie tagów alfabetycznie
    private var tagsByFirstLetter: [String: [String]] {
        Dictionary(grouping: filteredTags) { tag in
            guard let firstChar = tag.first?.uppercased() else { return "#" }
            return firstChar
        }
    }
    
    // Posortowane klucze dla sekcji alfabetycznych
    private var sortedTagSections: [String] {
        tagsByFirstLetter.keys.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Pasek wyszukiwania tagów
                if !allTags.isEmpty {
                    SearchBar(text: $searchText, placeholder: "Szukaj tagów")
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                if filteredTags.isEmpty && !searchText.isEmpty {
                    // Brak wyników wyszukiwania
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Brak pasujących tagów")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Nie znaleziono tagów pasujących do: \"\(searchText)\"")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if allTags.isEmpty {
                    // Brak tagów w ogóle
                    VStack(spacing: 20) {
                        Image(systemName: "tag.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Brak tagów")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Dodaj tagi do swoich cytatów, aby móc filtrować według nich")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Lista tagów
                    List {
                        // Opcja "Wszystkie tagi"
                        Button(action: {
                            selectedTag = nil
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                
                                Text("Wszystkie tagi")
                                    .foregroundColor(.primary)
                                    .fontWeight(selectedTag == nil ? .medium : .regular)
                                
                                Spacer()
                                
                                if selectedTag == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(selectedTag == nil ? Color.blue.opacity(0.1) : Color.clear)
                        
                        // Sekcje z tagami
                        ForEach(sortedTagSections, id: \.self) { section in
                            if filteredTags.count > 10 {
                                // Jeśli jest dużo tagów, grupujemy je w sekcje
                                Section(header: Text(section).font(.headline)) {
                                    ForEach(tagsByFirstLetter[section]?.sorted() ?? [], id: \.self) { tag in
                                        TagRowView(
                                            tag: tag,
                                            isSelected: selectedTag == tag,
                                            onTap: {
                                                selectedTag = tag
                                                dismiss()
                                            }
                                        )
                                    }
                                }
                            } else {
                                // Jeśli jest mało tagów, pokazujemy je bez sekcji
                                ForEach(tagsByFirstLetter[section]?.sorted() ?? [], id: \.self) { tag in
                                    TagRowView(
                                        tag: tag,
                                        isSelected: selectedTag == tag,
                                        onTap: {
                                            selectedTag = tag
                                            dismiss()
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Filtruj według tagów")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                if selectedTag != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Wyczyść") {
                            selectedTag = nil
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// Komponent dla pojedynczego wiersza z tagiem
struct TagRowView: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 20)
                
                Text(tag)
                    .foregroundColor(isSelected ? .white : .primary)
                    .fontWeight(isSelected ? .medium : .regular)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
    }
}

// Widok podglądu dla testowania
struct TagFilterView_Previews: PreviewProvider {
    static var previews: some View {
        TagFilterView(
            selectedTag: .constant("Filozofia"),
            allTags: ["Filozofia", "Nauka", "Sztuka", "Historia", "Literatura", "Psychologia", "Biznes", "Motywacja", "Życie", "Miłość"]
        )
    }
}
