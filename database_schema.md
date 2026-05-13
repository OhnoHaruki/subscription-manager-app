# データベース設計書 (Supabase/PostgreSQL)

本プロジェクトにおける PostgreSQL のテーブル構造を定義します。

## 1. テーブル構成

### `profiles`
認証ユーザー情報の拡張テーブル。
- `id`: UUID (Primary Key, `auth.users.id` にリンク)
- `username`: TEXT
- `created_at`: TIMESTAMP

### `payment_methods`
ユーザーの支払い方法を管理するテーブル。
- `id`: UUID (Primary Key, default: `gen_random_uuid()`)
- `user_id`: UUID (Foreign Key -> `profiles.id`)
- `name`: TEXT (NOT NULL)
- `type`: TEXT (NOT NULL)
- `last4`: TEXT
- `expiry_date`: TIMESTAMP

### `subscriptions`
サブスクリプション情報を管理するテーブル。
- `id`: UUID (Primary Key, default: `gen_random_uuid()`)
- `user_id`: UUID (Foreign Key -> `profiles.id`)
- `payment_method_id`: UUID (Foreign Key -> `payment_methods.id`)
- `name`: TEXT (NOT NULL)
- `amount`: INT (NOT NULL)
- `cycle`: TEXT (NOT NULL)
- `next_payment_date`: TIMESTAMP (NOT NULL)
- `created_at`: TIMESTAMP

### `tags`
タグ定義テーブル。
- `id`: UUID (Primary Key)
- `user_id`: UUID (Foreign Key -> `profiles.id`)
- `name`: TEXT (NOT NULL)

### `subscription_tags`
サブスクとタグの多対多関係を管理する中間テーブル。
- `subscription_id`: UUID (Foreign Key -> `subscriptions.id`)
- `tag_id`: UUID (Foreign Key -> `tags.id`)

## 2. 設計のポイント
- **外部キー制約**: テーブル間の参照整合性をデータベースレベルで保証します。
- **RLS (Row Level Security)**: 各テーブルに `user_id` を持たせ、自分のデータのみアクセス可能な行レベルセキュリティを適用します。
