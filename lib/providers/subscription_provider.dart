import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../repositories/subscription_repository.dart';

/// Firestoreのインスタンスを提供するProvider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// SubscriptionRepositoryのインスタンスを提供するProvider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(firestoreProvider));
});

/// サブスクリプション一覧をリアルタイムで監視するProvider
final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscriptions();
});

/// 月額合計金額を計算するProvider
final monthlyTotalAmountProvider = Provider<double>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider).value ?? [];
  
  return subscriptions.fold(0.0, (previousValue, sub) {
    if (sub.cycle == BillingCycle.monthly) {
      return previousValue + sub.amount;
    } else {
      // 年額の場合は月額換算（12分割）して合算
      return previousValue + (sub.amount / 12);
    }
  });
});
