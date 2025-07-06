import SwiftUI

struct TemplateEditView: View {
    @Binding var template: Template
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("テンプレート名")) {
                TextField("テンプレート名", text: $template.name)
            }

            Section(header: Text("食材一覧")) {
                ForEach($template.items) { $item in
                    VStack(alignment: .leading) {
                        TextField("食材名", text: $item.name)
                        Stepper(value: $item.quantity, in: 1...99) {
                            Text("数量: \(item.quantity)")
                        }
                        DatePicker(
                            "賞味期限",
                            selection: Binding(
                                get: { item.expirationDate ?? Date() },
                                set: { item.expirationDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        Picker("保存場所", selection: $item.storageType) {
                            ForEach(StorageType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        Picker("カテゴリ", selection: $item.category) {
                            ForEach(FoodCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    template.items.remove(atOffsets: offsets)
                }
            }
        }
        .navigationTitle("テンプレート編集")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完了") { presentationMode.wrappedValue.dismiss() }
            }
        }
    }
}

#if DEBUG
struct TemplateEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TemplateEditView(template: .constant(
                Template(name: "サンプル", items: [TemplateItem(name: "卵", quantity: 2)])
            ))
        }
    }
}
#endif
