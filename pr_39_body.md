### 概要
退会機能（アカウント削除）およびプライバシーポリシー画面を実装し、法規遵守とUXの向上を図りました。

### 行ったこと
- **退会機能の追加 (#39)**:
  - `ProfileRepository` に `deleteUser` メソッドを追加。
  - Supabase Edge Function (`delete-user`) を実装し、Admin APIを使用してユーザー認証情報および関連データを完全に削除する仕組みを構築。
  - `ProfileScreen` に「アカウントを削除する」ボタンと確認ダイアログを追加。
- **プライバシーポリシー画面の実装 (#39)**:
  - `PRIVACY_POLICY.md` を作成し、アプリのアセットとして追加。
  - `PrivacyPolicyScreen` を作成し、Markdown形式でポリシーを表示。
  - アプリ内の各所（サイドメニュー、プロフィール画面、新規登録画面）からポリシーにアクセスできるリンクを追加。
- **テストの追加**:
  - `test/auth_flow_test.dart` に、プロフィール画面からプライバシーポリシー画面への遷移テストを追加。

### レビュー観点
- 退会処理時、Edge Functionを介して確実にユーザー削除が行われる構成になっているか。
- 新規登録時にプライバシーポリシーへの同意を促す文言が適切に配置されているか。
- `test/auth_flow_test.dart` が正常にパスすること（ローカルで確認済み）。

### 動作確認コマンド
```bash
flutter test test/auth_flow_test.dart
```
