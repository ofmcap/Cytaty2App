import SwiftUI

struct TagFilterView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.appColors) var appColors

    @Binding var selectedTag: String?
    let allTags: [String]
    @State private var searchText = ""
    
    private var filteredTags: [String] {
        if searchText.isEmpty {
            return allTags.sorted()
        } else {
            return allTags.filter { tag in
                tag.localizedCaseInsensitiveContains(searchText)
            }.sorted()
        }
    }
    
    private var tagsByFirstLetter: [String: [String]] {
        Dictionary(grouping: filteredTags) { tag in
            guard let firstChar = tag.first?.uppercased() else { return "#" }
            return firstChar
        }
    }
    
    private var sortedTagSections: [String] {
        tagsByFirstLetter.keys.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if !allTags.isEmpty {
                    SearchBar(text: $searchText, placeholder: "Szukaj tagów")
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                if filteredTags.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(appColors.secondaryTextColor)
                        
                        Text("Brak pasujących tagów")
                            .font(.title2)
                            .foregroundColor(appColors.primaryTextColor)
                        
                        Text("Nie znaleziono tagów pasujących do: \"\(searchText)\"")
                            .font(.subheadline)
                            .foregroundColor(appColors.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if allTags.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tag.slash")
                            .font(.system(size: 60))
                            .foregroundColor(appColors.secondaryTextColor)
                        
                        Text("Brak tagów")
                            .font(.title2)
                            .foregroundColor(appColors.primaryTextColor)
                        
                        Text("Dodaj tagi do swoich cytatów, aby móc filtrować według nich")
                            .font(.subheadline)
                            .foregroundColor(appColors.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Button(action: {
                            selectedTag = nil
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(appColors.accentColor)
                                    .frame(width: 20)
                                
                                Text("Wszystkie tagi")
                                    .foregroundColor(appColors.primaryTextColor)
                                    .fontWeight(selectedTag == nil ? .medium : .regular)
                                
                                Spacer()
                                
                                if selectedTag == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(appColors.accentColor)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(selectedTag == nil ? appColors.accentColor.opacity(0.1) : Color.clear)
                        
                        ForEach(sortedTagSections, id: \.self) { section in
                            if filteredTags.count > 10 {
                                Section(header: Text(section).font(.headline).foregroundColor(appColors.secondaryTextColor)) {
                                    ForEach(tagsByFirstLetter[section]?.sorted() ?? [], id: \.self) { tag in
                                        TagRowView(
                                            tag: tag,
                                            isSelected: selectedTag == tag,
                                            onTap: {
                                                selectedTag = tag
                                                dismiss()
                                            },
                                            appColors: appColors
                                        )
                                    }
                                }
                            } else {
                                ForEach(tagsByFirstLetter[section]?.sorted() ?? [], id: \.self) { tag in
                                    TagRowView(
                                        tag: tag,
                                        isSelected: selectedTag == tag,
                                        onTap: {
                                            selectedTag = tag
                                            dismiss()
                                        },
                                        appColors: appColors
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .background(appColors.backgroundColor)
            .navigationTitle("Filtruj według tagów")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                    .foregroundColor(appColors.secondaryTextColor)
                }
                
                if selectedTag != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Wyczyść") {
                            selectedTag = nil
                            dismiss()
                        }
                        .foregroundColor(appColors.accentColor)
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
    let appColors: AppColorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(isSelected ? appColors.backgroundColor : appColors.accentColor)
                    .frame(width: 20)
                
                Text(tag)
                    .foregroundColor(isSelected ? appColors.backgroundColor : appColors.primaryTextColor)
                    .fontWeight(isSelected ? .medium : .regular)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(appColors.backgroundColor)
                        .fontWeight(.medium)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? appColors.accentColor : Color.clear)
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
       // .environment(\.appColors, AppColorScheme.preview)
    }
}
