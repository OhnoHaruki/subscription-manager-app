### 概要
ユーザーが自身の情報を管理できるプロフィール画面を実装しました。また、前回のタスクで残存していたFirebase関連のコード・設定を完全に削除し、アプリ全体のナビゲーションを整理しました。

### 行ったこと
- **プロフィール機能の実装 (#15)**:
  - `Profile` モデル（Freezedによる不変モデル）の作成。
  - `ProfileRepository`: プロフィール情報の取得・更新ロジック。初回ログインユーザー等のレコード未存在時に自動生成するロジック（`maybeSingle`と`insert`の組み合わせ）を追加。
  - `profileProvider`: Riverpodによるプロファイル状態の提供。
  - `ProfileScreen`: 
    - ユーザーのメールアドレス（読み取り専用）とユーザー名（編集可能）の表示。
    - インプレース編集UI、ローディング表示、スナックバーによる通知。
- **ナビゲーションの改善 (#15)**:
  - `SubscriptionListScreen` の Drawer に「プロフィール」メニューを追加。
  - AppBar からログアウトボタンを削除し、プロフィール画面への遷移ボタン（人物アイコン）を配置。
  - ログアウト機能を `ProfileScreen` 内に集約し、誤操作防止の確認ダイアログを実装。
- **Firebaseの完全削除 (#13の残り作業)**:
  - `pubspec.yaml` から `firebase_core`, `firebase_auth`, `cloud_firestore` を削除。
  - `lib/firebase_options.dart`, `firebase.json`, Android/iOS の設定ファイル（`google-services.json`, `GoogleService-Info.plist`）を削除。
- **テストの強化**:
  - `test/auth_flow_test.dart` を更新。モックを用いて「未ログイン」「ログイン済み」「プロフィール画面への遷移とデータ表示」のシナリオを自動テスト化。

### レビュー観点
- `ProfileRepository.getProfile()` における、レコード自動生成ロジックの安全性。
- 非同期処理中の `BuildContext` 利用に関する警告の修正（`Navigator.of(context)` の変数保持）。
- Firebase関連の削除漏れがないか。
- `test/auth_flow_test.dart` が正常にパスすること（ローカルで確認済み）。

### 動作確認コマンド
```bash
flutter test test/auth_flow_test.dart
```
