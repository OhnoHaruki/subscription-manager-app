import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/payment_method_provider.dart';
import 'add_subscription_screen.dart';
import 'payment_method_list_screen.dart';

/// サブスクリプション一覧を表示するホーム画面
class SubscriptionListScreen extends ConsumerWidget {
  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // サブスクリプション一覧を監視
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    // 月額合計金額を取得
    final totalAmount = ref.watch(monthlyTotalAmountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('サブスク管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              leading: const Icon(Icons.credit_card),
              title: const Text('支払い方法管理'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PaymentMethodListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 合計金額表示エリア
          _TotalAmountCard(amount: totalAmount),
          
          // 一覧表示エリア
          Expanded(
            child: subscriptionsAsync.when(
              data: (subscriptions) => subscriptions.isEmpty
                  ? const Center(child: Text('サブスクリプションが登録されていません'))
                  : ListView.builder(
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        final subscription = subscriptions[index];
                        return _SubscriptionTile(subscription: subscription);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
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
    final formatter = NumberFormat.simpleCurrency(locale: 'ja_JP');
    final dateFormatter = DateFormat('yyyy/MM/dd');

    // 支払い方法の名称を取得
    final paymentMethods = ref.watch(paymentMethodsProvider).value ?? [];
    final paymentMethodName = paymentMethods
        .where((m) => m.id == subscription.paymentMethod)
        .map((m) => m.name)
        .firstOrNull ?? '未設定';

    return ListTile(
      leading: CircleAvatar(
        child: Text(subscription.name.characters.first.toUpperCase()),
      ),
      title: Text(subscription.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('次回支払日: ${dateFormatter.format(subscription.nextPaymentDate)}'),
          Text('支払い方法: $paymentMethodName', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatter.format(subscription.amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            subscription.cycle == BillingCycle.monthly ? '月額' : '年額',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
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
