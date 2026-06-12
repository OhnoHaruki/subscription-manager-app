import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget.dart';

class BudgetRepository {
  BudgetRepository(this._client);
  final SupabaseClient _client;

  SupabaseQueryBuilder get _table => _client.from('budgets');

  Future<List<Budget>> getBudgets(int year, int month) async {
    final response = await _table
        .select()
        .eq('year', year)
        .eq('month', month);
    return (response as List).map((map) => Budget.fromJson(map)).toList();
  }

  Future<void> saveBudget(Budget budget) async {
    await _table.upsert({
      'id': budget.id.isEmpty ? null : budget.id,
      'tag_id': budget.tagId,
      'amount': budget.amount,
      'month': budget.month,
      'year': budget.year,
      'user_id': _client.auth.currentUser!.id,
    });
  }
}
