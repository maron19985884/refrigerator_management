import Foundation

// 買い物リストの1件を表すデータモデル
struct ShoppingItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Int = 1
    /// The expected expiration date when the item is converted to a `FoodItem`.
    ///
    /// This value is optional because shopping items created manually do not
    /// always have an expiration date. `ShoppingListView` falls back to a
    /// default date if this value is `nil` when adding to stock.
    var expirationDate: Date?
    var manuallyAdded: Bool
    var linkedFoodItemID: UUID?
    var note: String?
    var addedAt: Date
    var isChecked: Bool

    // 正しいイニシャライザ
    init(
        id: UUID = UUID(),
        name: String,
        quantity: Int = 1,
        expirationDate: Date? = nil,
        manuallyAdded: Bool = true,
        linkedFoodItemID: UUID? = nil,
        note: String? = nil,
        addedAt: Date = Date(),
        isChecked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expirationDate = expirationDate
        self.manuallyAdded = manuallyAdded
        self.linkedFoodItemID = linkedFoodItemID
        self.note = note
        self.addedAt = addedAt
        self.isChecked = isChecked
    }
}
