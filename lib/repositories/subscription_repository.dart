import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription.dart';

/// サブスクリプションデータの取得・保存を管理するリポジトリクラス
class SubscriptionRepository {
  SubscriptionRepository(this._client);

  final SupabaseClient _client;

  /// Supabaseのテーブル参照
  SupabaseQueryBuilder get _table => _client.from('subscriptions');

  /// サブスクリプション一覧をリアルタイムで取得する
  Stream<List<Subscription>> watchSubscriptions() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    // サブスクリプション本体のストリーム
    return _table
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((maps) async {
          final subscriptions = <Subscription>[];
          
          for (final map in maps) {
            final data = Map<String, dynamic>.from(map);
            data['id'] = map['id'];
            data['nextPaymentDate'] = data['next_payment_date'];
            data.remove('next_payment_date');

            // 紐付いているタグのIDを取得
            final tagResponse = await _client
                .from('subscription_tags')
                .select('tag_id')
                .eq('subscription_id', map['id']);
            
            final tagIds = (tagResponse as List)
                .map((item) => item['tag_id'] as String)
                .toList();
            
            data['tags'] = tagIds;
            subscriptions.add(Subscription.fromJson(data));
          }
          return subscriptions;
        });
  }

  /// 新規サブスクリプションを追加する
  Future<void> addSubscription(Subscription subscription) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('ログインが必要です');

    final json = subscription.toJson();
    
    // Supabaseのテーブル定義に合わせたJSONを構築
    final Map<String, dynamic> supabaseJson = {
      'user_id': user.id,
      'name': json['name'],
      'amount': json['amount'],
      'cycle': json['cycle'],
      'next_payment_date': json['nextPaymentDate'],
      'payment_method_id': json['paymentMethod']?.isEmpty ?? true ? null : json['paymentMethod'],
    };

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
      if (e is PostgrestException) {
        print('Supabase Error: ${e.message}, Detail: ${e.details}');
      }
      rethrow;
    }
  }

  /// サブスクリプション情報を更新する
  Future<void> updateSubscription(Subscription subscription) async {
    final json = subscription.toJson();
    final id = json['id'];
    
    // Supabaseのテーブル定義に合わせたJSONを構築
    final Map<String, dynamic> supabaseJson = {
      'name': json['name'],
      'amount': json['amount'],
      'cycle': json['cycle'],
      'next_payment_date': json['nextPaymentDate'],
      'payment_method_id': json['paymentMethod']?.isEmpty ?? true ? null : json['paymentMethod'],
    };

    // サブスクリプション本体の更新
    await _table.update(supabaseJson).eq('id', id);

    // タグの紐付け更新（一度全て削除して再登録）
    await _client.from('subscription_tags').delete().eq('subscription_id', id);
    if (subscription.tags.isNotEmpty) {
      final List<Map<String, dynamic>> tagInserts = subscription.tags.map((tagId) => {
        'subscription_id': id,
        'tag_id': tagId,
      }).toList();
      await _client.from('subscription_tags').insert(tagInserts);
    }
  }

  /// サブスクリプションを削除する
  Future<void> deleteSubscription(String id) async {
    await _table.delete().eq('id', id);
  }
}
