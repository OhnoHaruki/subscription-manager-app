import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription.dart';
import '../repositories/subscription_repository.dart';

/// Supabaseクライアントを提供するProvider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// SubscriptionRepositoryのインスタンスを提供するProvider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(supabaseProvider));
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
