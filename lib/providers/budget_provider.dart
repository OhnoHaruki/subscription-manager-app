import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/budget_repository.dart';
import '../models/budget.dart';

final budgetRepositoryProvider = Provider((ref) => BudgetRepository(Supabase.instance.client));

final currentBudgetsProvider = FutureProvider.family<List<Budget>, DateTime>((ref, date) async {
  return ref.watch(budgetRepositoryProvider).getBudgets(date.year, date.month);
});
