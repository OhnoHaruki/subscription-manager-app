# アーキテクチャ定義書: Subscription Manager App

## ディレクトリ構成
- `lib/`: アプリケーションのメインソースコード
  - `models/`: データモデル（Freezed使用）
  - `providers/`: 状態管理（Riverpod使用）
  - `repositories/`: データアクセス層（Supabase）
  - `services/`: ドメインロジック、外部サービス（API等）
  - `screens/`: UI画面
  - `widgets/`: 共通部品

## 責務の分離
- **Models**: データ構造の定義。ロジックは持たない。
- **Repositories**: Supabase への直接アクセスを担当。データの変換もここで行う。
- **Services**: 複雑なビジネスロジック、フィルタリング、ソート、集計を担当。Provider から呼び出される。
- **Providers**: アプリの状態保持、Repository と Service のオーケストレーションを担当。
- **Screens/Widgets**: UI表示。状態の購読とイベントの発火を担当。ビジネスロジックは記述しない。

## 設計ルール
- ビジネスロジックを UI や Provider に直接書かないこと（Service へ抽出する）。
- Riverpod は状態の受け渡しに徹すること。
- 非同期処理は適切に `AsyncValue` 等でハンドリングすること。
