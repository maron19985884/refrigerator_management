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
            HStack(alignment: .top) {
              if editMode == .active {
                Button(action: {
                  if selection.contains(item.id) {
                    selection.remove(item.id)
                  } else {
                    selection.insert(item.id)
                  }
                }) {
                  Image(
                    systemName: selection.contains(item.id) ? "checkmark.circle.fill" : "circle"
                  )
                  .resizable()
                  .frame(width: 28, height: 28)
                  .foregroundColor(selection.contains(item.id) ? .red : .gray)
                  .padding(.trailing, 8)
                }
                .buttonStyle(.borderless)
              }

              VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                  .font(.headline)
                HStack(spacing: 8) {
                  Text("x\(item.quantity)")
                  Text(item.category.rawValue)
                  Text(dateLabel(for: item.expirationDate))
                    .foregroundColor(color(for: item.expirationDate))
                }
                .font(.caption)
                .foregroundColor(.gray)
              }
              Spacer()
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .background(
              editMode == .active
                ? (selection.contains(item.id) ? Color.red.opacity(0.15) : Color.clear)
                : Color.clear
            )
            .cornerRadius(8)
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
            .swipeActions {
              Button(role: .destructive) {
                if let index = filteredItems.firstIndex(where: { $0.id == item.id }) {
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
        .safeAreaInset(edge: .bottom) {
          Spacer().frame(height: 94)
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
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        EditButton()
        Button(action: { showingRegister = true }) {
          Image(systemName: "plus")
        }
      }
      ToolbarItemGroup(placement: .bottomBar) {
        if editMode == .active {
          Button(role: .destructive) {
            deleteOffsets = nil
            showingDeleteConfirm = true
          } label: {
            Label("削除", systemImage: "trash")
          }
          .disabled(selection.isEmpty)
        }
      }
    }
    .toolbarBackground(.visible, for: .bottomBar)
    .alert("選択した項目を削除しますか？", isPresented: $showingDeleteConfirm) {
      Button("キャンセル", role: .cancel) {}
      Button("削除", role: .destructive) {
        performDelete()
      }
    }
    .onDisappear {
      editMode = .inactive
      selection.removeAll()
    }
    .navigationTitle("食材一覧")
  }

  // MARK: - Private Methods

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
    DateUtils.color(for: date)
  }

  func dateLabel(for date: Date) -> String {
    DateUtils.label(for: date)
  }
}
