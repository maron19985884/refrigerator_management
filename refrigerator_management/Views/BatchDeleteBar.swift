import SwiftUI

struct BatchDeleteBar: View {
    var selectionIsEmpty: Bool
    var deleteAction: () -> Void

    var body: some View {
        HStack {
            Button(role: .destructive, action: deleteAction) {
                Label("削除", systemImage: "trash")
            }
            .disabled(selectionIsEmpty)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.bar)
    }
}

#Preview {
    BatchDeleteBar(selectionIsEmpty: true, deleteAction: {})
}
