// lib/features/finance/presentation/pages/goals_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/financial_goal_entity.dart';
import '../providers/finance_providers.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(financialGoalsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: goalsAsync.when(
        data: (goals) {
          final activeGoals = goals
              .where((g) => g.status == GoalStatus.active)
              .toList();
          final achievedGoals = goals
              .where((g) => g.status == GoalStatus.achieved)
              .toList();

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 80,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma meta ainda',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie metas financeiras para alcançar seus objetivos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showGoalForm(context, ref);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Meta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Metas Ativas
              if (activeGoals.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metas Ativas',
                      style: AppTextStyles.headingH3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${activeGoals.length} ${activeGoals.length == 1 ? 'meta' : 'metas'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...activeGoals.map((goal) => _GoalCard(
                      goal: goal,
                      onTap: () {
                        _showGoalForm(context, ref, goal: goal);
                      },
                    )),
              ],

              // Metas Alcançadas
              if (achievedGoals.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metas Alcançadas',
                      style: AppTextStyles.headingH3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${achievedGoals.length} ${achievedGoals.length == 1 ? 'meta' : 'metas'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...achievedGoals.map((goal) => _GoalCard(
                      goal: goal,
                      onTap: () {
                        _showGoalForm(context, ref, goal: goal);
                      },
                    )),
              ],

              // Botão adicionar
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _showGoalForm(context, ref);
                },
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Meta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar metas',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalForm(BuildContext context, WidgetRef ref,
      {FinancialGoalEntity? goal}) {
    // TODO: Implementar formulário de metas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulário de metas em desenvolvimento'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final FinancialGoalEntity goal;
  final VoidCallback? onTap;

  const _GoalCard({
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final isAchieved = goal.status == GoalStatus.achieved;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    Color progressColor;
    if (isAchieved) {
      progressColor = AppColors.success;
    } else if (daysLeft < 0) {
      progressColor = AppColors.error;
    } else if (daysLeft < 30) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAchieved
                ? AppColors.success.withOpacity(0.3)
                : AppColors.border,
            width: isAchieved ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                // Ícone
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      isAchieved ? Icons.check_circle : Icons.flag,
                      color: progressColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Título
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (goal.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Badge de status
                if (isAchieved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Alcançada',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Valores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Economizado',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(goal.currentAmount),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Meta',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(goal.targetAmount),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barra de progresso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}% alcançado',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Faltam: ${_formatCurrency((goal.targetAmount - goal.currentAmount).clamp(0, goal.targetAmount))}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Informações de prazo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: progressColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAchieved
                          ? 'Alcançada em ${DateFormat('dd/MM/yyyy').format(goal.targetDate)}'
                          : daysLeft < 0
                              ? 'Prazo vencido há ${daysLeft.abs()} ${daysLeft.abs() == 1 ? 'dia' : 'dias'}'
                              : 'Faltam $daysLeft ${daysLeft == 1 ? 'dia' : 'dias'} (${DateFormat('dd/MM/yyyy').format(goal.targetDate)})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: progressColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
