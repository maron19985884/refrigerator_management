import SwiftUI

struct ShoppingListView: View {
  @ObservedObject var shoppingViewModel: ShoppingViewModel
  @ObservedObject var foodViewModel: FoodViewModel
  @ObservedObject var templateViewModel: TemplateViewModel

  @State private var editingItem: ShoppingItem? = nil
  @State private var showingRegister = false
  @State private var showingTemplateNameAlert = false
  @State private var newTemplateName: String = ""
  @State private var showingCartConfirm = false

  var body: some View {
    NavigationView {
      List {
        ForEach(
          shoppingViewModel.shoppingItems.sorted { $0.addedAt < $1.addedAt },
          id: \.id
        ) { item in
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
              editingItem = item
            }
            Spacer()
          }
          .contentShape(Rectangle())
          .padding(.vertical, 8)
          .background(item.isChecked ? Color.green.opacity(0.15) : Color.clear)
          .cornerRadius(8)
          .swipeActions {
            Button(role: .destructive) {
              if let index = shoppingViewModel.shoppingItems.firstIndex(where: {
                $0.id == item.id
              }) {
                shoppingViewModel.shoppingItems.remove(at: index)
                shoppingViewModel.save()
              }
            } label: {
              Label("削除", systemImage: "trash")
            }
          }
        }
      }
      .listStyle(.insetGrouped)
      .safeAreaInset(edge: .bottom) {
        Spacer().frame(height: 94)
      }
      .navigationTitle("買い物リスト")
      .overlay(alignment: .bottom) {
        bottomBar
      }
    }
    .navigationViewStyle(.stack)
    .sheet(item: $editingItem) { item in
      ShoppingItemRegisterView(itemToEdit: item) { updatedItem in
        shoppingViewModel.updateItem(updatedItem)
      }
    }
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
    .alert("チェック済みの項目を食材一覧に移動しますか？", isPresented: $showingCartConfirm) {
      Button("キャンセル", role: .cancel) {}
      Button("移動", role: .destructive) {
        processCheckedItems()
      }
    }
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

  private func color(for date: Date) -> Color {
    DateUtils.color(for: date)
  }

  private func dateLabel(for date: Date) -> String {
    DateUtils.label(for: date)
  }

  private var bottomBar: some View {
    HStack(spacing: 24) {
      Button(action: {
        showingRegister = true
      }) {
        Label("追加", systemImage: "plus")
      }

      Button(action: {
        newTemplateName = ""
        showingTemplateNameAlert = true
      }) {
        Label("テンプレート保存", systemImage: "square.and.arrow.down")
      }

      Button(action: {
        showingCartConfirm = true
      }) {
        Label("在庫へ追加", systemImage: "cart.fill.badge.plus")
      }
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(.bar)
  }
}
