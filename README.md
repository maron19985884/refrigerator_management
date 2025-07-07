# refrigerator_management

冷蔵庫内の食材を在庫・買い物リスト・テンプレートで管理するシンプルなアプリです。

主な機能

- 在庫一覧の閲覧・編集
- 買い物リストの作成と在庫への反映
- よく使うリストをテンプレートとして保存

## 広告表示の設定

このアプリでは Google AdMob を利用してバナー広告を表示しています。開発時はテスト用の AdUnitID（`ca-app-pub-3940256099942544/2934735716`）を使用してください。

### 依存関係の追加

Xcode の `Package Dependencies` に以下の URL を追加します。

```
https://github.com/googleads/swift-package-manager-google-mobile-ads.git
```

### Info.plist の設定例

Info.plist に次のキーを追加してください。

```
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

上記の ID はテスト用です。実運用ではご自身のアプリ ID に置き換えてください。
