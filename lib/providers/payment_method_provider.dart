import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_method.dart';
import '../repositories/payment_method_repository.dart';
import 'subscription_provider.dart';

/// PaymentMethodRepositoryのインスタンスを提供するProvider
final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  return PaymentMethodRepository(ref.watch(firestoreProvider));
});

/// 支払い方法一覧をリアルタイムで監視するProvider
final paymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  return ref.watch(paymentMethodRepositoryProvider).watchPaymentMethods();
});
