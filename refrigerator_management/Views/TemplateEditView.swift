import SwiftUI

struct TemplateEditView: View {
    @Binding var template: Template
    @Environment(\.presentationMode) var presentationMode
    @State private var deleteIndex: Int? = nil
    @State private var showingDeleteConfirm = false

    var body: some View {
        Form {
            Section(header: Text("テンプレート名")) {
                TextField("テンプレート名", text: $template.name)
            }

            Section(header: Text("食材一覧")) {
                ForEach(template.items.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        TextField("食材名", text: $template.items[index].name)
                        Stepper(value: $template.items[index].quantity, in: 1...99) {
                            Text("数量: \(template.items[index].quantity)")
                        }
                        DatePicker(
                            "賞味期限",
                            selection: Binding(
                                get: { template.items[index].expirationDate ?? Date() },
                                set: { template.items[index].expirationDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        Picker("保存場所", selection: $template.items[index].storageType) {
                            ForEach(StorageType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        Picker("カテゴリ", selection: $template.items[index].category) {
                            ForEach(FoodCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        HStack {
                            Spacer()
                            Button(role: .destructive) {
                                deleteIndex = index
                                showingDeleteConfirm = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Button(action: {
                    template.items.append(TemplateItem(name: ""))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("食材を追加")
                    }
                }
            }
        }
        .navigationTitle("テンプレート編集")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完了") { presentationMode.wrappedValue.dismiss() }
            }
        }
        .alert("この食材を削除しますか？", isPresented: $showingDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let index = deleteIndex {
                    template.items.remove(at: index)
                    deleteIndex = nil
                }
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
