import '../models/subscription.dart';
import '../models/sort_settings.dart';

class SubscriptionService {
  List<Subscription> filterAndSortSubscriptions(
    List<Subscription> subscriptions,
    String searchQuery,
    List<String> selectedTagIds,
    SortSettings sortSettings,
  ) {
    final query = searchQuery.toLowerCase();
    
    var list = subscriptions.where((sub) {
      final matchesSearch = sub.name.toLowerCase().contains(query);
      final matchesTags = selectedTagIds.isEmpty ||
          selectedTagIds.any((tagId) => sub.tags.contains(tagId));
      return matchesSearch && matchesTags;
    }).toList();

    list.sort((a, b) {
      int comparison = 0;
      switch (sortSettings.option) {
        case SortOption.amount:
          comparison = a.amount.compareTo(b.amount);
          break;
        case SortOption.nextPaymentDate:
          comparison = a.nextPaymentDate.compareTo(b.nextPaymentDate);
          break;
      }
      return sortSettings.order == SortOrder.asc ? comparison : -comparison;
    });

    return list;
  }

  double calculateMonthlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold(0.0, (previousValue, sub) {
      if (sub.cycle == BillingCycle.monthly) {
        return previousValue + sub.amount;
      } else {
        return previousValue + (sub.amount / 12);
      }
    });
  }
}
