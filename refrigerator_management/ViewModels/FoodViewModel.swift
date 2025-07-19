// ViewModels/FoodViewModel.swift

import Foundation
import SwiftUI

class FoodViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = [] {
        didSet { save() } // データ変更時に自動保存
    }

    private let store: FileStore<[FoodItem]>

    init(fileName: String = "food_items.json") {
        self.store = FileStore(fileName: fileName)
        load()
    }

    /// 指定した保存場所の食材を賞味期限順に取得
    func items(for storage: StorageType) -> [FoodItem] {
        foodItems
            .filter { $0.storageType == storage }
            .sorted { $0.expirationDate < $1.expirationDate }
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
        store.save(foodItems)
    }

    // 読み込み処理
    private func load() {
        guard FileManager.default.fileExists(atPath: store.url.path) else { return }
        store.load { [weak self] result in
            switch result {
            case let .success(items):
                self?.foodItems = items
            case let .failure(error):
                print("[FoodViewModel] 読み込みエラー: \(error.localizedDescription)")
            }
        }
    }
}
