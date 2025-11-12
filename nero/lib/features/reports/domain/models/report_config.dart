import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_config.freezed.dart';
part 'report_config.g.dart';

/// Tipo de relatório
enum ReportType {
  tasks,       // Relatório de Tarefas
  finance,     // Relatório Financeiro
  consolidated // Relatório Consolidado (Tarefas + Finanças)
}

/// Formato de exportação
enum ReportFormat {
  pdf,   // PDF
  excel  // Excel (.xlsx)
}

/// Período predefinido para relatórios
enum ReportPeriod {
  today,        // Hoje
  yesterday,    // Ontem
  thisWeek,     // Esta semana
  lastWeek,     // Semana passada
  thisMonth,    // Este mês
  lastMonth,    // Mês passado
  last7Days,    // Últimos 7 dias
  last30Days,   // Últimos 30 dias
  last90Days,   // Últimos 90 dias
  thisYear,     // Este ano
  custom        // Período customizado
}

/// Configuração de relatório
@freezed
class ReportConfig with _$ReportConfig {
  const factory ReportConfig({
    /// Tipo do relatório
    required ReportType type,

    /// Formato de exportação
    required ReportFormat format,

    /// Período predefinido
    @Default(ReportPeriod.thisMonth) ReportPeriod period,

    /// Data de início (para período customizado)
    DateTime? startDate,

    /// Data de fim (para período customizado)
    DateTime? endDate,

    /// Filtros aplicados
    @Default({}) Map<String, dynamic> filters,

    /// Título customizado do relatório
    String? customTitle,

    /// Incluir gráficos (somente PDF)
    @Default(true) bool includeCharts,

    /// Incluir estatísticas detalhadas
    @Default(true) bool includeStats,

    /// Agrupar por categoria (finanças)
    @Default(false) bool groupByCategory,

    /// Agrupar por origem (tarefas)
    @Default(false) bool groupBySource,

    /// Agrupar por prioridade (tarefas)
    @Default(false) bool groupByPriority,

    /// Incluir tarefas concluídas
    @Default(true) bool includeCompleted,

    /// Incluir tarefas pendentes
    @Default(true) bool includePending,

    /// Incluir receitas
    @Default(true) bool includeIncome,

    /// Incluir despesas
    @Default(true) bool includeExpenses,

    /// Categorias selecionadas (vazio = todas)
    @Default([]) List<String> selectedCategories,

    /// Origens selecionadas (vazio = todas)
    @Default([]) List<String> selectedSources,

    /// Prioridades selecionadas (vazio = todas)
    @Default([]) List<String> selectedPriorities,

    /// Empresas selecionadas (vazio = todas)
    @Default([]) List<String> selectedCompanies,
  }) = _ReportConfig;

  factory ReportConfig.fromJson(Map<String, dynamic> json) =>
      _$ReportConfigFromJson(json);
}

/// Extensões úteis para ReportConfig
extension ReportConfigX on ReportConfig {
  /// Obtém o título do relatório
  String getTitle() {
    if (customTitle != null && customTitle!.isNotEmpty) {
      return customTitle!;
    }

    switch (type) {
      case ReportType.tasks:
        return 'Relatório de Tarefas';
      case ReportType.finance:
        return 'Relatório Financeiro';
      case ReportType.consolidated:
        return 'Relatório Consolidado';
    }
  }

  /// Obtém o label do período
  String getPeriodLabel() {
    switch (period) {
      case ReportPeriod.today:
        return 'Hoje';
      case ReportPeriod.yesterday:
        return 'Ontem';
      case ReportPeriod.thisWeek:
        return 'Esta Semana';
      case ReportPeriod.lastWeek:
        return 'Semana Passada';
      case ReportPeriod.thisMonth:
        return 'Este Mês';
      case ReportPeriod.lastMonth:
        return 'Mês Passado';
      case ReportPeriod.last7Days:
        return 'Últimos 7 Dias';
      case ReportPeriod.last30Days:
        return 'Últimos 30 Dias';
      case ReportPeriod.last90Days:
        return 'Últimos 90 Dias';
      case ReportPeriod.thisYear:
        return 'Este Ano';
      case ReportPeriod.custom:
        if (startDate != null && endDate != null) {
          final start = '${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}';
          final end = '${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}';
          return '$start - $end';
        }
        return 'Período Customizado';
    }
  }

