import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @ObservedObject var foodViewModel: FoodViewModel
    @ObservedObject var templateViewModel: TemplateViewModel
    @State private var editingItem: ShoppingItem? = nil
    @State private var showingRegister = false
    @State private var showingTemplateNameAlert = false
    @State private var newTemplateName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(shoppingViewModel.shoppingItems) { item in
                        HStack {
                            Button(action: {
                                shoppingViewModel.toggleCheck(for: item)
                            }) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(item.isChecked ? .green : .gray)
                                    .padding(.trailing, 8)
                            }

                            Text(item.name)
                                .strikethrough(item.isChecked)
                                .onTapGesture {
                                    editingItem = item
                                }

                            Spacer()

                            if let note = item.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(item.isChecked ? Color.green.opacity(0.15) : Color.clear)
                        .cornerRadius(8)
                    }
                    .onDelete(perform: shoppingViewModel.delete)
                }

                Button(action: {
                    processCheckedItems()
                }) {
                    Text("チェック済みを在庫に反映")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("買い物リスト")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingRegister = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("テンプレート保存") {
                        newTemplateName = ""
                        showingTemplateNameAlert = true
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                // ShoppingItem → FoodItem に変換して編集画面へ
                let foodItem = FoodItem(
                    id: item.id,
                    name: item.name,
                    quantity: item.quantity,
                    expirationDate: item.expirationDate ?? Date(),
                    storageType: item.storageType,
                    category: item.category
                )
                FoodRegisterView(itemToEdit: foodItem) { updatedItem in
                    // ✅ 編集後に ShoppingItem に戻す（storageType含めて）
                    let updatedShoppingItem = ShoppingItem(
                        id: updatedItem.id,
                        name: updatedItem.name,
                        quantity: updatedItem.quantity,
                        expirationDate: updatedItem.expirationDate,
                        storageType: updatedItem.storageType,
                        category: updatedItem.category,
                        manuallyAdded: true,
                        linkedFoodItemID: nil,
                        note: item.note,
                        addedAt: item.addedAt,
                        isChecked: item.isChecked
                    )
                    shoppingViewModel.updateItem(updatedShoppingItem)
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingRegister) {
            FoodRegisterView { newItem in
                let shoppingItem = ShoppingItem(
                    name: newItem.name,
                    quantity: newItem.quantity,
                    expirationDate: newItem.expirationDate,
                    storageType: newItem.storageType,
                    category: newItem.category
                )
                shoppingViewModel.add(shoppingItem)
            }
        }
        .alert("テンプレート名を入力", isPresented: $showingTemplateNameAlert) {
            TextField("テンプレート名", text: $newTemplateName)
            Button("保存") {
                saveCurrentAsTemplate()
            }
            Button("キャンセル", role: .cancel) {}
        }
    }

    // ✅ ShoppingItem の storageType / expirationDate を反映して在庫に変換
    private func processCheckedItems() {
        let checkedItems = shoppingViewModel.extractCheckedItemsAndRemove()
        let groupedItems = Dictionary(grouping: checkedItems, by: { $0.name })

        for (name, items) in groupedItems {
            let quantity = items.reduce(0) { $0 + ($1.quantity > 0 ? $1.quantity : 1) }

            let expirationDate = items.first?.expirationDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            let storageType = items.first?.storageType ?? .fridge
            let category = items.first?.category ?? .other

            let newFoodItem = FoodItem(
                name: name,
                quantity: quantity,
                expirationDate: expirationDate,
                storageType: storageType,
                category: category
            )
            foodViewModel.add(item: newFoodItem)
        }
    }

    private func saveCurrentAsTemplate() {
        let items = shoppingViewModel.shoppingItems.map { item in
            TemplateItem(
                id: item.id,
                name: item.name,
                quantity: item.quantity,
                expirationDate: item.expirationDate,
                storageType: item.storageType,
                category: item.category
            )
        }
        guard !items.isEmpty else { return }
        templateViewModel.addTemplate(name: newTemplateName.isEmpty ? "テンプレート" : newTemplateName, items: items)
        showingTemplateNameAlert = false
    }
}

