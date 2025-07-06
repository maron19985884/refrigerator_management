// Views/FoodRegisterView.swift

import SwiftUI

struct FoodRegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var quantity: Int = 1
    @State private var expirationDate: Date = Date()
    @State private var showingDatePicker = false
    @State private var storageType: StorageType = .fridge
    @State private var category: FoodCategory = .other

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
                    Button(action: { showingDatePicker = true }) {
                        HStack {
                            Text(expirationDate, style: .date)
                            Spacer()
                            Image(systemName: "calendar")
                        }
                    }
                    .sheet(isPresented: $showingDatePicker) {
                        VStack {
                            DatePicker("", selection: $expirationDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .onChange(of: expirationDate) { _ in
                                    showingDatePicker = false
                                }
                            Button("閉じる") {
                                showingDatePicker = false
                            }
                            .padding()
                        }
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
                        let item = FoodItem(
                            id: itemToEdit?.id ?? UUID(),
                            name: name,
                            quantity: quantity,
                            expirationDate: expirationDate,
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
            .navigationTitle(itemToEdit == nil ? "食材を追加" : "食材を編集")
            .onAppear {
                // 編集時のみ初期値をセット
                if let item = itemToEdit {
                    name = item.name
                    quantity = item.quantity
                    expirationDate = item.expirationDate
                    storageType = item.storageType
                    category = item.category
                }
            }
        }
    }
}
