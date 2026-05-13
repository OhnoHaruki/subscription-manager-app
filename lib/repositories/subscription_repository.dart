import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

/// サブスクリプションデータの取得・保存を管理するリポジトリクラス
class SubscriptionRepository {
  SubscriptionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Firestoreのコレクション参照
  /// ※ 実際のアカウント連携時は `.collection('users').doc(userId).collection('subscriptions')` 
  /// のようにユーザーごとにサブコレクションを分けるのが一般的ですが、
  /// まずは簡易的にトップレベルの `subscriptions` コレクションを使用します。
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('subscriptions');

  /// サブスクリプション一覧をリアルタイムで取得する
  Stream<List<Subscription>> watchSubscriptions() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // ドキュメントIDをモデルのidフィールドに反映させてパース
        final data = doc.data();
        data['id'] = doc.id;
        return Subscription.fromJson(data);
      }).toList();
    });
  }

  /// 新規サブスクリプションを追加する
  Future<String> addSubscription(Subscription subscription) async {
    // 登録時はIDを自動生成させるため、idフィールドを除いたMapを送信
    final json = subscription.toJson();
    json.remove('id');
    
    final docRef = await _collection.add(json);
    return docRef.id;
  }

  /// サブスクリプション情報を更新する
  Future<void> updateSubscription(Subscription subscription) async {
    final json = subscription.toJson();
    final id = json.remove('id');
    
    if (id == null || (id as String).isEmpty) {
      throw Exception('Update failed: Subscription ID is empty');
    }

    await _collection.doc(id).update(json);
  }

  /// サブスクリプションを削除する
  Future<void> deleteSubscription(String id) async {
    await _collection.doc(id).delete();
  }
}
