import Foundation

// 買い物リストの1件を表すデータモデル
struct ShoppingItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Int = 1

    /// 食材カテゴリ
    var category: FoodCategory = .other

    /// 食材を在庫に変換する際の賞味期限
    var expirationDate: Date?

    /// 食材を在庫に変換する際の賞味期間(日数)
    var expirationPeriod: Int?

    /// 食材を在庫に変換する際の保存場所
    var storageType: StorageType = .fridge

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
        expirationPeriod: Int? = nil,
        storageType: StorageType = .fridge,
        category: FoodCategory = .other,
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
        self.expirationPeriod = expirationPeriod
        self.storageType = storageType
        self.category = category
        self.manuallyAdded = manuallyAdded
        self.linkedFoodItemID = linkedFoodItemID
        self.note = note
        self.addedAt = addedAt
        self.isChecked = isChecked
    }
}
