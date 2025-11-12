import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../domain/models/report_config.dart';

/// Widget para filtros do relatório
class ReportFilterWidget extends StatelessWidget {
  final ReportConfig config;
  final Function(ReportPeriod) onPeriodChanged;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final Function(ReportFormat) onFormatChanged;
  final Function(bool) onIncludeCompletedChanged;
  final Function(bool) onIncludePendingChanged;
  final Function(bool) onIncludeIncomeChanged;
  final Function(bool) onIncludeExpensesChanged;
  final bool isDark;

  const ReportFilterWidget({
    super.key,
    required this.config,
    required this.onPeriodChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onFormatChanged,
    required this.onIncludeCompletedChanged,
    required this.onIncludePendingChanged,
    required this.onIncludeIncomeChanged,
    required this.onIncludeExpensesChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formato
        _buildSectionTitle('Formato de Exportação'),
        const SizedBox(height: 12),
        _buildFormatSelector(),
        const SizedBox(height: 24),

        // Período
        _buildSectionTitle('Período'),
        const SizedBox(height: 12),
        _buildPeriodSelector(),

        if (config.period == ReportPeriod.custom) ...[
          const SizedBox(height: 16),
          _buildCustomDateRange(context),
        ],

        const SizedBox(height: 24),

        // Filtros específicos por tipo
        if (config.type == ReportType.tasks || config.type == ReportType.consolidated)
          _buildTasksFilters(),

        if (config.type == ReportType.finance || config.type == ReportType.consolidated)
          _buildFinanceFilters(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildFormatOption(
            ReportFormat.pdf,
            '📄',
            'PDF',
            'Documento visual',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFormatOption(
            ReportFormat.excel,
            '📊',
            'Excel',
            'Planilha editável',
          ),
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    ReportFormat format,
    String icon,
    String label,
    String description,
  ) {
    final isSelected = config.format == format;

    return GestureDetector(
      onTap: () => onFormatChanged(format),
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
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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

  Widget _buildPeriodSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPeriodChip(ReportPeriod.today, 'Hoje'),
        _buildPeriodChip(ReportPeriod.yesterday, 'Ontem'),
        _buildPeriodChip(ReportPeriod.thisWeek, 'Esta Semana'),
        _buildPeriodChip(ReportPeriod.lastWeek, 'Semana Passada'),
        _buildPeriodChip(ReportPeriod.thisMonth, 'Este Mês'),
        _buildPeriodChip(ReportPeriod.lastMonth, 'Mês Passado'),
        _buildPeriodChip(ReportPeriod.last7Days, 'Últimos 7 Dias'),
        _buildPeriodChip(ReportPeriod.last30Days, 'Últimos 30 Dias'),
        _buildPeriodChip(ReportPeriod.thisYear, 'Este Ano'),
        _buildPeriodChip(ReportPeriod.custom, 'Personalizado'),
      ],
    );
  }

  Widget _buildPeriodChip(ReportPeriod period, String label) {
    final isSelected = config.period == period;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPeriodChanged(period),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkText : AppColors.lightText),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.grey300),
      ),
    );
  }

  Widget _buildCustomDateRange(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            context,
            'Data Início',
            config.startDate,
            (date) => onStartDateChanged(date),
            dateFormat,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            context,
            'Data Fim',
            config.endDate,
            (date) => onEndDateChanged(date),
            dateFormat,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? value,
    Function(DateTime?) onChanged,
    DateFormat dateFormat,
  ) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.grey300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value != null ? dateFormat.format(value) : 'Selecione',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
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

  Widget _buildTasksFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Filtros de Tarefas'),
        const SizedBox(height: 12),
        _buildCheckbox(
          'Incluir tarefas concluídas',
          config.includeCompleted,
          onIncludeCompletedChanged,
        ),
        _buildCheckbox(
          'Incluir tarefas pendentes',
          config.includePending,
          onIncludePendingChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFinanceFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Filtros Financeiros'),
        const SizedBox(height: 12),
        _buildCheckbox(
          'Incluir receitas',
          config.includeIncome,
          onIncludeIncomeChanged,
        ),
        _buildCheckbox(
          'Incluir despesas',
          config.includeExpenses,
          onIncludeExpensesChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