  /// Obtém o label do formato
  String getFormatLabel() {
    switch (format) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.excel:
        return 'Excel';
    }
  }

  /// Obtém o ícone do tipo de relatório
  String getTypeIcon() {
    switch (type) {
      case ReportType.tasks:
        return '✓';
      case ReportType.finance:
        return '💰';
      case ReportType.consolidated:
        return '📊';
    }
  }

  /// Obtém o ícone do formato
  String getFormatIcon() {
    switch (format) {
      case ReportFormat.pdf:
        return '📄';
      case ReportFormat.excel:
        return '📊';
    }
  }

  /// Calcula as datas de início e fim baseado no período
  DateRange getDateRange() {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case ReportPeriod.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case ReportPeriod.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;

      case ReportPeriod.thisWeek:
        final weekday = now.weekday;
        start = now.subtract(Duration(days: weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = now;
        break;

      case ReportPeriod.lastWeek:
        final weekday = now.weekday;
        end = now.subtract(Duration(days: weekday));
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
        start = end.subtract(const Duration(days: 6));
        start = DateTime(start.year, start.month, start.day);
        break;

      case ReportPeriod.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = now;
        break;

      case ReportPeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        start = lastMonth;
        end = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
        break;

      case ReportPeriod.last7Days:
        end = now;
        start = now.subtract(const Duration(days: 7));
        start = DateTime(start.year, start.month, start.day);
        break;

      case ReportPeriod.last30Days:
        end = now;
        start = now.subtract(const Duration(days: 30));
        start = DateTime(start.year, start.month, start.day);
        break;

      case ReportPeriod.last90Days:
        end = now;
        start = now.subtract(const Duration(days: 90));
        start = DateTime(start.year, start.month, start.day);
        break;

      case ReportPeriod.thisYear:
        start = DateTime(now.year, 1, 1);
        end = now;
        break;

      case ReportPeriod.custom:
        if (startDate != null && endDate != null) {
          return DateRange(start: startDate!, end: endDate!);
        }
        // Fallback para este mês
        start = DateTime(now.year, now.month, 1);
        end = now;
        break;
    }

    return DateRange(start: start, end: end);
  }

  /// Valida se a configuração é válida
  bool isValid() {
    // Verifica período customizado
    if (period == ReportPeriod.custom) {
      if (startDate == null || endDate == null) {
        return false;
      }
      if (startDate!.isAfter(endDate!)) {
        return false;
      }
    }

    // Verifica se pelo menos um status está selecionado (tarefas)
    if (type == ReportType.tasks || type == ReportType.consolidated) {
      if (!includeCompleted && !includePending) {
        return false;
      }
    }

    // Verifica se pelo menos um tipo está selecionado (finanças)
    if (type == ReportType.finance || type == ReportType.consolidated) {
      if (!includeIncome && !includeExpenses) {
        return false;
      }
    }

    return true;
  }

  /// Obtém resumo da configuração
  Map<String, String> getSummary() {
    final summary = <String, String>{};

    summary['Tipo'] = getTitle();
    summary['Formato'] = getFormatLabel();
    summary['Período'] = getPeriodLabel();

    if (type == ReportType.tasks || type == ReportType.consolidated) {
      final statuses = <String>[];
      if (includeCompleted) statuses.add('Concluídas');
      if (includePending) statuses.add('Pendentes');
      summary['Status'] = statuses.join(', ');

      if (selectedPriorities.isNotEmpty) {
        summary['Prioridades'] = selectedPriorities.map((p) {
          switch (p) {
            case 'high':
              return 'Alta';
            case 'medium':
              return 'Média';
            case 'low':
              return 'Baixa';
            default:
              return p;
          }
        }).join(', ');
      }

      if (selectedSources.isNotEmpty) {
        summary['Origens'] = selectedSources.map((s) {
          switch (s) {
            case 'personal':
              return 'Pessoal';
            case 'company':
              return 'Empresa';
            case 'recurring':
              return 'Recorrente';
            default:
              return s;
          }
        }).join(', ');
      }
    }

    if (type == ReportType.finance || type == ReportType.consolidated) {
      final types = <String>[];
      if (includeIncome) types.add('Receitas');
      if (includeExpenses) types.add('Despesas');
      summary['Tipos'] = types.join(', ');

      if (selectedCategories.isNotEmpty) {
        summary['Categorias'] = selectedCategories.join(', ');
      }
    }

    return summary;
  }
}

/// Range de datas
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// Duração em dias
  int get durationInDays {
    return end.difference(start).inDays + 1;
  }

  /// Formata o range
  String format() {
    final startStr = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final endStr = '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
    return '$startStr - $endStr';
  }

  @override
  String toString() => format();
}
