import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/budget_repository.dart';
import '../models/budget.dart';

import 'subscription_provider.dart';

final budgetRepositoryProvider = Provider((ref) => BudgetRepository(ref.watch(supabaseProvider)));

final currentBudgetsProvider = FutureProvider.family<List<Budget>, DateTime>((ref, date) async {
  return ref.watch(budgetRepositoryProvider).getBudgets(date.year, date.month);
});
