import 'package:subscription_manager/models/subscription.dart';

class SubscriptionFactory {
  static Subscription create({
    String id = 'test_id',
    String name = 'Test Subscription',
    int amount = 1000,
    BillingCycle cycle = BillingCycle.monthly,
    DateTime? nextPaymentDate,
    String paymentMethod = '',
    List<String> tags = const [],
    bool isRecurring = true,
  }) {
    return Subscription(
      id: id,
      name: name,
      amount: amount,
      cycle: cycle,
      nextPaymentDate: nextPaymentDate ?? DateTime.now(),
      paymentMethod: paymentMethod,
      tags: tags,
      isRecurring: isRecurring,
    );
  }
}
