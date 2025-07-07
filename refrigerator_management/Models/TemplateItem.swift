// TemplateItem.swift
// テンプレート用の食材モデル

import Foundation

struct TemplateItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Int
    var expirationDate: Date?
    var expirationPeriod: Int?
    var storageType: StorageType
    var category: FoodCategory

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Int = 1,
        expirationDate: Date? = nil,
        expirationPeriod: Int? = nil,
        storageType: StorageType = .fridge,
        category: FoodCategory = .other
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expirationDate = expirationDate
        self.expirationPeriod = expirationPeriod
        self.storageType = storageType
        self.category = category
    }
}
