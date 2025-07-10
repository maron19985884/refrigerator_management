import SwiftUI
import GoogleMobileAds

/// SwiftUI で使用する Google AdMob バナー広告ビュー
struct AdMobBannerView: UIViewRepresentable {
    /// 表示する広告ユニットID
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: .banner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
