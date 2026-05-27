import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_method.dart';

/// 支払い方法（クレジットカード、銀行口座など）のデータを管理するリポジトリクラス
class PaymentMethodRepository {
  PaymentMethodRepository(this._client);

  final SupabaseClient _client;

  /// Supabaseのテーブル参照
  SupabaseQueryBuilder get _table => _client.from('payment_methods');

  /// 支払い方法一覧をリアルタイムで取得する
  Stream<List<PaymentMethod>> watchPaymentMethods() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _table
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((maps) {
          return maps.map((map) {
            final data = Map<String, dynamic>.from(map);
            data['expiryDate'] = data['expiry_date'];
            data.remove('expiry_date');
            return PaymentMethod.fromJson(data);
          }).toList();
        });
  }

  /// 新規支払い方法を追加する
  Future<void> addPaymentMethod(PaymentMethod method) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('ログインが必要です');

    final json = method.toJson();

    final Map<String, dynamic> supabaseJson = {
      'user_id': user.id,
      'name': json['name'],
      'type': json['type'],
      'last4': json['last4'],
      'expiry_date': json['expiryDate'],
    };

    await _table.insert(supabaseJson);
  }


  /// 支払い方法情報を更新する
  Future<void> updatePaymentMethod(PaymentMethod method) async {
    final json = method.toJson();
    final id = json['id'];

    final Map<String, dynamic> supabaseJson = {
      'name': json['name'],
      'type': json['type'],
      'last4': json['last4'],
      'expiry_date': json['expiryDate'],
    };

    await _table.update(supabaseJson).eq('id', id);
  }

  /// 支払い方法を削除する
  Future<void> deletePaymentMethod(String id) async {
    await _table.delete().eq('id', id);
  }
}
