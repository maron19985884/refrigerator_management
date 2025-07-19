//
//  refrigerator_managementUITests.swift
//  refrigerator_managementUITests
//
//  Created by 小林　景大 on 2025/05/21.
//

import XCTest

final class refrigerator_managementUITests: XCTestCase {

    override func setUpWithError() throws {
        // 各テストメソッド実行前に呼ばれるセットアップ処理

        // UI テストでは失敗時に直ちに停止するのが一般的
        continueAfterFailure = false

        // テスト実行前に必要な初期状態（画面の向きなど）を設定
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
