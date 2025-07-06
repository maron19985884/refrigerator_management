// TemplateListView.swift
// テンプレート一覧から買い物リストへ追加する画面

import SwiftUI

struct TemplateListView: View {
    @ObservedObject var templateViewModel: TemplateViewModel
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var templateToApply: Template? = nil
    @State private var showingConfirm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(templateViewModel.templates.indices, id: \.self) { index in
                    let template = templateViewModel.templates[index]
                    VStack(alignment: .leading) {
                        Text(template.name)
                            .font(.headline)
                        ForEach(template.items) { item in
                            Text("\(item.name) × \(item.quantity)")
                        }
                    }
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
            .toolbar {
                EditButton()
            }
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
    }

    // テンプレートを買い物リストに反映（重複時は数量加算）
    private func addTemplateToShoppingList(_ template: Template) {
        for item in template.items {
            if let index = shoppingViewModel.shoppingItems.firstIndex(where: { $0.name == item.name }) {
                shoppingViewModel.shoppingItems[index].quantity += item.quantity
            } else {
                let newItem = ShoppingItem(name: item.name, quantity: item.quantity)
                shoppingViewModel.shoppingItems.append(newItem)
            }
        }
        shoppingViewModel.save()
    }
}
