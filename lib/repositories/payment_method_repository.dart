import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_method.dart';

/// 支払い方法（クレジットカード、銀行口座など）のデータを管理するリポジトリクラス
class PaymentMethodRepository {
  PaymentMethodRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Firestoreのコレクション参照
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('payment_methods');

  /// 支払い方法一覧をリアルタイムで取得する
  Stream<List<PaymentMethod>> watchPaymentMethods() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PaymentMethod.fromJson(data);
      }).toList();
    });
  }

  /// 新規支払い方法を追加する
  Future<String> addPaymentMethod(PaymentMethod method) async {
    final json = method.toJson();
    json.remove('id');
    
    final docRef = await _collection.add(json);
    return docRef.id;
  }

  /// 支払い方法情報を更新する
  Future<void> updatePaymentMethod(PaymentMethod method) async {
    final json = method.toJson();
    final id = json.remove('id');
    
    if (id == null || (id as String).isEmpty) {
      throw Exception('Update failed: PaymentMethod ID is empty');
    }

    await _collection.doc(id).update(json);
  }

  /// 支払い方法を削除する
  Future<void> deletePaymentMethod(String id) async {
    await _collection.doc(id).delete();
  }
}
