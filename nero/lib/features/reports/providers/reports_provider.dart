import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/excel_service.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../finances/providers/transactions_provider.dart';
import '../domain/models/report_config.dart';

/// Provider para configuração do relatório
final reportConfigProvider =
    StateNotifierProvider<ReportConfigNotifier, ReportConfig>((ref) {
  return ReportConfigNotifier();
});

/// Notifier para gerenciar a configuração do relatório
class ReportConfigNotifier extends StateNotifier<ReportConfig> {
  ReportConfigNotifier()
      : super(const ReportConfig(
          type: ReportType.tasks,
          format: ReportFormat.pdf,
          period: ReportPeriod.thisMonth,
        ));

  /// Atualiza o tipo de relatório
  void setType(ReportType type) {
    state = state.copyWith(type: type);
  }

  /// Atualiza o formato
  void setFormat(ReportFormat format) {
    state = state.copyWith(format: format);
  }

  /// Atualiza o período
  void setPeriod(ReportPeriod period) {
    state = state.copyWith(period: period);
  }

  /// Atualiza data de início
  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date, period: ReportPeriod.custom);
  }

  /// Atualiza data de fim
  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date, period: ReportPeriod.custom);
  }

  /// Atualiza título customizado
  void setCustomTitle(String? title) {
    state = state.copyWith(customTitle: title);
  }

  /// Atualiza incluir gráficos
  void setIncludeCharts(bool value) {
    state = state.copyWith(includeCharts: value);
  }

  /// Atualiza incluir estatísticas
  void setIncludeStats(bool value) {
    state = state.copyWith(includeStats: value);
  }

  /// Atualiza agrupar por categoria
  void setGroupByCategory(bool value) {
    state = state.copyWith(groupByCategory: value);
  }

  /// Atualiza agrupar por origem
  void setGroupBySource(bool value) {
    state = state.copyWith(groupBySource: value);
  }

  /// Atualiza agrupar por prioridade
  void setGroupByPriority(bool value) {
    state = state.copyWith(groupByPriority: value);
  }

  /// Atualiza incluir concluídas
  void setIncludeCompleted(bool value) {
    state = state.copyWith(includeCompleted: value);
  }

  /// Atualiza incluir pendentes
  void setIncludePending(bool value) {
    state = state.copyWith(includePending: value);
  }

  /// Atualiza incluir receitas
  void setIncludeIncome(bool value) {
    state = state.copyWith(includeIncome: value);
  }

  /// Atualiza incluir despesas
  void setIncludeExpenses(bool value) {
    state = state.copyWith(includeExpenses: value);
  }

  /// Atualiza categorias selecionadas
  void setSelectedCategories(List<String> categories) {
    state = state.copyWith(selectedCategories: categories);
  }

  /// Atualiza origens selecionadas
  void setSelectedSources(List<String> sources) {
    state = state.copyWith(selectedSources: sources);
  }

  /// Atualiza prioridades selecionadas
  void setSelectedPriorities(List<String> priorities) {
    state = state.copyWith(selectedPriorities: priorities);
  }

  /// Atualiza empresas selecionadas
  void setSelectedCompanies(List<String> companies) {
    state = state.copyWith(selectedCompanies: companies);
  }

  /// Atualiza filtros
  void setFilters(Map<String, dynamic> filters) {
    state = state.copyWith(filters: filters);
  }

  /// Reseta para configuração padrão
  void reset() {
    state = const ReportConfig(
      type: ReportType.tasks,
      format: ReportFormat.pdf,
      period: ReportPeriod.thisMonth,
    );
  }

  /// Aplica preset de configuração rápida
  void applyPreset(ReportPreset preset) {
    switch (preset) {
      case ReportPreset.weeklyTasks:
        state = const ReportConfig(
          type: ReportType.tasks,
          format: ReportFormat.pdf,
          period: ReportPeriod.thisWeek,
          includeCharts: true,
          includeStats: true,
        );
        break;

      case ReportPreset.monthlyFinance:
        state = const ReportConfig(
          type: ReportType.finance,
          format: ReportFormat.excel,
          period: ReportPeriod.thisMonth,
          groupByCategory: true,
          includeStats: true,
        );
        break;

      case ReportPreset.yearlyConsolidated:
        state = const ReportConfig(
          type: ReportType.consolidated,
          format: ReportFormat.pdf,
          period: ReportPeriod.thisYear,
          includeCharts: true,
          includeStats: true,
          groupByCategory: true,
          groupBySource: true,
        );
        break;
    }
  }
}

