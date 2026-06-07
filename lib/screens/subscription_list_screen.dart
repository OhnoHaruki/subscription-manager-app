import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/payment_method_provider.dart';
import 'add_subscription_screen.dart';
import 'payment_method_list_screen.dart';
import 'tag_list_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'subscription_history_screen.dart';
import 'privacy_policy_screen.dart';
import '../models/sort_settings.dart';
import '../providers/tag_provider.dart';
import '../widgets/common_views.dart';

/// サブスクリプション一覧を表示するホーム画面
class SubscriptionListScreen extends ConsumerStatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  ConsumerState<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends ConsumerState<SubscriptionListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // フィルタリング後の一覧を監視
    final subscriptionsAsync = ref.watch(filteredSubscriptionsProvider);
    // 月額合計金額を取得
    final totalAmount = ref.watch(monthlyTotalAmountProvider);
    // タグ一覧を取得
    final tagsAsync = ref.watch(tagsProvider);
    final selectedTagIds = ref.watch(selectedFilterTagIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'サービス名で検索...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(subscriptionSearchQueryProvider.notifier).set(value);
                },
              )
            : const Text('サブスク管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  ref.read(subscriptionSearchQueryProvider.notifier).set('');
                } else {
                  _isSearching = true;
                }
              });
            },
            tooltip: _isSearching ? '検索を閉じる' : '検索',
          ),
          PopupMenuButton<SortSettings>(
            icon: const Icon(Icons.sort),
            onSelected: (settings) => ref.read(subscriptionSortOptionProvider.notifier).set(settings),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortSettings(option: SortOption.nextPaymentDate, order: SortOrder.asc),
                child: const Text('支払日が近い順'),
              ),
              PopupMenuItem(
                value: SortSettings(option: SortOption.amount, order: SortOrder.desc),
                child: const Text('金額が高い順'),
              ),
              PopupMenuItem(
                value: SortSettings(option: SortOption.amount, order: SortOrder.asc),
                child: const Text('金額が低い順'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'プロフィール',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'メニュー',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('プロフィール'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('支払い方法管理'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PaymentMethodListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('統計・分析'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('タグ管理'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TagListScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('プライバシーポリシー'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 有効期限警告バナー
          const _ExpiryAlertBanner(),
          
          // 合計金額表示エリア
          _TotalAmountCard(amount: totalAmount),

          // タグフィルタエリア
          tagsAsync.when(
            data: (tags) => tags.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index];
                        final isSelected = selectedTagIds.contains(tag.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(tag.name, style: const TextStyle(fontSize: 12)),
                            selected: isSelected,
                            onSelected: (selected) {
                              ref.read(selectedFilterTagIdsProvider.notifier).toggle(tag.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
            loading: () => const SizedBox(height: 50),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          
          // 一覧表示エリア
          Expanded(
            child: subscriptionsAsync.when(
              data: (subscriptions) {
                if (subscriptions.isEmpty) {
                  return EmptyView(
                    message: _isSearching || selectedTagIds.isNotEmpty
                        ? '条件に一致するサブスクリプションが見つかりません'
                        : 'サブスクリプションが登録されていません',
                    icon: Icons.list_alt,
                  );
                }
                return ListView.builder(
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final subscription = subscriptions[index];
                    return _SubscriptionTile(subscription: subscription);
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (error, stack) => ErrorView(message: '読み込みに失敗しました: $error'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 登録画面へ遷移
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 有効期限警告バナー
class _ExpiryAlertBanner extends ConsumerWidget {
  const _ExpiryAlertBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiringMethods = ref.watch(expiringPaymentMethodsProvider);
    if (expiringMethods.isEmpty) return const SizedBox.shrink();

    final isAnyExpired = expiringMethods.any((m) => m.expiryDate != null && m.expiryDate!.isBefore(DateTime.now()));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAnyExpired ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAnyExpired ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PaymentMethodListScreen()),
          );
        },
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: isAnyExpired ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAnyExpired
                    ? '有効期限が切れている支払い方法があります'
                    : '有効期限が近い支払い方法があります',
                style: TextStyle(
                  color: isAnyExpired ? Colors.red.shade900 : Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isAnyExpired ? Colors.red : Colors.orange,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// 合計金額を表示するカードウィジェット
class _TotalAmountCard extends StatelessWidget {
  const _TotalAmountCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.simpleCurrency(locale: 'ja_JP');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('月額合計（推定）', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              formatter.format(amount.toInt()),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// 個別のサブスクリプションを表示するタイルウィジェット
class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('yyyy/MM/dd');

    // 支払い方法の名称を取得
    final paymentMethods = ref.watch(paymentMethodsProvider).value ?? [];
    final paymentMethod = paymentMethods.where((m) => m.id == subscription.paymentMethod).firstOrNull;
    final paymentMethodName = paymentMethod?.name ?? '未設定';

    // 有効期限警告のチェック
    final expiringMethods = ref.watch(expiringPaymentMethodsProvider);
    final isMethodExpiring = paymentMethod != null && expiringMethods.any((m) => m.id == paymentMethod.id);

    // タグ名を取得
    final allTags = ref.watch(tagsProvider).value ?? [];
    final subscriptionTags = allTags.where((t) => subscription.tags.contains(t.id)).toList();

    return ListTile(
      leading: CircleAvatar(
        child: Text(subscription.name.characters.first.toUpperCase()),
      ),
      title: Row(
        children: [
          Text(subscription.name),
          if (isMethodExpiring) ...[
            const SizedBox(width: 8),
            const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('次回支払日: ${dateFormatter.format(subscription.nextPaymentDate)}'),
          Text('支払い方法: $paymentMethodName', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (subscriptionTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children: subscriptionTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag.name,
                      style: const TextStyle(fontSize: 10, color: Colors.deepPurple),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            onPressed: () async {
              await ref.read(subscriptionRepositoryProvider).markAsPaid(
                subscription.id,
                subscription.nextPaymentDate,
                subscription.amount,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('支払いを記録しました')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SubscriptionHistoryScreen(subscriptionId: subscription.id),
                ),
              );
            },
          ),
        ],
      ),
      onTap: () {
        // 編集画面へ遷移
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddSubscriptionScreen(subscription: subscription),
          ),
        );
      },
      onLongPress: () {
        // 長押しで削除確認ダイアログ（簡易実装）
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('削除の確認'),
            content: Text('${subscription.name} を削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(subscriptionRepositoryProvider).deleteSubscription(subscription.id);
                  Navigator.pop(context);
                },
                child: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}
