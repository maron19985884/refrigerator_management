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
        .font(DesignTokens.Typography.body)
        .padding(DesignTokens.Spacing.l)
        .frame(maxWidth: .infinity)
        .background(DesignTokens.Colors.surface)
    }
}

#Preview {
    BatchDeleteBar(selectionIsEmpty: true, deleteAction: {})
}
