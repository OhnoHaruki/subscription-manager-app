import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/payment_history.dart';
import '../repositories/payment_history_repository.dart';
import 'subscription_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final paymentHistoryRepositoryProvider = Provider((ref) => PaymentHistoryRepository(Supabase.instance.client));

final paymentHistoryProvider = FutureProvider<List<PaymentHistory>>((ref) async {
  return ref.watch(paymentHistoryRepositoryProvider).getAllHistory();
});

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

/// 過去6ヶ月の支出推移Provider
final monthlyExpenditureTrendProvider = FutureProvider<Map<String, double>>((ref) async {
  final history = await ref.watch(paymentHistoryProvider.future);
  final Map<String, double> trend = {};
  
  final now = DateTime.now();
  for (int i = 5; i >= 0; i--) {
    final monthDate = DateTime(now.year, now.month - i);
    final monthKey = DateFormat('yyyy-MM').format(monthDate);
    trend[monthKey] = 0;
  }

  for (final h in history) {
    final monthKey = DateFormat('yyyy-MM').format(h.paidDate);
    if (trend.containsKey(monthKey)) {
      trend[monthKey] = (trend[monthKey] ?? 0) + h.amount.toDouble();
    }
  }
  return trend;
});
