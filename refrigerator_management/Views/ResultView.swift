import SwiftUI
import GoogleMobileAds

/// ゲーム終了後の結果表示とインタースティシャル広告表示例
struct ResultView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Game Over")
                .font(.largeTitle)
            Button("閉じる") {
                if let root = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                    .first {
                    AdManager.shared.showInterstitial(from: root)
                }
                dismiss()
            }
            .padding()
        }
        .onAppear {
            AdManager.shared.loadInterstitial()
        }
    }
}

#if DEBUG
struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}
#endif
