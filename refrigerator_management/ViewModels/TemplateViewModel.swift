// TemplateViewModel.swift
// テンプレート管理用 ViewModel

import Foundation

class TemplateViewModel: ObservableObject {
    @Published var templates: [Template] = []

    private let storageKey = "savedTemplates"
    private let userDefaults = UserDefaults.standard

    init() {
        loadTemplates()
    }

    // テンプレート追加
    func addTemplate(name: String, items: [TemplateItem]) {
        let template = Template(name: name, items: items)
        templates.append(template)
        saveTemplates()
    }

    // テンプレート削除
    func deleteTemplate(at index: Int) {
        guard templates.indices.contains(index) else { return }
        templates.remove(at: index)
        saveTemplates()
    }

    // テンプレート読み込み
    func loadTemplates() {
        DispatchQueue.global(qos: .background).async {
            if let data = self.userDefaults.data(forKey: self.storageKey),
               let decoded = try? JSONDecoder().decode([Template].self, from: data) {
                DispatchQueue.main.async {
                    self.templates = decoded
                }
            } else {
                let defaults = Self.defaultTemplates
                DispatchQueue.main.async {
                    self.templates = defaults
                }
                self.saveTemplates()
            }
        }
    }

    // テンプレート保存
    func saveTemplates() {
        let items = templates
        DispatchQueue.global(qos: .background).async {
            if let encoded = try? JSONEncoder().encode(items) {
                self.userDefaults.set(encoded, forKey: self.storageKey)
            }
        }
    }

    /// アプリ初回起動時に登録されるデフォルトテンプレート
    private static var defaultTemplates: [Template] {
        [
            Template(
                name: "ミートソーススパゲッティ",
                items: [
                    TemplateItem(name: "合挽き肉", quantity: 1, expirationPeriod: 2, storageType: .fridge, category: .meat),
                    TemplateItem(name: "玉ねぎ", quantity: 1, expirationPeriod: 7, storageType: .pantry, category: .vegetable),
                    TemplateItem(name: "トマト缶", quantity: 1, expirationPeriod: 365, storageType: .pantry, category: .other),
                    TemplateItem(name: "にんにく", quantity: 1, expirationPeriod: 14, storageType: .pantry, category: .vegetable),
                    TemplateItem(name: "パスタ", quantity: 1, expirationPeriod: 365, storageType: .pantry, category: .other),
                    TemplateItem(name: "ピザ用チーズ", quantity: 1, expirationPeriod: 7, storageType: .fridge, category: .dairy)
                ]
            ),
            Template(
                name: "グラタン",
                items: [
                    TemplateItem(name: "マカロニ", quantity: 1, expirationPeriod: 365, storageType: .pantry, category: .other),
                    TemplateItem(name: "玉ねぎ", quantity: 1, expirationPeriod: 7, storageType: .pantry, category: .vegetable),
                    TemplateItem(name: "鶏むね肉", quantity: 1, expirationPeriod: 2, storageType: .fridge, category: .meat),
                    TemplateItem(name: "牛乳", quantity: 1, expirationPeriod: 7, storageType: .fridge, category: .dairy),
                    TemplateItem(name: "ピザ用チーズ", quantity: 1, expirationPeriod: 7, storageType: .fridge, category: .dairy),
                    TemplateItem(name: "バター", quantity: 1, expirationPeriod: 30, storageType: .fridge, category: .dairy)
                ]
            ),
            Template(
                name: "肉じゃが",
                items: [
                    TemplateItem(name: "じゃがいも", quantity: 2, expirationPeriod: 7, storageType: .pantry, category: .vegetable),
                    TemplateItem(name: "玉ねぎ", quantity: 1, expirationPeriod: 7, storageType: .pantry, category: .vegetable),
                    TemplateItem(name: "にんじん", quantity: 1, expirationPeriod: 7, storageType: .fridge, category: .vegetable),
                    TemplateItem(name: "牛肉", quantity: 1, expirationPeriod: 2, storageType: .fridge, category: .meat),
                    TemplateItem(name: "しらたき", quantity: 1, expirationPeriod: 7, storageType: .fridge, category: .other)
                ]
            ),
            Template(
                name: "ハンバーグ",
                items: [
                    TemplateItem(name: "合挽き肉", quantity: 1, expirationPeriod: 2, storageType: .fridge, category: .meat),
                    TemplateItem(name: "玉ねぎ", quantity: 1, expirationPeriod: 7, storageType: .pantry, category: .vegetable),
                    TemplateItem(name: "卵", quantity: 1, expirationPeriod: 14, storageType: .fridge, category: .other),
                    TemplateItem(name: "パン粉", quantity: 1, expirationPeriod: 180, storageType: .pantry, category: .other)
                ]
            ),
            Template(
                name: "しょうが焼き",
                items: [
                    TemplateItem(name: "豚ロース肉", quantity: 1, expirationPeriod: 2, storageType: .fridge, category: .meat),
                    TemplateItem(name: "玉ねぎ", quantity: 1, expirationPeriod: 7, storageType: .pantry, category: .vegetable),
                    TemplateItem(name: "しょうが", quantity: 1, expirationPeriod: 14, storageType: .fridge, category: .vegetable)
                ]
            )
        ]
    }
}

// ShoppingViewModel に追加する保存関数の例：
// func saveItems() {
//     if let encoded = try? JSONEncoder().encode(shoppingItems) {
//         UserDefaults.standard.set(encoded, forKey: storageKey)
//     }
// }
