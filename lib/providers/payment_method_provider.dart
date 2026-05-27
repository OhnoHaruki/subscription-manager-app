import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_method.dart';
import '../repositories/payment_method_repository.dart';
import 'subscription_provider.dart';

/// PaymentMethodRepositoryのインスタンスを提供するProvider
final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  return PaymentMethodRepository(ref.watch(supabaseProvider));
});

/// 支払い方法一覧をリアルタイムで監視するProvider
final paymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  return ref.watch(paymentMethodRepositoryProvider).watchPaymentMethods();
});

/// 有効期限が近い（30日以内）または切れている支払い方法を抽出するProvider
final expiringPaymentMethodsProvider = Provider<List<PaymentMethod>>((ref) {
  final methods = ref.watch(paymentMethodsProvider).value ?? [];
  final now = DateTime.now();
  final threshold = now.add(const Duration(days: 30));

  return methods.where((m) {
    if (m.type != PaymentMethodType.creditCard || m.expiryDate == null) {
      return false;
    }
    // 有効期限が30日以内、または既に切れている
    return m.expiryDate!.isBefore(threshold);
  }).toList();
});
