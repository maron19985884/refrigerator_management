import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @ObservedObject var foodViewModel: FoodViewModel
    @ObservedObject var templateViewModel: TemplateViewModel
    @State private var editingItem: ShoppingItem? = nil
    @State private var showingRegister = false
    @State private var showingTemplateNameAlert = false
    @State private var newTemplateName: String = ""
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<UUID>()
    @State private var showingDeleteConfirm = false
    @State private var deleteOffsets: IndexSet? = nil
    @State private var showingCartConfirm = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List(selection: $selection) {
                        ForEach(shoppingViewModel.shoppingItems) { item in
                            HStack(alignment: .top) {
                                Button(action: {
                                    shoppingViewModel.toggleCheck(for: item)
                                }) {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(item.isChecked ? .green : .gray)
                                        .padding(.trailing, 8)
                                }
                                .disabled(editMode == .active)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                        .strikethrough(item.isChecked)

                                HStack(spacing: 8) {
                                    Text("x\(item.quantity)")
                                    Text(item.category.rawValue)
                                    if let date = item.expirationDate {
                                        Text(dateLabel(for: date))
                                            .foregroundColor(color(for: date))
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.gray)

                                if let note = item.note, !note.isEmpty {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if editMode == .inactive {
                                    editingItem = item
                                }
                            }
                            Spacer()
                        }
                        .tag(item.id)
                        .padding(.vertical, 8)
                        .background(item.isChecked ? Color.green.opacity(0.15) : Color.clear)
                        .cornerRadius(8)
                    }
                    .onDelete { offsets in
                        deleteOffsets = offsets
                        showingDeleteConfirm = true
                    }
                }
                .environment(\.editMode, $editMode)
                .listStyle(.insetGrouped)

            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                        }) {
                            Image(systemName: editMode.isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            showingCartConfirm = true
                        }) {
                            Image(systemName: "cart.fill.badge.plus")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                }
            )
            .navigationTitle("買い物リスト")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingRegister = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if editMode == .active {
                        Button("削除") {
                            deleteOffsets = nil
                            showingDeleteConfirm = true
                        }.disabled(selection.isEmpty)
                    } else {
                        Button("テンプレート保存") {
                            newTemplateName = ""
                            showingTemplateNameAlert = true
                        }
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                // ShoppingItem → FoodItem に変換して編集画面へ
                let foodItem = FoodItem(
                    id: item.id,
                    name: item.name,
                    quantity: item.quantity,
                    expirationDate: item.expirationDate ?? Date(),
                    storageType: item.storageType,
                    category: item.category
                )
                FoodRegisterView(itemToEdit: foodItem) { updatedItem in
                    // ✅ 編集後に ShoppingItem に戻す（storageType含めて）
                    let updatedShoppingItem = ShoppingItem(
                        id: updatedItem.id,
                        name: updatedItem.name,
                        quantity: updatedItem.quantity,
                        expirationDate: updatedItem.expirationDate,
                        storageType: updatedItem.storageType,
                        category: updatedItem.category,
                        manuallyAdded: true,
                        linkedFoodItemID: nil,
                        note: item.note,
                        addedAt: item.addedAt,
                        isChecked: item.isChecked
                    )
                    shoppingViewModel.updateItem(updatedShoppingItem)
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingRegister) {
            FoodRegisterView { newItem in
                let shoppingItem = ShoppingItem(
                    name: newItem.name,
                    quantity: newItem.quantity,
                    expirationDate: newItem.expirationDate,
                    storageType: newItem.storageType,
                    category: newItem.category
                )
                shoppingViewModel.add(shoppingItem)
            }
        }
        .alert("テンプレート名を入力", isPresented: $showingTemplateNameAlert) {
            TextField("テンプレート名", text: $newTemplateName)
            Button("保存") {
                saveCurrentAsTemplate()
            }
            Button("キャンセル", role: .cancel) {}
        }
        .alert("選択した項目を削除しますか？", isPresented: $showingDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                performDelete()
            }
        }
        .alert("チェック済みの項目を食材一覧に移動しますか？", isPresented: $showingCartConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("移動", role: .destructive) {
                processCheckedItems()
            }
        }
        .onDisappear {
            editMode = .inactive
            selection.removeAll()
        }
    }
    }


    // ✅ ShoppingItem の storageType / expirationDate を反映して在庫に変換
    private func processCheckedItems() {
        let checkedItems = shoppingViewModel.extractCheckedItemsAndRemove()
        let groupedItems = Dictionary(grouping: checkedItems, by: { $0.name })

        for (name, items) in groupedItems {
            let quantity = items.reduce(0) { $0 + ($1.quantity > 0 ? $1.quantity : 1) }

            let expirationDate = items.first?.expirationDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            let storageType = items.first?.storageType ?? .fridge
            let category = items.first?.category ?? .other

            let newFoodItem = FoodItem(
                name: name,
                quantity: quantity,
                expirationDate: expirationDate,
                storageType: storageType,
                category: category
            )
            foodViewModel.add(item: newFoodItem)
        }
    }

    private func saveCurrentAsTemplate() {
        let items = shoppingViewModel.shoppingItems.map { item in
            TemplateItem(
                id: item.id,
                name: item.name,
                quantity: item.quantity,
                expirationDate: item.expirationDate,
                storageType: item.storageType,
                category: item.category
            )
        }
        guard !items.isEmpty else { return }
        templateViewModel.addTemplate(name: newTemplateName.isEmpty ? "テンプレート" : newTemplateName, items: items)
        showingTemplateNameAlert = false
    }

    private func performDelete() {
        if let offsets = deleteOffsets {
            shoppingViewModel.shoppingItems.remove(atOffsets: offsets)
            deleteOffsets = nil
            selection.removeAll()
        } else {
            shoppingViewModel.shoppingItems.removeAll { item in
                selection.contains(item.id)
            }
            selection.removeAll()
        }
        editMode = .inactive
        shoppingViewModel.save()
    }

    private func color(for date: Date) -> Color {
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

    private func dateLabel(for date: Date) -> String {
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

