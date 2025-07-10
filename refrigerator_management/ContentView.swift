import SwiftUI

/// アプリのメイン画面を構成する View
struct ContentView: View {
    /// 在庫を管理する ViewModel
    @StateObject private var foodViewModel = FoodViewModel()
    /// 買い物リストを管理する ViewModel
    @StateObject private var shoppingViewModel = ShoppingViewModel()
    /// テンプレートを管理する ViewModel
    @StateObject private var templateViewModel = TemplateViewModel()
    /// ゲーム結果画面の表示状態
    @State private var showingResult = false

    var body: some View {
        // TabView で在庫・買い物・テンプレートを切り替え、下部に広告を配置
        VStack(spacing: 0) {
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

            // サンプルとしてゲームオーバー画面を開くボタン
            Button("ゲーム終了") {
                showingResult = true
            }
            .padding(.vertical)

            // 画面下部に常に表示するバナー広告
            AdMobBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(width: 320, height: 50)
        }
        // ゲーム終了時に表示する画面
        .sheet(isPresented: $showingResult) {
            ResultView()
        }
        // アプリ起動時にインタースティシャル広告を事前読み込み
        .onAppear {
            AdManager.shared.loadInterstitial()
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
