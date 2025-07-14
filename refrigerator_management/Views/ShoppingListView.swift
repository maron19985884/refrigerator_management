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

  var body: some View {
    NavigationView {
      List {
          ForEach(
            shoppingViewModel.shoppingItems
              .sorted { $0.addedAt < $1.addedAt },
            id: \.id
          ) { item in
            HStack(alignment: .top) {
              Button(action: {
                if editMode == .active {
                  if selection.contains(item.id) {
                    selection.remove(item.id)
                  } else {
                    selection.insert(item.id)
                  }
                } else {
                  shoppingViewModel.toggleCheck(for: item)
                }
              }) {
                Image(
                  systemName: editMode == .active
                    ? (selection.contains(item.id) ? "checkmark.circle.fill" : "circle")
                    : (item.isChecked ? "checkmark.circle.fill" : "circle")
                )
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(
                  editMode == .active
                    ? (selection.contains(item.id) ? .red : .gray)
                    : (item.isChecked ? .green : .gray)
                )
                .padding(.trailing, 8)
              }
              .buttonStyle(.borderless)

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
                  } else if let period = item.expirationPeriod {
                    Text("期限: \(period)日")
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
              .onTapGesture {
                if editMode == .inactive {
                  editingItem = item
                } else {
                  if selection.contains(item.id) {
                    selection.remove(item.id)
                  } else {
                    selection.insert(item.id)
                  }
                }
              }
              Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
            .background(
              editMode == .active
                ? (selection.contains(item.id) ? Color.red.opacity(0.15) : Color.clear)
                : (item.isChecked ? Color.green.opacity(0.15) : Color.clear)
            )
            .cornerRadius(8)
            .swipeActions {
              Button(role: .destructive) {
                if let index = shoppingViewModel.shoppingItems.firstIndex(where: {
                  $0.id == item.id
                }) {
                  deleteOffsets = IndexSet(integer: index)
                  showingDeleteConfirm = true
                }
              } label: {
                Label("削除", systemImage: "trash")
              }
            }
          }
        }
        .environment(\.editMode, $editMode)
        .listStyle(.insetGrouped)
        // ボトムバーと重ならないように下部へ余白を追加
        .safeAreaInset(edge: .bottom) {
          Spacer().frame(height: 94)
        }
      }
    }
    .overlay(alignment: .bottom) {
      bottomBar
    }
    .navigationTitle("買い物リスト")
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        EditButton()
        Button(action: { showingRegister = true }) {
          Image(systemName: "plus")
        }
      }
      ToolbarItem(placement: .navigationBarLeading) {
        if editMode == .inactive {
          Button("テンプレート保存") {
            newTemplateName = ""
            showingTemplateNameAlert = true
          }
        }
      }
    }
    .sheet(item: $editingItem) { item in
      ShoppingItemRegisterView(itemToEdit: item) { updatedItem in
        shoppingViewModel.updateItem(updatedItem)
      }
    }
    .navigationViewStyle(.stack)
    .sheet(isPresented: $showingRegister) {
      ShoppingItemRegisterView { newItem in
        shoppingViewModel.add(newItem)
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

  private func processCheckedItems() {
    let checkedItems = shoppingViewModel.extractCheckedItemsAndRemove()
    let groupedItems = Dictionary(grouping: checkedItems, by: { $0.name })

    for (name, items) in groupedItems {
      let quantity = items.reduce(0) { $0 + ($1.quantity > 0 ? $1.quantity : 1) }

      let first = items.first
      let expirationDate: Date
      if let date = first?.expirationDate {
        expirationDate = date
      } else if let period = first?.expirationPeriod {
        expirationDate = Calendar.current.date(byAdding: .day, value: period, to: Date()) ?? Date()
      } else {
        expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
      }
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
        expirationPeriod: item.expirationPeriod,
        storageType: item.storageType,
        category: item.category
      )
    }
    guard !items.isEmpty else { return }
    templateViewModel.addTemplate(
      name: newTemplateName.isEmpty ? "テンプレート" : newTemplateName, items: items)
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
    DateUtils.color(for: date)
  }

  private func dateLabel(for date: Date) -> String {
    DateUtils.label(for: date)
  }

  private var bottomBar: some View {
    HStack {
      if editMode == .active {
        Button(role: .destructive) {
          deleteOffsets = nil
          showingDeleteConfirm = true
        } label: {
          Label("削除", systemImage: "trash")
        }
        .disabled(selection.isEmpty)
      }
      Spacer()
      Button(action: { showingCartConfirm = true }) {
        Label("在庫へ追加", systemImage: "cart.fill.badge.plus")
      }
      .disabled(editMode == .active)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(.bar)
  }
}
