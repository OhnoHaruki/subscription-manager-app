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

    final response = await _table
        .select()
        .eq('id', userId)
        .single();

    final data = Map<String, dynamic>.from(response);
    data['createdAt'] = data['created_at'];
    data.remove('created_at');
    
    return Profile.fromJson(data);
  }

  /// プロフィール情報を更新する
  Future<void> updateProfile(Profile profile) async {
    final Map<String, dynamic> supabaseJson = {
      'username': profile.username,
    };

    await _table.update(supabaseJson).eq('id', profile.id);
  }
}
