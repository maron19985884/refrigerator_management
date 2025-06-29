import Foundation

class ShoppingViewModel: ObservableObject {
    @Published var shoppingItems: [ShoppingItem] = []

    private let storageKey = "shoppingItems"

    init() {
        loadItems()
    }

    // アイテムを追加
    func addItem(name: String, quantity: Int = 1) {
        let newItem = ShoppingItem(name: name, quantity: quantity)
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

    // 保存
     func save() {
        if let encoded = try? JSONEncoder().encode(shoppingItems) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    // 読み込み
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) {
            shoppingItems = decoded
        }
    }

    // FoodItem → ShoppingItem に更新する際の update
    func updateItem(from foodItem: FoodItem) {
        if let index = shoppingItems.firstIndex(where: { $0.name == foodItem.name }) {
            shoppingItems[index].name = foodItem.name
            shoppingItems[index].quantity = foodItem.quantity
            save()
        }
    }
}
