import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_history.dart';

/// 支払い履歴の取得・保存を管理するリポジトリクラス
class PaymentHistoryRepository {
  PaymentHistoryRepository(this._client);

  final SupabaseClient _client;

  /// Supabaseのテーブル参照
  SupabaseQueryBuilder get _table => _client.from('payment_histories');

  /// 全ての支払い履歴を取得する
  Future<List<PaymentHistory>> getAllHistory() async {
    final response = await _table
        .select()
        .order('paid_date', ascending: false);

    return (response as List).map((map) {
      final data = Map<String, dynamic>.from(map);
      data['id'] = map['id'];
      data['subscriptionId'] = map['subscription_id'];
      data['paidDate'] = map['paid_date'];
      data['amount'] = map['amount'];
      return PaymentHistory.fromJson(data);
    }).toList();
  }

  /// 特定のサブスクリプションの支払い履歴を取得する
  Future<List<PaymentHistory>> getHistory(String subscriptionId) async {
    final response = await _table
        .select()
        .eq('subscription_id', subscriptionId)
        .order('paid_date', ascending: false);

    return (response as List).map((map) {
      final data = Map<String, dynamic>.from(map);
      data['id'] = map['id'];
      data['subscriptionId'] = map['subscription_id'];
      data['paidDate'] = map['paid_date'];
      data['amount'] = map['amount'];
      return PaymentHistory.fromJson(data);
    }).toList();
  }

  /// 支払いを記録する
  Future<void> addHistory(PaymentHistory history) async {
    await _table.insert({
      'subscription_id': history.subscriptionId,
      'paid_date': history.paidDate.toIso8601String(),
      'amount': history.amount,
    });
  }
}
