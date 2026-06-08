import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/stats_provider.dart';
import '../providers/tag_provider.dart';
import '../providers/budget_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(subscriptionStatsProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final trendAsync = ref.watch(monthlyExpenditureTrendProvider);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'ja_JP');

    return Scaffold(
      appBar: AppBar(
        title: const Text('統計・分析'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 支出トレンドグラフ
          const Text('支出推移（過去6ヶ月）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: trendAsync.when(
              data: (trend) {
                final spots = trend.entries.toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
                return LineChart(LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                    )
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(trend.keys.toList()[value.toInt()].split('-')[1]),
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('グラフ読み込みエラー: $e'),
            ),
          ),
          const SizedBox(height: 24),

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
                  _BudgetSection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('タグ別内訳', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 割合表示バー
                  if (stats.monthlyTotal > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 24,
                          child: Row(
                            children: sortedEntries.map((entry) {
                              final ratio = entry.value / stats.monthlyTotal;
                              if (ratio < 0.01) return const SizedBox.shrink();
                              
                              final color = Colors.primaries[sortedEntries.indexOf(entry) % Colors.primaries.length];
                              
                              return Expanded(
                                flex: (ratio * 1000).toInt(),
                                child: Container(color: color),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  
                  // 詳細リスト
                  ...sortedEntries.map((entry) {
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
                    final color = Colors.primaries[sortedEntries.indexOf(entry) % Colors.primaries.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tagName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    Text(currencyFormat.format(entry.value.toInt()), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withAlpha(25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: stats.monthlyTotal > 0 ? entry.value / stats.monthlyTotal : 0,
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color.withAlpha(150),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 45,
                            child: Text(
                              '$percentage%',
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
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

class _BudgetSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final budgetsAsync = ref.watch(currentBudgetsProvider(now));
    final stats = ref.watch(subscriptionStatsProvider);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'ja_JP');

    return budgetsAsync.when(
      data: (budgets) {
        final totalBudget = budgets.where((b) => b.tagId == null).fold(0, (sum, b) => sum + b.amount);
        if (totalBudget == 0) return TextButton(onPressed: () {}, child: const Text('予算を設定する'));
        
        final isOver = stats.monthlyTotal > totalBudget;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('予算'),
                Text('${currencyFormat.format(stats.monthlyTotal.toInt())} / ${currencyFormat.format(totalBudget)}'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stats.monthlyTotal / totalBudget,
              color: isOver ? Colors.red : Colors.indigo,
            ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
