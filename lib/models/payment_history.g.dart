// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentHistory _$PaymentHistoryFromJson(Map<String, dynamic> json) =>
    _PaymentHistory(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      paidDate: DateTime.parse(json['paidDate'] as String),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentHistoryToJson(_PaymentHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscriptionId': instance.subscriptionId,
      'paidDate': instance.paidDate.toIso8601String(),
      'amount': instance.amount,
    };
