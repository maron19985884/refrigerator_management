// TemplateViewModel.swift
// テンプレート管理用 ViewModel

import Foundation

class TemplateViewModel: ObservableObject {
    @Published var templates: [[TemplateItem]] = []

    private let storageKey = "savedTemplates"

    init() {
        loadTemplates()
    }

    // テンプレート追加
    func addTemplate(_ template: [TemplateItem]) {
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
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([[TemplateItem]].self, from: data) {
            self.templates = decoded
        }
    }

    // テンプレート保存
    func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

// ShoppingViewModel に追加する保存関数の例：
// func saveItems() {
//     if let encoded = try? JSONEncoder().encode(shoppingItems) {
//         UserDefaults.standard.set(encoded, forKey: storageKey)
//     }
// }
