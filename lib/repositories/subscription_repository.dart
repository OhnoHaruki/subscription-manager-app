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
          if (maps.isEmpty) return [];

          final subscriptionIds = maps.map((m) => m['id'] as String).toList();

          // 紐付いているタグを一括取得 (Batch query)
          final tagResponse = await _client
              .from('subscription_tags')
              .select('subscription_id, tag_id')
              .inFilter('subscription_id', subscriptionIds);

          final tagsMap = <String, List<String>>{};
          for (final row in tagResponse as List) {
            final subId = row['subscription_id'] as String;
            final tagId = row['tag_id'] as String;
            tagsMap.putIfAbsent(subId, () => []).add(tagId);
          }

          return maps.map((map) {
            final data = Map<String, dynamic>.from(map);
            data['tags'] = tagsMap[map['id']] ?? [];
            return Subscription.fromJson(data);
          }).toList();
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

  /// 支払い完了を記録し、次回支払日を更新する
  Future<void> markAsPaid(String subscriptionId, DateTime currentNextPaymentDate, int amount) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('ログインが必要です');

    // 次回支払日を計算（月額なら1ヶ月後、年額なら1年後）
    // ※今回は簡略化のため、単純に1ヶ月/1年加算するロジック
    // 実際にはBillingCycle enumを使用する
    final subscription = await _table.select().eq('id', subscriptionId).single();
    final cycle = subscription['cycle'] == 'monthly' ? 'monthly' : 'yearly';
    
    DateTime nextPaymentDate = currentNextPaymentDate;
    if (cycle == 'monthly') {
      nextPaymentDate = DateTime(nextPaymentDate.year, nextPaymentDate.month + 1, nextPaymentDate.day);
    } else {
      nextPaymentDate = DateTime(nextPaymentDate.year + 1, nextPaymentDate.month, nextPaymentDate.day);
    }

    // トランザクション的に処理（SupabaseはRPCを使うのが理想だが、ここでは順次実行）
    await _client.from('payment_histories').insert({
      'subscription_id': subscriptionId,
      'paid_date': DateTime.now().toIso8601String(),
      'amount': amount,
    });

    await _table.update({
      'next_payment_date': nextPaymentDate.toIso8601String(),
    }).eq('id', subscriptionId);
  }

  /// サブスクリプションを削除する
  Future<void> deleteSubscription(String id) async {
    await _table.delete().eq('id', id);
  }
}
