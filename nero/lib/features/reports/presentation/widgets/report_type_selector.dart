import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../domain/models/report_config.dart';

/// Widget para seleção do tipo de relatório
class ReportTypeSelector extends StatelessWidget {
  final ReportType selectedType;
  final Function(ReportType) onTypeSelected;
  final bool isDark;

  const ReportTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Relatório',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                context,
                ReportType.tasks,
                '✓',
                'Tarefas',
                'Relatório completo de tarefas',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                context,
                ReportType.finance,
                '💰',
                'Finanças',
                'Relatório financeiro',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                context,
                ReportType.consolidated,
                '📊',
                'Consolidado',
                'Tarefas + Finanças',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard(
    BuildContext context,
    ReportType type,
    String icon,
    String title,
    String subtitle,
  ) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onTypeSelected(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.grey300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkText : AppColors.lightText),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
