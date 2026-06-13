import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription.dart';
import '../models/sort_settings.dart';
import '../repositories/subscription_repository.dart';
import '../services/subscription_service.dart';

/// Supabaseクライアントを提供するProvider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// SubscriptionRepositoryのインスタンスを提供するProvider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(supabaseProvider));
});

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// サブスクリプション一覧をリアルタイムで監視するProvider
final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscriptions();
});

/// 検索キーワードを管理するNotifier
class SubscriptionSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final subscriptionSearchQueryProvider = NotifierProvider<SubscriptionSearchQuery, String>(SubscriptionSearchQuery.new);

/// 選択されたフィルタ用タグIDを管理するNotifier
class SelectedFilterTagIds extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void toggle(String tagId) {
    if (state.contains(tagId)) {
      state = state.where((id) => id != tagId).toList();
    } else {
      state = [...state, tagId];
    }
  }
  void clear() => state = [];
}

final selectedFilterTagIdsProvider = NotifierProvider<SelectedFilterTagIds, List<String>>(SelectedFilterTagIds.new);

/// ソート設定を管理するNotifier
class SubscriptionSortSettings extends Notifier<SortSettings> {
  @override
  SortSettings build() => SortSettings(option: SortOption.nextPaymentDate, order: SortOrder.asc);
  void set(SortSettings settings) => state = settings;
}

final subscriptionSortOptionProvider = NotifierProvider<SubscriptionSortSettings, SortSettings>(SubscriptionSortSettings.new);

/// フィルタリング・ソート適用後のサブスクリプション一覧を提供するProvider
final filteredSubscriptionsProvider = Provider<AsyncValue<List<Subscription>>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionsProvider);
  final searchQuery = ref.watch(subscriptionSearchQueryProvider);
  final selectedTagIds = ref.watch(selectedFilterTagIdsProvider);
  final sortSettings = ref.watch(subscriptionSortOptionProvider);
  final service = ref.watch(subscriptionServiceProvider);

  return subscriptionsAsync.whenData((subscriptions) {
    return service.filterAndSortSubscriptions(
      subscriptions,
      searchQuery,
      selectedTagIds,
      sortSettings,
    );
  });
});

/// 月額合計金額を計算するProvider
final monthlyTotalAmountProvider = Provider<double>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider).value ?? [];
  final service = ref.watch(subscriptionServiceProvider);
  
  return service.calculateMonthlyTotal(subscriptions);
});
