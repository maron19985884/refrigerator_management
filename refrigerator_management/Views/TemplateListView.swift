import SwiftUI

struct TemplateListView: View {
    @ObservedObject var templateViewModel: TemplateViewModel
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var templateToApply: Template? = nil
    @State private var showingConfirm = false
    @State private var editingIndex: Int? = nil
    @State private var showingEditSheet = false

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
                                HStack(spacing: 4) {
                                    Text(item.storageType.icon)
                                    Text(item.category.icon)
                                    Text("\(item.name) × \(item.quantity)")
                                }
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
            }
            .listStyle(.insetGrouped)
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: 94)
            }
            .navigationTitle("買い物テンプレート")
            .overlay(alignment: .bottom) {
                bottomBar
            }
        }
        .navigationViewStyle(.stack)
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
    }

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

    private var bottomBar: some View {
        HStack {
            Spacer()
            Button(action: {
                let new = Template(name: "新規テンプレート", items: [])
                withAnimation {
                    templateViewModel.templates.append(new)
                }
                editingIndex = templateViewModel.templates.count - 1
                showingEditSheet = true
            }) {
                Label("追加", systemImage: "plus")
            }
            Spacer()
        }
        .padding()
        .background(.bar)
    }
}
