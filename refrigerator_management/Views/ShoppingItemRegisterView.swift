import SwiftUI


struct ShoppingItemRegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var quantity: Int = 1
    @State private var expirationPeriod: Int = 0
    @State private var storageType: StorageType = .fridge
    @State private var category: FoodCategory = .other

    let itemToEdit: ShoppingItem?
    var onSave: (ShoppingItem) -> Void

    init(itemToEdit: ShoppingItem? = nil, onSave: @escaping (ShoppingItem) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("食材名")) {
                    TextField("例：牛乳", text: $name)
                }

                Section(header: Text("数量")) {
                    Stepper(value: $quantity, in: 1...99) {
                        Text("\(quantity) 個")
                    }
                }

                Section(header: Text("賞味期間(日)")) {
                    Stepper(value: $expirationPeriod, in: 0...30) {
                        Text("\(expirationPeriod) 日")
                    }
                }

                Section(header: Text("保存場所")) {
                    Picker("保存場所", selection: $storageType) {
                        ForEach(StorageType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("カテゴリ")) {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(FoodCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button(action: {
                        let item = ShoppingItem(
                            id: itemToEdit?.id ?? UUID(),
                            name: name,
                            quantity: quantity,
                            expirationPeriod: expirationPeriod == 0 ? nil : expirationPeriod,
                            storageType: storageType,
                            category: category
                        )
                        onSave(item)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text(itemToEdit == nil ? "登録する" : "更新する").bold()
                            Spacer()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .font(DesignTokens.Typography.body)
            .navigationTitle(itemToEdit == nil ? "食材を追加" : "食材を編集")
            .onAppear {
                if let item = itemToEdit {
                    name = item.name
                    quantity = item.quantity
                    expirationPeriod = item.expirationPeriod ?? 0
                    storageType = item.storageType
                    category = item.category
                }
            }
        }
        .background(DesignTokens.Colors.backgroundDark)
    }
}
