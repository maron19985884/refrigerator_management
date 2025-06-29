// ViewModels/FoodViewModel.swift

import Foundation
import SwiftUI

class FoodViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = [] {
        didSet { save() } // データ変更時に自動保存
    }

    private let fileName = "food_items.json"

    init() {
        load()
    }

    // 新規追加
    func add(item: FoodItem) {
        foodItems.append(item)
    }

    // 削除
    func delete(at offsets: IndexSet) {
        foodItems.remove(atOffsets: offsets)
    }

    // 保存処理
     func save() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try JSONEncoder().encode(foodItems)
            try data.write(to: url)
        } catch {
            print("[FoodViewModel] 保存エラー: \(error.localizedDescription)")
        }
    }

    // 読み込み処理
    private func load() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([FoodItem].self, from: data)
            foodItems = decoded
        } catch {
            print("[FoodViewModel] 読み込みエラー: \(error.localizedDescription)")
        }
    }

    // Documentsディレクトリ取得
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
