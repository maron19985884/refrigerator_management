// Views/FoodListView.swift

import SwiftUI

struct FoodListView: View {
    @State private var selectedStorage: StorageType = .fridge
    @State private var showingRegister = false
    @State private var editingItem: FoodItem? = nil
    @StateObject var viewModel: FoodViewModel
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<UUID>()
    @State private var showingDeleteConfirm = false
    @State private var deleteOffsets: IndexSet? = nil

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

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

                List(selection: $selection) {
                    ForEach(filteredItems) { item in
                        Button(action: {
                            editingItem = item
                        }) {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("x\(item.quantity)")
                                Text(item.category.rawValue)
                                Text(dateLabel(for: item.expirationDate))
                                    .foregroundColor(color(for: item.expirationDate))
                                    .font(.caption)
                            }
                        }
                    }
                    .onDelete { offsets in
                        deleteOffsets = offsets
                        showingDeleteConfirm = true
                    }
                }
                .environment(\.editMode, $editMode)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarLeading) {
                if editMode == .active {
                    Button("削除") {
                        deleteOffsets = nil
                        showingDeleteConfirm = true
                    }
                    .disabled(selection.isEmpty)
                }
            }
        }
        .alert("選択した項目を削除しますか？", isPresented: $showingDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                performDelete()
            }
        }
    }

    func deleteItem(at offsets: IndexSet) {
        deleteOffsets = offsets
        showingDeleteConfirm = true
    }

    private func performDelete() {
        if let offsets = deleteOffsets {
            let itemsToDelete = filteredItems
            let indexesToDelete = offsets.map { itemsToDelete[$0].id }
            viewModel.foodItems.removeAll { item in
                indexesToDelete.contains(item.id)
            }
            deleteOffsets = nil
            selection.removeAll()
        } else {
            viewModel.foodItems.removeAll { item in
                selection.contains(item.id)
            }
            selection.removeAll()
        }
        editMode = .inactive
    }

    func color(for date: Date) -> Color {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if date < today {
            return .red
        } else if calendar.isDateInTomorrow(date) {
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
            return "期限: \(Self.dateFormatter.string(from: date))"
        }
    }
}
