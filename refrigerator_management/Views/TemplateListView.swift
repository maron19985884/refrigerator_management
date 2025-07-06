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
    @State private var editingName: String = ""
    @State private var showingEditAlert = false

    var body: some View {
        NavigationView {
            List {
                ForEach(templateViewModel.templates.indices, id: \.self) { index in
                    let template = templateViewModel.templates[index]
                    HStack {
                        VStack(alignment: .leading) {
                            Text(template.name)
                                .font(.title2)
                                .bold()
                            ForEach(template.items) { item in
                                Text("\(item.name) × \(item.quantity)")
                            }
                        }
                        Spacer()
                        Button(action: {
                            editingIndex = index
                            editingName = template.name
                            showingEditAlert = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        templateToApply = template
                        showingConfirm = true
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        templateViewModel.deleteTemplate(at: index)
                    }
                }
            }
            .navigationTitle("テンプレート選択")
        }
        .alert("このテンプレートを反映しますか？", isPresented: $showingConfirm, presenting: templateToApply) { template in
            Button("キャンセル", role: .cancel) {}
            Button("追加") {
                addTemplateToShoppingList(template)
                presentationMode.wrappedValue.dismiss()
            }
        } message: { _ in
            Text("")
        }
        .alert("テンプレート名を編集", isPresented: $showingEditAlert) {
            TextField("テンプレート名", text: $editingName)
            Button("保存") {
                if let index = editingIndex {
                    templateViewModel.templates[index].name = editingName
                    templateViewModel.saveTemplates()
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
    }

    // テンプレートを買い物リストに反映（重複時は数量加算）
    private func addTemplateToShoppingList(_ template: Template) {
        for item in template.items {
            if let index = shoppingViewModel.shoppingItems.firstIndex(where: { $0.name == item.name }) {
                shoppingViewModel.shoppingItems[index].quantity += item.quantity
                shoppingViewModel.shoppingItems[index].expirationDate = item.expirationDate
                shoppingViewModel.shoppingItems[index].storageType = item.storageType
                shoppingViewModel.shoppingItems[index].category = item.category
            } else {
                let newItem = ShoppingItem(
                    name: item.name,
                    quantity: item.quantity,
                    expirationDate: item.expirationDate,
                    storageType: item.storageType,
                    category: item.category
                )
                shoppingViewModel.shoppingItems.append(newItem)
            }
        }
        shoppingViewModel.save()
    }
}
