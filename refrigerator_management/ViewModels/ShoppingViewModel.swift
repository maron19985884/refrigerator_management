import Foundation

class ShoppingViewModel: ObservableObject {
    @Published var shoppingItems: [ShoppingItem] = []

    private let storageKey = "shoppingItems"
    private let userDefaults = UserDefaults.standard

    init() {
        loadItems()
    }

    // アイテムを追加
    func addItem(name: String, quantity: Int = 1, category: FoodCategory = .other) {
        let newItem = ShoppingItem(name: name, quantity: quantity, category: category)
        shoppingItems.append(newItem)
        save()
    }

    func add(_ item: ShoppingItem) {
        shoppingItems.append(item)
        save()
    }

    // アイテムを削除
    func deleteItem(at offsets: IndexSet) {
        shoppingItems.remove(atOffsets: offsets)
        save()
    }

    func delete(at offsets: IndexSet) {
        shoppingItems.remove(atOffsets: offsets)
        save()
    }

    // チェック状態の切り替え
    func toggleCheck(for item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index].isChecked.toggle()
            save()
        }
    }

    // チェックされたアイテムだけ抽出＆削除（在庫に反映する用）
    func extractCheckedItemsAndRemove() -> [ShoppingItem] {
        let checkedItems = shoppingItems.filter { $0.isChecked }
        shoppingItems.removeAll { $0.isChecked }
        save()
        return checkedItems
    }

    /// ShoppingItem を更新する
    /// - Parameter item: 更新対象の ShoppingItem
    func updateItem(_ item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index] = item
            save()
        }
    }

    // 保存（バックグラウンドで実行）
    func save() {
        let items = shoppingItems
        let key = storageKey
        DispatchQueue.global(qos: .background).async {
            if let encoded = try? JSONEncoder().encode(items) {
                self.userDefaults.set(encoded, forKey: key)
            }
        }
    }

    // 読み込み
    private func loadItems() {
        let key = storageKey
        DispatchQueue.global(qos: .background).async {
            if let data = self.userDefaults.data(forKey: key),
               let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) {
                DispatchQueue.main.async {
                    self.shoppingItems = decoded
                }
            }
        }
    }

    // FoodItem → ShoppingItem に更新する際の update
    func updateItem(from foodItem: FoodItem) {
        if let index = shoppingItems.firstIndex(where: { $0.name == foodItem.name }) {
            shoppingItems[index].name = foodItem.name
            shoppingItems[index].quantity = foodItem.quantity
            shoppingItems[index].expirationDate = foodItem.expirationDate
            shoppingItems[index].storageType = foodItem.storageType
            shoppingItems[index].category = foodItem.category
            save()
        }
    }
}
