import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/payment_history_repository.dart';
import 'subscription_provider.dart';

/// PaymentHistoryRepositoryのインスタンスを提供するProvider
final paymentHistoryRepositoryProvider = Provider<PaymentHistoryRepository>((ref) {
  return PaymentHistoryRepository(ref.watch(supabaseProvider));
});
