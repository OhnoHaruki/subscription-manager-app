import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

/// ユーザープロフィールの取得・更新を管理するリポジトリクラス
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  /// Supabaseのテーブル参照
  SupabaseQueryBuilder get _table => _client.from('profiles');

  /// 現在のユーザープロフィールを取得する
  Future<Profile?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _table
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // プロフィールが存在しない場合は新規作成
        await _table.insert({
          'id': userId,
          'username': null,
        });
        
        // 作成したプロフィールを再取得
        final newResponse = await _table
            .select()
            .eq('id', userId)
            .single();
        return _mapToProfile(newResponse);
      }

      return _mapToProfile(response);
    } catch (e) {
      rethrow;
    }
  }

  /// プロフィール情報を更新する
  Future<void> updateProfile(Profile profile) async {
    final Map<String, dynamic> supabaseJson = {
      'username': profile.username,
    };

    await _table.update(supabaseJson).eq('id', profile.id);
  }

  /// アカウントを削除する
  Future<void> deleteUser() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('ログインが必要です');

    await _client.functions.invoke('delete-user', body: {'user_id': user.id});
    await _client.auth.signOut();
  }

  Profile _mapToProfile(Map<dynamic, dynamic> response) {
    final data = Map<String, dynamic>.from(response);
    data['createdAt'] = data['created_at'];
    data.remove('created_at');
    
    return Profile.fromJson(data);
  }
}
