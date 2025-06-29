import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @ObservedObject var foodViewModel: FoodViewModel
    @State private var editingItem: ShoppingItem? = nil
    @State private var showingStoragePicker = false
    @State private var selectedStorageType: StorageType = .fridge

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(shoppingViewModel.shoppingItems) { item in
                        HStack {
                            // チェックマークボタン
                            Button(action: {
                                shoppingViewModel.toggleCheck(for: item)
                            }) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isChecked ? .green : .gray)
                            }

                            // 食材名（タップで編集画面へ遷移）
                            Text(item.name)
                                .strikethrough(item.isChecked)
                                .onTapGesture {
                                    editingItem = item
                                }

                            Spacer()

                            // メモがあれば表示
                            if let note = item.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: shoppingViewModel.delete)
                }

                Button(action: {
                    showingStoragePicker = true
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
                    Button(action: addNewItem) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                // ShoppingItem → FoodItem に変換して編集画面へ
                let foodItem = FoodItem(
                    id: item.id,
                    name: item.name,
                    quantity: item.quantity,
                    expirationDate: item.expirationDate,
                    storageType: selectedStorageType
                )
                FoodRegisterView(itemToEdit: foodItem) { updatedItem in
                    // 更新後の処理（あくまでShoppingViewModelベースで更新）
                    shoppingViewModel.updateItem(from: updatedItem)
                }
            }

            .confirmationDialog("保存場所を選択", isPresented: $showingStoragePicker, titleVisibility: .visible) {
                ForEach(StorageType.allCases, id: \.self) { type in
                    Button(type.rawValue) {
                        selectedStorageType = type
                        processCheckedItems()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // 新しい食材を追加（編集画面には遷移しない）
    private func addNewItem() {
        let newItem = ShoppingItem(name: "新しい食材")
        shoppingViewModel.add(newItem)
    }

    // 在庫反映処理
    private func processCheckedItems() {
        let checkedItems = shoppingViewModel.extractCheckedItemsAndRemove()
        let groupedItems = Dictionary(grouping: checkedItems, by: { $0.name })

        for (name, items) in groupedItems {
            let quantity = items.reduce(0) { $0 + ($1.quantity > 0 ? $1.quantity : 1) }
            let expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

            let newFoodItem = FoodItem(
                name: name,
                quantity: quantity,
                expirationDate: expirationDate,
                storageType: selectedStorageType
            )
            foodViewModel.add(item: newFoodItem)
        }
    }
}
