import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import 'subscription_provider.dart';

/// 統計情報を表すモデル
class SubscriptionStats {
  final double monthlyTotal;
  final double yearlyTotal;
  final Map<String, double> amountByTag; // TagID -> MonthlyAmount

  SubscriptionStats({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.amountByTag,
  });
}

/// 統計情報を計算するProvider
final subscriptionStatsProvider = Provider<SubscriptionStats>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider).value ?? [];

  double monthlyTotal = 0;
  Map<String, double> amountByTag = {};

  for (final sub in subscriptions) {
    double monthlyAmount = sub.cycle == BillingCycle.monthly 
        ? sub.amount.toDouble() 
        : sub.amount / 12.0;
    
    monthlyTotal += monthlyAmount;

    for (final tagId in sub.tags) {
      amountByTag[tagId] = (amountByTag[tagId] ?? 0) + monthlyAmount;
    }
    
    // タグがない場合の「未分類」用
    if (sub.tags.isEmpty) {
      const unclassified = 'unclassified';
      amountByTag[unclassified] = (amountByTag[unclassified] ?? 0) + monthlyAmount;
    }
  }

  return SubscriptionStats(
    monthlyTotal: monthlyTotal,
    yearlyTotal: monthlyTotal * 12,
    amountByTag: amountByTag,
  );
});
