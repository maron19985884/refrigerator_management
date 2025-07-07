// TemplateListView.swift
// テンプレート一覧から買い物リストへ追加する画面

import SwiftUI

struct TemplateListView: View {
    @ObservedObject var templateViewModel: TemplateViewModel
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var templateToApply: Template? = nil
    @State private var showingConfirm = false
    @State private var editingIndex: Int? = nil
    @State private var showingEditSheet = false
    @State private var deleteIndexSet: IndexSet? = nil
    @State private var showingDeleteConfirm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(templateViewModel.templates.indices, id: \.self) { index in
                    let template = templateViewModel.templates[index]
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.title3)
                                .bold()
                                .underline()
                            ForEach(template.items) { item in
                                Text("\(item.name) × \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Button(action: {
                            editingIndex = index
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        templateToApply = template
                        showingConfirm = true
                    }
                }
                .onDelete { indexSet in
                    deleteIndexSet = indexSet
                    showingDeleteConfirm = true
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("買い物テンプレート")
        }
        .alert("このテンプレートを買い物リストに反映しますか？", isPresented: $showingConfirm, presenting: templateToApply) { template in
            Button("キャンセル", role: .cancel) {}
            Button("追加") {
                addTemplateToShoppingList(template)
                presentationMode.wrappedValue.dismiss()
            }
        } message: { _ in
            Text("")
        }
        .sheet(isPresented: $showingEditSheet) {
            if let index = editingIndex {
                NavigationView {
                    TemplateEditView(template: $templateViewModel.templates[index])
                }
            }
        }
        .alert("テンプレートを削除しますか？", isPresented: $showingDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let set = deleteIndexSet {
                    set.forEach { index in
                        templateViewModel.deleteTemplate(at: index)
                    }
                    deleteIndexSet = nil
                }
            }
        }
    }

    // テンプレートを買い物リストに反映（重複時は数量加算）
    private func addTemplateToShoppingList(_ template: Template) {
        for item in template.items {
            if let index = shoppingViewModel.shoppingItems.firstIndex(where: { $0.name == item.name }) {
                shoppingViewModel.shoppingItems[index].quantity += item.quantity
                shoppingViewModel.shoppingItems[index].expirationDate = item.expirationDate
                shoppingViewModel.shoppingItems[index].expirationPeriod = item.expirationPeriod
                shoppingViewModel.shoppingItems[index].storageType = item.storageType
                shoppingViewModel.shoppingItems[index].category = item.category
            } else {
                let newItem = ShoppingItem(
                    name: item.name,
                    quantity: item.quantity,
                    expirationDate: item.expirationDate,
                    expirationPeriod: item.expirationPeriod,
                    storageType: item.storageType,
                    category: item.category
                )
                shoppingViewModel.shoppingItems.append(newItem)
            }
        }
        shoppingViewModel.save()
    }
}
