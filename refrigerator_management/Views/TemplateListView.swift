// TemplateListView.swift
// テンプレート一覧から買い物リストへ追加する画面

import SwiftUI

struct TemplateListView: View {
    @ObservedObject var templateViewModel: TemplateViewModel
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(templateViewModel.templates.indices, id: \.self) { index in
                    let template = templateViewModel.templates[index]
                    VStack(alignment: .leading) {
                        Text("テンプレート \(index + 1)")
                            .font(.headline)
                        ForEach(template) { item in
                            Text("\(item.name) × \(item.quantity)")
                        }
                    }
                    .onTapGesture {
                        addTemplateToShoppingList(template)
                        presentationMode.wrappedValue.dismiss()
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
    }

    // テンプレートを買い物リストに反映（重複時は数量加算）
    private func addTemplateToShoppingList(_ template: [TemplateItem]) {
        for item in template {
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
