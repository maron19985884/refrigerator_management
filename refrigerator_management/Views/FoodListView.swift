// Views/FoodListView.swift

import SwiftUI

struct FoodListView: View {
    @State private var selectedStorage: StorageType = .fridge
    @State private var showingRegister = false
    @State private var editingItem: FoodItem? = nil
    @State private var showingOCR = false
    @StateObject var viewModel: FoodViewModel

    var filteredItems: [FoodItem] {
        viewModel.foodItems
            .filter { $0.storageType == selectedStorage }
            .sorted { $0.expirationDate < $1.expirationDate }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
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
            .navigationTitle("食材一覧")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingOCR = true }) {
                        Image(systemName: "text.viewfinder")
                    }
                    NavigationLink(
                        destination: ShoppingListView(
                            shoppingViewModel: ShoppingViewModel(),
                            foodViewModel: viewModel
                        )
                    ) {
                        Image(systemName: "cart")
                    }
                }
            }
            .sheet(isPresented: $showingRegister) {
                FoodRegisterView { newItem in
                    viewModel.add(item: newItem)
                }
            }
            .sheet(isPresented: $showingOCR) {
                ReceiptOCRView { items in
                    viewModel.foodItems.append(contentsOf: items)
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
        .navigationViewStyle(.stack)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "期限: \(formatter.string(from: date))"
    }
}
