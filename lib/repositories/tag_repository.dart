import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tag.dart';

/// タグの取得・保存を管理するリポジトリクラス
class TagRepository {
  TagRepository(this._client);

  final SupabaseClient _client;

  /// Supabaseのテーブル参照
  SupabaseQueryBuilder get _table => _client.from('tags');

  /// タグ一覧をリアルタイムで取得する
  Stream<List<Tag>> watchTags() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _table
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((maps) {
          return maps.map((map) {
            final data = Map<String, dynamic>.from(map);
            data['userId'] = data['user_id'];
            data.remove('user_id');
            return Tag.fromJson(data);
          }).toList();
        });
  }

  /// 新規タグを追加する
  Future<void> addTag(String name) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('ログインが必要です');

    await _table.insert({
      'user_id': user.id,
      'name': name,
    });
  }

  /// タグを削除する
  Future<void> deleteTag(String id) async {
    await _table.delete().eq('id', id);
  }

  /// タグ名を更新する
  Future<void> updateTag(String id, String name) async {
    await _table.update({'name': name}).eq('id', id);
  }
}
