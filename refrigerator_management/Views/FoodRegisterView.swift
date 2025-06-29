// Views/FoodRegisterView.swift

import SwiftUI

struct FoodRegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var quantity: Int = 1
    @State private var expirationDate: Date = Date()
    @State private var storageType: StorageType = .fridge

    let itemToEdit: FoodItem?
    var onSave: (FoodItem) -> Void

    init(itemToEdit: FoodItem? = nil, onSave: @escaping (FoodItem) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        // State変数の初期値はinitではセットできないため、代わりにonAppearで設定する
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

                Section(header: Text("賞味期限")) {
                    DatePicker("", selection: $expirationDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Section(header: Text("保存場所")) {
                    Picker("保存場所", selection: $storageType) {
                        ForEach(StorageType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button(action: {
                        let item = FoodItem(
                            id: itemToEdit?.id ?? UUID(),
                            name: name,
                            quantity: quantity,
                            expirationDate: expirationDate,
                            storageType: storageType
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
            .navigationTitle(itemToEdit == nil ? "食材を追加" : "食材を編集")
            .onAppear {
                // 編集時のみ初期値をセット
                if let item = itemToEdit {
                    name = item.name
                    quantity = item.quantity
                    expirationDate = item.expirationDate
                    storageType = item.storageType
                }
            }
        }
    }
}
