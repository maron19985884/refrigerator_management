import SwiftUI

/// アプリのメイン画面を構成する View
struct ContentView: View {
    /// 在庫を管理する ViewModel
    @StateObject private var foodViewModel = FoodViewModel()
    /// 買い物リストを管理する ViewModel
    @StateObject private var shoppingViewModel = ShoppingViewModel()
    /// テンプレートを管理する ViewModel
    @StateObject private var templateViewModel = TemplateViewModel()

    var body: some View {
        // TabView で在庫・買い物・テンプレートを切り替える
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView {
                // 在庫タブ
                FoodListView(viewModel: foodViewModel)
                    .tabItem {
                        Label("在庫", systemImage: "tray.full")
                    }

                // 買い物リストタブ
                ShoppingListView(
                    shoppingViewModel: shoppingViewModel,
                    foodViewModel: foodViewModel,
                    templateViewModel: templateViewModel
                )
                .tabItem {
                    Label("買い物リスト", systemImage: "cart")
                }

                // テンプレートタブ
                TemplateListView(
                    templateViewModel: templateViewModel,
                    shoppingViewModel: shoppingViewModel
                )
                .tabItem {
                    Label("テンプレート", systemImage: "list.bullet.rectangle")
                }
                }
                // 画面下部に常に表示するバナー広告
                BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                    .frame(width: 320, height: 50)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
