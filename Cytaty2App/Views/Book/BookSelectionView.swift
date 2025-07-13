import SwiftUI

struct BookSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: QuoteViewModel
    @Binding var selectedBook: Book?
    @Binding var showingAddQuoteSheet: Bool
    @Environment(\.appColors) private var appColors

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.books) { book in
                    Button(action: {
                        selectedBook = book
                        dismiss()
                    }) {
                        BookRowView(book: book)
                    }
                }
            }
            .navigationTitle("Wybierz książkę")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
            .background(appColors.backgroundColor)
        }
    }
}
