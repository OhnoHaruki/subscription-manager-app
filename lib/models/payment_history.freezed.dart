// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentHistory {

 String get id;@JsonKey(name: 'subscription_id') String get subscriptionId;@JsonKey(name: 'paid_date') DateTime get paidDate; int get amount;
/// Create a copy of PaymentHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentHistoryCopyWith<PaymentHistory> get copyWith => _$PaymentHistoryCopyWithImpl<PaymentHistory>(this as PaymentHistory, _$identity);

  /// Serializes this PaymentHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,paidDate,amount);

@override
String toString() {
  return 'PaymentHistory(id: $id, subscriptionId: $subscriptionId, paidDate: $paidDate, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $PaymentHistoryCopyWith<$Res>  {
  factory $PaymentHistoryCopyWith(PaymentHistory value, $Res Function(PaymentHistory) _then) = _$PaymentHistoryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'paid_date') DateTime paidDate, int amount
});




}
/// @nodoc
class _$PaymentHistoryCopyWithImpl<$Res>
    implements $PaymentHistoryCopyWith<$Res> {
  _$PaymentHistoryCopyWithImpl(this._self, this._then);

  final PaymentHistory _self;
  final $Res Function(PaymentHistory) _then;

/// Create a copy of PaymentHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subscriptionId = null,Object? paidDate = null,Object? amount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,paidDate: null == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentHistory].
extension PaymentHistoryPatterns on PaymentHistory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentHistory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentHistory value)  $default,){
final _that = this;
switch (_that) {
case _PaymentHistory():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentHistory value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentHistory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'paid_date')  DateTime paidDate,  int amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentHistory() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.paidDate,_that.amount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'paid_date')  DateTime paidDate,  int amount)  $default,) {final _that = this;
switch (_that) {
case _PaymentHistory():
return $default(_that.id,_that.subscriptionId,_that.paidDate,_that.amount);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'paid_date')  DateTime paidDate,  int amount)?  $default,) {final _that = this;
switch (_that) {
case _PaymentHistory() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.paidDate,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentHistory implements PaymentHistory {
  const _PaymentHistory({required this.id, @JsonKey(name: 'subscription_id') required this.subscriptionId, @JsonKey(name: 'paid_date') required this.paidDate, required this.amount});
  factory _PaymentHistory.fromJson(Map<String, dynamic> json) => _$PaymentHistoryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'subscription_id') final  String subscriptionId;
@override@JsonKey(name: 'paid_date') final  DateTime paidDate;
@override final  int amount;

/// Create a copy of PaymentHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentHistoryCopyWith<_PaymentHistory> get copyWith => __$PaymentHistoryCopyWithImpl<_PaymentHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,paidDate,amount);

@override
String toString() {
  return 'PaymentHistory(id: $id, subscriptionId: $subscriptionId, paidDate: $paidDate, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$PaymentHistoryCopyWith<$Res> implements $PaymentHistoryCopyWith<$Res> {
  factory _$PaymentHistoryCopyWith(_PaymentHistory value, $Res Function(_PaymentHistory) _then) = __$PaymentHistoryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'paid_date') DateTime paidDate, int amount
});




}
/// @nodoc
class __$PaymentHistoryCopyWithImpl<$Res>
    implements _$PaymentHistoryCopyWith<$Res> {
  __$PaymentHistoryCopyWithImpl(this._self, this._then);

  final _PaymentHistory _self;
  final $Res Function(_PaymentHistory) _then;

/// Create a copy of PaymentHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subscriptionId = null,Object? paidDate = null,Object? amount = null,}) {
  return _then(_PaymentHistory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,paidDate: null == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
