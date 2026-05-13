// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    _PaymentMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$PaymentMethodTypeEnumMap, json['type']),
      last4: json['last4'] as String? ?? '',
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$PaymentMethodToJson(_PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$PaymentMethodTypeEnumMap[instance.type]!,
      'last4': instance.last4,
      'expiryDate': instance.expiryDate?.toIso8601String(),
    };

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.creditCard: 'creditCard',
  PaymentMethodType.bankAccount: 'bankAccount',
};
