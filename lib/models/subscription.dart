import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

enum BillingCycle { monthly, yearly }

@freezed
sealed class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String name,
    required int amount,
    required BillingCycle cycle,
    @JsonKey(name: 'next_payment_date') required DateTime nextPaymentDate,
    @JsonKey(name: 'payment_method_id') @Default('') String paymentMethod,
    @Default([]) List<String> tags,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}
