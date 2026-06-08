import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
sealed class Budget with _$Budget {
  const factory Budget({
    required String id,
    String? tagId, // nullの場合は全体予算
    required int amount,
    required int month,
    required int year,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);
}
