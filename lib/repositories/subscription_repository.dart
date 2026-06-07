import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  final SupabaseClient _client;

  SubscriptionRepository(this._client);

  PostgrestQueryBuilder get _table => _client.from('subscriptions');

  /// 全てのサブスクリプションを取得
  Future<List<Subscription>> getAllSubscriptions() async {
    final response = await _table.select('*, tags:subscription_tags(tag_id)').order('created_at');
    return (response as List).map((data) => Subscription.fromJson(data)).toList();
  }

  /// リアルタイムでサブスクリプション一覧を監視
  Stream<List<Subscription>> watchSubscriptions() {
    return _client
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => Subscription.fromJson(json)).toList());
  }

  /// サブスクリプションを追加
  Future<void> addSubscription(Subscription subscription) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final supabaseJson = {
      ...subscription.toJson(),
      'user_id': user.id,
    };
    // idは自動生成されるため除外
    supabaseJson.remove('id');
    // tagsは別テーブルで管理するため除外
    supabaseJson.remove('tags');

    try {
      // サブスクリプションの挿入
      final response = await _table.insert(supabaseJson).select().single();
      final String subscriptionId = response['id'];

      // タグの紐付け
      if (subscription.tags.isNotEmpty) {
        final List<Map<String, dynamic>> tagInserts = subscription.tags.map((tagId) => {
          'subscription_id': subscriptionId,
          'tag_id': tagId,
        }).toList();
        await _client.from('subscription_tags').insert(tagInserts);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// サブスクリプションを更新
  Future<void> updateSubscription(Subscription subscription) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final supabaseJson = {
      ...subscription.toJson(),
      'user_id': user.id,
    };
    // tagsは別テーブルで管理するため除外
    supabaseJson.remove('tags');

    try {
      await _table.update(supabaseJson).eq('id', subscription.id);

      // タグの更新（一度削除して再登録）
      await _client.from('subscription_tags').delete().eq('subscription_id', subscription.id);
      if (subscription.tags.isNotEmpty) {
        final List<Map<String, dynamic>> tagInserts = subscription.tags.map((tagId) => {
          'subscription_id': subscription.id,
          'tag_id': tagId,
        }).toList();
        await _client.from('subscription_tags').insert(tagInserts);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// サブスクリプションを削除
  Future<void> deleteSubscription(String id) async {
    try {
      // 外部キー制約により、subscription_tagsも削除される（CASCADE想定）
      // もしCASCADEでない場合は、明示的に削除する必要がある
      await _table.delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
