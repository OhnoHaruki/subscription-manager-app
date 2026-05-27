import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/stats_provider.dart';
import '../providers/tag_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(subscriptionStatsProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'ja_JP');

    return Scaffold(
      appBar: AppBar(
        title: const Text('統計・分析'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 総計カード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('合計支出（月額換算）', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(stats.monthlyTotal.toInt()),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: '年間合計',
                        value: currencyFormat.format(stats.yearlyTotal.toInt()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('タグ別内訳', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          tagsAsync.when(
            data: (tags) {
              final sortedEntries = stats.amountByTag.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              if (sortedEntries.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('データがありません'),
                ));
              }

              return Column(
                children: sortedEntries.map((entry) {
                  String tagName;
                  if (entry.key == 'unclassified') {
                    tagName = '未分類';
                  } else {
                    try {
                      tagName = tags.firstWhere((t) => t.id == entry.key).name;
                    } catch (_) {
                      tagName = '削除済みタグ';
                    }
                  }
                  
                  final percentage = stats.monthlyTotal > 0 
                      ? (entry.value / stats.monthlyTotal * 100).toStringAsFixed(1)
                      : '0';

                  return ListTile(
                    leading: const Icon(Icons.label_outline),
                    title: Text(tagName),
                    subtitle: LinearProgressIndicator(
                      value: stats.monthlyTotal > 0 ? entry.value / stats.monthlyTotal : 0,
                      backgroundColor: Colors.grey[200],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currencyFormat.format(entry.value.toInt())),
                        Text('$percentage%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('タグ情報の読み込みエラー: $e'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
