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
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("食材名", text: $item.name)

                        Stepper(value: $item.quantity, in: 1...99) {
                            Text("数量: \(item.quantity)")
                        }

                        Stepper(value: Binding(
                            get: { item.expirationPeriod ?? 0 },
                            set: { item.expirationPeriod = $0 }
                        ), in: 0...30) {
                            Text("賞味期間: \(item.expirationPeriod ?? 0)日")
                        }

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
                    .padding(.vertical, 4)
                }
                .onDelete { indices in
                    withAnimation {
                        template.items.remove(atOffsets: indices)
                    }
                }

                Button(action: {
                    withAnimation {
                        template.items.append(TemplateItem(name: ""))
                    }
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
                Button("完了") {
                    presentationMode.wrappedValue.dismiss()
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
                Template(name: "サンプル", items: [
                    TemplateItem(name: "卵", quantity: 2),
                    TemplateItem(name: "牛乳", quantity: 1)
                ])
            ))
        }
    }
}
#endif
