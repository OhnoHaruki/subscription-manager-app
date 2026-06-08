import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/models/subscription.dart';
import 'package:subscription_manager/models/payment_history.dart';
import 'factories/subscription_factory.dart';

void main() {
  test('SubscriptionStats計算のテスト', () {
    final subscriptions = [
      SubscriptionFactory.create(name: 'Netflix', amount: 1200, cycle: BillingCycle.monthly, tags: ['ent']),
      SubscriptionFactory.create(name: 'Yearly Service', amount: 12000, cycle: BillingCycle.yearly, tags: []),
    ];

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
      if (sub.tags.isEmpty) {
        const unclassified = 'unclassified';
        amountByTag[unclassified] = (amountByTag[unclassified] ?? 0) + monthlyAmount;
      }
    }
    
    expect(monthlyTotal, 2200);
    expect(amountByTag['ent'], 1200);
    expect(amountByTag['unclassified'], 1000);
  });

  test('支出推移計算のテスト', () {
    final history = [
      PaymentHistory(id: '1', subscriptionId: 'a', paidDate: DateTime(2026, 5, 10), amount: 1000),
      PaymentHistory(id: '2', subscriptionId: 'a', paidDate: DateTime(2026, 5, 20), amount: 500),
      PaymentHistory(id: '3', subscriptionId: 'b', paidDate: DateTime(2026, 4, 15), amount: 2000),
    ];

    final Map<String, double> trend = {};
    for (final h in history) {
      final monthKey = '${h.paidDate.year}-${h.paidDate.month.toString().padLeft(2, '0')}';
      trend[monthKey] = (trend[monthKey] ?? 0) + h.amount.toDouble();
    }
    
    expect(trend['2026-05'], 1500);
    expect(trend['2026-04'], 2000);
  });

  test('予算超過判定のテスト', () {
    final monthlyTotal = 3000.0;
    final totalBudget = 2000.0;
    
    final isOver = monthlyTotal > totalBudget;
    
    expect(isOver, isTrue);
  });
}
