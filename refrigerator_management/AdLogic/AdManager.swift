import GoogleMobileAds
import UIKit

/// インタースティシャル広告の読み込みと表示を管理するシングルトンクラス
final class AdManager: NSObject, GADFullScreenContentDelegate {
    static let shared = AdManager()

    /// 読み込んだインタースティシャル広告
    private var interstitial: GADInterstitialAd?
    /// 連続表示を防ぐフラグ
    private var hasShown = false

    /// テスト用インタースティシャル広告ユニットID
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"

    private override init() {
        super.init()
    }

    /// 広告を読み込む
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("[AdManager] Failed to load interstitial: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
            self?.hasShown = false
        }
    }

    /// 読み込まれた広告を表示する
    func showInterstitial(from rootViewController: UIViewController) {
        guard let ad = interstitial, !hasShown else { return }
        ad.present(fromRootViewController: rootViewController)
        hasShown = true
    }

    // MARK: - GADFullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitial = nil
    }
}
