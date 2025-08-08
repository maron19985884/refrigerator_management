import SwiftUI
// Design Tokens


struct FoodListView: View {
  @State private var selectedStorage: StorageType = .fridge
  @State private var showingRegister = false
  @State private var editingItem: FoodItem? = nil
  @StateObject var viewModel: FoodViewModel

  var filteredItems: [FoodItem] {
    viewModel.items(for: selectedStorage)
  }

  var body: some View {
    NavigationView {
      VStack {
        Picker("保存場所", selection: $selectedStorage) {
          ForEach(StorageType.allCases) { type in
            Text(type.rawValue).tag(type)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignTokens.Spacing.l)

        List {
          ForEach(filteredItems) { item in
            HStack(alignment: .top, spacing: DesignTokens.Spacing.m) {
              Text(item.storageType.icon)
                .font(DesignTokens.Typography.title)
                .frame(width: 24)
              VStack(alignment: .leading, spacing: DesignTokens.Spacing.s / 2) {
                HStack {
                  Text(item.name)
                    .font(DesignTokens.Typography.body).bold()
                  Text(item.category.icon)
                }
                HStack(spacing: DesignTokens.Spacing.s) {
                  Text("x\(item.quantity)")
                  Text(item.category.rawValue)
                  Text(dateLabel(for: item.expirationDate))
                    .foregroundColor(color(for: item.expirationDate))
                  if DateUtils.isExpiringSoon(item.expirationDate) {
                    Text("⚠️")
                  }
                }
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Colors.onMuted)
              }
              Spacer()
            }
            .padding(.vertical, DesignTokens.Spacing.s / 2)
            .contentShape(Rectangle())
            .background(item.storageType.color.opacity(0.1))
            .cornerRadius(DesignTokens.Radius.m)
            .onTapGesture {
              editingItem = item
            }
            .swipeActions {
              Button(role: .destructive) {
                if let index = filteredItems.firstIndex(where: { $0.id == item.id }) {
                  withAnimation {
                    viewModel.foodItems.removeAll { $0.id == item.id }
                  }
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
      }
      .navigationTitle("在庫リスト")
      .overlay(alignment: .bottom) {
        bottomBar
      }
    }
    .background(DesignTokens.Colors.backgroundDark)
    .navigationViewStyle(.stack)
    .sheet(isPresented: $showingRegister) {
      FoodRegisterView { newItem in
        withAnimation {
          viewModel.add(item: newItem)
        }
      }
    }
    .sheet(item: $editingItem) { item in
      FoodRegisterView(itemToEdit: item) { updatedItem in
        if let index = viewModel.foodItems.firstIndex(where: { $0.id == updatedItem.id }) {
          withAnimation {
            viewModel.foodItems[index] = updatedItem
          }
        }
      }
    }
  }

  // MARK: - Helpers

  private func color(for date: Date) -> Color {
    DateUtils.color(for: date)
  }

  private func dateLabel(for date: Date) -> String {
    DateUtils.label(for: date)
  }

  private var bottomBar: some View {
    HStack {
      Spacer()
      Button(action: {
        showingRegister = true
      }) {
        Label("追加", systemImage: "plus")
      }
      Spacer()
    }
    .font(DesignTokens.Typography.body)
    .padding(DesignTokens.Spacing.l)
    .background(DesignTokens.Colors.surface)
  }
}
