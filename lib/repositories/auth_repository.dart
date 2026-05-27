import 'package:supabase_flutter/supabase_flutter.dart';

/// 認証処理を管理するリポジトリクラス
class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  /// 認証状態の変化を監視するストリーム
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// メールアドレスとパスワードでログイン
  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// メールアドレスとパスワードで新規登録
  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  /// サインアウト
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 現在のユーザー情報を取得
  User? get currentUser => _client.auth.currentUser;
}