/// Presets de configuração rápida
enum ReportPreset {
  weeklyTasks,        // Tarefas da semana
  monthlyFinance,     // Finanças do mês
  yearlyConsolidated, // Consolidado do ano
}

/// Provider para estado de geração de relatório
final reportGenerationProvider =
    StateNotifierProvider<ReportGenerationNotifier, ReportGenerationState>((ref) {
  return ReportGenerationNotifier(ref);
});

/// Estado de geração de relatório
class ReportGenerationState {
  final bool isGenerating;
  final double progress;
  final String? errorMessage;
  final File? generatedFile;

  const ReportGenerationState({
    this.isGenerating = false,
    this.progress = 0.0,
    this.errorMessage,
    this.generatedFile,
  });

  ReportGenerationState copyWith({
    bool? isGenerating,
    double? progress,
    String? errorMessage,
    File? generatedFile,
  }) {
    return ReportGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      generatedFile: generatedFile,
    );
  }
}

/// Notifier para geração de relatórios
class ReportGenerationNotifier extends StateNotifier<ReportGenerationState> {
  final Ref _ref;

  ReportGenerationNotifier(this._ref) : super(const ReportGenerationState());

  /// Gera relatório baseado na configuração
  Future<File?> generateReport() async {
    try {
      state = state.copyWith(isGenerating: true, progress: 0.0, errorMessage: null);

      final config = _ref.read(reportConfigProvider);

      // Validar configuração
      if (!config.isValid()) {
        state = state.copyWith(
          isGenerating: false,
          errorMessage: 'Configuração inválida',
        );
        return null;
      }

      // Obter range de datas
      final dateRange = config.getDateRange();

      File? file;

      // Gerar relatório baseado no tipo
      switch (config.type) {
        case ReportType.tasks:
          file = await _generateTasksReport(config, dateRange);
          break;

        case ReportType.finance:
          file = await _generateFinanceReport(config, dateRange);
          break;

        case ReportType.consolidated:
          file = await _generateConsolidatedReport(config, dateRange);
          break;
      }

      state = state.copyWith(
        isGenerating: false,
        progress: 1.0,
        generatedFile: file,
      );

      return file;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: 'Erro ao gerar relatório: $e',
      );
      return null;
    }
  }

  /// Gera relatório de tarefas
  Future<File?> _generateTasksReport(ReportConfig config, DateRange dateRange) async {
    state = state.copyWith(progress: 0.2);

    // Obter tarefas
    final allTasks = _ref.read(tasksProvider);

    // Filtrar por período
    var tasks = allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(dateRange.start) &&
          task.dueDate!.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    state = state.copyWith(progress: 0.4);

    // Filtrar por status
    if (!config.includeCompleted) {
      tasks = tasks.where((t) => !t.isCompleted).toList();
    }
    if (!config.includePending) {
      tasks = tasks.where((t) => t.isCompleted).toList();
    }

    // Filtrar por origem
    if (config.selectedSources.isNotEmpty) {
      tasks = tasks.where((t) => config.selectedSources.contains(t.origin)).toList();
    }

    // Filtrar por prioridade
    if (config.selectedPriorities.isNotEmpty) {
      tasks = tasks.where((t) => config.selectedPriorities.contains(t.priority ?? '')).toList();
    }

    state = state.copyWith(progress: 0.6);

    // Gerar relatório
    final title = config.getTitle();
    final period = config.getPeriodLabel();

    if (config.format == ReportFormat.pdf) {
      state = state.copyWith(progress: 0.8);
      return await PDFService.generateTasksReport(
        tasks: tasks,
        title: title,
        period: period,
        filters: config.getSummary(),
      );
    } else {
      state = state.copyWith(progress: 0.8);
      return await ExcelService.generateTasksReport(
        tasks: tasks,
        period: period,
        filters: config.getSummary(),
      );
    }
  }

  /// Gera relatório financeiro
  Future<File?> _generateFinanceReport(ReportConfig config, DateRange dateRange) async {
    state = state.copyWith(progress: 0.2);

    // Obter transações
    final allTransactions = _ref.read(transactionsProvider);

    // Filtrar por período
    var transactions = allTransactions.where((transaction) {
      if (transaction.date == null) return false;
      return transaction.date!.isAfter(dateRange.start) &&
          transaction.date!.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    state = state.copyWith(progress: 0.4);

    // Filtrar por tipo
    if (!config.includeIncome) {
      transactions = transactions.where((t) => t.type != 'income').toList();
    }
    if (!config.includeExpenses) {
      transactions = transactions.where((t) => t.type != 'expense').toList();
    }

    // Filtrar por categoria
    if (config.selectedCategories.isNotEmpty) {
      transactions = transactions.where((t) => config.selectedCategories.contains(t.category)).toList();
    }

    state = state.copyWith(progress: 0.6);

    // Calcular totais
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpenses;

    // Converter transações para Map para o PDF
    final transactionsMap = transactions.map((t) => {
      'date': t.date,
      'description': t.description,
      'category': t.category,
      'amount': t.amount,
      'type': t.type,
    }).toList();

    // Gerar relatório
    final period = config.getPeriodLabel();

    if (config.format == ReportFormat.pdf) {
      state = state.copyWith(progress: 0.8);
      return await PDFService.generateFinanceReport(
        transactions: transactionsMap,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
        title: config.getTitle(),
        period: period,
        filters: config.getSummary(),
      );
    } else {
      state = state.copyWith(progress: 0.8);
      return await ExcelService.generateFinanceReport(
        transactions: transactions,
        period: period,
        filters: config.getSummary(),
      );
    }
  }

  /// Gera relatório consolidado
  Future<File?> _generateConsolidatedReport(ReportConfig config, DateRange dateRange) async {
    state = state.copyWith(progress: 0.2);

    // Obter tarefas
    final allTasks = _ref.read(tasksProvider);
    var tasks = allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(dateRange.start) &&
          task.dueDate!.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    state = state.copyWith(progress: 0.4);

    // Obter transações
    final allTransactions = _ref.read(transactionsProvider);
    var transactions = allTransactions.where((transaction) {
      if (transaction.date == null) return false;
      return transaction.date!.isAfter(dateRange.start) &&
          transaction.date!.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    state = state.copyWith(progress: 0.6);

    // Aplicar filtros
    if (!config.includeCompleted) {
      tasks = tasks.where((t) => !t.isCompleted).toList();
    }
    if (!config.includePending) {
      tasks = tasks.where((t) => t.isCompleted).toList();
    }
    if (!config.includeIncome) {
      transactions = transactions.where((t) => t.type != 'income').toList();
    }
    if (!config.includeExpenses) {
      transactions = transactions.where((t) => t.type != 'expense').toList();
    }

    state = state.copyWith(progress: 0.7);

    // Calcular totais financeiros
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpenses;

    // Converter transações para Map para o PDF
    final transactionsMap = transactions.map((t) => {
      'date': t.date,
      'description': t.description,
      'category': t.category,
      'amount': t.amount,
      'type': t.type,
    }).toList();

    // Gerar relatório
    final period = config.getPeriodLabel();

    if (config.format == ReportFormat.pdf) {
      state = state.copyWith(progress: 0.9);
      return await PDFService.generateConsolidatedReport(
        tasks: tasks,
        transactions: transactionsMap,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
        title: config.getTitle(),
        period: period,
      );
    } else {
      state = state.copyWith(progress: 0.9);
      return await ExcelService.generateConsolidatedReport(
        tasks: tasks,
        transactions: transactions,
        period: period,
      );
    }
  }

  /// Limpa o estado
  void clear() {
    state = const ReportGenerationState();
  }
}
