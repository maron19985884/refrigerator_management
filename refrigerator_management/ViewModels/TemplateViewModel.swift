// TemplateViewModel.swift
// テンプレート管理用 ViewModel

import Foundation

class TemplateViewModel: ObservableObject {
    @Published var templates: [[TemplateItem]] = []

    private let storageKey = "savedTemplates"
    private let userDefaults = UserDefaults.standard

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
        DispatchQueue.global(qos: .background).async {
            if let data = self.userDefaults.data(forKey: self.storageKey),
               let decoded = try? JSONDecoder().decode([[TemplateItem]].self, from: data) {
                DispatchQueue.main.async {
                    self.templates = decoded
                }
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
}

// ShoppingViewModel に追加する保存関数の例：
// func saveItems() {
//     if let encoded = try? JSONEncoder().encode(shoppingItems) {
//         UserDefaults.standard.set(encoded, forKey: storageKey)
//     }
// }
