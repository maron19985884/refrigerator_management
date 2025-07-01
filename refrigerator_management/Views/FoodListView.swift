// Views/FoodListView.swift

import SwiftUI

struct FoodListView: View {
    @State private var selectedStorage: StorageType = .fridge
    @State private var showingRegister = false
    @State private var editingItem: FoodItem? = nil
    @StateObject var viewModel: FoodViewModel

    var filteredItems: [FoodItem] {
        viewModel.foodItems
            .filter { $0.storageType == selectedStorage }
            .sorted { $0.expirationDate < $1.expirationDate }
    }

    var body: some View {
        ZStack {
            VStack {
                Text("食材一覧")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                Picker("保存場所", selection: $selectedStorage) {
                    ForEach(StorageType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    ForEach(filteredItems) { item in
                        Button(action: {
                            editingItem = item
                        }) {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("x\(item.quantity)")
                                Text(dateLabel(for: item.expirationDate))
                                    .foregroundColor(color(for: item.expirationDate))
                                    .font(.caption)
                            }
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
            }

            // 右下の追加ボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingRegister = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showingRegister) {
            FoodRegisterView { newItem in
                viewModel.add(item: newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            FoodRegisterView(itemToEdit: item) { updatedItem in
                if let index = viewModel.foodItems.firstIndex(where: { $0.id == updatedItem.id }) {
                    viewModel.foodItems[index] = updatedItem
                }
            }
        }
    }

    func deleteItem(at offsets: IndexSet) {
        let itemsToDelete = filteredItems
        let indexesToDelete = offsets.map { itemsToDelete[$0].id }
        viewModel.foodItems.removeAll { item in
            indexesToDelete.contains(item.id)
        }
    }

    func color(for date: Date) -> Color {
        let today = Calendar.current.startOfDay(for: Date())
        if date < today {
            return .red
        } else if Calendar.current.isDateInTomorrow(date) {
            return .orange
        } else {
            return .gray
        }
    }

    func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if date < calendar.startOfDay(for: Date()) {
            return "期限切れ"
        } else if calendar.isDateInToday(date) {
            return "本日まで"
        } else if calendar.isDateInTomorrow(date) {
            return "明日まで"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            return "期限: \(formatter.string(from: date))"
        }
    }
}
