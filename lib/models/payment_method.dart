import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method.freezed.dart';
part 'payment_method.g.dart';

enum PaymentMethodType { creditCard, bankAccount }

@freezed
sealed class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    required String name,
    required PaymentMethodType type,
    @Default('') String last4,
    DateTime? expiryDate,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
}
