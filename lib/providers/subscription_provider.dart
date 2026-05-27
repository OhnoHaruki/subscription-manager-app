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

/// フィルタリング適用後のサブスクリプション一覧を提供するProvider
final filteredSubscriptionsProvider = Provider<AsyncValue<List<Subscription>>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionsProvider);
  final searchQuery = ref.watch(subscriptionSearchQueryProvider).toLowerCase();
  final selectedTagIds = ref.watch(selectedFilterTagIdsProvider);

  return subscriptionsAsync.whenData((subscriptions) {
    return subscriptions.where((sub) {
      // 名前による検索
      final matchesSearch = sub.name.toLowerCase().contains(searchQuery);
      
      // タグによる絞り込み（選択されているタグがいずれか1つでも含まれていればマッチ、未選択なら全てマッチ）
      final matchesTags = selectedTagIds.isEmpty || 
          selectedTagIds.any((tagId) => sub.tags.contains(tagId));

      return matchesSearch && matchesTags;
    }).toList();
  });
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
