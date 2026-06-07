# リリースガイド

## 1. プロダクション環境への切り替え

現在は開発用の Supabase プロジェクトを使用しています。リリース時には以下の手順でプロダクション環境へ切り替えてください。

### Supabase の設定
1. プロダクション用の Supabase プロジェクトを新規作成します。
2. `supabase/migrations` の各SQLファイルを順に適用して、テーブル構造とRLSポリシーを構築します。
3. `supabase/functions/delete-user` をデプロイします。
   ```bash
   supabase functions deploy delete-user --project-ref <prod-project-id>
   ```

### アプリの設定
1. `.env` ファイルにプロダクション用の URL と Anon Key を設定します（現在は `lib/main.dart` に直書きされていますが、環境変数への移行が推奨されます）。
2. `lib/main.dart` の `Supabase.initialize` でプロダクション環境の値を読み込むように修正します。

## 2. バージョン管理

`pubspec.yaml` の `version` フィールドで管理します。

- 形式: `x.y.z+n`
  - `x.y.z`: セマンティックバージョニング（メジャー.マイナー.パッチ）
  - `n`: ビルド番号（リリースごとに必ずインクリメントする）
- 例: 初回リリース `1.0.0+1`, 次のパッチリリース `1.0.1+2`

## 3. ビルド手順 (iOS)

1. `flutter clean`
2. `flutter pub get`
3. Xcode で `Runner.xcworkspace` を開く
4. `Product` -> `Archive`
5. App Store Connect にアップロード

## 4. ストア掲載情報の確認
- [ ] アプリアイコン
- [ ] スプラッシュスクリーン
- [ ] 利用規約
- [ ] プライバシーポリシー
- [ ] お問い合わせ先 (support@example.com を実際のメールアドレスに変更)
- [ ] ストア掲載用メタデータ (STORE_METADATA.md 参照)
