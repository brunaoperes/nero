import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';

class CompanyStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const CompanyStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTasks = stats['total_tasks'] ?? 0;
    final completedTasks = stats['completed_tasks'] ?? 0;
    final pendingTasks = stats['pending_tasks'] ?? 0;
    final totalMeetings = stats['total_meetings'] ?? 0;
    final upcomingMeetings = stats['upcoming_meetings'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tarefas
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.task_alt_outlined,
                  label: 'Tarefas',
                  value: totalTasks.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Concluídas',
                  value: completedTasks.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.pending_outlined,
                  label: 'Pendentes',
                  value: pendingTasks.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            height: 1,
          ),
          const SizedBox(height: 16),
          // Reuniões
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.event_outlined,
                  label: 'Reuniões',
                  value: totalMeetings.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.upcoming_outlined,
                  label: 'Próximas',
                  value: upcomingMeetings.toString(),
                ),
              ),
              const Expanded(child: SizedBox()), // Espaçador
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightText,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.darkText
                : AppColors.lightTextSecondary,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
