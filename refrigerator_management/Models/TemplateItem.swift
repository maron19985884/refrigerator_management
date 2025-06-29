// TemplateItem.swift
// テンプレート用の食材モデル

import Foundation

struct TemplateItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Int

    init(id: UUID = UUID(), name: String, quantity: Int = 1) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
}
