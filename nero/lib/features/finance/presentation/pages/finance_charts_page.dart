// lib/features/finance/presentation/pages/finance_charts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../providers/finance_providers.dart';

class FinanceChartsPage extends ConsumerWidget {
  const FinanceChartsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = DateRange.currentMonth();
    final summaryAsync = ref.watch(financialSummaryProvider(period));
    final expensesByCategoryAsync = ref.watch(expensesByCategoryProvider(period));
    final transactionsAsync = ref.watch(transactionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gráfico de Pizza - Gastos por Categoria
        expensesByCategoryAsync.when(
          data: (expensesByCategory) {
            if (expensesByCategory.isEmpty) {
              return _buildEmptyState('Nenhuma despesa neste período');
            }

            return _buildChartCard(
              title: 'Gastos por Categoria',
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(expensesByCategory),
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryLegend(expensesByCategory),
                ],
              ),
            );
          },
          loading: () => _buildLoadingChart(),
          error: (e, _) => _buildErrorChart(e.toString()),
        ),

        const SizedBox(height: 16),

        // Gráfico de Barras - Receitas vs Despesas
        summaryAsync.when(
          data: (summary) {
            final income = summary['income'] ?? 0.0;
            final expense = summary['expense'] ?? 0.0;

            return _buildChartCard(
              title: 'Receitas vs Despesas',
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: [income, expense].reduce((a, b) => a > b ? a : b) * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            _formatCurrency(rod.toY),
                            AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Text(
                                  'Receitas',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              case 1:
                                return Text(
                                  'Despesas',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: income,
                            color: AppColors.success,
                            width: 60,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: expense,
                            color: AppColors.error,
                            width: 60,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => _buildLoadingChart(),
          error: (e, _) => _buildErrorChart(e.toString()),
        ),

        const SizedBox(height: 16),

        // Gráfico de Linha - Tendência de Gastos
        transactionsAsync.when(
          data: (transactions) {
            final dailyExpenses = _calculateDailyExpenses(transactions, period);

            if (dailyExpenses.isEmpty) {
              return _buildEmptyState('Nenhuma transação neste período');
            }

            return _buildChartCard(
              title: 'Tendência de Gastos Diários',
              child: SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailyExpenses,
                        isCurved: true,
                        color: AppColors.error,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.error,
                              strokeWidth: 2,
                              strokeColor: AppColors.lightBackground,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.error.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => _buildLoadingChart(),
          error: (e, _) => _buildErrorChart(e.toString()),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headingH3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLoadingChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorChart(String error) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar gráfico',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bar_chart,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> expensesByCategory) {
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
      AppColors.primary,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    int index = 0;
    return expensesByCategory.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;

      final total = expensesByCategory.values.reduce((a, b) => a + b);
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '$percentage%',
        radius: 80,
        titleStyle: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryLegend(Map<String, double> expensesByCategory) {
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
      AppColors.primary,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    int index = 0;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: expensesByCategory.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key}: ${_formatCurrency(entry.value)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<FlSpot> _calculateDailyExpenses(
      List<dynamic> transactions, DateRange period) {
    final Map<int, double> dailyExpenses = {};

    for (final transaction in transactions) {
      if (transaction.type.toJson() == 'expense' &&
          transaction.date.isAfter(period.startDate) &&
          transaction.date.isBefore(period.endDate.add(const Duration(days: 1)))) {
        final day = transaction.date.day;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + transaction.amount;
      }
    }

    return dailyExpenses.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
}
