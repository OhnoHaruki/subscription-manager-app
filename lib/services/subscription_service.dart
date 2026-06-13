import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../models/sort_settings.dart';

class SubscriptionService {
  Future<List<Subscription>> filterAndSortSubscriptions(
    List<Subscription> subscriptions,
    String searchQuery,
    List<String> selectedTagIds,
    SortSettings sortSettings,
  ) async {
    return compute(_filterAndSort, {
      'subscriptions': subscriptions,
      'searchQuery': searchQuery,
      'selectedTagIds': selectedTagIds,
      'sortSettings': sortSettings,
    });
  }

  static List<Subscription> _filterAndSort(Map<String, dynamic> params) {
    final subscriptions = params['subscriptions'] as List<Subscription>;
    final searchQuery = (params['searchQuery'] as String).toLowerCase();
    final selectedTagIds = params['selectedTagIds'] as List<String>;
    final sortSettings = params['sortSettings'] as SortSettings;

    var list = subscriptions.where((sub) {
      final matchesSearch = sub.name.toLowerCase().contains(searchQuery);
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
// ... (calculateMonthlyTotal remains)

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
