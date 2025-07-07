import SwiftUI
import GoogleMobileAds

/// Google AdMob バナー広告ビュー
struct BannerAdView: UIViewRepresentable {
    /// 表示する広告ユニットID
    var adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // 特に更新処理は不要
    }
}
