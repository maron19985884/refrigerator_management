//
//  refrigerator_managementApp.swift
//  refrigerator_management
//
//  Created by 小林　景大 on 2025/05/21.
//

import SwiftUI

@main
struct refrigerator_managementApp: App {
    var body: some Scene {
        WindowGroup {
            // アプリのメイン画面を表示
            ContentView()
                // アプリ全体のロケールを日本語に設定
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
