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
          HStack(alignment: .top, spacing: DesignTokens.Spacing.m) {
            Button(action: {
              withAnimation {
                shoppingViewModel.toggleCheck(for: item)
              }
            }) {
              Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(item.isChecked ? DesignTokens.Colors.neonGreen : DesignTokens.Colors.onMuted)
            }
            .buttonStyle(.borderless)

            Text(item.storageType.icon)
              .font(DesignTokens.Typography.title)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.s / 2) {
              HStack {
                Text(item.name)
                  .font(DesignTokens.Typography.body).bold()
                  .strikethrough(item.isChecked)
                Text(item.category.icon)
              }

              HStack(spacing: DesignTokens.Spacing.s) {
                Text("x\(item.quantity)")
                Text(item.category.rawValue)
                if let date = item.expirationDate {
                  Text(dateLabel(for: date))
                    .foregroundColor(color(for: date))
                  if DateUtils.isExpiringSoon(date) {
                    Text("⚠️")
                  }
                } else if let period = item.expirationPeriod {
                  Text("期限: \(period)日")
                }
              }
              .font(DesignTokens.Typography.body)
              .foregroundColor(DesignTokens.Colors.onMuted)

              if let note = item.note, !note.isEmpty {
                Text(note)
                  .font(DesignTokens.Typography.body)
                  .foregroundColor(DesignTokens.Colors.onMuted)
              }
            }
            .onTapGesture {
              editingItem = item
            }
            Spacer()
          }
          .contentShape(Rectangle())
          .padding(.vertical, DesignTokens.Spacing.s)
          .background(item.isChecked ? DesignTokens.Colors.neonGreen.opacity(0.15) : Color.clear)
          .cornerRadius(DesignTokens.Radius.m)
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
      .scrollContentBackground(.hidden)
      .background(DesignTokens.Colors.backgroundDark)
      .safeAreaInset(edge: .bottom) {
        Spacer().frame(height: 94)
      }
      .navigationTitle("買い物リスト")
      .overlay(alignment: .bottom) {
        bottomBar
      }
    }
    .background(DesignTokens.Colors.backgroundDark)
    .navigationViewStyle(.stack)
    .sheet(item: $editingItem) { item in
      ShoppingItemRegisterView(itemToEdit: item) { updatedItem in
        withAnimation {
          shoppingViewModel.updateItem(updatedItem)
        }
      }
    }
    .sheet(isPresented: $showingRegister) {
      ShoppingItemRegisterView { newItem in
        withAnimation {
          shoppingViewModel.add(newItem)
        }
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
    HStack(spacing: DesignTokens.Spacing.xl) {
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
    .font(DesignTokens.Typography.body)
    .padding(DesignTokens.Spacing.l)
    .frame(maxWidth: .infinity)
    .background(DesignTokens.Colors.surface)
  }
}
