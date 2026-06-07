import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/payment_history.dart';
import '../providers/payment_history_provider.dart';

class SubscriptionHistoryScreen extends ConsumerWidget {
  const SubscriptionHistoryScreen({super.key, required this.subscriptionId});

  final String subscriptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyFuture = ref.watch(paymentHistoryRepositoryProvider).getHistory(subscriptionId);
    final formatter = NumberFormat.simpleCurrency(locale: 'ja_JP');

    return Scaffold(
      appBar: AppBar(title: const Text('支払履歴')),
      body: FutureBuilder<List<PaymentHistory>>(
        future: historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('エラー: ${snapshot.error}'));
          
          final history = snapshot.data ?? [];
          if (history.isEmpty) return const Center(child: Text('履歴がありません'));

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                title: Text(DateFormat('yyyy/MM/dd').format(item.paidDate)),
                trailing: Text(formatter.format(item.amount)),
              );
            },
          );
        },
      ),
    );
  }
}
