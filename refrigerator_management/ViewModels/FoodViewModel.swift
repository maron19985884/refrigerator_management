// ViewModels/FoodViewModel.swift

import Foundation
import SwiftUI

class FoodViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = [] {
        didSet { save() } // データ変更時に自動保存
    }

    private static let documentsDirectory =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let fileURL: URL

    init(fileName: String = "food_items.json") {
        self.fileURL = Self.documentsDirectory.appendingPathComponent(fileName)
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

    // 保存処理（バックグラウンドで実行）
    func save() {
        let items = foodItems
        let url = fileURL
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(items)
                try data.write(to: url)
            } catch {
                print("[FoodViewModel] 保存エラー: \(error.localizedDescription)")
            }
        }
    }

    // 読み込み処理
    private func load() {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([FoodItem].self, from: data)
                DispatchQueue.main.async {
                    self.foodItems = decoded
                }
            } catch {
                print("[FoodViewModel] 読み込みエラー: \(error.localizedDescription)")
            }
        }
    }
}
