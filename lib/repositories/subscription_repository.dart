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

    return _table
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((maps) {
          return maps.map((map) {
            final data = Map<String, dynamic>.from(map);
            data['id'] = map['id'];
            data['nextPaymentDate'] = data['next_payment_date'];
            data.remove('next_payment_date');
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
      await _table.insert(supabaseJson);
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

    await _table.update(supabaseJson).eq('id', id);
  }

  /// サブスクリプションを削除する
  Future<void> deleteSubscription(String id) async {
    await _table.delete().eq('id', id);
  }
}
