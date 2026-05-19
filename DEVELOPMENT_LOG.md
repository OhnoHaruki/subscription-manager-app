# 開発ログ: Supabase 移行とリアルタイム同期対応

## 1. Firebase から Supabase への移行
- **パッケージ変更**:
  - `firebase_auth`, `firebase_core`, `cloud_firestore` を削除準備。
  - `supabase_flutter` を追加。
- **初期化処理の変更**:
  - `lib/main.dart` を Firebase 依存から Supabase 依存へ切り替え。
  - プロジェクト URL と API Key を使用して SupabaseClient を初期化。

## 2. データベース設計とテーブル構築
- **テーブル定義 (`supabase/migrations/create_tables.sql`)**:
  - `profiles`: 認証情報を保持するプロファイルテーブル。
  - `payment_methods`: 支払い方法の管理。
  - `subscriptions`: サブスクリプション情報。
  - `tags` / `subscription_tags`: 多対多のリレーション構造を導入。
- **RLS (行レベルセキュリティ) 設定 (`supabase/migrations/enable_rls.sql`)**:
  - 各テーブルにポリシーを適用し、自分のデータのみアクセス可能な構成へ。
- **データ不整合解消 (`supabase/migrations/fix_profiles_constraint.sql`)**:
  - 外部キー制約の調整と、テスト用ダミーユーザーの挿入。

## 3. レポジトリ層とプロバイダ層のリファクタリング
- **Repository層**:
  - `SubscriptionRepository` / `PaymentMethodRepository` を Supabase 向けに書き換え。
  - `insert` / `update` 時の JSON マッピングを Supabase の `snake_case` に対応。
  - `user_id` を Supabase の `auth.currentUser!.id` から動的に取得・挿入するように実装。
- **Provider層**:
  - `firestoreProvider` を廃止し、`supabaseProvider` を導入。
  - `subscription_provider.dart` および `payment_method_provider.dart` を Supabase クライアント依存へ切り替え。

## 4. UI との同期対応
- **リアルタイム反映**:
  - Supabase ダッシュボードで Realtime 機能を有効化。
  - `watchSubscriptions` でのデータマッピング時、`id` を正しく保持するように修正。これにより、追加・削除・更新が即座にUIへ反映されるようになりました。
- **入力 UX 改善**:
  - 金額入力時の自動カンマ区切りフォーマッタ (`_CommaTextInputFormatter`) の実装。
  - `FilteringTextInputFormatter.digitsOnly` を使用した半角数字への入力制限の厳格化。
  - カーソル位置の保持ロジックを実装し、IME変換時や削除時の操作感向上。

## 5. ドキュメント化
- データベース構造を `database_schema.md` として管理。
- 各 Issue への進捗コメントと PR の作成完了。
