enum SortOption { amount, nextPaymentDate }
enum SortOrder { asc, desc }

class SortSettings {
  final SortOption option;
  final SortOrder order;

  SortSettings({required this.option, required this.order});
}
