// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var foodViewModel = FoodViewModel()
    @StateObject private var shoppingViewModel = ShoppingViewModel()
    @StateObject private var templateViewModel = TemplateViewModel()

    var body: some View {
        TabView {
            NavigationView {
                FoodListView(viewModel: foodViewModel)
            }
            .tabItem {
                Label("在庫", systemImage: "tray.full")
            }

            NavigationView {
                ShoppingListView(
                    shoppingViewModel: shoppingViewModel,
                    foodViewModel: foodViewModel
                )
            }
            .tabItem {
                Label("買い物リスト", systemImage: "cart")
            }

            NavigationView {
                TemplateListView(
                    templateViewModel: templateViewModel,
                    shoppingViewModel: shoppingViewModel
                )
            }
            .tabItem {
                Label("テンプレート", systemImage: "list.bullet.rectangle")
            }
        }
    }
}

#Preview {
    ContentView()
}
