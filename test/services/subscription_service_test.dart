import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/models/subscription.dart';
import 'package:subscription_manager/models/sort_settings.dart';
import 'package:subscription_manager/services/subscription_service.dart';

void main() {
  late SubscriptionService service;

  setUp(() {
    service = SubscriptionService();
  });

  group('SubscriptionService', () {
    final subscriptions = [
      Subscription(
        id: '1',
        name: 'Netflix',
        amount: 1200,
        cycle: BillingCycle.monthly,
        nextPaymentDate: DateTime(2026, 7, 1),
        tags: ['entertainment'],
      ),
      Subscription(
        id: '2',
        name: 'Spotify',
        amount: 980,
        cycle: BillingCycle.monthly,
        nextPaymentDate: DateTime(2026, 6, 25),
        tags: ['music'],
      ),
      Subscription(
        id: '3',
        name: 'Annual Insurance',
        amount: 12000,
        cycle: BillingCycle.yearly,
        nextPaymentDate: DateTime(2027, 1, 1),
        tags: ['insurance'],
      ),
    ];

    test('フィルタリングとソートが正しく機能すること', () {
      final sortSettings = SortSettings(option: SortOption.amount, order: SortOrder.asc);
      final filtered = service.filterAndSortSubscriptions(
        subscriptions,
        'Net',
        [],
        sortSettings,
      );

      expect(filtered.length, 1);
      expect(filtered.first.name, 'Netflix');
    });

    test('月額合計金額が正しく計算されること', () {
      final total = service.calculateMonthlyTotal(subscriptions);
      // Netflix(1200) + Spotify(980) + Insurance(12000 / 12 = 1000) = 3180
      expect(total, 3180.0);
    });
  });
}
