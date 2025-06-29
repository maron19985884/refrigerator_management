// Models/FoodItem.swift

import Foundation

// 保存場所（冷蔵・冷凍・常温）
enum StorageType: String, CaseIterable, Identifiable, Codable {
    case fridge = "冷蔵"
    case freezer = "冷凍"
    case pantry = "常温"

    var id: String { self.rawValue }
}

// 食材モデル
struct FoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var expirationDate: Date
    var storageType: StorageType

    init(id: UUID = UUID(), name: String, quantity: Int, expirationDate: Date, storageType: StorageType) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expirationDate = expirationDate
        self.storageType = storageType
    }
}
