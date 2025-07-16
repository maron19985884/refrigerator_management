//
//  refrigerator_managementApp.swift
//  refrigerator_management
//
//  Created by 小林　景大 on 2025/05/21.
//

import SwiftUI
import GoogleMobileAds

/// Google Mobile Ads の初期化を行う AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // AdMob SDK の初期化
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}

@main
struct refrigerator_managementApp: App {
    /// UIApplicationDelegateAdaptor で AppDelegate を使用
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // アプリのメイン画面を表示
            ContentView()
                // アプリ全体のロケールを日本語に設定
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .tint(.mint)
        }
    }
}
