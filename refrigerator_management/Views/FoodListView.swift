import SwiftUI

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
        .padding(.horizontal)

        List {
          ForEach(filteredItems) { item in
            HStack(alignment: .top, spacing: 12) {
              Text(item.storageType.icon)
                .font(.title3)
                .frame(width: 24)
              VStack(alignment: .leading, spacing: 4) {
                HStack {
                  Text(item.name)
                    .font(.headline)
                  Text(item.category.icon)
                }
                HStack(spacing: 8) {
                  Text("x\(item.quantity)")
                  Text(item.category.rawValue)
                  Text(dateLabel(for: item.expirationDate))
                    .foregroundColor(color(for: item.expirationDate))
                  if DateUtils.isExpiringSoon(item.expirationDate) {
                    Text("⚠️")
                  }
                }
                .font(.caption)
                .foregroundColor(.gray)
              }
              Spacer()
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .background(item.storageType.color.opacity(0.1))
            .cornerRadius(8)
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
        .safeAreaInset(edge: .bottom) {
          Spacer().frame(height: 94)
        }
      }
      .navigationTitle("在庫リスト")
      .overlay(alignment: .bottom) {
        bottomBar
      }
    }
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
    .padding()
    .background(.bar)
  }
}
