// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subscription _$SubscriptionFromJson(Map<String, dynamic> json) =>
    _Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toInt(),
      cycle: $enumDecode(_$BillingCycleEnumMap, json['cycle']),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$SubscriptionToJson(_Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'cycle': _$BillingCycleEnumMap[instance.cycle]!,
      'nextPaymentDate': instance.nextPaymentDate.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'tags': instance.tags,
    };

const _$BillingCycleEnumMap = {
  BillingCycle.monthly: 'monthly',
  BillingCycle.yearly: 'yearly',
};
