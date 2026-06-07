import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_method.dart';
import '../providers/payment_method_provider.dart';
import 'add_payment_method_screen.dart';

/// 支払い方法一覧画面
class PaymentMethodListScreen extends ConsumerWidget {
  const PaymentMethodListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('支払い方法管理'),
      ),
      body: paymentMethodsAsync.when(
        data: (methods) => methods.isEmpty
            ? const Center(child: Text('支払い方法が登録されていません'))
            : ListView.builder(
                itemCount: methods.length,
                itemBuilder: (context, index) {
                  final method = methods[index];
                  final expiringMethods = ref.watch(expiringPaymentMethodsProvider);
                  final isExpiring = expiringMethods.any((m) => m.id == method.id);
                  final isExpired = method.expiryDate != null && method.expiryDate!.isBefore(DateTime.now());

                  return ListTile(
                    leading: Icon(
                      method.type == PaymentMethodType.creditCard
                          ? Icons.credit_card
                          : Icons.account_balance,
                      color: isExpiring ? Colors.orange : null,
                    ),
                    title: Row(
                      children: [
                        Text(method.name),
                        if (isExpiring) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: isExpired ? Colors.red : Colors.orange,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (method.last4.isNotEmpty) Text('末尾: ${method.last4}'),
                        if (isExpiring)
                          Text(
                            isExpired ? '有効期限が切れています' : '有効期限が近づいています',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpired ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddPaymentMethodScreen(paymentMethod: method),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        // 削除確認
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('削除の確認'),
                            content: Text('${method.name} を削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(paymentMethodRepositoryProvider).deletePaymentMethod(method.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('削除', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
