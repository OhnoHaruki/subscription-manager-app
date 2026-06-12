import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history.freezed.dart';
part 'payment_history.g.dart';

@freezed
sealed class PaymentHistory with _$PaymentHistory {
  const factory PaymentHistory({
    required String id,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'paid_date') required DateTime paidDate,
    required int amount,
  }) = _PaymentHistory;

  factory PaymentHistory.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryFromJson(json);
}
