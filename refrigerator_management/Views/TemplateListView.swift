import SwiftUI

struct TemplateListView: View {
    @ObservedObject var templateViewModel: TemplateViewModel
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var templateToApply: Template? = nil
    @State private var showingConfirm = false
    @State private var editingIndex: Int? = nil
    @State private var deletingIndex: Int? = nil
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
                    .swipeActions {
                        Button(role: .destructive) {
                            deletingIndex = index
                            showingDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                        }
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
        .sheet(item: $editingIndex) { index in
            NavigationView {
                TemplateEditView(template: $templateViewModel.templates[index])
            }
        }
        .alert("このテンプレートを削除してもよいですか？", isPresented: $showingDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let index = deletingIndex {
                    withAnimation {
                        templateViewModel.deleteTemplate(at: index)
                    }
                    deletingIndex = nil
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
                    editingIndex = templateViewModel.templates.count - 1
                }
            }) {
                Label("追加", systemImage: "plus")
            }
            Spacer()
        }
        .padding()
        .background(.bar)
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
