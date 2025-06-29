import Foundation

// 買い物リストの1件を表すデータモデル
struct ShoppingItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Int = 1
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
        manuallyAdded: Bool = true,
        linkedFoodItemID: UUID? = nil,
        note: String? = nil,
        addedAt: Date = Date(),
        isChecked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.manuallyAdded = manuallyAdded
        self.linkedFoodItemID = linkedFoodItemID
        self.note = note
        self.addedAt = addedAt
        self.isChecked = isChecked
    }
}
